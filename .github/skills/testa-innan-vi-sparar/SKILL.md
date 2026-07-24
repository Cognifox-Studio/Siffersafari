---
name: testa-innan-vi-sparar
description: 'Run analyze and the right tests before proposing commit or declaring larger work finished. Use as a final quality gate after implementation.'
argument-hint: 'Beskriv vilken ändring som ska granskas innan avslut eller commit.'
---

# Testa innan vi sparar

Använd skillen som slutgrind innan du föreslår commit eller säger att en större ändring är klar.

**Facit:** följ också checklistan i `docs/DEFINITION_OF_DONE.md` (sektion A). Arbetssätt: `docs/DEV_SYSTEM.md`.

## Arbetsflöde
1. Bekräfta att slicen har **en avsikt** och att DoD A är realistisk.
2. Kör `flutter analyze`.
3. Kör `powershell -ExecutionPolicy Bypass -File scripts/verify_git_changes.ps1` när diffen inte är trivial docs-only.
4. Kör minst den närmast relaterade testfilen. Eskalera till bredare testning när ändringen rör providers, persistens, navigation eller flera huvudflöden.
5. Om analyze eller test fallerar: stoppa, förklara felet och fixa det innan arbetet betraktas som klart.
6. Om ändringen rör question generation, grade balancing eller audit-toleranser: kör även `.github/skills/testa-fragornas-svarighetsgrad/SKILL.md` som extra grind i stället för att nöja dig med generell QA.
7. Om Now-status eller användarvägar ändrats: påminn om `SESSION_BRIEF` / relevante START_HERE / TRACE_MAP i samma slice.