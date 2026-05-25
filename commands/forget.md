---
description: Archiva una memoria (no la borra). Uso, /forget <slug-o-descripción>
argument-hint: <slug-o-descripción>
---

# /forget

El usuario quiere olvidar `$ARGUMENTS`. Esto NO borra, sino que **archiva** la memoria en `~/.claude/memory/_archived/<tipo>/<slug>.md`.

**Paso 1 — Identifica la memoria.**
- Si `$ARGUMENTS` parece un slug (`kebab-case`), busca el archivo directamente en `~/.claude/memory/*/<slug>.md`.
- Si es una descripción libre, delega al subagente `memory-searcher` para localizar el candidato más probable. Si hay más de uno claro, pregunta al usuario cuál.

**Paso 2 — Archiva.**
1. Crea `~/.claude/memory/_archived/<tipo>/` si no existe.
2. Mueve el fichero a `_archived/<tipo>/<slug>.md` (lee el contenido y escribe en la nueva ubicación, luego borra el original).
3. Elimina la línea correspondiente de `~/.claude/memory/MEMORY.md`.

**Paso 3 — Confirma.** Una línea: `Archivado: <tipo>/<slug>.md (movido a _archived/).` Nada más.

Si no encuentras la memoria, dilo y sugiere al usuario ejecutar `/recall <consulta>` primero.
