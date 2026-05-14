# Night Cleanup Audit

Datum: 2026-05-11
Scope: Strategiskt över alla filer och dokument över hela repot
Läge: Read-only audit
Status: Inga patchar skapade. Allt är fortfarande ocommittat.

## Metod

- Läste nulägesfacit i `docs/SESSION_BRIEF.md`, `docs/ARCHITECTURE.md` och `docs/PROJECT_STRUCTURE.md`.
- Läste repo-regler i `.github/copilot-instructions.md`, `.github/instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md` och `.github/agents/plan.agent.md`.
- Inventerade sedan strategiskt över `.github`, `docs`, `lib`, `test`, `scripts`, `site`, workflows och `artifacts` med fokus på stale referenser, orphan-spår, saknade filer och riskig legacy-logik.

## Lag risk

### 1. Stale `WardrobeDialog`-referenser i docs och customization
- Filer:
  - `docs/SESSION_BRIEF.md`
  - `.github/instructions/regler-for-z-index-inventory.instructions.md`
- Signal:
  - `docs/SESSION_BRIEF.md` nämner fortfarande `WardrobeDialog` i garderobsflödet.
  - `.github/instructions/regler-for-z-index-inventory.instructions.md` har fortfarande `lib/features/inventory/presentation/widgets/wardrobe_dialog.dart` i `applyTo` och säger att logiken i `WardrobeDialog` ska styra inventory-beteende.
  - Aktiv kod pekar nu på `lib/features/inventory/presentation/screens/wardrobe_screen.dart`, och `lib/features/home/presentation/widgets/camp_scene_view.dart` importerar just `wardrobe_screen.dart`.
- Bedömning:
  - Hög signal, låg risk. Detta ser ut som ren docs/customization-städning efter att dialogspåret pensionerats.
- Billigaste verifiering:
  - Sök efter `WardrobeDialog` efter ändring och verifiera att instruktionen i stället pekar på `wardrobe_screen.dart` eller neutral inventory-logik.

### 2. Stale strukturpåstående om inventory-feature i `PROJECT_STRUCTURE.md`
- Filer:
  - `docs/PROJECT_STRUCTURE.md`
- Signal:
  - Dokumentet säger att `inventory/` saknar aktiv widgetfil i workspace.
  - Faktisk kod innehåller `lib/features/inventory/presentation/screens/wardrobe_screen.dart`.
- Bedömning:
  - Hög signal, låg risk. Dokumentationen är snävare än verkligheten och bör uppdateras till faktisk struktur.
- Billigaste verifiering:
  - Läs om inventory-delen i `docs/PROJECT_STRUCTURE.md` och bekräfta att den pekar på den verkliga skärmen i `lib/features/inventory/presentation/screens/wardrobe_screen.dart`.

### 3. Stale offline-audit-undantag för icke-existerande `AppUpdateService`
- Filer:
  - `test/unit/audits/offline_only_audit_test.dart`
- Signal:
  - Testet har `allowedViolations` för `lib/core/services/app_update_service.dart`.
  - Ingen fil som matchar `*app_update*` hittades i repo:t.
  - `test/unit/audits/naming_structure_audit_test.dart` markerar `AppUpdateService.installUpdate(` som pensionerat mönster.
- Bedömning:
  - Hög signal, låg till medel risk. Ser ut som stale testkommentar och allowlist efter att autoupdate-spåret togs bort.
- Billigaste verifiering:
  - Kör exakt `test/unit/audits/offline_only_audit_test.dart` efter att allowlisten/commenten rensats eller uppdaterats.

### 4. Root-filen `test_output.txt` ser ut som genererad logg, inte källmaterial
- Filer:
  - `test_output.txt`
- Signal:
  - Filen ligger i repo-roten, läses som rå UTF-16-liknande loggdata och gav ingen aktiv usage-signal i repo-sökningarna.
  - Den liknar ett exporterat terminal-/testutskriftsspår snarare än underhållen dokumentation eller testfixture.
- Bedömning:
  - Trolig låg-risk-kandidat, men kräver en sista mänsklig snabbkoll att den inte används i något manuellt arbetsflöde.
- Billigaste verifiering:
  - Bekräfta att ingen docs- eller scriptreferens finns och ta sedan bort filen i en isolerad patch.

## Krav pa beslut

### 5. CI-workflow refererar till saknad `tools/pipeline.py`
- Filer:
  - `.github/workflows/ci.yaml`
  - `docs/SESSION_BRIEF.md`
- Signal:
  - `ci.yaml` kör `python tools/pipeline.py lint-assets --strict --report-path artifacts/asset_lint_report.json`.
  - `tools/` saknas i workspace.
  - `docs/SESSION_BRIEF.md` nämner historiskt att `tools/pipeline.py` rensades bort vid Lottie/Rive-saneringen.
