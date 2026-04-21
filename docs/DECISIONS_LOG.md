# Beslut och antaganden (Siffersafari)

Syfte: samla stabila beslut utanfor chatten.
Princip: senaste datum vinner vid konflikt.

## Gallande nulage (2026-03-18)

- Plattform: Android-first, offline-first, flera barnprofiler.
- Arkitektur: lagerindelad Flutter-app med Riverpod + GetIt + Hive.
- Animation:
  - SVG-first for mascot-runtime i produkt-UI
  - Lottie for UI-effekter
  - `.riv`-filer, blueprint-guider och karaktarsmappar under `assets/characters/*/rive/` ar fortsatt tillatna som framtida enhancement-spor, men de styr inte nuvarande mascot-runtime
- Responsiv layout styrs av tillganglig bredd (`compact < 600`, `medium >= 600`, `expanded >= 840`).
- Quizens adaptiva svarighetsmodell ar hybrid (micro + macro + cooldown) och persisteras per raknesatt.
- Uppdateringsflode i foraldralage anvander GitHub Releases + OTA pa Android, utan avinstallation.

## Historik (kort)

### 2026-03-03
- Extern kontext via dokument i `docs/` i stallet for chat-historik.
- Standard QA-flode: analyze -> relevanta tester -> full suite vid storre andringar.
- Pixel_6-script anvands for deterministisk lokal korning vid behov.

### 2026-03-04
- Mix-audits och curriculum-gates kalibrerades for att undvika for tidiga svarighetshopp.
- Textuppgifter sparas per barnprofil och styrs av onboarding/installing.

### 2026-03-06
- Story progression och quest-reveal kopplades till faktisk quest completion.
- Storykarta utokad till 20 checkpoints med etappvis visualisering.
- Parent update-check + in-app update etablerad i dashboard.

### 2026-03-09
- Adaptiv svarighetsmodell hardenades till hybrid-regler med cooldown.
- Tidigare Lottie-only-spor finns i historiken, men ersattes av senare hybridbeslut.

### 2026-03-10
- Hybrid animation faststalldes som gallande riktning.
- Bilddriven karaktarsprocess etablerades (assetkit + spec + Rive-guide).
- Loke introducerades som forsta verifierade karaktar i detta arbetsflode.

### 2026-03-18
- Mascot-runtime forenklades till en tydlig SVG-first-modell: `GameCharacter` och `MascotReactionView.withState` anvander nu alltid composite-SVG + Flutter-animationer i produkt-UI.
- Oanvand theme/runtime-konfiguration for Rive togs bort for att minska parallella sanningar mellan kod och dokumentation.
- Optional Rive-material ligger kvar i repo:t som ett separat framtidsspor, inte som aktiv fallback i nuvarande app.

### 2026-03-13
- Nuvarande `assets/characters/mascot/rive/mascot_character.riv` verifierades pa emulator som placeholder/demo-export (`Template-NoRig`, inga state machines).
- Detta dokumenteras nu som historisk verifiering av asset-innehall, inte som gallande runtime-arkitektur.

### 2026-03-11
- Humanoid-standard faststalld: nya humanoid-karaktarer ska utga fran `assets/characters/_shared/config/humanoid_base_form_v1.json` via `baseFormRef` i respektive visual spec.
- Humanoid-standard utokad: den gemensamma riggmodellen ska nu stotta pelvis, shoulders, wrists, hips, ankles och toes som standard, med fallback-bindning till samma bilddel nar separata assets saknas.

### 2026-03-12
- Aterkommande Copilot-arbetsfloden for assetproduktion och kvalitetskontroll ska i forsta hand paketeras som workspace-skills under `.github/skills/` i stallet for att bara beskrivas i fri text.
- For detta repo ar foljande skills etablerade som basuppsattning: `game-character-pipeline`, `animation-preview-lab`, `asset-generation-runner`, `flutter-qa-guard`, `release-readiness-check`.
- Preview-strukturen for humanoid-animationer ska anvanda en tydlig labbkedja: `reference_preview` -> `still_preview` -> `motion_lab` -> `clean_preview` -> `scene_preview`, och canonical previews ska markeras i den centrala preview-hubben under `artifacts/animation_preview/`.

## Relaterade dokument

- `docs/ARCHITECTURE.md` (systemets faktiska nulage)
- `docs/PROJECT_STRUCTURE.md` (faktisk filstruktur)
- `docs/SERVICES_API.md` (aktuella servicekontrakt)
- `docs/SESSION_BRIEF.md` (detaljerad sessionshistorik)
