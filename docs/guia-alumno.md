# Guía del alumno — Empezar en 5 minutos

Si nunca has tocado un plugin de Claude Code, esta guía es para ti. Te llevará desde "no tengo nada" hasta "AIMAX Memory funciona y mi asistente me recuerda" en 5-10 minutos.

## 0. Antes de empezar

Necesitas:
- **Claude Code instalado** (ya lo tienes si estás leyendo esto).
- **Git** instalado en tu máquina. Si no, descárgalo desde [git-scm.com](https://git-scm.com).
- **Una terminal**: en Mac es Terminal o iTerm; en Windows es PowerShell (viene preinstalado) o Git Bash (viene con Git).

No necesitas saber programar. Necesitas saber pegar comandos.

## 1. Instalación

### Si usas Mac, Linux, WSL o Git Bash (Windows)

Abre la terminal y pega esto, línea a línea:

```bash
git clone https://github.com/davidhermosogrowthpartner-droid/aimax-memory.git
cd aimax-memory
./install.sh
```

> *Si el repo aún no existe en GitHub, cámbialo por la URL que te haya dado tu profe o por un clon local.*

### Si usas PowerShell de Windows

Abre PowerShell y pega:

```powershell
git clone https://github.com/davidhermosogrowthpartner-droid/aimax-memory.git
cd aimax-memory
.\install.ps1
```

Si te dice "no se puede ejecutar scripts", ejecuta primero:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Y vuelve a intentarlo.

## 2. Rellena tu perfil

El instalador ha creado `~/.claude/memory/operator.md`. Ábrelo con tu editor favorito (VS Code, Notepad, lo que sea) y rellena lo que conozcas de ti:

- Tu nombre y a qué te dedicas (2 frases).
- Cómo te gusta que te hablen (idioma, longitud, tono).
- Tus herramientas habituales (las que usas a diario).
- 1-3 objetivos amplios que enmarquen lo que estás haciendo este trimestre.

**No tienes que rellenarlo todo.** Lo que dejes en blanco, lo aprenderá con el uso. Pero cuanto más rellenes, más rápido empezará a serte útil.

Mantenlo **corto**. Si pasas de 30 líneas, condensa.

## 3. Reinicia Claude Code

Cierra todas las sesiones abiertas de Claude Code y abre una nueva. Si todo fue bien, la nueva sesión cargará tu índice y tu perfil sin que lo notes.

Para comprobar que cargó, escribe al modelo:

> "¿Qué sabes de mí?"

Debería responder con cosas que pusiste en `operator.md`. Si no responde nada, vete al final de esta guía (sección "No funciona").

## 4. Empieza a usarlo

Hay dos formas:

### Forma A — Sin comandos (recomendado)

Habla con el modelo normal. Cuéntale cosas sobre ti, sobre tus proyectos, sobre cómo te gustaría que trabaje. Él decidirá qué merece guardarse, lo guardará en silencio y la próxima sesión se acordará.

Ejemplos de cosas que vale la pena contarle:
- "Estoy preparando un curso sobre Claude Code que sale en junio."
- "Cuando me hagas guiones, prefiero estructura: hook, desarrollo en 3 puntos, call to action."
- "Migré de Notion a Obsidian porque la búsqueda local me parece más rápida."

### Forma B — Con comandos (cuando quieras control)

| Comando | Para qué |
|---|---|
| `/remember <texto>` | Le dices que guarde algo concreto. |
| `/recall <consulta>` | Le pides que busque algo en tu memoria. |
| `/memory-status` | Te enseña cuántas memorias tienes y cuáles toca revisar. |
| `/forget <slug>` | Archiva una memoria (no se borra, va a `_archived/`). |
| `/memory-export` | Hace un ZIP con toda tu memoria. |
| `/memory-import <ruta>` | Importa desde un ZIP o carpeta. |

## 5. Mantenimiento (1 vez al mes, opcional)

Una vez al mes, ejecuta `/memory-status`. Verás:

- Cuántas memorias tienes por tipo.
- Cuáles llevan tiempo sin revisar.
- Posibles duplicados.

El modelo te propondrá acciones (fusionar, archivar) y tú decides cuáles aplicar. **Nada se borra sin tu permiso**, todo va a `_archived/`.

---

## No funciona

### "No me carga el perfil al iniciar sesión"

1. Comprueba que `~/.claude/memory/operator.md` existe y tiene algo escrito.
2. Comprueba que `~/.claude/settings.json` tiene una sección `hooks` con `SessionStart` apuntando a algún script. Si no, vuelve a ejecutar el instalador.
3. Mira los logs de Claude Code (en la propia app, suele haber una opción "View logs").

### "El instalador da error de permisos en Windows"

Abre PowerShell **como administrador** y ejecuta:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Luego cierra PowerShell, abre uno nuevo (sin admin), y vuelve a intentar `.\install.ps1`.

### "El modelo no guarda nada por su cuenta"

Probablemente las skills no se cargaron. Comprueba que en `~/.claude/skills/` hay carpetas `memory/`, `memory-search/`, `memory-session/`. Si no, ejecuta el instalador de nuevo.

### "Quiero desinstalarlo"

```bash
rm -rf ~/.claude/aimax-memory
rm -rf ~/.claude/skills/memory ~/.claude/skills/memory-search ~/.claude/skills/memory-session
rm ~/.claude/commands/remember.md ~/.claude/commands/recall.md ~/.claude/commands/forget.md ~/.claude/commands/memory-status.md ~/.claude/commands/memory-export.md ~/.claude/commands/memory-import.md
rm ~/.claude/agents/memory-searcher.md ~/.claude/agents/memory-curator.md
```

Y edita `~/.claude/settings.json` para quitar los hooks de AIMAX Memory.

**`~/.claude/memory/` se queda intacto** — son tus datos. Bórralo a mano si quieres.

---

## Siguiente paso

Cuando te sientas cómodo, lee [`docs/filosofia.md`](filosofia.md) para entender el "por qué" del sistema, y [`docs/tipos-de-memoria.md`](tipos-de-memoria.md) para los detalles de cada tipo con ejemplos.
