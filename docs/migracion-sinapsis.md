# Migración desde Sinapsis

Si vienes del sistema **Sinapsis v4.x**, esta guía te ayuda a llevar lo importante a AIMAX Memory sin perder nada.

> **Importante:** la migración es **manual y selectiva**, no automática. Sinapsis acumula mucha información, parte de la cual ya no es útil. Aprovechamos el cambio para hacer limpieza.
>
> Nada se borra: Sinapsis sigue en `~/.claude/skills/sinapsis*/` y en `~/.claude/projects/`. Solo dejamos de usarlo.

## 1. Antes de empezar

Haz un backup de seguridad de tu Sinapsis actual:

```bash
cp -R ~/.claude/skills ~/.claude/skills-backup-pre-aimax-memory
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup-pre-aimax-memory
```

## 2. Operator state → operator.md

El equivalente más directo de Sinapsis es:

- **Sinapsis**: `~/.claude/skills/_operator-state.json`
- **AIMAX Memory**: `~/.claude/memory/operator.md`

**Pasos:**

1. Abre `~/.claude/skills/_operator-state.json` y mira las secciones `operator`, `techStack`, `strategicDecisions`, `lessons`.
2. Abre `~/.claude/memory/operator.md` (la plantilla recién instalada).
3. Reescribe la información en lenguaje natural. **No copies el JSON literal** — el formato de AIMAX Memory es markdown legible.

Ejemplo:

| Sinapsis (`_operator-state.json`) | AIMAX Memory (`operator.md`) |
|---|---|
| `"role": "Creator de contenido"` | "Soy David, creator de contenido sobre IA." |
| `"techStack.frontend": "Astro"` | Bajo "Stack y herramientas": "- Frontend: Astro" |
| `"strategicDecisions": [{ "decision": "...", "why": "..." }]` | Va a `decision/` como memorias individuales, no a `operator.md`. |

## 3. Instincts → memorias

Los **instincts** de Sinapsis viven en `~/.claude/skills/sinapsis-instincts/` (o donde los hayas guardado). Cada uno representa un patrón aprendido.

**Cómo migrarlos:**

1. Mira la lista con `/instinct-status` (si todavía tienes Sinapsis activa) o lista los `.md` a mano.
2. Para cada instinct **que sigas usando**:
   - Si describe **cómo te gusta trabajar** → memoria `feedback`.
   - Si describe **un aprendizaje no obvio** → memoria `learning`.
   - Si describe **una decisión con porqué** → memoria `decision`.
   - Si es **demasiado específico de un proyecto que ya terminó** → no lo migres.
3. Crea la memoria nueva con `/remember <texto>` o a mano siguiendo el formato de la skill `memory`.
4. **No migres todo en masa**. Filtra. Sinapsis acumula instincts útiles y otros que dejaron de aplicar. Lleva solo lo que pasa el filtro "¿me alegraré en 3 meses de no tener que decir esto otra vez?".

## 4. Projects de Sinapsis → memorias `project/`

Sinapsis tiene un registro de proyectos en `_projects.json`. Cada proyecto activo merece una memoria `project/`:

```markdown
---
name: <slug>
type: project
created: <YYYY-MM-DD>
reviewed: <YYYY-MM-DD>
---

<Una frase sobre el proyecto>

**Por qué:** <razón estratégica>
**Plazo clave:** <fecha si aplica>
**Stakeholders:** <gente involucrada si aplica>
```

Los proyectos terminados o pausados no se migran. Si los necesitas más adelante, están en el backup.

## 5. Daily summaries

Sinapsis guarda resúmenes en `~/.claude/skills/_daily-summaries/`. AIMAX Memory usa la misma ruta: `~/.claude/memory/_daily-summaries/`.

**Pasos:**

1. **Solo migra los últimos 7-14 días** (los recientes son los que dan continuidad).
2. Cópialos uno a uno:
   ```bash
   cp ~/.claude/skills/_daily-summaries/<fecha>.md ~/.claude/memory/_daily-summaries/<fecha>.md
   ```
3. Verifica que el formato del frontmatter sigue siendo válido. Si no, ajústalo a:
   ```markdown
   ---
   date: YYYY-MM-DD
   sessions: 1
   ---
   ```

## 6. Desactivar Sinapsis

Cuando hayas terminado de migrar lo útil:

1. **Edita `~/.claude/CLAUDE.md`**: borra o comenta la sección "Session Entry" que apunta a Sinapsis. AIMAX Memory no necesita inyectarse desde CLAUDE.md — sus hooks lo hacen automáticamente.
2. **No borres `~/.claude/skills/sinapsis*/`** todavía. Espera 2-4 semanas para confirmar que no echas en falta nada de Sinapsis. Pasado ese tiempo, si no lo has usado, bórralo o muévelo a un backup externo.

## 7. Verificación

Después de migrar:

1. Cierra todas las sesiones de Claude Code.
2. Abre una sesión nueva.
3. Pregunta al modelo: "¿Qué sabes de mí?" Debería responder con información de tu `operator.md`.
4. Pregunta: "¿En qué proyectos estoy trabajando?" Debería listar lo que pusiste en `project/`.
5. Ejecuta `/memory-status` para ver el conteo y que todo está donde debe estar.

Si algo se quedó por el camino, vuelves al backup y lo añades. Sin prisa.

---

## Qué se gana con la migración

- **Menos peso en CLAUDE.md** y menos lectura inicial inflada.
- **Tipos universales**, no solo programación: ahora `feedback`, `preference`, `learning`, `decision` funcionan para creators, estudio, negocio.
- **Subagentes para búsqueda**: el contexto principal queda más limpio.
- **Sistema más simple**: 3 skills + 6 comandos + 2 subagentes. Sinapsis tenía muchas más piezas; algunas eran potentes, otras añadían fricción.

## Qué se pierde

- **`/dna`, `/audit`, `/evolve`, `/promote`** y otros comandos avanzados de Sinapsis. Si los echas en falta, puedes mantener Sinapsis instalada en paralelo durante un tiempo — solo evita que sus hooks compitan con los de AIMAX Memory.
- **Captura automática de patrones**: AIMAX Memory no detecta patrones por su cuenta como hacía Sinapsis con el `observer`. La decisión de qué guardar es del modelo, basada en la skill `memory`.
