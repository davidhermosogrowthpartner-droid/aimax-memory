#!/usr/bin/env bash
# AIMAX Memory — UserPromptSubmit hook
# Cuenta turnos. Si la sesión es sustancial y no se ha guardado memoria en muchos turnos,
# inyecta un nudge silencioso. Tolerante a fallos: si algo va mal, devuelve {} y sigue.

set -u

MEMORY_DIR="${HOME}/.claude/memory"
CATALOG="${MEMORY_DIR}/_catalog.json"
NUDGE_THRESHOLD=15  # turnos sin guardar antes de soltar el nudge

if [ ! -d "${MEMORY_DIR}" ] || [ ! -f "${CATALOG}" ]; then
  printf '{}\n'
  exit 0
fi

# Leer y actualizar el contador. Usamos python si está disponible.
NUDGE="no"
if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
  PY=$(command -v python3 || command -v python)
  RESULT=$("${PY}" - <<PYEOF "${CATALOG}" "${NUDGE_THRESHOLD}"
import json, sys
path, threshold = sys.argv[1], int(sys.argv[2])
try:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    c = data.setdefault('counters', {})
    c['lastSessionTurns'] = int(c.get('lastSessionTurns', 0)) + 1
    nudge = "yes" if c['lastSessionTurns'] >= threshold and c['lastSessionTurns'] % threshold == 0 else "no"
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
    print(nudge)
except Exception:
    print("no")
PYEOF
)
  NUDGE="${RESULT}"
fi

if [ "${NUDGE}" = "yes" ]; then
  MSG="<system-reminder>AIMAX Memory: la sesión lleva varios turnos. Si hubo alguna decisión, preferencia, dato del usuario o aprendizaje que merezca persistir, considera guardarlo según la skill memory antes de continuar. Si no hay nada que guardar, ignora este aviso.</system-reminder>"
  # Escapado JSON
  if command -v python3 >/dev/null 2>&1; then
    ESC=$(printf '%s' "${MSG}" | python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))')
  elif command -v python >/dev/null 2>&1; then
    ESC=$(printf '%s' "${MSG}" | python -c 'import sys, json; print(json.dumps(sys.stdin.read()))')
  else
    ESC="\"${MSG}\""
  fi
  printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":%s}}\n' "${ESC}"
else
  printf '{}\n'
fi
