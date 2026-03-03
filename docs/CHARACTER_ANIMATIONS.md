# Karaktärsanimationer (Ville / character_v2)

Mål: kunna använda maskoten (t.ex. `character_v2`) som **animerad** figur i UI utan att introducera ny UI/nya flöden.

## Rekommenderad approach (MVP)

- Använd **frame-sekvenser** (PNG/WebP med transparens) och spela upp dem som en enkel loop.
- I appen används widgeten `MascotView` som stödjer både:
  - statisk bild (idag), och
  - frame-sekvens (senare) utan att ändra resten av UI.

## Asset-struktur (för framtida frames)

Lägg bara in **kuraterade** frames i `assets/`.
Allt som genereras under iteration ska ligga i `artifacts/` tills det är godkänt.

Förslag:

```
assets/images/characters/
  character_v2/
    idle/
      idle_000.png
      idle_001.png
      ...
    wave/
      wave_000.png
      wave_001.png
      ...
```

Konvention:
- Filnamn: `<anim>_<index med 3 siffror>.png`
- Samma dimensioner för alla frames i en animation.
- Helst transparent bakgrund.

## Koppla in i UI

- Idag används `AppThemeConfig.characterAsset` (en statisk PNG).
- När frames finns kan vi (nästa steg) låta `AppThemeConfig` även ange en frame-sekvens för t.ex. "idle" och använda den i `MascotView(frames: [...])`.

## Generering (ComfyUI)

- Använd scripts för att generera pose-pack i `artifacts/comfyui/...`.
- Välj ut och ev. frilägg de frames du vill använda, och flytta dem sedan manuellt till `assets/images/characters/...` enligt strukturen ovan.

## Frame-sekvenser (rekommenderat)

För riktiga animationer (arm/ben/ansikte) behöver varje frame vara en egen genererad bild.

Startset vi bygger först:
- `idle/`
- `jump/`
- `run/`
- `wave/`

Rekommenderat flöde:
- Generera frames till `artifacts/comfyui/...` (iteration).
- När en loop känns bra: kopiera/byt namn till `assets/images/characters/character_v2/<anim>/` enligt konventionen ovan.

### Script: generera frames via ComfyUI

Det finns ett helper-script som genererar en frame i taget (en ComfyUI-körning per frame) och sparar dem med rätt filnamn:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 -Anim idle -Frames 8 -AlphaAll
```

Exempel för wave:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 -Anim wave -Frames 8 -AlphaAll
```
