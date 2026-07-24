# Agentförteckning

Detta dokument är snabb routing för de anpassade GitHub Copilot-agenterna i `.github/agents/` och de närmaste startytorna för skills, promptar och QA i Siffersafari.

## Starta här

- Läs `docs/SESSION_BRIEF.md` först vid start och när användaren säger "fortsätt".
- Läs `.github/copilot-instructions.md` för alltid-på-regler, repo-fallgropar och QA-baseline.
- Läs `docs/README.md` som index och `docs/ARCHITECTURE.md` bara när uppgiften kräver mer faktisk implementation.
- Om scopet fortfarande är oklart: börja med `.github/prompts/repo-start-routing.prompt.md` eller agenten `Plan` innan du väljer en skill.

## Snabbstart

- Om scopet är oklart: kör `.github/prompts/repo-start-routing.prompt.md` först.
- Om en ny utvecklare eller kall agent behöver snabb repo-onboarding: kör `.github/prompts/repo-start-routing.prompt.md` och be om onboardingläge.
- Om uppgiften gäller assets, `_incoming/`, saknad grafik, app-ikoner eller Play-listingbilder: kör `.github/prompts/asset-flow-router.prompt.md`.
- Om storykartan, home story-kortet, biome-previews eller theme bundles visar fel bild eller verkar ha fel ägare: kör `.github/prompts/story-theme-asset-pass.prompt.md`.
- Om du behöver veta vilka instructions, skills eller prompts som faktiskt matchar en viss fil eller mapp: kör `.github/prompts/instruction-match-audit.prompt.md`.
- Om uppgiften gäller garderob, inventory eller `GameCharacter` och du vill få rätt call sites och QA-slice först: kör `.github/prompts/inventory-rendering-pass.prompt.md`.
- Om uppgiften gäller garderob, inventory eller `GameCharacter`: läs `.github/instructions/regler-for-z-index-inventory.instructions.md` innan du ändrar equip-logik eller rendering.
- Om du ändrar `question_generator_service.dart`, grade-svårighetsgrad, frågebanker eller `docs/curriculum_facit.json`: använd `.github/skills/testa-fragornas-svarighetsgrad/SKILL.md` för att verifiera balansen före commit.
- Om ett analyze-, test-, emulator- eller buildfel precis klistrats in eller behöver första triage: kör `.github/prompts/qa-failure-router.prompt.md` först.
- Om felet redan är konkret och du behöver djupare repo-felsökning efter triage: kör `.github/prompts/felsok.prompt.md`.
- Om det är oklart om en releasefråga gäller AAB-upload, listing-sync, release notes eller GitHub-release: kör `.github/prompts/play-release-router.prompt.md` för första release-triage.
- Om butikstext eller release notes behöver granskas: kör `.github/prompts/play-listing-copy-pass.prompt.md`.
- Om du ska verifiera en diff, välja minsta QA före commit eller bedöma blandade ändringar: kör `.github/prompts/repo-qa-slice.prompt.md` eller `.github/skills/dubbelkolla-andrad-kod/SKILL.md`.
- Om v1.5.0 resume- eller persistensscopet ska auditeras: kör `.github/prompts/resume-v150-persistence-audit.prompt.md`.
- Om uppgiften bara gäller `.github/`, eller användaren vill skapa, uppdatera eller städa instruktioner, promptar, skills, hooks eller agentfiler: välj `Customization Maintainer`.
- Börja då med `.github/prompts/customization-audit-pass.prompt.md` för audit, init av ett customization-pass eller låg-risk-fixar; använd `.github/skills/granska-github-customizations/SKILL.md` när du redan vet att det är en ren `.github`-audit.
- Om sessionhistorik finns och du förbättrar `.github` över tid: kontrollera chronicle först för att fånga återkommande discovery-, routing- eller path-friktion innan du patchar.
- Om en read-only cleanup-audit behövs: kör `.github/prompts/night-cleanup-audit.prompt.md`.
- Om du vill att ett nattpass ska göra låg-risk-cleanup automatiskt och lämna allt ocommittat: kör `.github/prompts/night-low-risk-apply.prompt.md`.
- När releaseytan redan är känd och du behöver ett faktiskt `Go`/`Soft go`/`No-go`: kör `.github/prompts/release-go-no-go.prompt.md`.
- Om användaren ber om verifiering eller du har en blandad diff: använd `.github/prompts/repo-qa-slice.prompt.md` eller relevant QA-skill direkt.

## Snabb routing

- Använd standardagenten för små frågor eller små direkta ändringar.
- Välj `Plan` när scope, risk eller verifiering först måste avgränsas.
- Välj `Beast Mode` när kod ska ändras eller QA ska köras end-to-end.
- Välj `Customization Maintainer` när arbetet gäller att skapa, uppdatera, granska eller städa `.github`-customizations.
- Välj `UI Reviewer` för ren UI-granskning utan implementation.
- Välj `release-manager` för version, release readiness eller Play Console-arbete.
- Använd skills först när arbetsflödet redan är känt; om du fortfarande mappar problemet är prompt eller agent bättre startyta.

