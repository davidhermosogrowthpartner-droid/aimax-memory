# AIMAX Memory

**Memoria persistente para Claude Code. Universal, ligera, invisible.**

AIMAX Memory hace que tu asistente te conozca un poco mejor en cada sesión. No tienes que repetirle quién eres, cómo te gusta que te hable, en qué proyectos estás o qué decidiste el lunes pasado. La memoria vive en archivos markdown legibles dentro de tu propia carpeta `~/.claude/memory/`, no en una nube, no en una base de datos opaca, no gastando tokens innecesarios.

Inspirado en [Engram](https://github.com/Gentleman-Programming/engram), pero abierto a cualquier uso: creators, estudio, negocio, productividad personal, programación. Si usas Claude Code para todo, AIMAX Memory es para ti.

---

## Filosofía

> Si notas que estás pensando en la memoria, algo va mal. La memoria debe ser invisible: te ayuda cuando hace falta y desaparece cuando no.

AIMAX Memory se basa en tres ideas:

1. **Señal, no ruido.** Solo se guarda lo que te ahorra repetirte en el futuro. El resto es conversación que vive y muere en la sesión.
2. **Markdown legible.** Tu memoria está en archivos `.md` que puedes leer, editar, mover y compartir. Sin binarios ni dependencias.
3. **Recuperación perezosa.** Al iniciar sesión solo se carga un índice y tu perfil (~10 KB). El detalle se lee solo cuando hace falta, vía subagentes que no contaminan el contexto principal.

---

## Instalación en 2 minutos

### Opción A — Plugin de Claude Code (recomendado)

```
/plugin marketplace add github:davidhermosogrowthpartner-droid/aimax-memory
/plugin install aimax-memory@aimax-memory
```

> *Nota: reemplaza `davidhermosogrowthpartner-droid/aimax-memory` por el slug del repo donde publiques tu fork. Si aún no lo has publicado, usa la opción B.*

### Opción B — Script de instalación

**Mac / Linux / Git Bash / WSL:**

```bash
git clone https://github.com/davidhermosogrowthpartner-droid/aimax-memory.git
cd aimax-memory
./install.sh
```

**Windows PowerShell:**

```powershell
git clone https://github.com/davidhermosogrowthpartner-droid/aimax-memory.git
cd aimax-memory
.\install.ps1
```

El instalador es idempotente y no machaca datos existentes. Puedes ejecutarlo de nuevo para actualizar.

---

## Primeros pasos (5 min)

1. **Rellena tu perfil.** Abre `~/.claude/memory/operator.md` y completa nombre, cómo te gusta trabajar, herramientas habituales. Mantenlo corto — es tu carta de presentación al modelo, no un CV.
2. **Reinicia Claude Code.** En la siguiente sesión, AIMAX Memory inyectará tu índice y tu perfil automáticamente.
3. **Empieza a usarlo.** No hay que aprender comandos. Cuéntale al modelo cosas sobre ti, sobre tus proyectos, tus preferencias. Él decidirá qué merece persistirse según la skill `memory`.

¿Quieres tomar el control? Tienes 6 comandos:

| Comando | Para qué |
|---|---|
| `/remember <texto>` | Guarda algo a mano |
| `/recall <consulta>` | Busca en tu memoria |
| `/forget <slug-o-descripción>` | Archiva (no borra) una memoria |
| `/memory-status` | Informe de salud y sugerencias |
| `/memory-export [ruta]` | Backup a ZIP |
| `/memory-import <ruta>` | Restaura o fusiona |

---

## Qué hace por ti (ejemplos reales)

**Creator de contenido.** Le cuentas una vez que tu marca es AIMAX, que tus guías PDF usan plantilla oscura, y que tus vídeos hablan a un público hispano de 25-40 años. Tres semanas después le pides una guía nueva — el formato, paleta y tono salen alineados a la primera.

**Estudio / aprendizaje.** Cada vez que descubres algo no obvio sobre cómo aprendes mejor (por ejemplo, "rindo más estudiando por mañanas con bloques de 50 min"), AIMAX Memory lo guarda. En futuras sesiones de planificación, lo recuerda y te propone planes coherentes.

**Negocio.** Tus clientes activos, sus criterios de aprobación, los plazos críticos del trimestre — todo en `project/`. Pides un email de seguimiento y el modelo ya sabe a quién, con qué tono y qué evitar mencionar.

**Programación.** Decisiones de stack, gotchas que te quemaron una vez, convenciones de tu equipo. Lo clásico que ya hacía Engram, sin perder esa potencia.

---

## Estructura

```
~/.claude/memory/
├── MEMORY.md                # índice maestro (siempre cargado)
├── operator.md              # tu perfil (siempre cargado)
├── user/                    # quién eres
├── feedback/                # cómo te gusta trabajar
├── project/                 # proyectos activos
├── preference/              # gustos y formatos
├── learning/                # aprendizajes a retener
├── decision/                # decisiones con porqué
├── reference/               # punteros a sistemas externos
├── _daily-summaries/        # resúmenes diarios (continuidad)
└── _archived/               # memorias archivadas (nunca se borran)
```

Lee [`docs/tipos-de-memoria.md`](docs/tipos-de-memoria.md) para ejemplos concretos de cada tipo.

---

## Más

- [Filosofía](docs/filosofia.md) — por qué AIMAX Memory existe y cómo pensar la memoria.
- [Tipos de memoria](docs/tipos-de-memoria.md) — los 7 tipos con ejemplos no técnicos.
- [Guía del alumno](docs/guia-alumno.md) — empezar desde cero en 5 minutos.
- [Migración desde Sinapsis](docs/migracion-sinapsis.md) — si vienes del sistema anterior.

---

## Licencia

MIT — úsalo, modifícalo, redistribúyelo, enséñalo. Si lo bifurcas, una mención al original es bienvenida pero no obligatoria.

Inspirado en y con gratitud a [Engram de Gentleman-Programming](https://github.com/Gentleman-Programming/engram).
