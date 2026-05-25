---
name: memory-session
description: Continuidad entre sesiones. Maneja el resumen del fin de sesión y la lectura del resumen del día anterior. USAR cuando el usuario diga "cerramos", "hasta luego", "fin de sesión", "guarda dónde estamos", o cuando arranque una sesión y haya un resumen del día anterior que afecte al trabajo de hoy.
---

# AIMAX Memory Session Continuity

Esta skill cubre los bordes de la sesión: cómo cerrarla bien y cómo retomar al día siguiente sin perder hilo.

## Al inicio de la sesión

El hook `session-start` ya ha inyectado:
- El índice `MEMORY.md`.
- El perfil `operator.md`.
- El último resumen diario (si existe) en `<aimax-memory-last-session-summary>`.

Si ves un `<aimax-memory-last-session-summary>` con una sección **"Para mañana"**, **revísala antes de responder al primer mensaje del usuario**. Si lo que el usuario te pide hoy se conecta con algo pendiente de ayer, menciónalo en una sola frase: "Veo que ayer quedó pendiente X — ¿lo retomamos antes?". Si no se conecta, no lo menciones — el usuario lo verá si lo necesita.

## Durante la sesión

No hagas nada especial. La skill `memory` ya cubre cuándo guardar.

## Al cierre (cuando el usuario lo señala)

Si el usuario dice "cerramos", "hasta luego", "fin de sesión", "guarda dónde estamos" o equivalente:

1. **Antes de despedirte**, revisa mentalmente la sesión y decide si hay que guardar memorias pendientes según la skill `memory`. Si las hay, guárdalas ahora.
2. **Comprueba si vale la pena un resumen del día** (≥5 turnos, hubo decisiones o trabajo sustancial). Si sí:
   - El hook `Stop` escribirá un stub al cerrar. Para un resumen rico (no stub), **escríbelo tú directamente** antes de despedirte: crea/actualiza `~/.claude/memory/_daily-summaries/<YYYY-MM-DD>.md` siguiendo el formato del subagente `memory-curator`.
3. Despídete con una línea muy corta. Algo como: "Listo. Resumen guardado en `_daily-summaries/<fecha>.md`. Hasta mañana." Nada de listas largas.

## Formato del resumen del día (cuando lo escribes manualmente)

```markdown
---
date: <YYYY-MM-DD>
sessions: <n>
---

# Resumen de <YYYY-MM-DD>

## Sesión <HH:MM>

**Qué se hizo:** <1-2 líneas. Acciones reales, no narración.>

**Decisiones tomadas:** <bullets si las hay, omite la sección si no.>

**Memorias guardadas:** <lista de slugs creados/actualizados hoy, omite si vacío.>

**Para mañana:** <bullets accionables. Omite la sección si no hay nada pendiente.>
```

Si el fichero del día ya existe (sesión múltiple), **añade** una nueva sección "## Sesión HH:MM" al final. No machaques.

## Qué NO hacer

- No anuncies "voy a hacer el resumen" antes de hacerlo. Hazlo y di una línea final.
- No metas la transcripción completa. Lo importante son decisiones y "para mañana".
- No invoques al subagente `memory-curator` desde aquí — el curator es para mantenimiento periódico, no para el cierre normal. Para el cierre, tú escribes el fichero directamente.

## Edge case: sesión trivial

Si el usuario sólo hizo una consulta corta y se va: no escribas resumen. El stub del hook ya marca que hubo sesión. Despídete y ya.
