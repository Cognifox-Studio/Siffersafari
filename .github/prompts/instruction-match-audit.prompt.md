---
name: "instruction-match-audit"
description: "Use when du vill matcha instructions, skills och narliggande prompts mot en fil, mapp eller andringsyta i detta repo"
argument-hint: "Ange en fil, mapp eller ett scope, till exempel lib/features/quiz/presentation/ eller .github/prompts/"
agent: "agent"
---

Gor en read-only matchningsaudit for att avgora vilka repo-customizations som faktiskt bor laddas for en viss andringsyta.

Utga fran dessa kallor:

- [.github/AGENTS.md](../AGENTS.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- `.github/instructions/`
- `.github/skills/`
- `.github/prompts/`
- [docs/README.md](../../docs/README.md) bara om scopebeskrivningen ar for bred for att matcha direkt

Arbetsordning:

1. Utga fran anvandarens fil, mapp eller scope och hitta de instruktioner vars `applyTo` eller beskrivning faktiskt matchar.
2. Lista vilka skills som ar direkt relevanta for samma yta och vilka som bara ar narliggande men inte primara.
3. Peka ut narliggande prompts eller agenter om de ger battre startyta an en skill.
4. Flagga overlap, luckor eller potentiellt for breda instruktioner bara om det finns tydlig evidens.
5. Hall auditen read-only om anvandaren inte uttryckligen bad om att nagot ska andras.

Svarskrav:

- Borja med en kort sammanfattning av den matchade ytan.
- Lista matchande instructions forst, med kort motivering per fil.
- Lista sedan relevanta skills och prompts/agenter.
- Sag uttryckligen om ingen tydlig instruction matchar.
- Avsluta med hogst en kort rekommendation om basta nasta steg.