---
description: Exporta toda la memoria persistente a un ZIP para backup o migración. Uso, /memory-export [ruta-destino]
argument-hint: [ruta-destino opcional]
---

# /memory-export

El usuario quiere exportar su memoria persistente.

**Paso 1 — Determina destino.**
- Si `$ARGUMENTS` tiene una ruta válida, úsala.
- Si no, usa `~/aimax-memory-memory-backup-<YYYY-MM-DD>.zip` por defecto.

**Paso 2 — Crea el ZIP.**

En Windows PowerShell:
```powershell
$src = Join-Path $env:USERPROFILE '.claude\memory'
$dst = '<ruta-destino>'
Compress-Archive -Path "$src\*" -DestinationPath $dst -Force
```

En Mac/Linux:
```bash
cd ~/.claude && zip -r <ruta-destino> memory/ -x "memory/_archived/*"
```

**Paso 3 — Confirma.** Una línea: `Exportado: <ruta> (<tamaño>).`

Aclara al usuario: el ZIP incluye sus datos privados. No lo subas a nada público sin revisarlo antes.

## Sync vía git (alternativa)

Si el usuario prefiere sync via git en vez de ZIP, sugiérele inicializar `~/.claude/memory/` como repo git privado y hacer `git push` a su remoto. Es la opción más limpia para sincronizar entre máquinas.
