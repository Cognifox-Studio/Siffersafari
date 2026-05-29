---
name: "customization-audit-pass"
description: "Granska .github-customizations mot aktuell runtime, repo-facit och discoverykrav och returnera en kort, prioriterad åtgärdslista"
argument-hint: "Valfritt: begränsa auditen till en viss fil eller mapp under .github"
agent: "agent"
---

Granska chat-customizations under `.github/` och fokusera på hög signal, låg dramatik.

Utgå från dessa källor:

- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/AGENTS.md](../AGENTS.md)
- [.github/instructions/regler-for-customization-hygien.instructions.md](../instructions/regler-for-customization-hygien.instructions.md)
- [.github/skills/granska-github-customizations/SKILL.md](../skills/granska-github-customizations/SKILL.md)
- [docs/README.md](../../docs/README.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/DECISIONS_LOG.md](../../docs/DECISIONS_LOG.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)

Arbetsordning:

1. Läs centralfilerna först.
2. Inventera relevant yta under `.github/` utifrån användarens scope eller hela customization-lagret.
3. Leta efter brutna paths, stale referenser, name/mapp-mismatch, svaga `description`-fält, för breda `applyTo`-mönster och onödig duplicering mot `docs/`.
4. Leta också efter runtime- eller nulägesdrift mot repo-facit, till exempel stale experimentspår, fel runtimepåståenden, gamla tema- eller mascotspår, fel QA-kommandon eller fel releaseväg.
5. Håll fokus på det som påverkar discovery, routing och underhåll först.
6. Returnera en kort åtgärdslista. Gör bara direkta ändringar om användaren uttryckligen bad om att få saker fixade nu.

Svarskrav:

- Lista fynd först, sorterade efter allvarlighetsgrad.
- Ange vilka filer som bör ändras.
- Nämn vilket repo-facit som väger tyngst om du flaggar runtime- eller nulägesdrift.
- Säg uttryckligen om inga tydliga problem hittas.
- Håll sammanfattningen kort och repo-specifik.