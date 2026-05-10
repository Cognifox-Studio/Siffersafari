# Copilot-instruktioner (Siffersafari)

## Projektet

Siffersafari är ett Flutter-baserat mattespel för barn. Appen är Android-first, offline-first och byggd för ett enkelt barnflöde: profilval -> quiz -> resultat -> story map.

## Läsordning

Läs dessa källor i den här ordningen när uppgiften kräver mer kontext:

1. `docs/SESSION_BRIEF.md` vid start, vid "fortsätt" och när du behöver nuläget.
2. `docs/README.md` som index till övrig dokumentation.
3. `docs/ARCHITECTURE.md` för faktisk arkitektur, startup och aktiva runtime-val.
4. `docs/DECISIONS_LOG.md` när äldre beslut eller avvägningar påverkar lösningen.
5. `docs/PROJECT_STRUCTURE.md` och `docs/SERVICES_API.md` när struktur eller servicekontrakt berörs.

Länka hellre till dessa dokument än att duplicera innehåll i nya customizations.

## Kärnregler

- **Nulägesfacit först:** `docs/ARCHITECTURE.md`, `docs/DECISIONS_LOG.md` och `docs/SESSION_BRIEF.md` väger högre än äldre artefakter och historiska spår.
- **COPPA gäller alltid:** ingen persondata, inga trackers, inga annons-SDK:er och inga onlinekrav i huvudupplevelsen. Läs `docs/PRIVACY_POLICY.md` och `/memories/repo/coppa_compliance_2026-03-04.md` före ändringar som rör analytics, nätverk, export eller användardata.
- **Feature-first UI:** ny featureägd UI ligger under `lib/features/<feature>/presentation/`. `lib/presentation/widgets/` är endast för verkligt delad UI.
- **PNG-first mascot-runtime:** produkt-UI använder Loke som PNG med Flutter-styrda proceduranimationer. Rive och `.riv` är researchspår, inte aktiv runtime. Lottie används bara för fristående UI-effekter.
- **Offline-first persistens:** Hive via repository-lagret. Session-state som byggs upp under quiz måste mergas tillbaka till permanent användarprofil vid avslut.
- **Link, don't embed:** håll customizations korta och repo-specifika. Peka vidare till docs, minnen och smalare instruktioner i stället för att samla allt här.

## När du jobbar med .github-customizations

- Uppdatera befintliga `AGENTS.md`, `.github/copilot-instructions.md`, skills och instruktioner före att skapa nya centrala filer.
- `AGENTS.md` är snabb routingyta för agentval; `.github/copilot-instructions.md` är alltid-på repo-regler.
- Nya skills ska ha `name` som matchar mappnamn och en konkret `description` med tydliga triggerord.
- Lägg smala regler i `.github/instructions/` eller `.github/skills/` i stället för att svälla centralfilen.
- Behåll "link, don't embed": länka till `docs/README.md`, `docs/ARCHITECTURE.md` och `docs/SESSION_BRIEF.md` när detaljer redan finns där.
- Använd `.github/prompts/customization-audit-pass.prompt.md` för en snabb audit och `.github/hooks/customization-path-guard.json` som lättviktsvarning vid customization-arbete.

## Före kodändring

1. Identifiera ägande kodväg och billigaste möjliga verifiering.
2. Välj den minsta rimliga QA-slicen för ändringen.
3. Kontrollera om en befintlig skill eller instruktion redan täcker arbetsflödet.
4. Uppdatera `docs/DECISIONS_LOG.md` eller `docs/SESSION_BRIEF.md` bara när verkligheten faktiskt har ändrats.

## Bygg och QA

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

## Skills och routing

Använd repo-skillen i stället för att improvisera när uppgiften matchar något av följande:

