---
description: "Run pre-commit checks to verify code formatting, analysis, and tests"
applyTo: "**/*.dart, pubspec.yaml"
---

# Verify Git Changes (Pre-commit)

Denna skill används för att kvalitetssäkra ändringar innan commit. Den säkerställer att koden formateras korrekt, undviker linterfel och inte bryter befintliga tester.

## Arbetsflöde

Innan du utför en `git commit` för en kodändring, bör du alltid följa dessa steg för att förhindra regressioner och lint-fel:

1. **Analysera koden**: 
   Kör `QA: Analyze` (antingen via Task eller manuellt: `flutter analyze`). Om det finns problem (Problems-listan i VS Code), åtgärda dessa först.
2. **Pre-commit skript**:
   Kör PowerShell-skriptet `scripts/verify_git_changes.ps1` för att validera ändringar. Skriptet fungerar som ett lokalt QA-lås och analyserar git status och relevanta tester.
3. **Tester**:
   Gäller ändringen kritisk logik (ex. state management, utils, domain)? Kör en fullständig testrunda (`QA: Test (alla)` eller `flutter test`). Gäller det specifika filer, kör testerna för de specifika filerna.

Vid mindre text-, asset-, eller dokumentationsförändringar kan fullständig testrunda ibland hoppas över, men `analyze` och formatteringskontroller skall alltid gå igenom rena.