# AIMAX Memory — instalador Windows PowerShell
# Copia skills, commands, agents y hooks a ~/.claude/ y prepara la zona de memoria.
# Registra los hooks .ps1 (variante Windows) en settings.json.
# Idempotente: no machaca datos del usuario.

$ErrorActionPreference = 'Stop'

$ClaudeDir = Join-Path $env:USERPROFILE '.claude'
$AimaxDir = Join-Path $ClaudeDir 'aimax-memory'
$MemoryDir = Join-Path $ClaudeDir 'memory'
$ScriptDir = $PSScriptRoot

Write-Host "-> AIMAX Memory installer (Windows)"
Write-Host "   Repo:     $ScriptDir"
Write-Host "   Destino:  $ClaudeDir"
Write-Host ""

if (-not (Test-Path $ClaudeDir)) {
    Write-Host "-> Creando $ClaudeDir"
    New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
}

# 1. Copiar el repo a ~/.claude/aimax-memory/
Write-Host "-> Copiando archivos de AIMAX Memory a $AimaxDir"
if (-not (Test-Path $AimaxDir)) {
    New-Item -ItemType Directory -Path $AimaxDir -Force | Out-Null
}
foreach ($d in @('skills', 'agents', 'commands', 'hooks', '.claude-plugin', 'templates', 'docs')) {
    $src = Join-Path $ScriptDir $d
    if (Test-Path $src) {
        $dst = Join-Path $AimaxDir $d
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        Copy-Item -Recurse -Path $src -Destination $dst
    }
}

