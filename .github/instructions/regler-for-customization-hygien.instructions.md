---
name: "Customization-hygien"
description: "Use when editing chat customization files under .github such as AGENTS.md, copilot-instructions, skills, prompts, hooks or agent files. Covers minimalism, path hygiene, trigger wording and link-first maintenance."
applyTo: ".github/{AGENTS.md,copilot-instructions.md,agents/**/*.md,prompts/**/*.md,instructions/**/*.md,skills/**/SKILL.md,hooks/**/*.json,hooks/**/*.ps1}"
---

# Regler för customization-hygien

## Håll centralfiler små
- `AGENTS.md` ska vara snabb routingyta för agentval, inte en dump av repo-dokumentation.
- `.github/copilot-instructions.md` ska bara bära repo-breda regler som verkligen behöver vara alltid på.
- Flytta smala arbetsflöden till en skill, prompt eller smal instruction i stället för att svälla centralfilerna.

## Link, don't embed
- Länka till `docs/README.md`, `docs/ARCHITECTURE.md`, `docs/DECISIONS_LOG.md` och `docs/SESSION_BRIEF.md` när detaljer redan finns där.
- Duplicera inte listor över struktur, services, testlager eller releaseflöden om de redan underhålls i `docs/`.

## Upptäckbarhet
- `description` är discovery-ytan: använd tydliga signalord och konkreta "Use when..."-formuleringar.
- För skills ska `name` matcha mappnamnet exakt.
- Nya filer ska bara skapas när en befintlig customization inte kan bära regeln utan att bli otydlig eller för bred.

## Path- och verklighetskontroll
- Kontrollera att alla nämnda filer, scripts och relative paths faktiskt finns.
- Om hook-logik flyttas mellan `.json` och `.ps1` under `.github/hooks/`, håll instruktioner och referenskontroller i sync med båda filtyperna.
- Kontrollera påståenden mot aktuell kod och aktuella docs, inte mot historiska customization-filer.
- Om äldre namn eller workflow-spår tas bort: rensa även promptar, skills och instruktioner som fortfarande refererar till dem.

## Validering
- För rena `.github`-ändringar räcker diagnostikkoll och diffgranskning normalt bättre än Flutter-QA.
- Om en customization instruerar om QA, verify eller release: se till att den nämner repo:ts faktiska tasks eller kommandon.