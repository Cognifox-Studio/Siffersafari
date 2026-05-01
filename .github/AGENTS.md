# Multiplikation - Agentförteckning

Detta dokument beskriver de anpassade GitHub Copilot-agents (subagents) som finns konfigurerade i `.github/agents/`. De är specialiserade på olika faser av utvecklings- och kvalitetssäkringsprocessen för Siffersafari.

## Tillgängliga Agenter

### 1. Plan (@plan)
**Fil:** `.github/agents/plan.agent.md`
**Syfte:** Research, analys, riskbedömning och testplanering.
**Användning:** 
Innan kodning påbörjas av en ny stor feature eller komplex bugg. Agenten analyserar `docs/ARCHITECTURE.md`, `docs/DECISIONS_LOG.md` och relevant kod för att formulera en genomförandeplan och identifiera fallgropar *utan att göra kodändringar*.

### 2. Beast Mode (@beastmode)
**Fil:** `.github/agents/beastmode.agent.md`
**Syfte:** Självgående implementation, feltestning, QA-pass och systematiska kodrättelser.
**Användning:** 
När en plan finns och kod ska produceras. Beast Mode tar ägarskap över processen, kör tester automatiskt via terminalkommandon, och itererar tills koden uppfyller kvalitetskraven (se t.ex. `flutter-qa-guard` i `.github/skills/`).

## Automation och Skills (Floden)
Utöver dessa agenter förlitar sig projektet starkt på "Skills" (verktygskedjor och skript) som agenterna kan anropa. Några av de viktigaste för Beast Mode och standardagenten är:
- **verify-git-changes:** Körs lokalt före commits ("pre-commit") för att verifiera forms, lints och relevanta tester så git-historiken förblir ren.
- **difficulty-mix-audit:** Testar generering av svårighetsgrader (`question_generator_service.dart`) från `specs/` med fokus på rätt matematisk mix i spelet.
- **flutter-qa-guard:** Verifierar `analyze`, widget/integration tests och screenshot regression.
- **asset-generation-runner:** Genererar mascot SVG-delar och composite SVGs för karaktärer.
- **animation-preview-lab:** Isolerad miljö för att bygga animationspreviews (t.ex. wave, walk).
- **release-readiness-check:** Slutgiltig kvalitetssäkring innan paketering (testar bygget mot QA).

## Processflöde
1. **Brief:** Läs `docs/SESSION_BRIEF.md`.
2. **Plan (Valfritt):** Instruera `@plan` att utvärdera nästa steg utifrån briefen.
3. **Genomför:** Instruera `@beastmode` eller standardagenten att bygga och iterera utifrån planen.
4. **Verifiera:** Låt agenten köra tester och `flutter-qa-guard`.
5. **Dokumentera:** Använd `@copilot` eller documentation-skillen för att uppdatera `docs/DECISIONS_LOG.md` om systemet ändrats.
