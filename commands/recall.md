---
description: Busca en la memoria persistente. Uso, /recall <consulta>
argument-hint: <consulta>
---

# /recall

El usuario quiere buscar `$ARGUMENTS` en su memoria persistente.

**Paso 1 — Mira primero el índice.** `MEMORY.md` ya está en tu contexto desde SessionStart. Si la respuesta está ahí, responde directamente citando la entrada con su ruta. No invoques al subagente para algo que el índice ya responde.

**Paso 2 — Si el índice no basta, delega al subagente `memory-searcher`**:

```
Agent(
  subagent_type: "memory-searcher",
  description: "Recall: <consulta>",
  prompt: "Busca memorias relacionadas con: $ARGUMENTS. Devuelve máximo 5 resultados en el formato estándar."
)
```

**Paso 3 — Presenta los resultados al usuario** en formato compacto:

```
Encontré <n> entradas relevantes:

1. <Título> (<tipo>/<slug>.md) — <resumen 1 línea>
2. ...

¿Quieres ver alguna en detalle?
```

Si quiere detalle: usa `Read` sobre el fichero concreto y muéstralo.

Si no hay resultados: dilo en una línea y sugiere palabras clave alternativas.
