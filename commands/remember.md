---
description: Guarda algo en la memoria persistente. Uso, /remember <texto a recordar>
argument-hint: <texto a recordar>
---

# /remember

El usuario quiere guardar `$ARGUMENTS` en la memoria persistente. Aplica la skill `memory`:

1. Decide el tipo más apropiado entre los 7 (`user`, `feedback`, `project`, `preference`, `learning`, `decision`, `reference`).
2. Genera un slug kebab-case claro y comprueba que no existe ya. Si el usuario está pidiendo guardar algo ya cubierto, **actualiza** la memoria existente en lugar de duplicar.
3. Escribe el archivo `~/.claude/memory/<tipo>/<slug>.md` con frontmatter (`name`, `type`, `created`, `reviewed` con la fecha de hoy).
4. Añade la línea correspondiente a `~/.claude/memory/MEMORY.md` bajo la sección del tipo.
5. Confirma al usuario en una sola línea: `Guardado: <tipo>/<slug>.md`. Nada más.

Si el contenido es ambiguo y no sabes qué tipo asignar, pregunta UNA pregunta breve antes de guardar — no inventes.
