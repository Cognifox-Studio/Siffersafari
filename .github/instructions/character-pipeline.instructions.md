---
description: "Use when the user attaches an image and asks for a usable character, game-ready character, character pipeline, SVG layers, rig spec, animation spec, Rive guide, or writes 'Gör en användbar karaktär av denna'."
---

# Bild -> användbar karaktär

Använd denna instruktion när användaren klistrar in eller bifogar en bild och vill att Copilot ska göra en användbar spelkaraktär av den.

## Mål

Förvandla en enda bild till en rigg-vänlig, spelklar karaktär för Siffersafari med konkreta filer i repo:t.

Repo-standard:
- Produkt-UI använder SVG-first runtime för karaktärer.
- Lottie används för UI-effekter, inte som huvudformat för nya karaktärer.
- Rive-guide och blueprint kan skapas som manuellt framtidsunderlag, men \.riv\ är inte en aktiv runtime-dependency i huvudflödet.
- Förenkla detaljtunga källbilder till stora, mjuka former i stället för att försöka pseudo-rigga 1:1.

## Standardflöde

1. Analysera bilden.
2. Välj ett stabilt karaktärsnamn och slug-format (\ssets/characters/<slug>/\).
3. Definiera rigg-vänliga delar.
4. Skapa eller uppdatera faktiska filer för SVG-delar, config och eventuellt Rive-underlag.
5. Sammanfatta vad som skapades.

## Bildanalys
Beskriv karaktärstyp, stil, vad som ska behållas och vad som förenklas/tas bort. Prioritera siluett, ansikte och rena lemmar.

## Filer som normalt ska skapas

Ladda ner och strukturera allt enligt denna modell:
\\\	ext
assets/
  characters/
    <slug>/
      config/
        <slug>_visual_spec.json
        <slug>_animation_spec.json
      svg/
        <slug>_head.svg
        <slug>_eyes_open.svg
        <slug>_torso.svg
        ...
        <slug>_shadow.svg

Optional future-rigging material:
artifacts/
  <SLUG>_RIVE_GUIDE.md
  <slug>_rive_blueprint.json
\\\

## SVG-regler
Rena färgblock, inga gradienter, ingen struktur. Centrerad, separerbar, barnvänlig outline. Ska fungera i appens SVG-runtime.

## Standardrigg
För humanoider (chest/neck/shoulders/pelvis/hips/ankles). Följ \_shared/config/humanoid_base_form_v1.json\ därmed rimligt och ange \aseFormRef\.

## Svarskontrakt
Skapa alltid riktiga filer, inga svepande ord. Markera vad som är gjort och vad som återstår lokalt.
