# AIMAX Memory — SessionStart hook (Windows PowerShell)
# Inyecta el índice de memoria, el perfil del operador y el último resumen diario.
# Tolerante a fallos: si algo falla, devuelve JSON vacío y la sesión arranca sin memoria.

$ErrorActionPreference = 'SilentlyContinue'

$MemoryDir = Join-Path $env:USERPROFILE '.claude\memory'
$IndexFile = Join-Path $MemoryDir 'MEMORY.md'
$OperatorFile = Join-Path $MemoryDir 'operator.md'
$SummariesDir = Join-Path $MemoryDir '_daily-summaries'

if (-not (Test-Path $MemoryDir)) {
    '{}' | Write-Output
    exit 0
}

$parts = @()

# 1. Índice maestro
if (Test-Path $IndexFile) {
    $indexContent = Get-Content -Path $IndexFile -Raw -ErrorAction SilentlyContinue
    if ($indexContent) {
        $parts += "<aimax-memory-index>`n$indexContent`n</aimax-memory-index>`n"
    }
}

# 2. Perfil del operador
if (Test-Path $OperatorFile) {
    $opContent = Get-Content -Path $OperatorFile -Raw -ErrorAction SilentlyContinue
    if ($opContent) {
        $parts += "<aimax-memory-operator-profile>`n$opContent`n</aimax-memory-operator-profile>`n"
    }
}

# 3. Último resumen diario
if (Test-Path $SummariesDir) {
    $latest = Get-ChildItem -Path $SummariesDir -Filter '*.md' -ErrorAction SilentlyContinue |
              Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}\.md$' } |
              Sort-Object Name |
              Select-Object -Last 1
    if ($latest) {
        $sumContent = Get-Content -Path $latest.FullName -Raw -ErrorAction SilentlyContinue
        if ($sumContent) {
            $parts += "<aimax-memory-last-session-summary file=`"$($latest.Name)`">`n$sumContent`n</aimax-memory-last-session-summary>`n"
        }
    }
}

# 4. Reset lastSessionTurns en _catalog.json
$Catalog = Join-Path $MemoryDir '_catalog.json'
if (Test-Path $Catalog) {
    try {
        $cat = Get-Content -Path $Catalog -Raw | ConvertFrom-Json
        if ($cat.counters) {
            $cat.counters.lastSessionTurns = 0
            $json = $cat | ConvertTo-Json -Depth 8
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($Catalog, $json, $utf8NoBom)
        }
    } catch { }
}

if ($parts.Count -eq 0) {
    '{}' | Write-Output
    exit 0
}

$context = ($parts -join "`n")
$payload = @{
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = $context
    }
}
$payload | ConvertTo-Json -Depth 8 -Compress | Write-Output
