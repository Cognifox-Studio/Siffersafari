# Karaktärsanimationer (Ville / character_v2)

Mål: använda maskoten (t.ex. `character_v2`) som **animerad** figur i UI utan att introducera nya flöden.

## Nuläge (2026-03-05)

- ✅ **Idle-animation** används i appen (`assets/images/characters/character_v2/idle/`)
- ✅ Widgeten `MascotView` stödjer frame-sekvenser (loop)
- ❌ Jump/Run/Wave är inte implementerade (assets borttagna)

## Asset-struktur

Lägg bara in **kuraterade** frames i `assets/`.
Allt som genereras under iteration ska ligga i `artifacts/` tills det är godkänt.

Struktur:
```
assets/images/characters/
  character_v2/
    idle/
      idle_000.png
      idle_001.png
      ...
```

Konvention:
- Filnamn: `<anim>_<frameno start 000>.png`
- Samma dimensioner för alla frames i en animation
- Transparent bakgrund

## Generering (ComfyUI)

Använd `scripts/generate_character_v2_animation_frames.ps1` för att generera frame-sekvenser:

```powershell
powershell -ExecutionPolicy Bypass `
  -File scripts/generate_character_v2_animation_frames.ps1 `
  -Anim idle -Frames 8 -AlphaAll
```

Frames genereras till `artifacts/comfyui/...`. Välj ut bästa och flytta manuellt till `assets/`.

Tips:
- Använd `-StableSeed` för konsekvent karaktär över frames
- Håll `-Denoise` låg (0.25–0.45) för att undvika drift
- Preview med GIF: `dart run scripts/preview_animation_gif.dart`
