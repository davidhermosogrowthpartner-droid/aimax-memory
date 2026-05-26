---
name: memory
description: Sistema de memoria persistente AIMAX Memory. Decide qué guardar de cada conversación (decisiones, preferencias, contexto del usuario, aprendizajes) y cómo escribirlo en ~/.claude/memory/ sin gastar tokens innecesarios. USAR cuando el usuario dé información sobre sí mismo, cómo le gusta trabajar, decisiones importantes, datos de proyectos o referencias a sistemas externos. También cuando diga "recuerda esto", "guarda esto", "para que no se te olvide", "no me preguntes esto otra vez". Estar SIEMPRE activa, no on-demand.
---

# AIMAX Memory Memory Protocol

Eres responsable de mantener la memoria persistente del usuario en `~/.claude/memory/`. Tu trabajo es decidir qué merece guardarse, escribirlo en el archivo correcto, y mantener el índice maestro al día. Si lo haces bien, el usuario no tendrá que repetirte nada en futuras sesiones.

## Filosofía

> **Si el usuario nota que estás pensando en la memoria, algo va mal.** El sistema debe ser invisible: guarda lo que importa, calla cuando no, y nunca explica el proceso a no ser que te lo pidan.

Tres reglas de oro:

1. **Guarda señal, no ruido.** Cada entrada debe ahorrarle al usuario tener que repetirse en una futura conversación. Si no cumple eso, no la guardes.
2. **Una entrada = un concepto.** No mezcles "es creator de contenido" con "prefiere respuestas en español" en el mismo archivo. Son dos memorias distintas.
3. **El porqué sobrevive al qué.** Para `feedback`, `project` y `decision`, incluye SIEMPRE una línea `**Por qué:**` con la razón. Sin el porqué, una memoria se vuelve inútil cuando el contexto cambia.

## Cuándo guardar (gatillos)

Pregúntate después de cada respuesta del usuario: ¿se cumple alguno de estos?

- El usuario ha dicho algo sobre **quién es** o a **qué se dedica** que no estaba claro antes → tipo `user`.
- El usuario ha **corregido** algo que hiciste o ha **validado** un enfoque no obvio → tipo `feedback`.
- El usuario ha mencionado un **proyecto activo**, una **fecha clave** o un **objetivo** → tipo `project`.
- El usuario ha indicado un **formato preferido**, una **herramienta favorita** o un **gusto** → tipo `preference`.
- El usuario o tú habéis **descubierto algo no obvio** que merece retener → tipo `learning`.
- Se ha tomado una **decisión** con consecuencias futuras (cambio de stack, de proceso, de proveedor) → tipo `decision`.
- El usuario ha apuntado a un **sistema externo** que tú no controlas (canal de Slack, dashboard, carpeta de Obsidian) → tipo `reference`.

Si el usuario dice explícitamente "recuerda esto", "guarda esto", o cualquier variante: guarda, sin preguntar. Asigna el tipo más apropiado.

## Cuándo NO guardar

- **Detalles efímeros**: estado de la tarea actual, archivos que estás editando ahora, comandos que acabas de ejecutar. Para eso ya tienes la conversación y los Tasks.
- **Información derivable del repo**: convenciones que se ven leyendo el código, estructura de carpetas, qué hace una función. `git log` y `Read` ya están ahí.
- **Cosas ya guardadas**: antes de crear una memoria nueva, comprueba si existe una entrada del mismo tema en `MEMORY.md`. Si existe, **actualízala** en lugar de duplicar.
- **Juicios negativos sobre el usuario**: nunca guardes algo que pueda leerse como crítica o etiqueta peyorativa. La memoria es para servirle, no para clasificarle.
- **Información sensible sin permiso**: tokens, contraseñas, datos personales de terceros. Si el usuario te los da, úsalos en la sesión pero no los persistas.

## Los 7 tipos

| Tipo | Carpeta | Para qué | Ventana de revisión |
|---|---|---|---|
| `user` | `user/` | Quién es el usuario, rol, contexto personal | 12 meses |
| `feedback` | `feedback/` | Cómo le gusta trabajar (correcciones y validaciones) | 6 meses |
| `project` | `project/` | Proyecto activo, plazos, decisiones de scope | 3 meses |
| `preference` | `preference/` | Gustos, formatos, herramientas favoritas | 3 meses |
| `learning` | `learning/` | Aprendizajes a retener (suyos o tuyos sobre él) | 6 meses |
| `decision` | `decision/` | Decisiones importantes con su porqué | 6 meses |
| `reference` | `reference/` | Punteros a sistemas externos (URLs, rutas, canales) | 12 meses |

