---
name: game-character-pipeline
description: 'Create a usable, game-ready character pipeline from an image, concept, or existing preview. Use when the user asks for spelklar karaktär, användbar karaktär, SVG layers, rig spec, animation spec, Rive guide, character pipeline, mascot rebuild, or Gör en användbar karaktär av denna.'
argument-hint: 'Describe the source character, desired style, and whether app integration is included.'
---

# Game Character Pipeline

## När den ska användas
- När användaren bifogar en bild och vill ha en användbar spelkaraktär.
- När en ny mascot eller humanoid figur behöver brytas ned till rigg-vänliga delar.
- När en befintlig preview ska lyftas till riktig asset-struktur med spec + blueprint.

## Mål
Skapa faktiska repo-filer för en karaktär som går att rigga, animera och senare integrera i appen.

## Standardoutput
- `assets/characters/<slug>/config/<slug>_visual_spec.json`
- `assets/characters/<slug>/config/<slug>_animation_spec.json`
- rigg-vänliga SVG-delar under `assets/characters/<slug>/svg/`
- eventuell preview under `artifacts/animation_preview/...`
- `artifacts/<slug>_rive_blueprint.json`
- `artifacts/<SLUG>_RIVE_GUIDE.md`

## Arbetsflöde
1. Analysera källan kort.
   - Behåll tydlig siluett, ansikte och viktiga attribut.
   - Förenkla brus, smådetaljer och sådant som inte är rigg-vänligt.
2. Välj stabilt namn och slug.
3. Avgör om figuren är humanoid.
   - För humanoider: utgå från delhierarkin pelvis/spine/chest/neck/head/shoulders/hips/ankles/toes där det är rimligt.
4. Skapa eller uppdatera faktiska config-filer och SVG-delar.
5. Om preview behövs: bygg inline SVG-preview med tydliga lägen som T-pose, idle, pivot eller wave i `artifacts/animation_preview/`.
6. Skapa Rive-guide och blueprint.
7. Om användaren vill integrera i appen: uppdatera även asset-referenser och relevanta widgets/teman.

## Hårda regler
- Rive är standard för karaktärer. Lottie är för UI-effekter, inte huvudformat för nya karaktärer.
- Påstå inte att `.riv` finns om den inte faktiskt skapats/exporterats.
- Försök inte pseudo-rigga en detaljtung ensam PNG 1:1. Förenkla till större, mjuka former först.
- Följ repo:ts etablerade karaktärspipeline i `.github/instructions/character-pipeline.instructions.md`.

## Kvalitetsgränser
- Alla delar ska vara separerbara och rimliga att vikta i Rive.
- Animation-spec ska minst täcka `idle`, `answer_correct` eller `happy`, `answer_wrong` eller `sad`, `tap`, `enter`, `exit`.
- Var tydlig med vad som är automatiserat kontra manuellt Rive-arbete.

## När skillen inte räcker ensam
- Om användaren främst vill finjustera rörelse i en befintlig preview: använd även `animation-preview-lab`.
- Om användaren främst vill generera om filer från redan färdiga specs: använd även `asset-generation-runner`.