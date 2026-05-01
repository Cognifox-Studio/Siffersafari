---
description: "Kodstandard för automationsverktyg (PowerShell och Python under scripts/ tools/)"
applyTo: "scripts/**/*.ps1, tools/**/*.py"
---

# Automationsskript och Tooling

Våra pipeline-verktyg och CLI-script följer plattformsoberoende standarder istället för shell-specifika ful-hack. Blanda inte in bash-script i det här repot.

## PowerShell (`.ps1`)
- **Felsäkerhet:** Alla `.ps1`-script **MÅSTE** inledas med `$ErrorActionPreference = 'Stop'`.
- **Parametrar:** Använd strikt typade `param()`-block. Validera indata via `[ValidateSet("Value1", "Value2")]` och `[ValidateNotNullOrEmpty()]`.
- **Sökvägar:** Bygg aldrig relativa `../` sökvägar från `cwd`. Använd alltid statisk resolution via `$PSScriptRoot`. Exempel: `Join-Path $PSScriptRoot "..\path\to\file"`.

## Python (`.py`)
- **Strikt och Modern Python:** Inled alltid med `from __future__ import annotations`.
- **Sökvägar:** Använd uteslutande `pathlib.Path`. Konkatenera paths med operatorn `/`. Utgå från skriptets position: `BASE_DIR = Path(__file__).resolve().parent.parent`.
- **CLI Argument:** Använd modulerna `argparse` eller `click` för inmatning. Inga "råa" läsningar av `sys.argv[1]`.
- **Utskrift:** Separera tydligt debug/info-loggar (print/logging) från den faktiska data som returneras eller sparas.