---
description: "Process för att bygga spelklara karaktärer och bevara procedurell SVG-styling"
applyTo: "assets/characters/**, scripts/generate_*.dart, tools/**/*.py"
---

# Bild -> Användbar karaktär & SVG Styling

Dessa regler gäller när en ny karaktär genereras från en bild (pipeline) OCH när färg/stil appliceras på våra procedurella biomekaniska SVG-skelett.

## 1. Mål & Standard (Pipeline)
Förvandla en enda bild till en rigg-vänlig karaktär för Siffersafari. Förenkla detaljtunga bilder till stora, mjuka former i stället för 1:1 rigning.
- **Runtime:** Produkt-UI använder exklusivt **SVG-first** procedur/frame-by-frame-runtime.
- Lottie används **endast** för generiska UI-effekter. `.riv`-filer är endast research.
- **Mappstruktur:** Skapa allt under `assets/characters/<slug>/` uppdelat i `config/` (`_visual_spec.json`, `_animation_spec.json`) och `svg/` (rena, separerade delar typ huvuden, armar, osv). Mappas helst mot `humanoid_base_form_v1.json`.

## 2. Bevarande av Biomekanik (Styling i code/SVG)
När karaktärer får kläder, hudfärg eller accessoarer (styling) på ett procedurgenererat SVG-skelett (`ville_run_*.svg`):
- **Skydda transform-matriserna:** Ändra **aldrig** befintliga `transform`-attribut (rotate, translate) på de strukturella huvudgrupperna (`<g>`). Dessa innehåller uträknad fysik (torsion, whip-effect).
- **Applicera stil internt:** Färger (`fill`, `stroke`) appliceras på inre geometrier (`<path>`, `<rect>`) *inuti* transformations-grupperna.
- **Syskon för accessoarer:** Ryggsäckar eller byxor läggs in som nya shape-syskon inuti (t.ex.) torons `<g>`-node, så att de ärver rotationsfysiken utan att rubba ankar-koordinaterna.
- **Behåll ID:n:** Ta aldrig bort knutpunkts-ID:n (t.ex. `id="head"`, `id="torso"`) eftersom våra scripts förlitar sig på dessa "bones" för iterationer.