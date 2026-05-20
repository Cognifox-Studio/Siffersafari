---
name: "onboard-new-dev"
description: "Ge en kort repo-onboarding for ny utvecklare eller kall agent och peka ut ratt agent, instruktioner och forsta verifiering"
argument-hint: "Valfritt: beskriv uppgiften, malomradet eller om du bara vill ha en generell repo-onboarding"
agent: "agent"
---

Starta en snabb onboarding i Siffersafari utan att hoppa direkt till implementation.

Utga fran dessa kallor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [.github/AGENTS.md](../AGENTS.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [docs/README.md](../../docs/README.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md) bara om scopet faktiskt kraver implementation eller runtime-kontext

Arbetsordning:

1. Las `docs/SESSION_BRIEF.md` forst och sammanfatta nulaget i hogst nagra korta punkter.
2. Identifiera vilken typ av arbete anvandaren sannolikt ska gora: liten direkt andring, analys/plan, implementation, UI-review, release eller ren `.github`-customization.
3. Valj ratt startyta: standardagent, `Plan`, `Beast Mode`, `UI Reviewer`, `release-manager`, relevant prompt eller relevant skill.
4. Peka ut vilka `.github/instructions/` som sannolikt blir relevanta om anvandaren namnde en fil eller ett omrade.
5. Valj minsta rimliga QA-slice eller sag uttryckligen att ingen QA behovs an.
6. Halla svaret kort och repo-specifikt. Skapa inte en stor plan om anvandaren bara behover orientering.

Svarskrav:

- Borja med en kort "sa startar du"-rekommendation.
- Lista vilka kallor som faktiskt behovdes.
- Namnge vald agent eller prompt, eventuell skill och eventuell instruction-yta.
- Namnge forsta verifiering eller sag att ingen verifiering behovs i detta lage.
- Om viktiga antaganden saknas, skriv dem som korta oppna fragor i slutet.