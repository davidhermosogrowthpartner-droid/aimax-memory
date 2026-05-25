---
description: Importa memoria desde un ZIP o carpeta. Uso, /memory-import <ruta>
argument-hint: <ruta-al-zip-o-carpeta>
---

# /memory-import

El usuario quiere importar memoria desde `$ARGUMENTS`. Esto **fusiona** con la memoria actual, no la machaca.

**Paso 1 — Identifica fuente.**
- Si la ruta apunta a un `.zip`, hay que descomprimir primero a un directorio temporal.
- Si apunta a una carpeta, úsala directamente. Debe contener al menos un `MEMORY.md` en raíz para considerarse válida.

**Paso 2 — Backup defensivo.**
Antes de tocar nada, crea un backup del estado actual: copia `~/.claude/memory/` a `~/.claude/memory-backup-<timestamp>/`. Si la importación va mal, el usuario tiene rollback.

**Paso 3 — Fusión.**
Para cada archivo de la fuente bajo `<tipo>/<slug>.md`:
- Si **no existe** en destino: cópialo.
- Si **existe** en destino: muestra al usuario un diff resumido y pregunta: `(a) mantener el local, (b) sobrescribir con el importado, (c) ambos (rename el importado a <slug>-imported.md)`. Si hay muchos conflictos (>10), ofrece "aplicar la misma respuesta a todos".

Para `MEMORY.md`: regenera el índice desde cero leyendo los `.md` resultantes, no fusiones líneas a ciegas (el índice se desincroniza fácil).

**Paso 4 — Confirma.**
```
Importadas <n> entradas (<x> nuevas, <y> sobrescritas, <z> renombradas).
Backup del estado anterior: ~/.claude/memory-backup-<timestamp>/
```
