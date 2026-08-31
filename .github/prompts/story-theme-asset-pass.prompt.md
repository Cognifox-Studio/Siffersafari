---
name: "story-theme-asset-pass"
description: "Use when story map art, next-biome previews, home story heroes, camp story art, startup backgrounds or theme bundles may be owned by multiple Dart surfaces and you need call sites and QA first."
argument-hint: "Valfritt: story map, home hero, biome preview, camp souvenir art, theme bundle, fallback"
agent: "agent"
---

Gör en snabb routing för story-, home-, camp- och theme-assets innan implementation.

Utgå från dessa källor:

- [.github/instructions/asset-runtime-consumption.instructions.md](../instructions/asset-runtime-consumption.instructions.md)
- [.github/instructions/regler-for-bildfiler-i-incoming.instructions.md](../instructions/regler-for-bildfiler-i-incoming.instructions.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [lib/features/story/START_HERE.md](../../lib/features/story/START_HERE.md)
- [lib/features/home/START_HERE.md](../../lib/features/home/START_HERE.md)
- [lib/core/theme/app_theme_config.dart](../../lib/core/theme/app_theme_config.dart)
- [lib/app/bootstrap/presentation/startup_flow_gate.dart](../../lib/app/bootstrap/presentation/startup_flow_gate.dart)
- [lib/features/home/presentation/screens/home_screen__content_part.dart](../../lib/features/home/presentation/screens/home_screen__content_part.dart)
- [lib/features/home/presentation/widgets/home_story_progress_card__content_part.dart](../../lib/features/home/presentation/widgets/home_story_progress_card__content_part.dart)
- [lib/features/home/presentation/widgets/camp_scene_view.dart](../../lib/features/home/presentation/widgets/camp_scene_view.dart)
- [lib/features/home/presentation/widgets/camp_collection_album.dart](../../lib/features/home/presentation/widgets/camp_collection_album.dart)
- [lib/features/story/presentation/screens/story_map_screen__map_canvas_part.dart](../../lib/features/story/presentation/screens/story_map_screen__map_canvas_part.dart)
- [lib/features/story/presentation/screens/story_map_screen__content_part.dart](../../lib/features/story/presentation/screens/story_map_screen__content_part.dart)
- [lib/core/utils/image_cache_size.dart](../../lib/core/utils/image_cache_size.dart)
- [test/widget/app_home_test.dart](../../test/widget/app_home_test.dart)
- [test/unit/services/story_progression_service_test.dart](../../test/unit/services/story_progression_service_test.dart)

Arbetsordning:

1. Läs `asset-runtime-consumption.instructions.md` först.
2. Klassificera ytan: theme bundle, startup-precache, home hero, home story card, **next-biome-preview**, story map-landmark, **camp souvenir/piedestal-art**, asset-fallback eller manifest/device.
3. Peka ut ägare / call sites:
   - `app_theme_config.dart` — theme paths (`background`, `quest_hero`, `character`)
   - `startup_flow_gate.dart` — precache
   - `home_screen__content_part.dart` / `home_story_progress_card__content_part.dart` — home hero + storykort
   - `story_map_screen__*_part.dart` — karta, landmarks, biome-previews
   - `camp_scene_view.dart` / `camp_collection_album.dart` — camp-scen och souveniralbum (ofta story-PNG via `InventoryItem.assetPath`)
4. Om det egentligen är `_incoming/` / saknad grafik: `asset-flow-router` eller asset-skill.
5. Om det egentligen är equip/Z-index/garderob: `inventory-rendering-pass`.
6. Minsta verifiering:
   - path/docs-only → filkontroll
   - home/story/camp UI → analyze + `app_home_test.dart`
   - biome/story-state → analyze + `story_progression_service_test.dart`
   - startup/manifest/device → Pixel_6 sync eller core smoke
7. Nämn när full omstart av `flutter run` behövs efter nya assetfiler (inte bara Hot Reload).

Svarskrav:

- Börja med vilken story/theme/camp-slice det gäller.
- Instruction → primär ägare → sekundära call sites.
- Minsta verifiering innan implementation.
- Om det inte är runtime-konsumtion: peka vidare direkt.
