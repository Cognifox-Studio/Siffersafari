---
name: granska-github-customizations
description: 'Audit chat customization files under .github for broken paths, weak descriptions, stale references, name mismatches and unnecessary duplication. Use when cleaning up Copilot instructions, skills, prompts or custom agents.'
argument-hint: 'Valfritt: begränsa till en viss fil, mapp eller typ av customization under .github.'
---

# Granska GitHub-customizations

Denna skill används för att granska chat-customizations under `.github/` utan att blanda in appkod eller vanlig Flutter-QA.

## Mål

Hitta och rätta sådant som gör discovery, routing eller underhåll sämre:

- brutna eller stale filreferenser
- skill- eller agentnamn som inte matchar fil- eller mappnamn
- svaga `description`-fält utan tydliga triggerord
- centralfiler som duplicerar innehåll som redan finns i `docs/`
- gamla alias, gamla workflows eller gamla assets som fortfarande nämns i `.github/`

## Arbetsflöde

1. Börja med att läsa `.github/copilot-instructions.md` och `.github/AGENTS.md`.
2. Inventera relevant yta under `.github/skills/`, `.github/prompts/`, `.github/agents/` och `.github/instructions/`.
3. Verifiera att länkar, relativa sökvägar och namngivning matchar faktiska filer i repot.
4. Jämför påståenden mot `docs/README.md`, `docs/ARCHITECTURE.md`, `docs/DECISIONS_LOG.md` och `docs/SESSION_BRIEF.md` i stället för att anta att äldre customization-text är korrekt.
5. Föreslå eller gör den minsta rimliga saneringen.

## Regler

- Håll fokus på chat-customizations, inte produktkod.
- Följ "link, don't embed": länka till docs i stället för att kopiera struktur- eller arkitekturtext.
- Om en skill skapas eller döps om ska `name` matcha mappnamnet exakt.
- Om en agent, prompt eller instruction har svag upptäckbarhet: skärp `description` innan du skapar fler filer.
- Om flera filer säger nästan samma sak: flytta detaljregler till den smalaste filen och förenkla centralfilen.

## Validering

- Kontrollera att varje nämnd fil faktiskt finns.
- Kontrollera att frontmatter är syntaktiskt enkel och konsekvent.
- Kör diffgranskning eller diagnostikkoll för de customization-filer som ändrats.
- Kör inte `flutter analyze` om ändringen verkligen bara rör `.github`-markdown.