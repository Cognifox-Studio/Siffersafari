---
name: documentation
description: 'Audit and update Siffersafari documentation. Use when the user says dokumentera, uppdatera docs, documentation audit, synka docs med kod, Diátaxis, or when code/workflow changes require docs to match reality.'
argument-hint: 'Beskriv vilka kod-, struktur-, workflow- eller assetändringar som ska speglas i dokumentationen.'
---

# Documentation

## När den ska användas
- När användaren ber om dokumentation, docs-audit eller Diátaxis-städning.
- När kod, struktur, services, assets eller workflow har ändrats och dokumentationen behöver synkas.
- När dokument säger emot varandra och repo:t behöver en enda aktuell sanning.

## Källor (Länka hellre än att kopiera)
- docs/README.md för dokumentationsindex och facitordning.
- docs/ARCHITECTURE.md för faktisk arkitektur och startup.
- docs/PROJECT_STRUCTURE.md för faktisk repo-struktur.
- docs/SERVICES_API.md för service- och providerkontrakt.
- docs/DECISIONS_LOG.md för stabila beslut och varför.

## Regler
1. Dokumentation ska spegla faktisk kod, struktur, assets och workflow. Kopiera inte in text från dessa när de kan länkas till med Markdown.
2. Använd Diátaxis-klassning i dokumentheadern när dokumentet är under docs/.
3. Ta bort eller markera föråldrad information när verkligheten har ändrats.
4. Skapa inte exempel som visar features, scripts eller assets som inte finns.

## Arbetsflöde
1. Identifiera berörda dokument från docs/README.md.
2. Jämför mot faktisk kod och workspace-struktur.
3. Uppdatera minsta nödvändiga dokument.
4. Kontrollera interna länkar och att nämnda filer/scripts faktiskt finns.
5. Sammanfatta vad som ändrades och vilka kvarstående osäkerheter som finns.
