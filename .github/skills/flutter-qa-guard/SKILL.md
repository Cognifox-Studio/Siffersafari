---
name: flutter-qa-guard
description: 'Run focused Flutter QA for this repo. Use when validating analyze, widget tests, integration tests, screenshot regression, Pixel_6 sync/install, asset integration, or when the user asks verify, testa, QA, regression, or analyze after code or asset changes.'
argument-hint: 'Describe what changed and whether validation should be targeted or full.'
---

# Flutter QA Guard

## När den ska användas
- Efter kodändringar som påverkar quizflöde, providers, onboarding, parent mode eller assets.
- Efter integration av nya animationer eller asset-paths.
- Inför demo, merge eller release.

## Mål
Köra minsta tillräckliga validering snabbt, och bara eskalera till full QA när ändringen motiverar det.

## Standardordning
1. Välj smalast rimliga kontroll först.
   - bara statisk kontroll: `QA: Analyze`
   - riktad testfil: `QA: Test (valfri path)`
   - större ändring: `QA: Analyze + Full Test (stora ändringar)`
2. Om ändringen berör Android/device/assets i verklig körning:
   - `Flutter: Sync (Pixel_6 only)` eller install/run-flöde
3. Om UI-regression misstänks:
   - använd integration screenshots hellre än emulator-dump
4. Sammanfatta pass/fail, relevanta fel och eventuella kvarstående risker.

## Repo-specifika risker att tänka på
- `flutter_screenutil` i widgettester kräver stabil test-window-setup.
- Undvik blind `pumpAndSettle()` på vyer med kontinuerliga animationer.
- Parent PIN och recovery-flöden kräver mer precisa finders i dialoger.
- Screenshot-regression ska i första hand använda repo:ts integrationstestflöde.

## Kvalitetsgränser
- Kör inte full testsvit slentrianmässigt om en riktad validering räcker.
- Fixa inte orelaterade testproblem i samma steg utan tydlig anledning.
- Rapportera när något inte kunnat verifieras, särskilt device-specifika delar.