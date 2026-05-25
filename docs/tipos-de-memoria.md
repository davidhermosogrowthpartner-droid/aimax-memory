# Los 7 tipos de memoria

Cada memoria que guardas tiene un tipo. El tipo determina dónde se almacena y cada cuánto debe revisarse. Esta página los explica con ejemplos concretos.

> Si dudas entre dos tipos, elige el que tenga ventana de revisión más larga. Una memoria mal clasificada no rompe nada; lo único que cambia es cuándo el `memory-curator` la propondrá para revisión.

---

## `user` — Quién eres

**Para qué:** información sobre ti como persona. Rol, dominio, brand, contexto vital.

**Ventana de revisión:** 12 meses.

**Ejemplos:**
- "Soy creator de contenido sobre IA. Marca: AIMAX Agency. Audiencia: hispana, 25-40 años, interesada en automatización."
- "Estudio segundo año de Ingeniería Industrial en la UPV. Foco: optimización de procesos."
- "Soy abogada especializada en propiedad intelectual. Llevo 12 años en el despacho XYZ."

**Cuándo NO:** detalles operativos (eso va a `project/`) o cómo te gusta trabajar (eso va a `feedback/`).

---

## `feedback` — Cómo te gusta trabajar

**Para qué:** correcciones y validaciones sobre el estilo de colaboración. La diferencia con `preference` es que `feedback` es más conductual ("cómo quieres que me comporte") y `preference` es más sobre artefactos ("qué formato uso").

**Ventana de revisión:** 6 meses.

**Ejemplos:**
- "Prefiero respuestas en español, máx 3 bullets por sección, sin emojis."
- "Si vas a hacer una acción destructiva o que cueste dinero, pregúntame antes."
- "Cuando me expliques algo técnico, asume que sé programar pero no que conozco el framework concreto."

**Cuándo SÍ guardar:** el usuario te corrigió ("no, eso no") o validó un enfoque no obvio ("perfecto, así me gusta").

**Cuándo NO:** preferencias de output específicas de un artefacto (eso va a `preference`).

---

## `project` — Proyectos activos

**Para qué:** proyectos en curso con sus objetivos, plazos, decisiones de scope.

**Ventana de revisión:** 3 meses (los proyectos cambian rápido).

**Ejemplos:**
- "Lanzamiento del curso 'Claude Code para Creators' en junio 2026. Target: 200 alumnos. Precio: 297 €. Canal: ManyChat → Hotmart."
- "Tesis sobre IA en logística. Entrega: septiembre. Tutor: profesor García. Capítulo en curso: estado del arte."
- "Cliente Acme Corp: rediseño de su web. Deadline 15 julio. Stack acordado: Next.js + Vercel. Punto único de contacto: María (CMO)."

**Cuándo SÍ guardar:** se inicia un proyecto nuevo, cambia un plazo importante, hay una decisión de scope.

**Cuándo NO:** tareas del día a día (eso son TODOs, no memoria) o aprendizajes técnicos derivados (eso va a `learning`).

---

## `preference` — Gustos y formatos

**Para qué:** preferencias sobre artefactos concretos: formatos, paletas, plantillas, herramientas favoritas.

**Ventana de revisión:** 3 meses.

**Ejemplos:**
- "Para guías PDF uso la plantilla AIMAX con fondo oscuro, tipografía Inter y bloques tipo terminal."
- "Mis posts de LinkedIn empiezan con un hook de una frase, tienen 3 bullets en el medio y cierran con una pregunta."
- "Para gestionar mis notas uso Obsidian con el plugin Dataview. Carpeta principal: `~/Obsidian/`."

**Cuándo SÍ guardar:** el usuario te enseña una plantilla, un formato o una herramienta que quiere reutilizar.

---

## `learning` — Aprendizajes a retener

**Para qué:** lecciones aprendidas (tuyas o del modelo sobre ti) que merecen sobrevivir a la sesión.

**Ventana de revisión:** 6 meses.

**Ejemplos:**
- "Los reels de TikTok con hook de 1 segundo (movimiento brusco al inicio) duplican la retención respecto a hooks de 3 segundos."
- "Estudiar por la mañana en bloques de 50 minutos me rinde el doble que sesiones largas de 2 h sin pausa."
- "En negociaciones con clientes nuevos, abrir con un caso concreto similar al suyo cierra más rápido que listar capacidades."

**Cuándo SÍ guardar:** descubres algo no obvio que querrías recordar dentro de 6 meses.

**Cuándo NO:** información general que está en cualquier libro o web (eso no es tuyo).

---

## `decision` — Decisiones con porqué

**Para qué:** decisiones con consecuencias futuras y la razón detrás.

**Ventana de revisión:** 6 meses.

**Ejemplos:**
- "Migré de Notion a Obsidian porque la búsqueda local es más rápida y los datos viven en mi disco. Aceptado el coste de perder algunas vistas colaborativas."
- "Decidimos lanzar el curso solo en español aunque tengamos audiencia LATAM. Razón: dar soporte en multiidioma con el equipo actual nos saturaba."
- "Para la próxima generación de productos, abandonamos Tailwind y volvemos a CSS plano. Razón: el equipo no junior se atascaba con utility classes y el debugging visual mejoró."

**El porqué es lo crítico.** Sin él, una decisión vieja se vuelve incomprensible cuando el contexto cambia. Siempre incluye `**Por qué:**` en el cuerpo.

---

## `reference` — Punteros a sistemas externos

**Para qué:** URLs, rutas locales, canales de Slack, dashboards. Información que **no controla** AIMAX Memory pero a la que querrás dirigirte.

**Ventana de revisión:** 12 meses.

**Ejemplos:**
- "Mi calendario editorial vive en `~/Obsidian/AIMAX/Editorial.md`. Lo actualizo los domingos."
- "El dashboard de KPIs del curso está en https://analytics.hotmart.com/dashboard/abc123."
- "Los assets de la marca AIMAX (logos, fuentes, plantillas) están en `~/Dropbox/AIMAX/brand/`."
- "Para feedback de los alumnos uso el canal #curso-feedback en mi Discord."

**Cuándo SÍ guardar:** quieres que el modelo sepa dónde está algo importante para futuras consultas.

**Cuándo NO:** URLs efímeras (un PR concreto, un commit).

---

## Resumen visual

| Tipo | Folder | Revisión | "Es esto si te preguntas..." |
|---|---|---|---|
| `user` | `user/` | 12 m | ¿quién soy? |
| `feedback` | `feedback/` | 6 m | ¿cómo quiero que me hablen? |
| `project` | `project/` | 3 m | ¿en qué estoy trabajando ahora? |
| `preference` | `preference/` | 3 m | ¿qué formato/plantilla uso para X? |
| `learning` | `learning/` | 6 m | ¿qué he descubierto que no quiero olvidar? |
| `decision` | `decision/` | 6 m | ¿por qué elegimos esto y no aquello? |
| `reference` | `reference/` | 12 m | ¿dónde vive esa información? |