# 2. Enlazar skills/commands/agents al ~/.claude/ global
Write-Host "-> Enlazando skills, commands y agents a $ClaudeDir"
foreach ($d in @('skills', 'commands', 'agents')) {
    $dir = Join-Path $ClaudeDir $d
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

function Link-OrCopy {
    param([string]$Src, [string]$Dst)
    if (Test-Path $Dst) { Remove-Item -Recurse -Force $Dst }
    try {
        New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -ErrorAction Stop | Out-Null
    } catch {
        # Sin permisos para symlink (Windows requiere admin o developer mode) -> copia
        if ((Get-Item $Src).PSIsContainer) {
            Copy-Item -Recurse -Path $Src -Destination $Dst
        } else {
            Copy-Item -Path $Src -Destination $Dst
        }
    }
}

Get-ChildItem -Path (Join-Path $AimaxDir 'skills') -Directory | ForEach-Object {
    Link-OrCopy -Src $_.FullName -Dst (Join-Path $ClaudeDir "skills\$($_.Name)")
}
Get-ChildItem -Path (Join-Path $AimaxDir 'commands') -Filter '*.md' | ForEach-Object {
    Link-OrCopy -Src $_.FullName -Dst (Join-Path $ClaudeDir "commands\$($_.Name)")
}
Get-ChildItem -Path (Join-Path $AimaxDir 'agents') -Filter '*.md' | ForEach-Object {
    Link-OrCopy -Src $_.FullName -Dst (Join-Path $ClaudeDir "agents\$($_.Name)")
}

# 3. Inicializar zona de memoria
Write-Host "-> Inicializando $MemoryDir"
if (-not (Test-Path $MemoryDir)) { New-Item -ItemType Directory -Path $MemoryDir -Force | Out-Null }
foreach ($sub in @('user', 'feedback', 'project', 'preference', 'learning', 'decision', 'reference', '_daily-summaries', '_archived')) {
    $p = Join-Path $MemoryDir $sub
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

# Plantillas sólo si no existen
foreach ($tpl in @('MEMORY.md', 'operator.md', '_catalog.json')) {
    $dst = Join-Path $MemoryDir $tpl
    $src = Join-Path $AimaxDir "templates\$tpl"
    if (-not (Test-Path $dst) -and (Test-Path $src)) {
        Copy-Item -Path $src -Destination $dst
    }
}

# 4. Registrar hooks .ps1 en settings.json
$Settings = Join-Path $ClaudeDir 'settings.json'
Write-Host "-> Registrando hooks en $Settings"

# Conversión PSCustomObject → Hashtable recursiva (compatible PS 5.1, donde -AsHashtable no existe).
function ConvertTo-HashtableDeep {
    param($InputObject)
    if ($null -eq $InputObject) { return $null }
    if ($InputObject -is [string] -or $InputObject.GetType().IsPrimitive) { return $InputObject }
    if ($InputObject -is [System.Collections.IDictionary]) {
        $h = @{}
        foreach ($k in $InputObject.Keys) { $h[$k] = ConvertTo-HashtableDeep -InputObject $InputObject[$k] }
        return $h
    }
    if ($InputObject -is [System.Management.Automation.PSCustomObject]) {
        $h = @{}
        foreach ($p in $InputObject.PSObject.Properties) { $h[$p.Name] = ConvertTo-HashtableDeep -InputObject $p.Value }
        return $h
    }
    if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
        $list = New-Object System.Collections.ArrayList
        foreach ($item in $InputObject) { [void]$list.Add((ConvertTo-HashtableDeep -InputObject $item)) }
        return ,$list.ToArray()
    }
    return $InputObject
}

# Escritura UTF-8 SIN BOM (PS 5.1 mete BOM con Set-Content -Encoding utf8).
function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

if (Test-Path $Settings) {
    $raw = Get-Content -Path $Settings -Raw
    if ($raw -and $raw.Trim()) {
        $parsed = $raw | ConvertFrom-Json
        $data = ConvertTo-HashtableDeep -InputObject $parsed
    } else {
        $data = @{}
    }
} else {
    $data = @{}
}

if (-not $data.ContainsKey('hooks')) { $data['hooks'] = @{} }
$hooks = $data['hooks']

function Upsert-Hook {
    param([string]$Event, [string]$Matcher, [string]$Command, [int]$Timeout)

    if (-not $hooks.ContainsKey($Event)) { $hooks[$Event] = @() }

    # Filtrar SOLO los sub-hooks de aimax-memory de cada bloque, conservando intactos
    # los hooks de otras herramientas (Sinapsis, sonidos, etc.) que vivan en el mismo bloque.
    # Si tras filtrar un bloque se queda sin sub-hooks, se descarta entero.
    $filtered = New-Object System.Collections.ArrayList
    foreach ($entry in $hooks[$Event]) {
        if (-not $entry) { continue }
        $subKept = New-Object System.Collections.ArrayList
        if ($entry.ContainsKey('hooks') -and $entry['hooks']) {
            foreach ($h in $entry['hooks']) {
                $cmd = if ($h -and $h.ContainsKey('command')) { [string]$h['command'] } else { '' }
                if (-not ($cmd -match 'aimax-memory')) { [void]$subKept.Add($h) }
            }
        }
        if ($subKept.Count -gt 0) {
            $newEntry = @{}
            foreach ($k in $entry.Keys) { $newEntry[$k] = $entry[$k] }
            $newEntry['hooks'] = $subKept.ToArray()
            [void]$filtered.Add($newEntry)
        }
    }

    $block = @{ hooks = @(@{ type = 'command'; command = $Command; timeout = $Timeout }) }
    if ($Matcher) { $block['matcher'] = $Matcher }
    [void]$filtered.Add($block)
    $hooks[$Event] = $filtered.ToArray()
}

$hooksRoot = Join-Path $AimaxDir 'hooks'
Upsert-Hook 'SessionStart' 'startup|clear|compact' "powershell -ExecutionPolicy Bypass -File `"$(Join-Path $hooksRoot 'session-start.ps1')`"" 10
Upsert-Hook 'UserPromptSubmit' '' "powershell -ExecutionPolicy Bypass -File `"$(Join-Path $hooksRoot 'user-prompt-submit.ps1')`"" 2
Upsert-Hook 'Stop' '' "powershell -ExecutionPolicy Bypass -File `"$(Join-Path $hooksRoot 'stop.ps1')`"" 5

$json = $data | ConvertTo-Json -Depth 12
Write-Utf8NoBom -Path $Settings -Content $json
Write-Host "   Hooks registrados."

Write-Host ""
Write-Host "[OK] AIMAX Memory instalado."
Write-Host ""
Write-Host "Siguientes pasos:"
Write-Host "  1. Abre tu perfil:    $MemoryDir\operator.md   y rellena lo basico (nombre, como trabajas)."
Write-Host "  2. Reinicia Claude Code (o abre una sesion nueva)."
Write-Host "  3. Prueba:            /recall hola    o cuentale algo sobre ti y observa /memory-status."
