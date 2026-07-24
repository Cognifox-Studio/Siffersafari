---
name: "customization-audit-pass"
description: "Granska eller härda .github-customizations mot aktuell runtime, repo-facit, discoverykrav och återkommande friktion; returnera en kort åtgärdslista eller gör låg-risk-fixar när användaren ber om det"
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
2. Om sessionhistorik finns: använd chronicle eller sessionhistoriken för att leta efter återkommande discovery-, routing-, path- eller triggerfriktion. Om ingen historik finns, säg det kort och fortsätt på repo-facit.
3. Inventera relevant yta under `.github/` utifrån användarens scope eller hela customization-lagret.
4. Leta efter brutna paths, stale referenser, name/mapp-mismatch, svaga `description`-fält, för breda `applyTo`-mönster och onödig duplicering mot `docs/`.
5. Leta också efter runtime- eller nulägesdrift mot repo-facit, till exempel stale experimentspår, fel runtimepåståenden, gamla tema- eller mascotspår, fel QA-kommandon eller fel releaseväg.
6. Håll fokus på det som påverkar discovery, routing och underhåll först.
7. Returnera en kort åtgärdslista. Om användaren uttryckligen bad om fix nu: applicera den minsta rimliga `.github`-patchen i samma pass i stället för att stanna vid audit.

Svarskrav:

- Lista fynd först, sorterade efter allvarlighetsgrad.
- Ange vilka filer som bör ändras.
- Nämn vilket repo-facit som väger tyngst om du flaggar runtime- eller nulägesdrift.
- Säg om sessionhistorik användes eller saknades.
- Säg uttryckligen om inga tydliga problem hittas.
- Föreslå 1-2 närliggande customization-spår att skapa eller förbättra härnäst när det finns tydlig ROI.
- Håll sammanfattningen kort och repo-specifik.