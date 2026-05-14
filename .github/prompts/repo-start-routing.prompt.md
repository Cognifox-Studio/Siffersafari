---
name: "repo-start-routing"
description: "Läs repo-briefen och välj rätt agent, skill och minsta QA-slice innan arbetet börjar"
argument-hint: "Valfritt: beskriv uppgiften eller nämn fil/scope som ska arbetas på"
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
2. Läs bara fler docs om uppgiften faktiskt kräver det.
3. Föreslå rätt utförandeform:
   - standardagenten för små, direkta frågor eller små ändringar
   - `Plan` för analys, riskbedömning eller avgränsning
   - `Beast Mode` för implementation och QA
   - `UI Reviewer` för ren UI-granskning
   - `release-manager` för release- eller Play Console-arbete
4. Föreslå relevant repo-skill om uppgiften matchar en befintlig skill.
5. Välj minsta rimliga QA-slice för uppgiften redan från start.

Svarskrav:

- Börja med en kort routingrekommendation.
- Lista vilka källor som faktiskt behövdes.
- Nämn vald agent, eventuell skill och föreslagen QA-slice.
- Om ingen extra skill behövs, säg det uttryckligen.
- Skapa inte en stor plan om uppgiften är liten.