---
name: dubbelkolla-andrad-kod
description: 'Classify the current diff and run the smallest sufficient pre-commit verification. Use when checking changes before commit, staged files, QA scope or mixed docs/code diffs.'
argument-hint: 'Beskriv vilka filer eller vilket commit-scope som ska verifieras.'
---

# Dubbelkolla ändrad kod

Denna skill används för att kvalitetssäkra ändringar innan commit. Den ska klassificera diffen först och sedan köra minsta tillräckliga kontroll utan slentrian.

## Klassificera diffen först

### 1. Docs-only
Typiska pathar:
- `docs/**`
- `README.md`
- andra rena markdownfiler utan exekverbar kod eller config

Kontroller:
1. Verifiera att namnda filer, scripts och interna lankar faktiskt finns.
2. Om docs beskriver struktur, services eller workflow: kor drift-kontroll mot `docs/ARCHITECTURE.md`, `docs/SERVICES_API.md` och `docs/SESSION_BRIEF.md`.
3. Hoppa over `flutter analyze` om diffen verkligen ar docs-only.

### 2. Dart-logik
Typiska pathar:
- `lib/**`
- `test/**`
- `pubspec.yaml`

Kontroller:
1. `QA: Analyze`
2. Riktade tester for den agande logiken
3. Full testsvit bara om ändringen rör delad, högrisk logik eller flera huvudflöden
4. Kor `scripts/verify_git_changes.ps1` om commiten blandar flera kodpathar

### 3. Parent mode
Typiska pathar:
- `lib/features/parent/**`
- PIN-, recovery- eller parent settings-floden

Kontroller:
1. `QA: Analyze`
2. Fokuserade tester for parent mode eller relevanta integrationstest
3. Kor pre-commit-skriptet om andringen korsar quiz-, settings- eller exportfloden

### 4. Android eller release
Typiska pathar:
- `android/**`
- `.github/workflows/**`
- `pubspec.yaml` nar release- eller runtime-beroenden andras

Kontroller:
1. Kor relevanta Android- eller release-specifika checks, inte bara standardtesterna
2. `QA: Analyze` om Dart eller runtime berors
3. Knyt vid behov in release-readiness eller build-validering innan commit
4. Kor pre-commit-skriptet om kod och releasefiler andras tillsammans

### 5. Assets
Typiska pathar:
- `assets/**`
- `artifacts/**`
- asset-generatorer under `scripts/`

Kontroller:
1. Kor relevant asset-generator eller asset-workflow
2. `QA: Analyze` om appen konsumerar asseten i Dart-kod
3. Kor fokuserad widget-, integration- eller Pixel_6-verifiering for den vy som anvander asseten
4. Kor pre-commit-skriptet om assetandringen ocksa paverkar runtime-kod

## Arbetsflöde
1. Titta på den faktiska diffen eller det som ska committas och välj högsta riskkategori som matchar.
2. Kör kategorins minsta tillräckliga kontroller.
3. Kör `scripts/verify_git_changes.ps1` när diffen inte är docs-only och när skriptet tillför signal.
4. Commita inte förrän pass eller fail och eventuella kvarstående risker är tydliga.

## Regler
- Om diffen är blandad: välj den högsta riskkategorin i stället för att behandla allt som docs-only.
- Kör inte full testsvit slentrianmässigt om riktad QA ger samma signal.
- Om docs, kod och workflow har drivit isär i samma diff: fixa det innan commit i stället för att lämna det till senare.