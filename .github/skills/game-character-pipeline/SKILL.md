---
name: game-character-pipeline
description: 'Create a usable, game-ready character pipeline from an image, concept, or existing preview. Use when the user asks for spelklar karaktär, användbar karaktär, SVG layers, rig spec, animation spec, Rive guide, character pipeline, mascot rebuild, or Gör en användbar karaktär av denna.'
argument-hint: 'Describe the source character, desired style, and whether app integration is included.'
---

# Game Character Pipeline

## När den ska användas
- När användaren bifogar en bild och vill ha en användbar spelkaraktär.
- När en ny/avancerad figur behöver brytas ned till rigg-vänliga delar.

## Mål
Skapa faktiska filer för framtida riggning, animering och validering. SVG-first är den nuvarande produkten.

## Standardoutput
- \ssets/characters/<slug>/config/<slug>_visual_spec.json\
- \ssets/characters/<slug>/config/<slug>_animation_spec.json\
- Rigg-vänliga SVG-delar under \ssets/characters/<slug>/svg/\
- Preview under \rtifacts/animation_preview/...\
- Eventuell \rtifacts/<slug>_rive_blueprint.json\ och Rive-guide, som manuellt framtidsunderlag.

## Arbetsflöde
1. Förenkla brus, smådetaljer och gör bilden cartoon-rimlig.
2. Välj namn och slug.
3. Utgå från humanoid-hierarkin (pelvis/spine/chest/etc.) om applicerbart.
4. Skapa/uppdatera config och SVG-delar.
5. Bygg inline SVG-preview (T-pose, idle, etc.) för att kvalitetssäkra.
6. Om framtida Rive ämnas: skapa Rive-guide och blueprint. (Använd inte \.riv\ som runtime-produkt just nu).

## Hårda regler
- Produkt-UI är SVG-first. Lottie är bara UI. Rive är framtida underlag.
- Påstå inte att en \.riv\ existerar om du inte fixat det själv.
- Inga detaljtunga pseudo-rigg-försök från en ensam PNG. De ska göras block- och rigg-vänliga.

## Begränsningar
- Kombinera med \nimation-preview-lab\ om fokus är timing/rörelsekvalitet i befintlig preview.
- Kombinera med \sset-generation-runner\ om filer ska uppdateras via färdiga scripts.
