---
name: "qa-quick-select"
description: "Välj rätt QA-flöde för senaste ändringarna och kör minsta rimliga verifiering"
argument-hint: "Valfritt: beskriv ändringen eller ange testpath/riskområde"
agent: "agent"
---

Välj rätt QA-nivå för den aktuella ändringen i detta repo och kör den mest träffsäkra verifieringen.

Utgå från dessa källor och regler:

- [copilot-instructions.md](../copilot-instructions.md)
- [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- [docs/DECISIONS_LOG.md](../docs/DECISIONS_LOG.md)
- [docs/SESSION_BRIEF.md](../docs/SESSION_BRIEF.md)
- [.vscode/tasks.json](../.vscode/tasks.json)

Använd workspace-tasks när de passar bättre än manuella kommandon.

Följ denna beslutsordning:

1. Läs senaste ändringar eller användarens beskrivning och avgör risknivå.
2. Om ändringen bara rör dokumentation, promptar eller instruktioner: förklara kort varför Flutter-QA inte behövs.
3. Om ändringen är liten och lokal: kör `flutter analyze` och minst ett relevant riktat test.
4. Om ändringen är bred eller rör flera lager: kör analyze + full testsvit.
5. Om ändringen påverkar navigation, rendering, assets eller device-specifikt beteende: inkludera Pixel_6 sync/install-flödet när det är motiverat.
6. Om ändringen rör kritiska appflöden: överväg relevant integration smoke och motivera valet.

Prioritera dessa tasks när de matchar behovet:

- `QA: Analyze`
- `QA: Test (valfri path)`
- `QA: Test (alla)`
- `QA: Analyze + Test (valfri path)`
- `QA: Analyze + Full Test (stora ändringar)`
- `Flutter: Sync (Pixel_6 only)`
- `Pixel_6: Sync + QA (valfri testpath)`
- `QA: Integration Smoke (core)`
- `QA: Integration Smoke (full)`

Svarskrav:

- Säg först vilken QA-nivå du valde och varför.
- Kör verifieringen, inte bara föreslå den.
- Om något inte kan köras, säg exakt vad som blockerar.
- Avsluta med en kort sammanfattning:
  - vad som kördes
  - vad som passerade eller föll
  - om ytterligare QA rekommenderas