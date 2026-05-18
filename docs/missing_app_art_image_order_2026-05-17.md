<!--
typ: reference
syfte: Repo-specifik bildbeställning för saknade aktiva visuella assets
uppdaterad: 2026-05-17
-->

# Missing App Art Image Order (2026-05-17)

Detta underlag är inventerat mot faktisk kod, faktiska filer i `assets/` och lokala original i `_incoming/`.
Det inkluderar bara aktiva visuella luckor i nuvarande app och utesluter redan existerande assets, vuxenverktyg/UI-ikoner samt legacy-SVG-spår som inte används aktivt i runtime.

Status 2026-05-17 efter första inkommande batch:
- Integrerat i appen: `item_pet_zebra_companion_nobg.png`
- Integrerat i appen: `map_fruit_glade.png`, `map_bridge.png`, `map_cartography_camp.png`, `map_temple_gate.png`, `map_sun_temple.png`, `map_forest_grove.png`, `map_drum_grove.png`, `map_stone_gate.png`, `map_treasure_cache.png`
- Kvar som verkliga bildluckor: `map_shadow_trail.png`, `biome_night_forest_preview.png`, `biome_star_desert_preview.png`

## Underlag

Ägande ytor och facit i kod:
- [lib/domain/entities/inventory_item.dart](../lib/domain/entities/inventory_item.dart)
- [lib/features/home/presentation/widgets/camp_scene_view.dart](../lib/features/home/presentation/widgets/camp_scene_view.dart)
- [lib/features/story/presentation/screens/story_map_screen.dart](../lib/features/story/presentation/screens/story_map_screen.dart)
- [lib/core/services/story_progression_service.dart](../lib/core/services/story_progression_service.dart)
- [lib/core/theme/app_theme_config.dart](../lib/core/theme/app_theme_config.dart)
- [lib/gen/assets.g.dart](../lib/gen/assets.g.dart)

Verifierat redan på plats och ska inte beställas igen:
- `assets/images/themes/jungle/*`
- `assets/images/themes/space/*`
- `assets/images/story/cabin.png`
- `assets/images/story/campfire.png`
- `assets/images/story/map_fruit_glade.png`
- `assets/images/story/map_bridge.png`
- `assets/images/story/map_cartography_camp.png`
- `assets/images/story/map_temple_gate.png`
- `assets/images/story/map_sun_temple.png`
- `assets/images/story/map_forest_grove.png`
- `assets/images/story/map_drum_grove.png`
- `assets/images/story/map_stone_gate.png`
- `assets/images/story/map_treasure_cache.png`
- `assets/images/story/map_waterfall.png`
- `assets/images/items/item_pet_zebra_companion_nobg.png`
- de befintliga item-assets under `assets/images/items/`
- befintliga UI-ikoner och UI-bilder under `assets/images/ui/`

Verifierat men ska inte bildbeställas:
- `lib/gen/assets.g.dart` innehåller fortfarande en legacy-path till `assets/characters/loke/svg/loke_composite.svg`, men ingen aktiv användning hittades i `lib/`. Det är ett cleanup-/regenereringsspår, inte ett nytt bildbehov.

## Globala krav

- Platt 2D-stil för barnapp.
- Tydliga siluetter och stora enkla former.
- Ingen fotorealism, inga verkliga personer, ingen text i bilden.
- Inga 3D-effekter, inga glossy highlights och inga tunga gradients.
- PNG-first leverans. Om asseten är cutout: leverera transparent PNG eller format som enkelt kan exporteras till transparent PNG.
- Färger ska fungera ovanpå appens befintliga djungel- och rymdpaletter utan att bli leriga eller mörka.
- Objekten måste vara läsbara redan vid små UI-storlekar, ungefär 44 till 54 px.
- Barnvänligt uttryck: mjuka hörn, ingen aggressiv pose, inga skrämmande ansikten.
- COPPA-säkert: inga mänskliga foton, inga varumärken, inga läsbara texter eller skyltar i bilderna.

