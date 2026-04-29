---
name: asset-generation-runner
description: 'Generate, refresh, validate, or promote Siffersafari assets. Use when changing SVG character specs/parts, mascot composite output, character promotion, generated assets, or when the user says generate assets, regenerera assets, rebuild visuals, uppdatera animation assets, sync generated files, or promote character.'
argument-hint: 'Describe which asset or character changed, and whether to generate, promote, or verify only.'
---

# Asset Generation Runner

## När den ska användas
- När en karaktärs visual/animation spec eller SVG-delar har ändrats.
- När mascot SVG-parts eller composite-SVG behöver genereras om.
- När en ny/uppdaterad karaktär ska promotas.
- När en preview/appintegration visar gamla/saknade filer.

## Mål
Ta fram korrekta filer i \ssets/\ och \rtifacts/\ med repo:ts befintliga scripts, och verifiera referenser.

## Repo-standard
- Produkt-UI är SVG-first för mascot/characters. (Ingen aktiv Rive-runtime).
- \.riv\ och Rive-blueprints är research/framtida underlag och exporteras manuellt om de behövs.
- Lottie används bara för UI-effekter.

## Arbetsflöde
1. Föredra repo:ts VS Code tasks före fria anrop:
   - \Assets: Generate Mascot SVG Parts\
   - \Assets: Generate Mascot Composite SVG\
   - \Assets: Generate All (SVG)\
   - \Assets: Promote New/Update Character\
   - \Assets: Verify Git Changes\
2. Verifiera att förväntade filer uppdaterades.
3. Om appen ska använda nya assets: kolla \pubspec.yaml\ och relevanta widget/config-filer.
4. Kör relevant QA när assets påverkar appflöden.

## Kvalitetsgränser
- Påstå inte att en \.riv\-fil nyss skapats om du inte faktiskt vet att det är sant.
- Nämn inga generator-scripts som inte finns.
- Redovisa kort vad som kördes och resultatet.
