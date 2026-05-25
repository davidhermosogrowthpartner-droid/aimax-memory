#!/usr/bin/env bash
# AIMAX Memory — Stop hook
# Al cerrar la sesión: si tuvo entidad (>=5 turnos), escribe un stub mínimo en
# _daily-summaries/<hoy>.md. NO invoca al subagente memory-curator desde aquí
# (los hooks deben ser rápidos y no bloqueantes). El curator se invoca con
# /memory-status cuando el usuario quiera curar.

set -u

MEMORY_DIR="${HOME}/.claude/memory"
SUMMARIES_DIR="${MEMORY_DIR}/_daily-summaries"
CATALOG="${MEMORY_DIR}/_catalog.json"
MIN_TURNS=5

if [ ! -d "${MEMORY_DIR}" ]; then
  exit 0
fi

# Leer contador de turnos
TURNS=0
if [ -f "${CATALOG}" ] && command -v python3 >/dev/null 2>&1; then
  TURNS=$(python3 -c "import json; print(json.load(open('${CATALOG}')).get('counters', {}).get('lastSessionTurns', 0))" 2>/dev/null || echo 0)
elif [ -f "${CATALOG}" ] && command -v python >/dev/null 2>&1; then
  TURNS=$(python -c "import json; print(json.load(open('${CATALOG}')).get('counters', {}).get('lastSessionTurns', 0))" 2>/dev/null || echo 0)
fi

if [ "${TURNS}" -lt "${MIN_TURNS}" ] 2>/dev/null; then
  exit 0
fi

mkdir -p "${SUMMARIES_DIR}" 2>/dev/null

TODAY="$(date +%Y-%m-%d)"
NOW="$(date +%H:%M)"
SUMMARY_FILE="${SUMMARIES_DIR}/${TODAY}.md"

if [ ! -f "${SUMMARY_FILE}" ]; then
  cat > "${SUMMARY_FILE}" <<EOF
---
date: ${TODAY}
sessions: 1
---

# Resumen de ${TODAY}

## Sesión ${NOW}

**Turnos:** ${TURNS}
**Estado:** stub (sin curar). Ejecuta \`/memory-status\` para detalles.
EOF
else
  cat >> "${SUMMARY_FILE}" <<EOF

## Sesión ${NOW}

**Turnos:** ${TURNS}
**Estado:** stub (sin curar). Ejecuta \`/memory-status\` para detalles.
EOF
fi

exit 0
