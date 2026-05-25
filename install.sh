#!/usr/bin/env bash
# AIMAX Memory — instalador POSIX (Mac/Linux/WSL/Git Bash)
# Copia skills, commands, agents y hooks a ~/.claude/ y prepara la zona de memoria.
# Idempotente: no machaca datos del usuario.

set -e

CLAUDE_DIR="${HOME}/.claude"
AIMAX_DIR="${CLAUDE_DIR}/aimax-memory"
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
echo "→ Copiando archivos de AIMAX Memory a ${AIMAX_DIR}"
mkdir -p "${AIMAX_DIR}"
for d in skills agents commands hooks .claude-plugin templates docs; do
  if [ -d "${SCRIPT_DIR}/${d}" ]; then
    rm -rf "${AIMAX_DIR}/${d}"
    cp -R "${SCRIPT_DIR}/${d}" "${AIMAX_DIR}/${d}"
  fi
done

# 3. Asegurar permisos de ejecución en hooks shell
if [ -d "${AIMAX_DIR}/hooks" ]; then
  chmod +x "${AIMAX_DIR}/hooks/"*.sh 2>/dev/null || true
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

for skill_dir in "${AIMAX_DIR}/skills/"*/; do
  [ -d "${skill_dir}" ] || continue
  name="$(basename "${skill_dir}")"
  link_or_copy "${skill_dir%/}" "${CLAUDE_DIR}/skills/${name}"
done

for cmd_file in "${AIMAX_DIR}/commands/"*.md; do
  [ -f "${cmd_file}" ] || continue
  name="$(basename "${cmd_file}")"
  link_or_copy "${cmd_file}" "${CLAUDE_DIR}/commands/${name}"
done

for agent_file in "${AIMAX_DIR}/agents/"*.md; do
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
  if [ ! -f "${MEMORY_DIR}/${tpl}" ] && [ -f "${AIMAX_DIR}/templates/${tpl}" ]; then
    cp "${AIMAX_DIR}/templates/${tpl}" "${MEMORY_DIR}/${tpl}"
  fi
done

# 6. Registrar los hooks en ~/.claude/settings.json
SETTINGS="${CLAUDE_DIR}/settings.json"
echo "→ Registrando hooks en ${SETTINGS}"

if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
  PY=$(command -v python3 || command -v python)
  "${PY}" - <<PYEOF "${SETTINGS}" "${AIMAX_DIR}"
import json, os, re, sys

def winpath(p):
    """Convierte /c/foo/bar (Git Bash) a C:/foo/bar (Windows-compatible)."""
    if sys.platform.startswith("win") and re.match(r"^/[a-zA-Z]/", p):
        return p[1].upper() + ":" + p[2:]
    return p

path = winpath(sys.argv[1])
aimax_dir = winpath(sys.argv[2])
hooks_root = os.path.join(aimax_dir, "hooks")

if os.path.exists(path):
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
else:
    data = {}

hooks = data.setdefault("hooks", {})

def upsert(event, matcher, command, timeout):
    entries = hooks.setdefault(event, [])
    # Filtrar SOLO los sub-hooks de aimax-memory de cada bloque, conservando intactos
    # los hooks de otras herramientas (Sinapsis, sonidos, etc.) que vivan en el mismo bloque.
    # Si tras filtrar un bloque se queda sin sub-hooks, se descarta entero.
    new_entries = []
    for entry in entries:
        sub_hooks = entry.get("hooks") or []
        kept = [h for h in sub_hooks if "aimax-memory" not in (h.get("command", "") or "").lower()]
        if kept:
            new_entry = dict(entry)
            new_entry["hooks"] = kept
            new_entries.append(new_entry)
    entries[:] = new_entries

    block = {"hooks": [{"type": "command", "command": command, "timeout": timeout}]}
    if matcher:
        block["matcher"] = matcher
    entries.append(block)

# En Windows, prefijamos 'bash' como hace Sinapsis: los .sh no se ejecutan directamente.
# Usamos rutas con ~ para portabilidad (bash las expande).
HOOK_PREFIX = "bash " if sys.platform.startswith("win") else ""
SHORT_HOOKS = "~/.claude/aimax-memory/hooks"

upsert("SessionStart", "startup|clear|compact", f"{HOOK_PREFIX}{SHORT_HOOKS}/session-start.sh", 10)
upsert("UserPromptSubmit", None, f"{HOOK_PREFIX}{SHORT_HOOKS}/user-prompt-submit.sh", 2)
upsert("Stop", None, f"{HOOK_PREFIX}{SHORT_HOOKS}/stop.sh", 5)

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
