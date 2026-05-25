#!/usr/bin/env bash
# AIMAX Memory — SessionStart hook
# Inyecta el índice de memoria, el perfil del operador y el último resumen diario.
# Tolerante a fallos: si algo falla, devuelve JSON vacío y la sesión arranca sin memoria.

set -u

MEMORY_DIR="${HOME}/.claude/memory"
INDEX_FILE="${MEMORY_DIR}/MEMORY.md"
OPERATOR_FILE="${MEMORY_DIR}/operator.md"
SUMMARIES_DIR="${MEMORY_DIR}/_daily-summaries"

# Si la zona de memoria no existe todavía (alumno acaba de instalar y aún no abrió Claude Code),
# salimos en silencio sin inyectar nada.
if [ ! -d "${MEMORY_DIR}" ]; then
  printf '{}\n'
  exit 0
fi

CONTEXT=""

# 1. Índice maestro
if [ -f "${INDEX_FILE}" ]; then
  INDEX_CONTENT="$(cat "${INDEX_FILE}" 2>/dev/null)"
  if [ -n "${INDEX_CONTENT}" ]; then
    CONTEXT="${CONTEXT}<aimax-memory-index>
${INDEX_CONTENT}
</aimax-memory-index>

"
  fi
fi

# 2. Perfil del operador
if [ -f "${OPERATOR_FILE}" ]; then
  OP_CONTENT="$(cat "${OPERATOR_FILE}" 2>/dev/null)"
  if [ -n "${OP_CONTENT}" ]; then
    CONTEXT="${CONTEXT}<aimax-memory-operator-profile>
${OP_CONTENT}
</aimax-memory-operator-profile>

"
  fi
fi

# 3. Último resumen diario (continuidad de sesión)
if [ -d "${SUMMARIES_DIR}" ]; then
  LATEST_SUMMARY="$(ls -1 "${SUMMARIES_DIR}" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | sort | tail -n 1)"
  if [ -n "${LATEST_SUMMARY}" ] && [ -f "${SUMMARIES_DIR}/${LATEST_SUMMARY}" ]; then
    SUM_CONTENT="$(cat "${SUMMARIES_DIR}/${LATEST_SUMMARY}" 2>/dev/null)"
    if [ -n "${SUM_CONTENT}" ]; then
      CONTEXT="${CONTEXT}<aimax-memory-last-session-summary file=\"${LATEST_SUMMARY}\">
${SUM_CONTENT}
</aimax-memory-last-session-summary>

"
    fi
  fi
fi

# 4. Resetear contador de turnos en _catalog.json para esta sesión
CATALOG="${MEMORY_DIR}/_catalog.json"
if [ -f "${CATALOG}" ]; then
  # Reset lastSessionTurns a 0 usando awk para evitar dependencia de jq
  TMP="${CATALOG}.tmp"
  awk '/"lastSessionTurns":/ { sub(/: *[0-9]+/, ": 0") } { print }' "${CATALOG}" > "${TMP}" 2>/dev/null && mv "${TMP}" "${CATALOG}" 2>/dev/null
fi

# Si no había nada que inyectar, devolvemos vacío
if [ -z "${CONTEXT}" ]; then
  printf '{}\n'
  exit 0
fi

# Escapado JSON básico: backslashes, comillas, saltos de línea.
# Usamos python si está disponible (más fiable); si no, fallback a sed.
if command -v python3 >/dev/null 2>&1; then
  ESCAPED=$(printf '%s' "${CONTEXT}" | python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))')
elif command -v python >/dev/null 2>&1; then
  ESCAPED=$(printf '%s' "${CONTEXT}" | python -c 'import sys, json; print(json.dumps(sys.stdin.read()))')
else
  # Fallback rudimentario (suficiente para la mayoría de contenido markdown)
  ESC=$(printf '%s' "${CONTEXT}" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g' -e 's/\r/\\r/g' -e 's/\t/\\t/g')
  ESCAPED="\"${ESC}\""
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "${ESCAPED}"
