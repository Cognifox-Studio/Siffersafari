# Copilot-instruktioner (Siffersafari)

## Projektet

Siffersafari är ett Flutter-baserat mattespel för barn. Appen är Android-first och offline-first.

Primärt flöde: profilval → quiz → resultat → story map.

Läs först dessa dokument vid behov, och länka hellre dit än att duplicera innehåll:

- `docs/README.md` för dokumentationsindex
- `docs/ARCHITECTURE.md` för faktisk arkitektur och startup
- `docs/PROJECT_STRUCTURE.md` för repo-struktur
- `docs/SERVICES_API.md` för service- och providerkontrakt
- `docs/DECISIONS_LOG.md` för stabila beslut

## Bygg och QA

Standardkommandon:

```sh
flutter pub get
flutter analyze
flutter test
flutter test <path>
```

Använd Pixel_6-flödet för emulatorarbete:

- `scripts/flutter_pixel6.ps1 -Action run`
- `scripts/flutter_pixel6.ps1 -Action install`
- `scripts/flutter_pixel6.ps1 -Action sync`

Arbetsstandard:

1. Kör `flutter analyze` före commit.
2. Kör relevant testsvit för ändringen. Kör full testsvit vid större ändringar.
3. Kör Pixel_6 sync/install när ändringen påverkar navigation, rendering, assets eller device-specifikt beteende.

Om repo-skillen matchar, använd den i stället för att improvisera arbetsflödet:

- `.github/skills/flutter-qa-guard/SKILL.md`
- `.github/skills/asset-generation-runner/SKILL.md`
- `.github/skills/release-readiness-check/SKILL.md`

## Automation-floden (skills)

Använd skill-floden när uppgiften matchar signalorden nedan.

- QA och verifiering: `.github/skills/flutter-qa-guard/SKILL.md`
	- Signalord: `verify`, `testa`, `QA`, `regression`, `analyze`
- Asset-generering: `.github/skills/asset-generation-runner/SKILL.md`
	- Signalord: `generate assets`, `regenerera assets`, `uppdatera animation assets`, `sync generated files`
- Karaktärspipeline: `.github/skills/game-character-pipeline/SKILL.md`
	- Signalord: `spelklar karaktär`, `användbar karaktär`, `character pipeline`, `Gör en användbar karaktär av denna`
- Animation preview-lab: `.github/skills/animation-preview-lab/SKILL.md`
	- Signalord: `idle`, `walk`, `pivot`, `wave`, `T-pose`, `motion-lab`, `clean preview`
- Release readiness: `.github/skills/release-readiness-check/SKILL.md`
	- Signalord: `release check`, `readiness`, `ship`, `preflight`, `final QA`
- Dokumentationspass: `.github/skills/documentation/SKILL.md`
	- Signalord: `dokumentera`, `uppdatera docs`, `documentation audit`, `synka docs med kod`

## Arkitektur

UI-lagret är hybrid under övergång till feature-first struktur:

- `lib/app/` för bootstrap och routing
- `lib/features/` för featureägda skärmar, dialoger och widgets
- `lib/presentation/` för kvarvarande legacy-UI
- `lib/core/` för DI, providers, services, tema och utilities
- `lib/domain/` för Flutter-fri domänlogik
- `lib/data/` för lokal persistens via Hive

Teknikval som gäller repo-brett:

- State: Riverpod
- DI: GetIt
- Persistens: Hive
- Layout: `AdaptiveLayoutInfo` med breakpoints compact `<600`, medium `>=600`, expanded `>=840`

Detaljer finns i `docs/ARCHITECTURE.md` och `docs/PROJECT_STRUCTURE.md`.

## Repo-specifika regler

- Mascot-runtime i produkt-UI är SVG-first. Rive-blueprints och `.riv`-material i `artifacts/` är inte en aktiv runtime-dependency i huvudflödet.
- `.riv`-filer exporteras manuellt från Rive Editor. Script och blueprints genererar inte den slutliga `.riv`-filen automatiskt.
- Lottie används för UI-effekter, inte som fallback för mascot-runtime.
- Nya humanoid-karaktärer ska referera `assets/characters/_shared/config/humanoid_base_form_v1.json` via `baseFormRef`.
- `SpacedRepetitionService` finns implementerad men är inte fullt inkopplad i hela quiz-flödet. Anta inte att den används överallt.
- Vid progression- eller difficulty-ändringar: verifiera att session-state mergas tillbaka till persistent user state vid quiz-slut.

## Områdesspecifika instruktioner

Följ dessa filer när uppgiften berör respektive område:

- `.github/instructions/features.instructions.md` för `lib/features/**`
- `.github/instructions/presentation.instructions.md` för `lib/presentation/**`
- `.github/instructions/test.instructions.md` för `test/**`
- `.github/instructions/character-pipeline.instructions.md` när en bild ska bli en spelklar karaktär

## Vanliga fallgropar

- Pixel_6-emulatorn kan fastna offline i adb. Använd cold boot utan snapshot: `emulator.exe -avd Pixel_6 -no-snapshot-load`.
- Stale APK på device efter rebuild löses ofta med explicit install via `flutter_pixel6.ps1 -Action install`.
- Historiska dokument och artifacts kan beskriva gamla spår. Behandla `docs/ARCHITECTURE.md` som nulägesfacit före äldre guider.

## Sessionskontinuitet

Använd dessa filer som extern kontext i stället för att förlita dig på chatthistorik:

- `docs/SESSION_BRIEF.md` för aktuellt läge och nästa steg
- `docs/DECISIONS_LOG.md` för beslut som ska leva kvar

Standardrutin:

1. Läs `docs/SESSION_BRIEF.md` vid start och när användaren säger "fortsätt".
2. Läs `docs/DECISIONS_LOG.md` vid komplexa uppgifter eller när äldre beslut påverkar arbetet.
3. Uppdatera dessa filer när uppgiften uttryckligen handlar om sessionslogg eller beslut.
