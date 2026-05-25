# Filosofía

## El problema

Claude Code es brillante pero amnésico. Cada sesión empieza desde cero. Le tienes que repetir quién eres, cómo te gusta trabajar, qué decidiste el lunes pasado, qué proyecto está activo. Al cabo de un par de meses, la mitad de cada conversación es contexto que ya le diste antes.

Hay dos soluciones malas y una buena:

- **Mala 1: meter todo en CLAUDE.md.** Funciona unos meses, luego CLAUDE.md pesa 50 KB y el modelo lo lee al inicio de cada sesión gastando tokens. La señal se pierde entre el ruido.
- **Mala 2: no hacer nada y repetirse.** Funciona también, pero te roba minutos cada día y la calidad de las respuestas baja con el tiempo.
- **Buena: memoria estructurada con recuperación perezosa.** Solo se carga lo imprescindible al inicio (índice + perfil ≈ 10 KB), y el detalle se busca solo cuando hace falta, idealmente desde un subagente que no contamina el contexto principal.

Esa tercera vía es AIMAX Memory.

## Las tres reglas

### 1. Señal, no ruido

Cada entrada en tu memoria tiene que justificar su existencia respondiendo: *¿esto me ahorra repetirme en el futuro?* Si la respuesta es no, no se guarda.

Cosas que **no** se guardan:
- Detalles efímeros de la tarea actual (qué archivo editas ahora).
- Información que se puede derivar del proyecto leyendo el código.
- Etiquetas o juicios sobre ti (la memoria es para servirte, no clasificarte).

Cosas que **sí** se guardan:
- Quién eres y a qué te dedicas.
- Cómo te gusta que trabajen contigo.
- Proyectos activos con sus porqués.
- Decisiones con consecuencias futuras.
- Aprendizajes no obvios.
- Punteros a sistemas externos donde vive información útil.

### 2. Markdown legible

No hay binario, no hay base de datos opaca, no hay sincronización en la nube de un tercero. Tu memoria son archivos `.md` en `~/.claude/memory/`. Los puedes:

- **Leer** sin ningún programa raro.
- **Editar** a mano cuando algo está mal.
- **Versionar** con git si quieres historial.
- **Compartir** mandando un ZIP a un compañero.
- **Migrar** copiando la carpeta a otra máquina.

Esa transparencia tiene un coste: la búsqueda es por Grep, no por embeddings ni FTS. Pero con buena jerarquía y un índice de una línea por entrada, Grep es más que suficiente para volúmenes humanos (hasta unos pocos miles de memorias).

### 3. Recuperación perezosa

El truco para no gastar tokens es no cargar lo que no necesitas. AIMAX Memory carga al inicio:

- **`MEMORY.md`** — el índice. Una línea por entrada, ≤120 caracteres. 100 entradas pesan unos 10 KB.
- **`operator.md`** — tu perfil. Idealmente ≤1 KB.
- **El último resumen diario** — para continuidad de sesión.

Eso es todo. Para volúmenes humanos, el contexto inicial inyectado es de aproximadamente **10-15 KB**, comparable a un CLAUDE.md medio, pero con la ventaja de que **detrás** del índice hay potencialmente cientos de memorias detalladas, accesibles bajo demanda.

¿Cómo se accede al detalle?

- **Lectura directa** si conoces el slug (`Read` sobre el archivo).
- **Búsqueda** vía el subagente `memory-searcher`, que hace Grep aislado y devuelve solo los resúmenes relevantes.

El thread principal nunca tiene que leer 20 archivos completos para responderte. Ese es el ahorro real.

## Por qué subagentes

Hay dos subagentes en AIMAX Memory:

- **`memory-searcher`** — para búsquedas profundas. Recibe una consulta, devuelve 3-5 resúmenes. El thread principal queda limpio.
- **`memory-curator`** — para mantenimiento (revisar fechas, fusionar duplicados, escribir resúmenes diarios). Trabaja con la transcripción y el directorio, sin necesidad del contexto completo de la sesión.

La regla: **cualquier tarea que implique leer muchos archivos o procesar mucho texto va a un subagente.** Así el thread principal mantiene su contexto limpio para el trabajo real.

## Qué AIMAX Memory no es

- **No es un sistema de notas.** Para eso tienes Obsidian, Notion, Apple Notes, lo que quieras. AIMAX Memory guarda lo que sirve para que el asistente trabaje mejor contigo, no tus notas personales.
- **No es un sistema de tareas.** No reemplaza un Todoist o un GTD. Si necesitas tracking de tareas, sigue usando lo tuyo y deja que AIMAX Memory guarde la *meta-información* (cómo te gusta trabajar, decisiones de proceso, herramientas).
- **No es una base de conocimiento técnico.** No es para guardar tutoriales o documentación. Para eso está la web. AIMAX Memory guarda **lo que es específico a ti** y a tu forma de trabajar.

## El criterio final

Cuando dudes si guardar algo, pregúntate: *si en tres meses empiezo una sesión nueva, ¿me alegraré de no tener que decir esto otra vez?*

Si la respuesta es sí, guárdalo.

Si la respuesta es no o "no estoy seguro", no lo guardes. Mejor poco y útil que mucho y ruidoso.
