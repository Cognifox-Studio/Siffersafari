---
name: "customization-runtime-drift-audit"
description: "Auditerar .github-customizations mot aktuell runtime och repo-facit för att hitta stale experimentspår, fel runtimepåståenden och drift mot docs"
argument-hint: "Valfritt: begränsa auditen till prompts, skills, hooks, agents, instructions eller en specifik fil under .github"
agent: "agent"
---

Granska `.github`-customizations med fokus på runtime- och nulägesdrift, inte generell stilgranskning.

Utgå från dessa källor:

- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/AGENTS.md](../AGENTS.md)
- [.github/instructions/regler-for-customization-hygien.instructions.md](../instructions/regler-for-customization-hygien.instructions.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/DECISIONS_LOG.md](../../docs/DECISIONS_LOG.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/README.md](../../docs/README.md)

Arbetsordning:

1. Läs centralfilerna först och fastställ vad som är aktiv runtime och gällande nuläge.
2. Inventera bara den `.github`-yta som matchar användarens scope, eller hela customization-lagret om inget scope gavs.
3. Leta efter stale experimentspår, fel runtimepåståenden och andra customization-texter som driver från facit, till exempel kring mascot-runtime, feature-first-struktur, offline-first-persistens, faktiska teman, QA-kommandon eller releaseväg.
4. Prioritera drift som påverkar discovery, routing eller felsökningsspår före allmän stilpolish.
5. Returnera minsta rimliga åtgärdslista. Gör bara direkta ändringar om användaren uttryckligen bad om att få saker fixade nu.

Svarskrav:

- Lista fynd först, sorterade efter allvarlighetsgrad.
- Ange vilka `.github`-filer som bör ändras.
- Nämn vilket repo-facit som väger tyngst för varje driftpunkt.
- Säg uttryckligen om ingen tydlig runtime-drift hittas.
- Håll svaret kort, konkret och repo-specifikt.