## Asset-lista

| Föreslaget filnamn | Kategori | Föreslagen target path | Target size i UI | Behöver _nobg? | Plats och syfte | Beskrivning |
| --- | --- | --- | --- | --- | --- | --- |
| `map_shadow_trail.png` | cutout | `assets/images/story/map_shadow_trail.png` | ca 48 till 54 px | Nej | Story map node för `sceneTag == skugga` | En mörk stig eller skuggad trädkorridor med enkel form, inte skrämmande. Transparent bakgrund. |
| `biome_night_forest_preview.png` | full scene | `assets/images/story/biome_night_forest_preview.png` | ca 48 till 52 px cirkelcrop i teaser, även användbar som 96 px thumbnail | Nej | Låst biome-teaser för `Nattskogen` i home/story map | En liten nattlig skogsvinjett med blågröna träd, stjärnhimmel eller månljus, utan text och utan figurer i fokus. Motivet ska fungera som en enkel teaserbild för låst värld. |
| `biome_star_desert_preview.png` | full scene | `assets/images/story/biome_star_desert_preview.png` | ca 48 till 52 px cirkelcrop i teaser, även användbar som 96 px thumbnail | Nej | Låst biome-teaser för `Stjärnöknen` i home/story map | En liten rymdöken-vinjett med sanddyner, stjärnhimmel och klar siluett. Ingen text. Ska tåla liten visning i låst teaser. |

## Prioriterad order

Beställ i denna ordning om du vill dela upp leveransen:

1. `map_shadow_trail.png`
2. `biome_night_forest_preview.png`
3. `biome_star_desert_preview.png`

## Engelska AI-prompter

### Prompt A — Shadow trail landmark

```text
CRITICAL INSTRUCTION: Do not rewrite this prompt. Use it EXACTLY as written.
Create ONE flat 2D children's game cutout asset for a story map in a children's math adventure app. The asset is a shadow-trail landmark used for the sceneTag "skugga".

Deliverable:
- 1 separate transparent PNG-ready cutout
- filename target: map_shadow_trail.png
- square composition, centered, easy to crop
- readable at very small UI size (roughly 48 to 54 px on screen)

Visual requirements:
- flat 2D illustration
- child-friendly, soft rounded shapes, safe and readable
- strong silhouette
- no photorealism
- no text in the image
- transparent background
- no 3D shading, no glossy rendering, no lens effects
- dark jungle path or shadowy trail motif
- slightly mysterious but not scary
- simple foreground shape language that still reads at tiny size
- should feel like a map landmark, not a full environment painting

Safety requirements:
- no real people
- no brand references
- COPPA-safe children's app style

Output intent:
This image will replace a generic Material icon in the Flutter story map and must work as a transparent landmark cutout.
```

### Prompt B — Locked biome teaser pair

```text
CRITICAL INSTRUCTION: Do not rewrite this prompt. Use it EXACTLY as written.
Create TWO small full-scene teaser illustrations for locked future worlds in a children's math adventure app. These are not character portraits. They are compact world-preview images that must still read clearly when cropped into a small circular or square thumbnail.

Deliverables:
1. biome_night_forest_preview.png — a night forest world preview
2. biome_star_desert_preview.png — a star desert world preview

Visual requirements:
- flat 2D illustration
- no text inside the image
- no human characters
- no photoreal faces
- no 3D render style
- clear foreground/midground/background separation using simple shapes
- strong read at thumbnail size
- keep compositions uncluttered

Night forest brief:
- cool blue-green palette
- moonlit trees, soft glow, safe and adventurous mood
- magical but not fantasy-overloaded
- child-friendly, calm, slightly mysterious

Star desert brief:
- warm sand dunes with a deep starry sky
- adventurous, bright silhouettes, easy horizon line
- a subtle cosmic feeling without sci-fi machinery
- child-friendly and clear at small size

Output intent:
These images will be used in locked-biome teaser cards in a Flutter app. They must work as small preview art first and larger card art second.
```
