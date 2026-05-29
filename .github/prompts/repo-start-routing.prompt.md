---
name: "repo-start-routing"
description: "Use when du startar nytt arbete, ar ny i repo:t eller ar en kall agent och vill lasa repo-briefen, valja ratt agent eller skill och hitta minsta QA-slice"
argument-hint: "Valfritt: beskriv uppgiften, namnge fil eller scope, eller sag att du bara vill ha snabb repo-onboarding"
agent: "agent"
---

Starta ett nytt arbete i Siffersafari med minsta nödvändiga routing och utan bred, onödig scanning.

Utgå från dessa källor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/README.md](../../docs/README.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/AGENTS.md](../AGENTS.md)

Arbetsordning:

1. Läs `docs/SESSION_BRIEF.md` först.
2. Om användaren främst behöver onboarding eller orientering: sammanfatta nuläget i högst några korta punkter innan du väljer startyta.
3. Läs bara fler docs om uppgiften faktiskt kräver det.
4. Om uppgiften gäller assets, `_incoming/`, saknad grafik, ikoner, screenshots eller Play-listingbilder: routea direkt till `.github/prompts/asset-flow-router.prompt.md` i stället för bred repo-scanning.
5. Om användaren uttryckligen vill verifiera en diff eller välja minsta QA före commit: routea till `.github/prompts/repo-qa-slice.prompt.md` och lyft vid behov `.github/skills/dubbelkolla-andrad-kod/SKILL.md`.
6. Föreslå rätt utförandeform:
   - standardagenten för små, direkta frågor eller små ändringar
   - `Plan` för analys, riskbedömning eller avgränsning
   - `Beast Mode` för implementation och QA
   - `UI Reviewer` för ren UI-granskning
   - `release-manager` för release- eller Play Console-arbete
7. Föreslå relevant repo-skill om uppgiften matchar en befintlig skill.
8. Peka ut sannolika `.github/instructions/` om användaren nämnde en fil eller ett område.
9. Välj minsta rimliga QA-slice för uppgiften redan från start, eller säg uttryckligen att ingen QA behövs ännu.

Svarskrav:

- Börja med en kort routingrekommendation.
- Om användaren bara behöver orientering: börja i stället med en kort "sa startar du"-rekommendation och 1-3 punkter om nuläget.
- Lista vilka källor som faktiskt behövdes.
- Nämn vald agent eller prompt, eventuell skill, eventuell instruction-yta och föreslagen QA-slice.
- Om ingen extra skill behövs, säg det uttryckligen.
- Skapa inte en stor plan om uppgiften är liten.