## Vanliga skills

### QA och felsökning

- `.github/skills/testa-att-appen-fungerar/SKILL.md` för repo-standardiserad QA.
- `.github/skills/dubbelkolla-andrad-kod/SKILL.md` när aktuell diff eller staged scope ska klassificeras och få minsta tillräckliga verifiering före commit.
- `.github/skills/laga-kraschande-tester/SKILL.md` när widget- eller integrationstester timeoutar eller tappar synk.
- `.github/skills/hantera-flutter-test-animationer/SKILL.md` för animationstester, teardown-varningar och testrelaterade encoding-problem.
- `.github/skills/testa-innan-vi-sparar/SKILL.md` för sista lilla quality gate när implementationen redan är klar och du vill låsa rätt analyze-/testnivå.
- `.github/skills/felsok-android-emulatorn/SKILL.md` för Pixel_6-, adb- och stale APK-problem.
- `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md` för resume, replay, session och resultat-merge.
- `.github/skills/mocka-temporar-offline-session/SKILL.md` när offline- eller quizpersistensflöden behöver mockas i test.

### Arkitektur och refaktor

- `.github/skills/flytta-ut-logik-fran-ui/SKILL.md` när widgets bär för mycket logik eller sidoeffekter.
- `.github/skills/bryt-ut-delade-visuella-komponenter/SKILL.md` när feature-UI behöver brytas ut eller delas säkert.
- `.github/skills/validera-formular-och-input/SKILL.md` för formulär, `TextEditingController`, validering och submit-flöden.

### Audit och specialspår

- `.github/skills/granska-github-customizations/SKILL.md` för path-, trigger- och dupliceringsaudit i `.github/`.
- `.github/skills/faststall-spelar-statistik/SKILL.md` när funnel-events, payload-fält eller triggerpunkter i lokal analytics ändras.
- `.github/skills/uppdatera-dokumentationen/SKILL.md` när docs måste spegla verkligheten exakt.
- `.github/skills/synka-play-assets/SKILL.md` när Play Console-screenshots eller listing-bilder ska kopieras in i Fastlane-metadata.
- `.github/skills/granska-legacy-hive-format/SKILL.md` för evidensbaserad audit innan legacy-format eller fallback-parsning städas bort.
- `.github/skills/verifiera-coppa-regler/SKILL.md` för policy-, tracking- och barnsäkera compliancekontroller.
- `.github/skills/kolla-om-appen-ar-redo-att-slappas/SKILL.md` för release readiness.
- Övriga nischspår finns under `.github/skills/`, till exempel assets, analytics, UX-copy och difficulty-audits.

## QA-genväg

- `QA: Analyze` för de flesta Dart- eller runtime-ändringar.
- `QA: Analyze + Test (valfri path)` för fokuserade kodändringar med tydlig testyta.
- `Pixel_6: Sync + QA (valfri testpath)` när rendering, navigation, assets eller devicebeteende berörs.

## Tillgängliga agenter

### Plan
- Fil: `.github/agents/plan.agent.md`
- Analys, riskbedömning, inventering och testplan utan kodändringar.

### Beast Mode
- Fil: `.github/agents/beastmode.agent.md`
- Implementation, refaktor, QA och verifiering end-to-end.

### Customization Maintainer
- Fil: `.github/agents/customization-maintainer.agent.md`
- Underhåll av prompts, skills, hooks, instruktioner och agentfiler under `.github/`.

### UI Reviewer
- Fil: `.github/agents/ui-reviewer.agent.md`
- UI/UX-granskning av Flutter-skärmar och widgets.

### release-manager
- Fil: `.github/agents/release-manager.agent.md`
- Releaseförberedelser, versionsbump och Play-flöde.

## Arbetsordning

1. Läs `docs/SESSION_BRIEF.md`.
2. Om scopet eller QA-valet är oklart, börja med relevant prompt eller agenten `Plan` i stället för bred scanning.
3. Välj skill först när arbetsflödet redan matchar en etablerad slice.
4. Välj specialagent bara när uppgiften behöver ett tydligt modebyte.
5. Läs agentfilen i `.github/agents/` om du behöver agentens exakta arbetssätt.
6. Följ `.github/copilot-instructions.md` för repo-regler; låt skills och promptar bära smalare arbetsflöden.

## Underhållsprincip

- Håll denna fil kort. Agentfilen själv är facit för roll, begränsningar och arbetsflöde.
- Lägg repo-breda regler i `.github/copilot-instructions.md`, inte här.
