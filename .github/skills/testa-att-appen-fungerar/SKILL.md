---
name: testa-att-appen-fungerar
description: 'Run focused Flutter QA for this repo. Use when validating analyze, widget tests, integration tests, screenshot regression, Pixel_6 sync/install, asset integration, or when the user asks verify, testa, QA, regression or analyze after code or asset changes.'
argument-hint: 'Beskriv vad som ändrats, vilken kodväg som äger beteendet och om QA ska vara riktad eller bred.'
---

# Testa att appen fungerar

## När den ska användas
- Efter kodändringar som påverkar quizflöde, providers, onboarding, parent mode eller assets.
- Efter integration av nya animationer eller asset-paths.
- Inför demo, merge eller release.

## Mål
Kör minsta tillräckliga validering snabbt, och eskalera bara till full QA när ändringen motiverar det.

## Klassificera andringen forst

### 1. Provider-, domain-, service- eller repository-logik
Typiska pathar:
- `lib/core/providers/**`
- `lib/core/services/**`
- `lib/domain/**`
- `lib/data/**`

Kora i denna ordning:
1. `QA: Analyze`
2. Smalast mojliga unit-test eller riktad testfil under `test/unit/**`
3. Eskalera till widgettest bara om anvandarsynligt kontrakt eller skarmflode faktiskt andras

### 2. Widget- eller presentationskod
Typiska pathar:
- `lib/features/**/presentation/**`
- `lib/presentation/**`

Kora i denna ordning:
1. `QA: Analyze`
2. Fokuserat widgettest
3. Eskalera till integration nar andringen beror navigation, teardown, animation, ljud, haptics eller state-handoff mellan skarmar

### 3. Integration eller floden over flera skarmar
Typiska signaler:
- navigation genom profilval -> home -> quiz -> resultat -> story
- parent mode
- startup eller lifecycle

Kora i denna ordning:
1. `QA: Analyze`
2. Relevanta integrationstest eller smoke-test
3. Full testsvit bara om andringen ror delad app-shell, startup eller flera huvudfloden samtidigt

### 4. Pixel_6 eller annan device-specifik verifiering
Anvand nar andringen paverkar:
- rendering pa riktig enhet
- navigation eller install/sync-beteende
- assets, animationer, ljud eller haptics

Kora i denna ordning:
1. Valj smalast relevanta kodtest forst
2. `Flutter: Sync (Pixel_6 only)` nar en riktig enhet behovs
3. `Flutter: Install (Pixel_6 only)` eller run-flode bara nar sync inte racker

### 5. Assets eller animation
Anvand nar andringen ror:
- `assets/**`
- generatorer under `scripts/`
- widgetar som konsumerar SVG, ljud eller andra runtime-assets

Kora i denna ordning:
1. Kor relevant asset-generator eller asset-workflow om andringen kraver det
2. `QA: Analyze`
3. Fokuserat widget- eller integrationstest kring den vy som konsumerar asseten
4. Pixel_6 sync om visuellt eller device-specifikt beteende ar viktigt

## Standardordning inom vald gren
1. Valj smalast rimliga kontroll forst.
   - bara statisk kontroll: `QA: Analyze`
   - riktad testfil: `QA: Test (valfri path)`
   - storre andring: `QA: Analyze + Full Test (stora andringar)`
2. Om UI-regression misstanks:
   - anvand integration screenshots hellre an emulator-dump
3. Sammanfatta pass eller fail, relevanta fel och eventuella kvarstaende risker.

## Repo-specifika risker att tanka pa
- `flutter_screenutil` i widgettester kraver stabil test-window-setup.
- Undvik blind `pumpAndSettle()` pa vyer med kontinuerliga animationer.
- Parent PIN och recovery-floden kraver mer precisa finders i dialoger.
- Screenshot-regression ska i forsta hand anvanda repo:ts integrationstestflode.

## Kvalitetsgranser
- Kor inte full testsvit slentrianmassigt om en riktad validering racker.
- Om flera kategorier matchar: folj den hogsta risknivan, inte alla grenar slaviskt.
- Fixa inte orelaterade testproblem i samma steg utan tydlig anledning.
- Rapportera nar nagot inte kunnat verifieras, sarskilt device-specifika delar.