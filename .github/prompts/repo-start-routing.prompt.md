---
name: "repo-start-routing"
description: "Use when du startar nytt arbete, ar ny i repo:t eller ar en kall agent och vill lasa repo-briefen, valja ratt agent eller skill och hitta minsta QA-slice"
argument-hint: "Valfritt: beskriv uppgiften, namnge fil eller scope, eller sag att du bara vill ha snabb repo-onboarding"
agent: "agent"
---

Starta ett nytt arbete i Siffersafari med minsta nödvändiga routing och utan bred, onödig scanning.

Utgå från dessa källor:

- [docs/DEV_SYSTEM.md](../../docs/DEV_SYSTEM.md)
- [docs/DEFINITION_OF_DONE.md](../../docs/DEFINITION_OF_DONE.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ACTIVE_PLAN.md](../../docs/ACTIVE_PLAN.md)
- [docs/README.md](../../docs/README.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/AGENTS.md](../AGENTS.md)

Arbetsordning:

1. Läs `docs/SESSION_BRIEF.md` (Now) och `docs/DEV_SYSTEM.md` först.
2. Om användaren startar ny implementation och Now/slice är oklart: routea till `.github/prompts/slice-start.prompt.md` innan kod.
3. Om användaren främst behöver onboarding eller orientering: sammanfatta nuläget i högst några korta punkter innan du väljer startyta.
4. Läs bara fler docs om uppgiften faktiskt kräver det.
5. Om uppgiften gäller assets, `_incoming/`, saknad grafik, ikoner, screenshots eller Play-listingbilder: routea direkt till `.github/prompts/asset-flow-router.prompt.md` i stället för bred repo-scanning.
6. Om uppgiften gäller `question_generator_service.dart`, grade-svårighetsgrad, frågebanker eller `docs/curriculum_facit.json`: routea till `.github/skills/testa-fragornas-svarighetsgrad/SKILL.md` och föreslå en audit-baserad QA-slice i stället för bred generell testning.
7. Om användaren uttryckligen vill verifiera en diff eller välja minsta QA före commit: routea till `.github/prompts/repo-qa-slice.prompt.md` och lyft vid behov `.github/skills/dubbelkolla-andrad-kod/SKILL.md`.
8. Om uppgiften gäller att skapa, förbättra eller städa chat-customizations under `.github/`: routea till `Customization Maintainer` eller `.github/prompts/customization-audit-pass.prompt.md` och föreslå att befintliga centralfiler uppdateras före nya filer.
9. Föreslå rätt utförandeform:
   - standardagenten för små, direkta frågor eller små ändringar
   - `Plan` för analys, riskbedömning eller avgränsning
   - `Beast Mode` för implementation och QA
   - `Customization Maintainer` för `.github`-customizations, routingpolish och hygiene-pass
   - `UI Reviewer` för ren UI-granskning
   - `release-manager` för release- eller Play Console-arbete
10. Föreslå relevant repo-skill om uppgiften matchar en befintlig skill.
11. Peka ut sannolika `.github/instructions/` om användaren nämnde en fil eller ett område.
12. Välj minsta rimliga QA-slice för uppgiften redan från start, eller säg uttryckligen att ingen QA behövs ännu.

Svarskrav:

- Börja med en kort routingrekommendation.
- Om användaren bara behöver orientering: börja i stället med en kort "sa startar du"-rekommendation och 1-3 punkter om nuläget.
- Lista vilka källor som faktiskt behövdes.
- Nämn vald agent eller prompt, eventuell skill, eventuell instruction-yta och föreslagen QA-slice.
- Om ingen extra skill behövs, säg det uttryckligen.
- Skapa inte en stor plan om uppgiften är liten.