# Copilot-instruktioner (Siffersafari)

## Projektet

Siffersafari är ett Flutter-baserat mattespel för barn. Appen är Android-first, offline-first och byggd för ett enkelt barnflöde: profilval -> quiz -> resultat -> story map.

## Start här

Läs dessa källor i den här ordningen när uppgiften kräver mer kontext:

0. `docs/DEV_SYSTEM.md` — hur vi jobbar (Now/DoD/AI-loop). `docs/DEFINITION_OF_DONE.md` innan “klart”/commit.
1. `docs/SESSION_BRIEF.md` vid start, vid "fortsätt" och när du behöver **Now**.
2. `.github/AGENTS.md` när du behöver snabb routing till rätt agent, skill eller prompt.
3. Matchande filinstruktion under `.github/instructions/` när filytan är känd.
4. Relevant repo-skill under `.github/skills/` först när arbetsflödet redan matchar en etablerad slice.
5. `docs/README.md` som index till övrig dokumentation.
6. `docs/ARCHITECTURE.md` för faktisk arkitektur, startup och aktiva runtime-val.
7. `docs/DECISIONS_LOG.md` när äldre beslut eller avvägningar påverkar lösningen.
8. `docs/PROJECT_STRUCTURE.md` och `docs/SERVICES_API.md` när struktur eller servicekontrakt berörs.

Länka hellre till dessa dokument än att duplicera innehåll i nya customizations.

## Alltid på

- **Nulägesfacit först:** `docs/ARCHITECTURE.md`, `docs/DECISIONS_LOG.md` och `docs/SESSION_BRIEF.md` väger högre än äldre artefakter och historiska spår.
- **COPPA gäller alltid:** ingen persondata, inga trackers, inga annons-SDK:er och inga onlinekrav i huvudupplevelsen. Läs `docs/PRIVACY_POLICY.md` och `/memories/repo/coppa_compliance_2026-03-04.md` före ändringar som rör analytics, nätverk, export eller användardata.
- **Feature-first UI:** ny featureägd UI ligger under `lib/features/<feature>/presentation/`. `lib/presentation/widgets/` är endast för verkligt delad UI.
- **PNG-first mascot-runtime:** produkt-UI använder Loke som PNG med Flutter-styrda proceduranimationer. Rive och `.riv` är researchspår, inte aktiv runtime. Lottie används bara för fristående UI-effekter.
- **Offline-first persistens:** Hive via repository-lagret. Session-state som byggs upp under quiz måste mergas tillbaka till permanent användarprofil vid avslut.
- **Link, don't embed:** håll customizations korta och repo-specifika. Peka vidare till docs, minnen och smalare instruktioner i stället för att samla allt här.

## Arbetsflöde

1. Läs `docs/SESSION_BRIEF.md` (Now). Om Now saknas eller slice är icke-trivial: kör `.github/prompts/slice-start.prompt.md` / `Plan` och **vänta på godkännande** innan kod.
2. Hitta ägande kodväg och välj billigaste möjliga verifiering (DoD + QA-slice).
3. När filytan är känd: följ matchande `.github/instructions/` före bredare scanning.
4. Använd repo-skills först när problemet redan matchar ett etablerat arbetsflöde; om scopet är oklart, börja med `.github/AGENTS.md`, `slice-start`, eller agenten `Plan`.
5. En avsikt per commit-grupp. Blanda inte refaktor + feature + mattebank + `.github` utan uttrycklig orsak.
6. Före commit: `docs/DEFINITION_OF_DONE.md` (A) + `.github/skills/testa-innan-vi-sparar/SKILL.md`.
7. Uppdatera `docs/DECISIONS_LOG.md` eller `docs/SESSION_BRIEF.md` när verkligheten (särskilt Now) faktiskt har ändrats.
8. Vid `.github`-arbete: uppdatera befintliga customizations före att skapa nya centrala filer.
9. Utmana planen: flagga luckor, COPPA-risk och för stort scope — utför inte blint.