## Cómo guardar (los dos pasos)

**Paso 1 — Escribir el archivo.** Crea `~/.claude/memory/<tipo>/<slug>.md` con este formato exacto:

```markdown
---
name: <kebab-slug>
type: <user|feedback|project|preference|learning|decision|reference>
created: <YYYY-MM-DD>
reviewed: <YYYY-MM-DD>
---

<Cuerpo libre. Empieza con la afirmación en una frase, luego desarrolla.>

**Por qué:** <Sólo para feedback/project/decision: la razón. Sobrevive a cambios de contexto.>
**Cuándo aplica:** <Sólo para feedback/preference: el dominio en que vale la regla. Evita aplicarla fuera.>
```

- `name`: slug kebab-case único dentro del tipo. Ej: `prefiere-respuestas-cortas`.
- `created` y `reviewed`: fecha actual (`YYYY-MM-DD`). Usa la fecha real de hoy.
- Cuerpo: directo, sin preámbulos. Empieza con la afirmación.

**Paso 2 — Añadir línea al índice.** Edita `~/.claude/memory/MEMORY.md` y añade una sola línea bajo la sección del tipo correspondiente:

```
- [<nombre legible>](<tipo>/<slug>.md) — <gancho de una frase, ≤120 chars>
```

El gancho debe responder en una sola línea: "¿qué me dice esta memoria si la abro?". Si no cabe en 120 chars, condensa. Nunca uses dos líneas.

## Cómo enlazar memorias relacionadas

En el cuerpo de una memoria, referencia otras con `[[slug]]` (sin extensión). Si el slug no existe todavía, también vale: marca un futuro link. Ejemplo:

```
Prefiere recibir las guías PDF con la plantilla [[plantilla-aimax-oscura]].
```

Esto te ayuda a navegar entre memorias relacionadas sin necesidad de buscar.

## Cómo actualizar en lugar de duplicar

Antes de crear una memoria nueva, **mira el índice** (`MEMORY.md`) buscando el tema. Si ya existe:

- Si la memoria sigue siendo válida pero se ha enriquecido: edita el archivo, actualiza `reviewed:`, y deja el gancho del índice como esté (o cámbialo si la nueva versión es más clara).
- Si la memoria ha quedado obsoleta: muévela a `~/.claude/memory/_archived/<tipo>/<slug>.md` y borra su línea del índice. **Nunca borres sin archivar.**

## Cómo manejar el contexto en sesión

Al inicio de cada sesión, el hook `session-start` ya inyecta `MEMORY.md` y `operator.md` en tu contexto. No los releas. Asume que los conoces.

Si necesitas el contenido completo de una memoria concreta y no recuerdas el detalle:
- **Si es UNA memoria conocida**: usa `Read` directamente sobre el archivo.
- **Si necesitas buscar entre muchas**: invoca la skill `memory-search` o llama al subagente `memory-searcher`. **NO hagas Grep tú mismo desde el thread principal** — contaminas el contexto con resultados crudos.

## Errores comunes (no los cometas)

- Crear una memoria por cada cosa que dice el usuario. La memoria se infla y deja de ser útil. Filtra.
- Escribir cuerpos largos llenos de contexto efímero. El cuerpo debe ser denso: afirmación + porqué + cuándo aplica. Si necesitas más de 8 líneas, probablemente estás mezclando dos memorias.
- Olvidar actualizar `MEMORY.md`. Una memoria que no está en el índice es invisible al inicio de la próxima sesión.
- Cambiar el formato del frontmatter "porque queda más bonito". Otros scripts y subagentes esperan ese formato exacto.

## Verificación rápida después de guardar

Confirma mentalmente:
1. ¿Está el archivo en la carpeta correcta del tipo correcto?
2. ¿El frontmatter tiene `name`, `type`, `created`, `reviewed`?
3. ¿Hay línea correspondiente en `MEMORY.md` bajo la sección del tipo?
4. ¿La línea del índice cabe en ≤120 caracteres y es informativa?

Si las cuatro son "sí", terminaste. No anuncies al usuario que has guardado nada salvo que te lo pida.
