# AIMAX Memory — Stop hook (Windows PowerShell)
# Al cerrar la sesión: si tuvo entidad (>=5 turnos), escribe un stub mínimo en
# _daily-summaries/<hoy>.md. NO invoca al subagente memory-curator desde aquí.

$ErrorActionPreference = 'SilentlyContinue'

$MemoryDir = Join-Path $env:USERPROFILE '.claude\memory'
$SummariesDir = Join-Path $MemoryDir '_daily-summaries'
$Catalog = Join-Path $MemoryDir '_catalog.json'
$MinTurns = 5

if (-not (Test-Path $MemoryDir)) { exit 0 }

$turns = 0
if (Test-Path $Catalog) {
    try {
        $cat = Get-Content -Path $Catalog -Raw | ConvertFrom-Json
        if ($cat.counters -and $cat.counters.lastSessionTurns) {
            $turns = [int]$cat.counters.lastSessionTurns
        }
    } catch { }
}

if ($turns -lt $MinTurns) { exit 0 }

if (-not (Test-Path $SummariesDir)) {
    New-Item -ItemType Directory -Path $SummariesDir -Force | Out-Null
}

$today = Get-Date -Format 'yyyy-MM-dd'
$now = Get-Date -Format 'HH:mm'
$summaryFile = Join-Path $SummariesDir "$today.md"

if (-not (Test-Path $summaryFile)) {
    $body = @"
---
date: $today
sessions: 1
---

# Resumen de $today

## Sesión $now

**Turnos:** $turns
**Estado:** stub (sin curar). Ejecuta ``/memory-status`` para detalles.
"@
    Set-Content -Path $summaryFile -Value $body -Encoding utf8
} else {
    $body = @"

## Sesión $now

**Turnos:** $turns
**Estado:** stub (sin curar). Ejecuta ``/memory-status`` para detalles.
"@
    Add-Content -Path $summaryFile -Value $body -Encoding utf8
}

exit 0
