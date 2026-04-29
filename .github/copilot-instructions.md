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

## Agentprinciper

- **Länka hellre än duplicera.** Kopiera inte in text från `docs/` hit. Länka dit.
- **Nulägesfacit:** `docs/ARCHITECTURE.md` och `docs/DECISIONS_LOG.md` gäller över äldre historik.
- **Sessionskontext:** Läs alltid `docs/SESSION_BRIEF.md` vid start eller "fortsätt".
- **Lärdomar:** Läs repo-minnen i `/memories/repo/` för kända fallgropar. Uppdatera minnet när ny insikt nås.

## Innan du kodar
1. COPPA-compliance: offline-first, ingen persondata. Se `docs/PRIVACY_POLICY.md`.
2. UI-arkitektur: Ny UI under `lib/features/<feature>/presentation/`. Delad UI i `lib/presentation/widgets/`.
3. QA & Test: Bestäm snävaste rimliga QA. Analysera innan test.
4. Beslut: Uppdatera `docs/DECISIONS_LOG.md` om du ändrat kodens strukturella riktning.

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
4. **Alla tester ska passera före commit vid stora ändringar.** Vid fel, fixa grundorsaken och verifiera med `flutter test` innan commit.

Om repo-skillen matchar, använd den i stället för att improvisera arbetsflödet:

- `.github/skills/flutter-qa-guard/SKILL.md`
- `.github/skills/asset-generation-runner/SKILL.md`
- `.github/skills/release-readiness-check/SKILL.md`

## Custom Agents

- **Plan** (`.github/agents/plan.agent.md`): Research, analys, riskbedömning och testplan (körs utan kodändringar).
- **Beast Mode** (`.github/agents/beastmode.agent.md`): Självgående implementation, feltestning, QA-pass och systematiska kodrättelser.

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

UI-lagret är feature-first. Migrationen från `presentation/screens` och `presentation/dialogs` är klar:

- `lib/app/` för bootstrap och routing
- `lib/features/` för alla featureägda skärmar, dialoger och widgets
- `lib/presentation/screens/` och `lib/presentation/dialogs/` är tomma
- `lib/presentation/widgets/` för delade UI-komponenter
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

### Compliance och juridik

- **COPPA-compliance är obligatorisk** för detta barnspel (target: 6-12 år). Vid features som rör analytics, server-sync, dataexport eller användardata: läs `docs/PRIVACY_POLICY.md` och `/memories/repo/coppa_compliance_2026-03-04.md` först. Appen ska vara offline-first utan krav på konto eller molnsync.

### Asset-runtime

- **Mascot-runtime i produkt-UI är SVG-first.** Rive-blueprints och `.riv`-material i `artifacts/` är **research/future enhancement** – de är inte en aktiv runtime-dependency i huvudflödet och används inte i production UI.
- `.riv`-filer exporteras manuellt från Rive Editor om de ska användas. Script och blueprints genererar inte den slutliga `.riv`-filen automatiskt.
- Lottie används för UI-effekter (konfetti, pulser), inte som fallback för mascot-runtime.

### Karaktärer och animation

- Nya humanoid-karaktärer ska referera `assets/characters/_shared/config/humanoid_base_form_v1.json` via `baseFormRef`.
- För asset-automation: använd `scripts/promote_assets.ps1` och `.github/skills/asset-generation-runner/SKILL.md` för komplett workflow med validering, QA och promotion.

### State och progression

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
- **Rive-förvirring:** Om du hittar `.riv`-filer eller Rive-relaterade artifacts, kom ihåg att de är research/exploration – productkoden använder SVG för mascot-runtime.

## Sessionskontinuitet

Använd dessa filer som extern kontext i stället för att förlita dig på chatthistorik:

- `docs/SESSION_BRIEF.md` för aktuellt läge och nästa steg
- `docs/DECISIONS_LOG.md` för beslut som ska leva kvar

Standardrutin:

1. Läs `docs/SESSION_BRIEF.md` vid start och när användaren säger "fortsätt".
2. Läs `docs/DECISIONS_LOG.md` vid komplexa uppgifter eller när äldre beslut påverkar arbetet.
3. Uppdatera dessa filer när uppgiften uttryckligen handlar om sessionslogg eller beslut.
