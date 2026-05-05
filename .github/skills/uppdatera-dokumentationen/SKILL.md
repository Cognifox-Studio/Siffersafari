---
name: uppdatera-dokumentationen
description: 'Audit and update Siffersafari documentation. Use when the user says dokumentera, uppdatera docs, documentation audit, synka docs med kod, Diataxis, or when code or workflow changes require docs to match reality.'
argument-hint: 'Beskriv vilka kod-, struktur-, workflow- eller assetändringar som ska speglas i dokumentationen.'
---

# Documentation

## När den ska användas
- När användaren ber om dokumentation, docs-audit eller Diataxis-städning.
- När kod, struktur, services, assets eller workflow har ändrats och dokumentationen behöver synkas.
- När dokument säger emot varandra och repo:t behöver en enda aktuell sanning.

## Källor (länka hellre än att kopiera)
- docs/README.md för dokumentationsindex och facitordning.
- docs/ARCHITECTURE.md för faktisk arkitektur och startup.
- docs/PROJECT_STRUCTURE.md för faktisk repo-struktur.
- docs/SERVICES_API.md för service- och providerkontrakt.
- docs/DECISIONS_LOG.md för stabila beslut och varför.
- docs/SESSION_BRIEF.md för aktuellt läge, senaste leveranser och nästa steg.

## Regler
1. Dokumentation ska spegla faktisk kod, struktur, assets och workflow. Kopiera inte in text när källan kan länkas.
2. Använd Diataxis-klassning i dokumentheadern när dokumentet ligger under docs/.
3. Ta bort eller markera föråldrad information när verkligheten har ändrats.
4. Skapa inte exempel som visar features, scripts eller assets som inte finns.
5. Efter strukturella ändringar är drift-kontroll mot `docs/ARCHITECTURE.md`, `docs/SERVICES_API.md` och `docs/SESSION_BRIEF.md` obligatorisk.

## Strukturella andringar som alltid triggar drift-kontroll
- filer eller ansvar flyttas mellan `app/`, `features/`, `presentation/`, `core/`, `domain/` eller `data/`
- startup, routing, persistens eller huvudflode andras
- services, providers eller eventkontrakt andras
- nya skills, scripts eller repo-workflows laggs till eller andras

## Drift-kontroll som maste goras
1. Jamfor andringen mot `docs/ARCHITECTURE.md`.
   - lageransvar
   - startup och routing
   - persistensmodell
   - huvudflode profilval -> home -> quiz -> resultat -> story
2. Jamfor andringen mot `docs/SERVICES_API.md`.
   - services och providers
   - quiz- och analytics-kontrakt
   - repository-ansvar
3. Jamfor andringen mot `docs/SESSION_BRIEF.md`.
   - aktuellt lage
   - senaste leveranser
   - nasta steg
4. Om ett dokument ar as-is och verkligheten har andrats: uppdatera dokumentet i samma slice eller sag explicit varfor andringen medvetet inte ar dokumenterad annu.

## Arbetsflode
1. Identifiera berorda dokument fran docs/README.md.
2. Jamfor mot faktisk kod och workspace-struktur.
3. Gor drift-kontroll mot `docs/ARCHITECTURE.md`, `docs/SERVICES_API.md` och `docs/SESSION_BRIEF.md` om andringen ar strukturell.
4. Uppdatera minsta nodvandiga dokument.
5. Kontrollera interna lankar och att namnda filer och scripts faktiskt finns.
6. Sammanfatta vad som andrades och vilka kvarstaende osakerheter som finns.