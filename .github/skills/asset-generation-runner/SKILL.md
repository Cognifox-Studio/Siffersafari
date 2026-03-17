---
name: asset-generation-runner
description: 'Generate or regenerate game assets for Siffersafari. Use when changing character specs, SVG parts, Lottie effects, Rive blueprints, composite SVG output, or when the user says generate assets, regenerera assets, rebuild visuals, uppdatera animation assets, or sync generated files.'
argument-hint: 'Describe what changed and whether to run one generator or all.'
---

# Asset Generation Runner

## När den ska användas
- När en visual spec eller animation spec har ändrats.
- När SVG-delar, Lottie-effekter eller Rive-blueprints behöver genereras om.
- När en preview eller appintegration visar gamla eller saknade genererade filer.
- När användaren vill köra hela asset-pipelinen i rätt ordning.

## Mål
Få fram korrekta genererade filer i `assets/` och `artifacts/` med minsta möjliga manuella steg.

## Arbetsflöde
1. Identifiera vilken input som ändrats.
   - Karaktärs-SVG/spec: kör SVG-generatorn.
   - UI-effekter: kör Lottie-generatorn.
   - Rigg/animation spec: kör Rive blueprint-generatorn.
   - Osäker eller större ändring: kör hela asset-pipelinen.
2. Föredra repo:ts befintliga VS Code tasks framför fria terminalkommandon.
   - `Assets: Generate Mascot SVG Parts`
   - `Assets: Generate Lottie Effects`
   - `Assets: Generate Rive Blueprint`
   - `Assets: Generate Mascot Composite SVG`
   - `Assets: Generate All (SVG + Lottie + Rive Blueprint)`
3. Verifiera att förväntade output-filer faktiskt uppdaterades i rätt mappar.
4. Om nya filer ska användas i appen, kontrollera att `pubspec.yaml` och relevant Flutter-kod refererar rätt asset-path.
5. Redovisa tydligt:
   - vad som genererades
   - vilka filer som blev output
   - om något fortfarande måste göras manuellt

## Kvalitetsgränser
- Påstå inte att en `.riv`-fil finns om bara blueprint/guide genererats.
- Ändra inte genererade filer manuellt om källan är ett script eller en spec, om inte användaren uttryckligen vill göra ett engångsingrepp.
- Om asset-cache misstänks i emulator/app, föreslå ny filnamnsversion eller deterministisk device-sync i stället för att gissa.

## Repo-specifika kommandon
- Task: `Assets: Generate All (SVG + Lottie + Rive Blueprint)`
- Script: `dart run scripts/generate_mascot_svg_parts.dart`
- Script: `dart run scripts/generate_lottie_effects.dart`
- Script: `dart run scripts/generate_rive_blueprint.dart`
- Script: `dart run scripts/generate_mascot_composite.dart`

## Förväntad output
- Uppdaterade filer under `assets/characters/...`, `assets/ui/lottie/...` och/eller `artifacts/...`
- Kort status på vad som är klart automatiserat och vad som återstår