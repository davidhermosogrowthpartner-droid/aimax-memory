---
name: memory-search
description: Cómo buscar dentro de ~/.claude/memory/ sin contaminar el contexto principal. USAR cuando necesites localizar una memoria concreta y el índice (MEMORY.md) no es suficiente para responder. Siempre delega la búsqueda al subagente memory-searcher, no la hagas tú con Grep desde el thread principal.
---

# AIMAX Memory Memory Search

Esta skill no busca por ti — te dice **cómo** buscar sin gastar tokens.

## Regla maestra

Si la respuesta está en el **índice** (`MEMORY.md`), úsalo y ya está. Está cargado en tu contexto desde SessionStart.

Si el índice no basta y necesitas leer el cuerpo de **UNA** memoria concreta cuyo path conoces: usa `Read` sobre ese fichero. Coste: una lectura corta.

Si necesitas buscar entre **varias** memorias por un concepto que no aparece literal en el índice: **delega al subagente `memory-searcher`** (`Agent` con `subagent_type: memory-searcher`). Tú no haces Grep desde el thread principal.

## Por qué delegar

- Grep desde el thread principal devuelve líneas crudas y tú acabas leyendo varios ficheros completos en el contexto.
- El subagente devuelve sólo los 3-5 resultados relevantes resumidos en pocas líneas.
- Tu contexto principal queda limpio para el trabajo real.

## Cómo invocar al searcher

```
Agent(
  subagent_type: "memory-searcher",
  description: "Buscar memorias sobre <tema>",
  prompt: "Busca memorias relacionadas con <consulta concreta>. Devuelve máximo 5 resultados en el formato estándar de la skill memory-searcher. Si no hay nada relevante, dilo."
)
```

El prompt debe ser autocontenido: incluye palabras clave, contexto mínimo, y qué quieres que devuelva (resúmenes, no contenido completo).

## Cuándo NO usar el searcher

- Para temas que están en el índice. Lee el índice y ya.
- Para abrir UNA memoria cuya ruta exacta conoces. `Read` directo.
- Para buscar en código del proyecto del usuario. El searcher sólo busca en `~/.claude/memory/`.

## Después de recibir los resultados

Cuando el searcher te devuelva un puñado de resultados:
1. Si responden a tu pregunta, sigue trabajando.
2. Si quieres el detalle completo de uno: `Read` sobre `~/.claude/memory/<tipo>/<slug>.md`.
3. No vuelvas a invocar al searcher para refinar — refina tú mentalmente sobre el resumen que ya tienes.

## Ejemplo

Usuario: "Genera una guía PDF sobre prompting."

Tú piensas: el índice menciona "preferencias sobre guías PDF" pero no recuerdo si especifica longitud o paleta. Delego.

```
Agent(
  subagent_type: "memory-searcher",
  description: "Memorias sobre guías PDF",
  prompt: "Busca memorias sobre cómo el usuario prefiere que estructure y diseñe las guías PDF: longitud, secciones, paleta, plantilla, tono. Máximo 5 resultados."
)
```

Recibes 2-3 resúmenes. Aplicas lo relevante. Sigues con la guía. Cero ficheros completos en tu contexto principal.
