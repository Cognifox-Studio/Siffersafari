---
name: "story-theme-asset-pass"
description: "Use when story map art, next-biome previews, home story heroes, startup backgrounds or theme bundles may be owned by multiple Dart surfaces and you need the right Siffersafari call sites and QA slice first."
argument-hint: "Valfritt: ange fil, asset eller symptom som story map, home hero, biome preview, theme bundle, fallback eller fel bild i runtime."
agent: "agent"
---

Gör en snabb och repo-specifik routing för story-, home- och theme-assets innan implementation, så att rätt ägande kodväg, fallback och verifiering väljs först.

Utgå från dessa källor:

- [.github/instructions/asset-runtime-consumption.instructions.md](../instructions/asset-runtime-consumption.instructions.md)
- [.github/instructions/regler-for-bildfiler-i-incoming.instructions.md](../instructions/regler-for-bildfiler-i-incoming.instructions.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [lib/core/theme/app_theme_config.dart](../../lib/core/theme/app_theme_config.dart)
- [lib/app/bootstrap/presentation/startup_flow_gate.dart](../../lib/app/bootstrap/presentation/startup_flow_gate.dart)
- [lib/features/home/presentation/screens/home_screen__content_part.dart](../../lib/features/home/presentation/screens/home_screen__content_part.dart)
- [lib/features/home/presentation/widgets/home_story_progress_card__content_part.dart](../../lib/features/home/presentation/widgets/home_story_progress_card__content_part.dart)
- [lib/features/story/presentation/screens/story_map_screen__map_canvas_part.dart](../../lib/features/story/presentation/screens/story_map_screen__map_canvas_part.dart)
- [lib/features/story/presentation/screens/story_map_screen__content_part.dart](../../lib/features/story/presentation/screens/story_map_screen__content_part.dart)
- [lib/core/utils/image_cache_size.dart](../../lib/core/utils/image_cache_size.dart)
- [test/widget/app_home_test.dart](../../test/widget/app_home_test.dart)
- [test/unit/services/story_progression_service_test.dart](../../test/unit/services/story_progression_service_test.dart)

Arbetsordning:

1. Läs `asset-runtime-consumption.instructions.md` först och sammanfatta vilka regler som faktiskt styr ändringen.
2. Klassificera ytan: theme bundle-path, startup-precache, home hero, home story card, next-biome-preview, story map-landmark, asset-fallback eller asset-manifest/deviceproblem.
3. Peka ut primär ägare och sekundära call sites innan implementation:
   - `app_theme_config.dart` äger theme bundle-paths för `background`, `quest_hero` och `character`
   - `startup_flow_gate.dart` precachar theme backgrounds och hero-assets
   - `home_screen__content_part.dart` konsumerar home hero och temaägda UI-bilder
   - `home_story_progress_card__content_part.dart` konsumerar hero-, bakgrunds- och character-assets med fallback
   - `story_map_screen__map_canvas_part.dart` och `story_map_screen__content_part.dart` konsumerar story map-bakgrund, landmarks och biome-previews
4. Om problemet egentligen gäller råa filer, saknad grafik eller promotion från `_incoming/`: peka vidare till `.github/prompts/asset-flow-router.prompt.md` eller rätt asset-skill i stället för att felsöka runtime först.
5. Välj minsta rimliga verifiering:
   - filkontroll eller diffgranskning för rena path- eller promptändringar
   - `QA: Analyze` och `test/widget/app_home_test.dart` när home/story card eller theme hero påverkas
   - `QA: Analyze` och `test/unit/services/story_progression_service_test.dart` när biome-preview eller story-state-koppling ändras
   - Pixel_6 sync/install eller `integration_test/app_smoke_test.dart --dart-define=FULL_SMOKE=false` när startup-precache, asset-manifest eller device-rendering är en del av risken
6. Nämn uttryckligen när full omstart av `flutter run` är rimligare än Hot Reload eller Hot Restart, särskilt efter nya assetfiler.

Svarskrav:

- Börja med vilken story/theme-slice det faktiskt gäller.
- Lista matchande instruction först, sedan primär ägare och sekundära call sites.
- Nämn minsta verifiering du rekommenderar innan implementation.
- Om problemet egentligen inte är runtime-konsumtion, säg det direkt och peka vidare till bättre prompt eller skill.