- GitHub-customization audit: `.github/skills/granska-github-customizations/SKILL.md`
- QA och verifiering: `.github/skills/testa-att-appen-fungerar/SKILL.md`
- Pre-commit och diffklassning: `.github/skills/dubbelkolla-andrad-kod/SKILL.md`
- Quiz-persistens och merge: `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md`
- Hive-diagnostik: `.github/skills/felsok-sparad-data/SKILL.md`
- Difficulty mix audit: `.github/skills/testa-fragornas-svarighetsgrad/SKILL.md`
- Android-emulator och Pixel_6: `.github/skills/felsok-android-emulatorn/SKILL.md`
- Test-timeouts och Flutter-animationer: `.github/skills/hantera-flutter-test-animationer/SKILL.md`
- Mocka offline-quiz och state: `.github/skills/mocka-temporar-offline-session/SKILL.md`
- Dokumentation: `.github/skills/uppdatera-dokumentationen/SKILL.md`
- Analytics-kontrakt: `.github/skills/faststall-spelar-statistik/SKILL.md`
- UI-extraktion eller logikflytt: `.github/skills/bryt-ut-delade-visuella-komponenter/SKILL.md`, `.github/skills/flytta-ut-logik-fran-ui/SKILL.md`
- Formulärgranskning: `.github/skills/validera-formular-och-input/SKILL.md`
- Bildbeställningar: `.github/skills/skapa-bildbestallning/SKILL.md`
- Release readiness och COPPA-kontroll: `.github/skills/kolla-om-appen-ar-redo-att-slappas/SKILL.md`, `.github/skills/verifiera-coppa-regler/SKILL.md`

## Custom Agents

- **Plan** (`.github/agents/plan.agent.md`): analys, research, risker och testplan utan kodändringar.
- **Beast Mode** (`.github/agents/beastmode.agent.md`): genomförande, iteration och QA end-to-end.
- **Customization Maintainer** (`.github/agents/customization-maintainer.agent.md`): underhåll av prompts, skills, hooks, instruktioner och agentfiler under `.github/`.
- **UI Reviewer** (`.github/agents/ui-reviewer.agent.md`): UI/UX- och responsivitetsgranskning.
- **Release Manager** (`.github/agents/release-manager.agent.md`): releaseförberedelser, versionsbump och Play-flöde.

## Områdesspecifika instruktioner

Följ rätt instruktion när motsvarande filtyp eller arbetsyta berörs:

- `.github/instructions/regler-for-customization-hygien.instructions.md`
- `.github/instructions/regler-for-hur-skarmar-och-knappar-ska-se-ut.instructions.md`
- `.github/instructions/regler-for-app-navigation.instructions.md`
- `.github/instructions/regler-for-formular-och-validering.instructions.md`
- `.github/instructions/regler-for-async-och-loading.instructions.md`
- `.github/instructions/regler-for-att-uppdatera-information-pa-skarmen.instructions.md`
- `.github/instructions/regler-for-att-spara-saker-permanent-i-telefonen.instructions.md`
- `.github/instructions/regler-for-hur-pabade-quiz-avbryts-och-sparas.instructions.md`
- `.github/instructions/regler-for-appens-inre-logik.instructions.md`
- `.github/instructions/regler-for-hur-appens-osynliga-delar-kopplas-ihop.instructions.md`
- `.github/instructions/regler-for-animationer-och-rorelser.instructions.md`
- `.github/instructions/regler-for-hur-vi-testar-att-appen-fungerar.instructions.md`
- `.github/instructions/regler-for-smarta-hjalpskript.instructions.md`
- `.github/instructions/regler-for-att-paketera-ihop-android-appen.instructions.md`
- `.github/instructions/regler-for-att-ladda-upp-appen-pa-google-play.instructions.md`
- `.github/instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md`

## Repo-fallgropar

- Pixel_6 kan fastna offline i adb. Prioritera cold boot utan snapshot: `emulator.exe -avd Pixel_6 -no-snapshot-load`.
- Stale APK efter rebuild löses ofta med `scripts/flutter_pixel6.ps1 -Action install` eller `-Action sync`.
- Historiska docs och artifacts kan vara stale. Kontrollera alltid mot `docs/ARCHITECTURE.md` och aktuell kod.
- Anta inte längre SVG-first mascot-runtime. Den aktiva maskotvägen är PNG-first med Flutter-animationer ovanpå.
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

## Workspace-prompter

- `.github/prompts/customization-audit-pass.prompt.md` för att auditera `.github` och få en kort prioriterad åtgärdslista.
- `.github/prompts/repo-start-routing.prompt.md` för att välja rätt agent, skill och minsta QA-slice vid arbetets start.
- `.github/prompts/repo-qa-slice.prompt.md` för att välja och köra minsta tillräckliga QA-slice för aktuell diff eller riskyta.

## Hooks

- `.github/hooks/customization-path-guard.json` lägger in en kort hygiene-varning när en prompt ser ut att gälla nya eller ändrade chat-customizations.
