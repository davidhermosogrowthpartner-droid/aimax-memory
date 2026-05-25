#!/usr/bin/env bash
# AIMAX Memory — instalador POSIX (Mac/Linux/WSL/Git Bash)
# Copia skills, commands, agents y hooks a ~/.claude/ y prepara la zona de memoria.
# Idempotente: no machaca datos del usuario.

set -e

CLAUDE_DIR="${HOME}/.claude"
CORTEX_DIR="${CLAUDE_DIR}/aimax-memory"
MEMORY_DIR="${CLAUDE_DIR}/memory"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "→ AIMAX Memory installer"
echo "  Repo:      ${SCRIPT_DIR}"
echo "  Destino:   ${CLAUDE_DIR}"
echo ""

# 1. Crear ~/.claude/ si no existe
if [ ! -d "${CLAUDE_DIR}" ]; then
  echo "→ Creando ${CLAUDE_DIR}"
  mkdir -p "${CLAUDE_DIR}"
fi

# 2. Copiar el repo a ~/.claude/aimax-memory/ (no symlinks: más portable, evita problemas en Windows)
echo "→ Copiando archivos de AIMAX Memory a ${CORTEX_DIR}"
mkdir -p "${CORTEX_DIR}"
for d in skills agents commands hooks .claude-plugin templates docs; do
  if [ -d "${SCRIPT_DIR}/${d}" ]; then
    rm -rf "${CORTEX_DIR}/${d}"
    cp -R "${SCRIPT_DIR}/${d}" "${CORTEX_DIR}/${d}"
  fi
done

# 3. Asegurar permisos de ejecución en hooks shell
if [ -d "${CORTEX_DIR}/hooks" ]; then
  chmod +x "${CORTEX_DIR}/hooks/"*.sh 2>/dev/null || true
fi

# 4. Enlazar skills/commands/agents al ~/.claude/ global para que Claude Code los descubra
echo "→ Enlazando skills, commands y agents a ${CLAUDE_DIR}"
mkdir -p "${CLAUDE_DIR}/skills" "${CLAUDE_DIR}/commands" "${CLAUDE_DIR}/agents"

link_or_copy() {
  local src="$1"
  local dst="$2"
  rm -rf "${dst}"
  if ln -s "${src}" "${dst}" 2>/dev/null; then
    return 0
  fi
  cp -R "${src}" "${dst}"
}

for skill_dir in "${CORTEX_DIR}/skills/"*/; do
  [ -d "${skill_dir}" ] || continue
  name="$(basename "${skill_dir}")"
  link_or_copy "${skill_dir%/}" "${CLAUDE_DIR}/skills/${name}"
done

for cmd_file in "${CORTEX_DIR}/commands/"*.md; do
  [ -f "${cmd_file}" ] || continue
  name="$(basename "${cmd_file}")"
  link_or_copy "${cmd_file}" "${CLAUDE_DIR}/commands/${name}"
done

for agent_file in "${CORTEX_DIR}/agents/"*.md; do
  [ -f "${agent_file}" ] || continue
  name="$(basename "${agent_file}")"
  link_or_copy "${agent_file}" "${CLAUDE_DIR}/agents/${name}"
done

# 5. Inicializar la zona de memoria del usuario (NO machaca lo existente)
echo "→ Inicializando ${MEMORY_DIR}"
mkdir -p "${MEMORY_DIR}"
for sub in user feedback project preference learning decision reference _daily-summaries _archived; do
  mkdir -p "${MEMORY_DIR}/${sub}"
done

# Copiar plantillas sólo si no existen ya
for tpl in MEMORY.md operator.md _catalog.json; do
  if [ ! -f "${MEMORY_DIR}/${tpl}" ] && [ -f "${CORTEX_DIR}/templates/${tpl}" ]; then
    cp "${CORTEX_DIR}/templates/${tpl}" "${MEMORY_DIR}/${tpl}"
  fi
done

# 6. Registrar los hooks en ~/.claude/settings.json
SETTINGS="${CLAUDE_DIR}/settings.json"
echo "→ Registrando hooks en ${SETTINGS}"

if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
  PY=$(command -v python3 || command -v python)
  "${PY}" - <<PYEOF "${SETTINGS}" "${CORTEX_DIR}"
import json, os, sys
path, aimax-memory_dir = sys.argv[1], sys.argv[2]
hooks_root = os.path.join(aimax-memory_dir, "hooks")

if os.path.exists(path):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
else:
    data = {}

hooks = data.setdefault("hooks", {})

def upsert(event, matcher, command, timeout):
    entries = hooks.setdefault(event, [])
    # Borrar entradas previas de aimax-memory (idempotencia)
    entries[:] = [e for e in entries if not any(
        h.get("command", "").endswith(("session-start.sh", "user-prompt-submit.sh", "stop.sh"))
        and "aimax-memory" in h.get("command", "").lower()
        for h in e.get("hooks", [])
    )]
    block = {"hooks": [{"type": "command", "command": command, "timeout": timeout}]}
    if matcher:
        block["matcher"] = matcher
    entries.append(block)

upsert("SessionStart", "startup|clear|compact", os.path.join(hooks_root, "session-start.sh"), 10)
upsert("UserPromptSubmit", None, os.path.join(hooks_root, "user-prompt-submit.sh"), 2)
upsert("Stop", None, os.path.join(hooks_root, "stop.sh"), 5)

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
print("  Hooks registrados.")
PYEOF
else
  echo "  ⚠ Python no disponible. Edita ${SETTINGS} manualmente — instrucciones en docs/guia-alumno.md"
fi

echo ""
echo "✓ AIMAX Memory instalado."
echo ""
echo "Siguientes pasos:"
echo "  1. Abre tu perfil:    ${MEMORY_DIR}/operator.md   y rellena lo básico (nombre, cómo trabajas)."
echo "  2. Reinicia Claude Code (o abre una sesión nueva)."
echo "  3. Prueba:            /recall hola    o cuéntale algo sobre ti y observa /memory-status."
