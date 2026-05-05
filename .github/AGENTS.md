# Agentförteckning

Detta dokument beskriver de anpassade GitHub Copilot-agenter som finns i `.github/agents/` för Siffersafari.

## Starta här

- Läs `.github/copilot-instructions.md` först för workspace-regler, repo-fallgropar och skill-routing.
- Läs `docs/SESSION_BRIEF.md` vid start eller när användaren säger "fortsätt".
- Använd `docs/README.md` som index och länka vidare till docs i stället för att duplicera innehåll.

## Snabb routing

- Använd standardagenten för små frågor eller små, direkta ändringar.
- Välj `Plan` när scope, risk eller verifiering först måste avgränsas.
- Välj `Beast Mode` när kod, tester eller QA faktiskt ska köras.
- Välj `Customization Maintainer` när arbetet bara gäller `.github`-customizations.
- Välj `UI Reviewer` för ren granskning av Flutter-UI utan implementation.
- Välj `Release Manager` för version, release readiness eller Play Console-arbete.

## Tillgängliga agenter

### Plan
- Fil: `.github/agents/plan.agent.md`
- Använd när uppgiften först behöver analys, riskbedömning, avgränsning eller testplan utan kodändringar.

### Beast Mode
- Fil: `.github/agents/beastmode.agent.md`
- Använd när kod faktiskt ska ändras, QA ska köras och ett arbete ska genomföras end-to-end.

### Customization Maintainer
- Fil: `.github/agents/customization-maintainer.agent.md`
- Använd när prompts, skills, hooks, instruktioner eller agentfiler under `.github/` ska skapas, granskas eller städas.

### UI Reviewer
- Fil: `.github/agents/ui-reviewer.agent.md`
- Använd när en Flutter-skärm eller widget ska granskas för responsivitet, hierarki, copy eller touch-ergonomi.

### Release Manager
- Fil: `.github/agents/release-manager.agent.md`
- Använd när repo:t behöver en releasegenomgång, versionsbump-plan eller Play-specifik publiceringshjälp.

## Skills som agenterna lutar sig mot

Se `.github/copilot-instructions.md` för full routing. Vanliga ankare är:

- `.github/skills/testa-att-appen-fungerar/SKILL.md`
- `.github/skills/dubbelkolla-andrad-kod/SKILL.md`
- `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md`
- `.github/skills/uppdatera-dokumentationen/SKILL.md`
- `.github/skills/kolla-om-appen-ar-redo-att-slappas/SKILL.md`
- `.github/skills/verifiera-coppa-regler/SKILL.md`

## Enkel arbetsordning

1. Läs `docs/SESSION_BRIEF.md`.
2. Välj `Plan` om uppgiften kräver analys först.
3. Välj `Customization Maintainer` för rent `.github`-arbete.
4. Välj `Beast Mode` eller standardagenten när kod ska ändras.
5. Välj `UI Reviewer` för ren UI-granskning.
6. Välj `Release Manager` för releaseförberedelser.
