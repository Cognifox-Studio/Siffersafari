---
name: "slice-start"
description: "Use when starting a new work slice: lock Now, challenge the plan, set DoD and minimal QA before any code"
argument-hint: "Valfritt: föreslaget Now-mål eller kort uppgiftsbeskrivning"
agent: "Plan"
---

Starta en ny arbetsslice enligt Siffersafaris utvecklingssystem.

Läs först:

- [docs/DEV_SYSTEM.md](../../docs/DEV_SYSTEM.md)
- [docs/DEFINITION_OF_DONE.md](../../docs/DEFINITION_OF_DONE.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md) (Now)
- [docs/ACTIVE_PLAN.md](../../docs/ACTIVE_PLAN.md) (Next/Later)

Arbetsordning (ingen kod ännu):

1. Citera aktuellt **Now**. Om Now saknas eller är oklart: stoppa och be användaren välja *ett* mål från Next (eller ett nytt uttryckligt Now).
2. Formulera slice-scope i 3–6 punkter: vad som ingår, vad som **inte** ingår.
3. **Utmana planen:** risker, COPPA, persistens, blandad diff, för stor yta. Föreslå snävare scope om behövs.
4. Skriv **Definition of Done** för just denna slice (referera A/B/C i DoD-filen).
5. Välj **minsta QA-slice** (analyze / vilka tester / Pixel_6 / ingen ännu).
6. Föreslå agent/skill för execute-fasen (`Beast Mode`, difficulty-skill, release-prompt, …).
7. Fråga uttryckligen: “Godkänner du planen?” — vänta på go innan implementation.

Svarskrav:

- Kort, på svenska, med ÅÄÖ.
- Ingen implementation i detta svar.
- Om användaren redan gett ett tydligt Now och sagt “bygg”, bekräfta DoD + QA i 5 rader och säg att execute kan starta.
