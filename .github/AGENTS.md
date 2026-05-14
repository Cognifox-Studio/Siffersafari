# Agentförteckning

Detta dokument är snabb routing för de anpassade GitHub Copilot-agenterna i `.github/agents/` och de närmaste startytorna för skills, promptar och QA i Siffersafari.

## Starta här

- Läs `docs/SESSION_BRIEF.md` först vid start och när användaren säger "fortsätt".
- Läs `.github/copilot-instructions.md` för alltid-på-regler, repo-fallgropar och QA-baseline.
- Läs `docs/README.md` som index och `docs/ARCHITECTURE.md` bara när uppgiften kräver mer faktisk implementation.

## Snabbstart

- Om scopet är oklart: kör `.github/prompts/repo-start-routing.prompt.md` först.
- Om v1.5.0 resume- eller persistensscopet ska auditeras: kör `.github/prompts/resume-v150-persistence-audit.prompt.md`.
- Om uppgiften bara gäller `.github/`: välj `Customization Maintainer` och använd gärna `.github/skills/granska-github-customizations/SKILL.md`.
- Om användaren ber om verifiering eller du har en blandad diff: använd `.github/prompts/repo-qa-slice.prompt.md` eller relevant QA-skill direkt.

## Snabb routing

- Använd standardagenten för små frågor eller små direkta ändringar.
- Välj `Plan` när scope, risk eller verifiering först måste avgränsas.
- Välj `Beast Mode` när kod ska ändras eller QA ska köras end-to-end.
- Välj `Customization Maintainer` när arbetet bara gäller `.github`-customizations.
- Välj `UI Reviewer` för ren UI-granskning utan implementation.
- Välj `release-manager` för version, release readiness eller Play Console-arbete.

## Vanliga skills

- `.github/skills/testa-att-appen-fungerar/SKILL.md` för repo-standardiserad QA.
- `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md` för resume, replay, session och resultat-merge.
- `.github/skills/granska-legacy-hive-format/SKILL.md` för evidensbaserad audit innan legacy-format eller fallback-parsning städas bort.
- `.github/skills/felsok-android-emulatorn/SKILL.md` för Pixel_6-, adb- och stale APK-problem.
- `.github/skills/uppdatera-dokumentationen/SKILL.md` när docs måste spegla verkligheten exakt.
- `.github/skills/granska-github-customizations/SKILL.md` för path-, trigger- och dupliceringsaudit i `.github/`.

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
2. Om scopet eller QA-valet är oklart, börja med motsvarande prompt eller skill i stället för bred scanning.
3. Välj specialagent bara när uppgiften behöver ett tydligt modebyte.
4. Läs agentfilen i `.github/agents/` om du behöver agentens exakta arbetssätt.
5. Följ `.github/copilot-instructions.md` för repo-regler; låt skills och promptar bära smalare arbetsflöden.

## Underhållsprincip

- Håll denna fil kort. Agentfilen själv är facit för roll, begränsningar och arbetsflöde.
- Lägg repo-breda regler i `.github/copilot-instructions.md`, inte här.
