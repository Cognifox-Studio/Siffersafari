---
name: "customization-audit-pass"
description: "Granska .github-customizations och returnera en kort, prioriterad åtgärdslista"
argument-hint: "Valfritt: begränsa auditen till en viss fil eller mapp under .github"
agent: "agent"
---

Granska chat-customizations under `.github/` och fokusera på hög signal, låg dramatik.

Utgå från dessa källor:

- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/AGENTS.md](../AGENTS.md)
- [.github/skills/granska-github-customizations/SKILL.md](../skills/granska-github-customizations/SKILL.md)
- [docs/README.md](../../docs/README.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/DECISIONS_LOG.md](../../docs/DECISIONS_LOG.md)

Arbetsordning:

1. Läs centralfilerna först.
2. Inventera relevant yta under `.github/` utifrån användarens scope eller hela customization-lagret.
3. Leta efter brutna paths, stale referenser, name/mapp-mismatch, svaga `description`-fält, för breda `applyTo`-mönster och onödig duplicering mot `docs/`.
4. Håll fokus på det som påverkar discovery, routing och underhåll först.
5. Returnera en kort åtgärdslista. Gör bara direkta ändringar om användaren uttryckligen bad om att få saker fixade nu.

Svarskrav:

- Lista fynd först, sorterade efter allvarlighetsgrad.
- Ange vilka filer som bör ändras.
- Säg uttryckligen om inga tydliga problem hittas.
- Håll sammanfattningen kort och repo-specifik.