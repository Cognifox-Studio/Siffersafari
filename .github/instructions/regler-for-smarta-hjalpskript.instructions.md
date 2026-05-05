---
name: "Smarta hjälpskript"
description: "Use when editing PowerShell or Python automation under scripts/ or tools/. Covers safe path handling, typed parameters and repo policy against heavy new generator pipelines."
applyTo: "scripts/**/*.ps1, tools/**/*.py"
---

# Automationsskript och tooling

Det här repot använder skript främst för QA, Android-emulatorflöden och mindre repoautomation. Lägg inte tillbaka stora generationspipelines utan tydlig produktnytta.

## PowerShell (`.ps1`)
- Sätt `$ErrorActionPreference = 'Stop'` tidigt.
- Använd tydliga `param()`-block med typer och validering där input kan variera.
- Bygg sökvägar från `$PSScriptRoot`, inte från antagen `cwd`.
- Favorisera tydliga cmdlets och idiomatisk PowerShell framför shell-hack och långa kedjor av externa verktyg.

## Python (`.py`)
- Börja med `from __future__ import annotations`.
- Använd `pathlib.Path` för sökvägar och utgå från filens verkliga plats.
- Använd `argparse` eller `click` för CLI-argument i stället för rå `sys.argv`-parsning.
- Håll debug-loggar och faktisk maskinläsbar output separerade.