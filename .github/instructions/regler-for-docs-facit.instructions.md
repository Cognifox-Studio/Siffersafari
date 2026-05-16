---
name: "Docs-facit"
description: "Use when editing docs/**/*.md. Keeps documentation anchored to repo facit files, Diataxis intent and verified file/script references."
applyTo: "docs/**/*.md"
---

# Regler för docs-facit

## Nulägesfacit först
- Använd `docs/README.md` som index och facitordning för dokumentationen.
- Kontrollera påståenden mot `docs/ARCHITECTURE.md`, `docs/PROJECT_STRUCTURE.md`, `docs/SERVICES_API.md`, `docs/DECISIONS_LOG.md` och `docs/SESSION_BRIEF.md` innan du skriver om nuläge, struktur, services eller senaste status.
- Om kod och docs krockar: uppdatera docs mot faktisk kod, inte mot äldre docs eller gamla promptar.

## Link, don't embed
- Länka till befintliga docs i stället för att duplicera hela checklistor, arbetsflöden eller arkitekturförklaringar.
- Återanvänd etablerade namn på features, scripts, tasks och workflows exakt som de finns i repot.
- Skapa inte exempel, kommandon eller strukturbeskrivningar som inte kan verifieras i workspace.

## Skrivsätt och scope
- Håll docs korta, konkreta och repo-specifika.
- Bevara dokumentets Diataxis-roll: tutorial, how-to, reference eller explanation.
- Lägg aktuellt nuläge i as-is-dokument och lägg beslut eller historik i rätt logg i stället för att blanda ihop dem.

## Verifiering före avslut
- Kontrollera att alla nämnda filer, scripts, tasks, workflows och kataloger faktiskt finns.
- Efter struktur- eller workflow-ändringar: jämför särskilt mot `docs/ARCHITECTURE.md`, `docs/PROJECT_STRUCTURE.md` och `docs/SESSION_BRIEF.md` så att de inte driver isär.
- Om ett dokument medvetet inte uppdateras i samma slice trots relevant kodändring: säg det uttryckligen.
