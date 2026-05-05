---
name: testa-innan-vi-sparar
description: 'Run analyze and the right tests before proposing commit or declaring larger work finished. Use as a final quality gate after implementation.'
argument-hint: 'Beskriv vilken ändring som ska granskas innan avslut eller commit.'
---

# Testa innan vi sparar

Använd skillen som slutgrind innan du föreslår commit eller säger att en större ändring är klar.

## Arbetsflöde
1. Kör `flutter analyze`.
2. Kör `powershell -ExecutionPolicy Bypass -File scripts/verify_git_changes.ps1` när diffen inte är trivial docs-only.
3. Kör minst den närmast relaterade testfilen. Eskalera till bredare testning när ändringen rör providers, persistens, navigation eller flera huvudflöden.
4. Om analyze eller test fallerar: stoppa, förklara felet och fixa det innan arbetet betraktas som klart.