## QA

Standardkommandon:

```sh
flutter pub get
flutter analyze
flutter test
flutter test <path>
flutter test integration_test/app_smoke_test.dart --dart-define=FULL_SMOKE=false
powershell -ExecutionPolicy Bypass -File scripts/verify_git_changes.ps1
```

Pixel_6-flödet används när ändringen berör rendering, navigation, assets eller annat device-specifikt:

- `scripts/flutter_pixel6.ps1 -Action run`
- `scripts/flutter_pixel6.ps1 -Action install`
- `scripts/flutter_pixel6.ps1 -Action sync`

Arbetsstandard:

1. Kör smalast möjliga verifiering först.
2. Kör `flutter analyze` före commit och efter större kodändringar.
3. Kör fokuserade tester för berörd yta; eskalera till full testsvit bara när riskytan kräver det.
4. Kör Pixel_6 sync/install när ändringen är UI-, asset-, navigation- eller Android-specifik.
5. Lämna inte nya analyze- eller testfel efter dig.
6. Vid web- eller browser-bunden validering: dela den öppna sidan med agenten i VS Code Integrated Browser när browser tools finns tillgängliga.

## Routing

- Börja med `.github/AGENTS.md`, en relevant prompt eller agenten `Plan` om scopet fortfarande är oklart efter första läsningen.
- Använd repo-skills under `.github/skills/` i stället för att improvisera när uppgiften redan matchar ett etablerat arbetsflöde, särskilt för QA, quiz-persistens, docs, analytics, release, Android-emulator, formulär, assets och `.github`-audits.
- Ladda inte en skill bara för att samla generell kontext; skills är smala workflow-ytor när problemtypen redan är identifierad.
- För konkret agent-, prompt- och skill-routing: läs `.github/AGENTS.md`.
- Följ matchande filer under `.github/instructions/` när en viss arbetsyta berörs, i stället för att duplicera de reglerna här.
- Använd `.github/prompts/` och `.github/hooks/` som stödyta vid customization-arbete, inte som ersättning för repo-dokumentation.

## Repo-fallgropar

- Pixel_6 kan fastna offline i adb. Prioritera cold boot utan snapshot: `emulator.exe -avd Pixel_6 -no-snapshot-load`.
- Stale APK efter rebuild löses ofta med `scripts/flutter_pixel6.ps1 -Action install` eller `-Action sync`.
- Historiska docs och artifacts kan vara stale. Kontrollera alltid mot `docs/ARCHITECTURE.md` och aktuell kod.
- Garderob och inventory bygger pa fri mix via Z-index, inte harda slot-begransningar. Las `.github/instructions/regler-for-z-index-inventory.instructions.md` innan du andrar `GameCharacter`, `WardrobeScreen` eller `InventoryItem`.
- Legacy-spår för mascot i docs, artifacts eller äldre customizations kan fortfarande nämna SVG/Rive. Följ alltid PNG-first-regeln ovan.
- Vid progression- eller difficulty-ändringar: verifiera att session-state mergas tillbaka till `UserProgress` när quizet avslutas.
- Vid parsningslogik/formatering (t.ex. SRS-nycklar): packa data med formatversion (t.ex. `v2|`) stället för regex-gissningar på varierande display-text.

## Sessionskontinuitet

Använd dessa filer som extern kontext i stället för att förlita dig på chatthistorik:

- `docs/SESSION_BRIEF.md` för aktuellt läge och nästa steg
- `docs/DECISIONS_LOG.md` för beslut som ska leva kvar

Standardrutin:

1. Läs `docs/SESSION_BRIEF.md` vid start och när användaren säger "fortsätt".
2. Läs `docs/DECISIONS_LOG.md` när beslutshistorik påverkar arbetet.
3. Uppdatera dem bara när ändringen faktiskt påverkar nuläge eller beslut.
