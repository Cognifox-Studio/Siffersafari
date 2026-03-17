---
description: "Use when the user attaches an image and asks for a usable character, game-ready character, character pipeline, SVG layers, rig spec, animation spec, Rive guide, or writes 'Gör en användbar karaktär av denna'."
---

# Bild -> användbar karaktär

Använd denna instruktion när användaren klistrar in eller bifogar en bild och vill att Copilot ska göra en användbar spelkaraktär av den.

## Mål

Förvandla en enda bild till en rigg-vänlig, spelklar karaktär för Siffersafari med konkreta filer i repo:t, inte bara en allmän beskrivning.

Repo-standard:
- Rive används för karaktärer.
- Lottie används för UI-effekter, inte som huvudformat för nya karaktärer.
- Om källbilden inte är rigg-vänlig ska du förenkla den till stora, mjuka former i stället för att försöka pseudo-rigga en detaljtung bild 1:1.

## Standardflöde

När användaren säger något i stil med "Gör en användbar karaktär av denna" ska du, om inte användaren uttryckligen begränsar uppgiften, göra detta:

1. Analysera bilden.
2. Välj ett stabilt karaktärsnamn och slug-format (`assets/characters/<slug>/`).
3. Definiera rigg-vänliga delar.
4. Skapa eller uppdatera faktiska filer för SVG-delar, config och Rive-underlag.
5. Sammanfatta vad som skapades och vad som eventuellt återstår manuellt.

## Bildanalys

Beskriv kort:
- karaktärstyp
- visuell stil
- proportioner
- färgpalett
- vilka detaljer som ska behållas
- vilka detaljer som ska förenklas eller tas bort för bättre riggning

Om bilden är svår att rigga:
- prioritera läsbar siluett
- prioritera tydligt ansikte
- prioritera separata lemmar/accessoarer
- minska smådetaljer, texturer och brus

## Filer som normalt ska skapas

Skapa så långt det är möjligt riktiga filer under:

```text
assets/
  characters/
    <slug>/
      config/
        <slug>_visual_spec.json
        <slug>_animation_spec.json
      svg/
        <slug>_head.svg
        <slug>_eyes_open.svg
        <slug>_eyes_blink.svg
        <slug>_mouth_neutral.svg
        <slug>_mouth_happy.svg
        <slug>_mouth_sad.svg
        <slug>_torso.svg
        <slug>_arm_left.svg
        <slug>_arm_right.svg
        <slug>_leg_left.svg
        <slug>_leg_right.svg
        <slug>_shoe_left.svg
        <slug>_shoe_right.svg
        <slug>_shadow.svg
      rive/
        README.md

artifacts/
  <SLUG>_RIVE_GUIDE.md
  <slug>_rive_blueprint.json
```

Om karaktären kräver särskilda accessoarer eller delar, lägg till dem konsekvent i både SVG-delar och config.

## SVG-regler

Alla SVG-delar ska vara rigg-vänliga:
- rena färgblock
- inga gradienter
- inga texturer
- tydlig outline
- centrerad huvudgrupp i egen `viewBox`
- proportioner som passar barnvänlig cartoon-stil

Varje del ska kunna importeras separat i Rive.

## JSON-regler

`<slug>_visual_spec.json` ska minst innehålla:
- namn
- version
- färger/palett
- proportioner
- stil
- delar eller namngiven deluppsättning

`<slug>_animation_spec.json` ska minst innehålla:
- karaktärsnamn
- rig/bones
- constraints
- animationsgrupper
- states
- transitions
- triggers

Följ befintliga mönster under `assets/characters/mascot/config/` när det går.

## Standardrigg

Om inget tydligare passar bilden, utgå från denna hierarki:

```text
root
 └─ pelvis
    ├─ spine
    │  └─ chest
    │     ├─ neck
    │     │  └─ head
    │     │     ├─ eyes
    │     │     └─ mouth
    │     ├─ shoulder_left
    │     │  └─ upper_arm_left
    │     │     └─ lower_arm_left
    │     │        └─ wrist_left
    │     │           └─ hand_left
    │     └─ shoulder_right
    │        └─ upper_arm_right
    │           └─ lower_arm_right
    │              └─ wrist_right
    │                 └─ hand_right
    ├─ hip_left
    │  └─ upper_leg_left
    │     └─ lower_leg_left
    │        └─ ankle_left
    │           └─ foot_left
    │              └─ toe_left
    └─ hip_right
      └─ upper_leg_right
        └─ lower_leg_right
          └─ ankle_right
            └─ foot_right
              └─ toe_right
```

Rekommenderade begränsningar:
- head: cirka 15-20 graders rotation
- shoulders: cirka 30-40 grader
- elbows och knan: bojs helst framfor allt i en riktning och med soft limits
- wrists och ankles: subtla sekundarriggar, inte huvuddrivare
- legs: cirka 20-30 grader i huvudsvang, med extra kontroll i fotled/toe om delen finns
- accessoarer ska följa relevant kroppsdel, inte ligga frikopplade

## Standardanimationer

Skapa minst specifikation för:
- idle
- happy eller answer_correct
- sad eller answer_wrong
- tap eller user_tap
- enter
- exit

Animationerna ska vara enkla, tydliga och barnvänliga. Prioritera läsbar feedback framför komplex show-animation.

## Repo-specifika regler

- Om uppgiften gäller en ny karaktär: skapa en ny mapp under `assets/characters/<slug>/`.
- For humanoid-karaktarer: utga fran `assets/characters/_shared/config/humanoid_base_form_v1.json` och lagg in en `baseFormRef` i `<slug>_visual_spec.json`.
- For humanoid-karaktarer: animation spec ska som standard anvanda det utokade ledschemat med pelvis, shoulder, wrist, hip, ankle och toe dar det ar rimligt, aven om vissa slutassets binds till samma bilddel i forsta iterationen.
- For humanoid-karaktarer: preview ska folja Loke-standarden (inline SVG + explicit T-pose-overrides), inte enbart statisk composite-bild.
- Om uppgiften gäller maskoten: återanvänd etablerad struktur och namnkonventioner där det är rimligt.
- Om användaren vill integrera karaktären i appen: uppdatera även `pubspec.yaml` och relevant tema/widget-konfiguration.
- Om ingen faktisk `.riv` kan skapas i verktygskedjan: påstå inte att den finns. Skapa i stället komplett Rive-guide + blueprint + importinstruktioner.
- Om ett genereringsscript behövs för återanvändning eller större assetmängd: följ stilen i `scripts/generate_mascot_svg_parts.dart` och `scripts/generate_rive_blueprint.dart`.

## Svarskontrakt

När du utför detta arbetsflöde ska du:
- skapa faktiska filer när användaren vill att arbetet ska utföras
- vara tydlig med vad som är automatiserat och vad som eventuellt återstår i Rive Editor
- inte stanna vid en generell guide om användaren ber dig göra jobbet
- hålla svaret kort, men redovisa skapade paths och nästa praktiska steg

## Bra triggerfraser

Ladda denna instruktion när användaren skriver eller menar något som liknar:
- "Gör en användbar karaktär av denna"
- "Gör en spelklar karaktär av bilden"
- "Bygg en karaktärspipeline från den här bilden"
- "Generera SVG-lager, rigg-spec och animation-spec från denna karaktär"
- "Gör om den här bilden till en Rive-vänlig karaktär"