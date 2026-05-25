---
description: Informe de salud de la memoria persistente, conteos por tipo, pendientes de revisión, duplicados.
---

# /memory-status

El usuario quiere un informe del estado de su memoria. Delega al subagente `memory-curator` en **modo B (revisión de salud)**:

```
Agent(
  subagent_type: "memory-curator",
  description: "Revisión de salud de la memoria",
  prompt: "Modo B: revisión de salud. Cuenta entradas por tipo en ~/.claude/memory/, detecta memorias pendientes de revisión según las ventanas (preference/project=3mo, feedback/learning/decision=6mo, user/reference=12mo), candidatos a fusión y inconsistencias del índice. Devuelve el informe en el formato estándar de la skill memory-curator. No hagas cambios todavía."
)
```

**Cuando recibas el informe del curator**, muéstralo al usuario tal cual y termina con:

```
¿Quieres que aplique alguna acción? Responde con los números (ej: "1 y 3") o "ninguna".
```

Si el usuario responde con números o "todas", invoca de nuevo al curator en **modo B+ (aplicar acciones)** especificando exactamente cuáles. Si responde "ninguna", termina con una línea: `OK, sin cambios.`
