# AIMAX Memory — UserPromptSubmit hook (Windows PowerShell)
# Cuenta turnos. Si la sesión es sustancial y no se ha guardado memoria en muchos turnos,
# inyecta un nudge silencioso. Tolerante a fallos: si algo va mal, devuelve {} y sigue.

$ErrorActionPreference = 'SilentlyContinue'

$MemoryDir = Join-Path $env:USERPROFILE '.claude\memory'
$Catalog = Join-Path $MemoryDir '_catalog.json'
$NudgeThreshold = 15

if (-not (Test-Path $MemoryDir) -or -not (Test-Path $Catalog)) {
    '{}' | Write-Output
    exit 0
}

$shouldNudge = $false
try {
    $cat = Get-Content -Path $Catalog -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $cat.counters) {
        $cat | Add-Member -NotePropertyName counters -NotePropertyValue ([pscustomobject]@{ lastSessionTurns = 0 }) -Force
    }
    $turns = [int]$cat.counters.lastSessionTurns + 1
    $cat.counters.lastSessionTurns = $turns
    if ($turns -ge $NudgeThreshold -and ($turns % $NudgeThreshold) -eq 0) {
        $shouldNudge = $true
    }
    $json = $cat | ConvertTo-Json -Depth 8
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Catalog, $json, $utf8NoBom)
} catch {
    '{}' | Write-Output
    exit 0
}

if ($shouldNudge) {
    $msg = '<system-reminder>AIMAX Memory: la sesión lleva varios turnos. Si hubo alguna decisión, preferencia, dato del usuario o aprendizaje que merezca persistir, considera guardarlo según la skill memory antes de continuar. Si no hay nada que guardar, ignora este aviso.</system-reminder>'
    $payload = @{
        hookSpecificOutput = @{
            hookEventName = 'UserPromptSubmit'
            additionalContext = $msg
        }
    }
    $payload | ConvertTo-Json -Depth 8 -Compress | Write-Output
} else {
    '{}' | Write-Output
}