- Bedömning:
  - Hög signal, men inte låg risk. Antingen är CI i praktiken bruten, eller så är workflown stale och måste ersättas/rensas. Detta korsar workflow, docs och potentiellt asset-policy.
- Billigaste verifiering:
  - Verifiera om nuvarande CI-run faktiskt använder ett externt eller saknat scriptspår. Om inte: välj mellan att återinföra motsvarande lintverktyg eller pensionera `asset-lint`-jobbet och dess docsreferenser.

### 6. `lib/wardrobe_preview.dart` är en aktiv sandbox-fil men inte del av produktflödet
- Filer:
  - `lib/wardrobe_preview.dart`
  - `docs/PROJECT_STRUCTURE.md`
  - `site/project-map/graph-data.js`
- Signal:
  - Filen är en fristående `main()`-entrypoint för lokal preview av `GameCharacter`.
  - Inga aktiva importer hittades; referenserna finns i docs och genererad project-map-data.
- Bedömning:
  - Beslutskandidat, inte auto-delete. Den kan vara nyttig som lokal verktygsyta, men dess placering i `lib/` gör den lätt att missta för produktkod.
- Billigaste verifiering:
  - Besluta om teamet fortfarande använder den. Om ja: behåll och dokumentera den tydligare som dev-sandbox. Om nej: pensionera den i separat patch.

### 7. `artifacts/`-policyn och repo-innehållet driver isär
- Filer:
  - `scripts/verify_git_changes.ps1`
  - `artifacts/**`
  - `.github/skills/skapa-bildbestallning/SKILL.md`
- Signal:
  - `scripts/verify_git_changes.ps1` varnar att `artifacts/` inte ska committas, med undantag för `artifacts/asset_pipeline_manifest.json`.
  - Samtidigt innehåller repo:t ett stort antal committade filer under `artifacts/` och skill-dokument beskriver `artifacts/` som visuell referens.
- Bedömning:
  - Kräver policybeslut. Antingen ska `artifacts/` vara lokalt previewmaterial, eller så ska vissa curated undermappar uttryckligen vara tillåtna i repo och scriptet justeras.
- Billigaste verifiering:
  - Besluta vilka artifact-typer som faktiskt ska versionshanteras och synka sedan script, docs och arbetsflöden efter det beslutet.

## Ror ej automatiskt

### 8. Legacy-rensning i quiz-provider är fortfarande aktiv och testskyddad
- Filer:
  - `lib/core/providers/quiz_provider.dart`
  - `test/unit/logic/quiz_progression_edge_cases_test.dart`
- Signal:
  - `quiz_provider.dart` rensar legacy in-progress entries uttryckligen.
  - `quiz_progression_edge_cases_test.dart` seedar och verifierar purge av `legacy_inprogress`.
- Bedömning:
  - Rör inte automatiskt. Detta är bakåtkompatibilitet och offline-first-persistens med aktiv testtäckning.

### 9. Legacy-stöd i `UserProgressAdapter` är fortfarande avsiktligt
- Filer:
  - `test/unit/logic/user_progress_adapter_test.dart`
- Signal:
  - Testet verifierar läsning av äldre profiler utan nyare fält med defaultvärden.
- Bedömning:
  - Rör inte automatiskt. Detta är tydligt bakåtkompatibilitetsspår för sparad användardata.

### 10. Legacy-ikonspåret i Android-launcher-generatorn ser avsiktligt ut
- Filer:
  - `scripts/generate_android_launcher_icons.dart`
- Signal:
  - Scriptet genererar uttryckligen legacy icons som fallback/pre-26-stöd.
- Bedömning:
  - Rör inte automatiskt utan Android/release-beslut. Ordet `legacy` här signalerar kompatibilitet, inte död kod.

## Rekommenderad ordning

1. Rensa stale `WardrobeDialog`-referenser i docs och customization.
2. Rätta inventory-beskrivningen i `docs/PROJECT_STRUCTURE.md`.
3. Rensa eller uppdatera stale allowlist för `AppUpdateService` i offline-auditen.
4. Gör en liten manuell kontroll av `test_output.txt`; radera om den inte fyller någon faktisk funktion.
5. Ta ett separat beslut om CI:s `tools/pipeline.py`-spår.
6. Ta därefter beslut om `lib/wardrobe_preview.dart` och artifact-policyn.

## Morgonsammanfattning

- Lag risk hittad: 4 kandidater
- Krav pa beslut: 3 kandidater
- Ror ej automatiskt: 3 kandidater
- Inga patchar skapades
- Inga commits gjordes
- Allt är fortfarande ocommittat
