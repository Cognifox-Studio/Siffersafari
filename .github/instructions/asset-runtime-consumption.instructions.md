---
name: "Asset runtime consumption"
description: "Use when editing Dart files that consume story art, theme bundles, startup backgrounds, home hero assets or story map images. Covers owner paths, cache sizing, fallbacks and restart or Pixel_6 verification."
applyTo: "lib/app/bootstrap/presentation/startup_flow_gate.dart, lib/core/theme/app_theme_config.dart, lib/core/utils/image_cache_size.dart, lib/features/home/presentation/screens/home_screen__content_part.dart, lib/features/home/presentation/widgets/home_story_progress_card*.dart, lib/features/story/presentation/screens/story_map_screen*.dart, lib/presentation/widgets/themed_background_scaffold.dart"
---

# Runtime-konsumtion av assets

Använd denna instruktion när Dart-koden redan konsumerar theme- eller story-assets i runtime och problemet inte längre bara gäller råfiler i `_incoming/`.

## Ägande först

- `lib/core/theme/app_theme_config.dart` är facit för theme bundles. Lägg inte nya theme-paths direkt i enskilda widgets när de egentligen hör hemma som `background`, `quest_hero` eller `character`.
- `lib/app/bootstrap/presentation/startup_flow_gate.dart` är den centrala precache-ytan för theme backgrounds och hero-assets. Duplicera inte bred precache på flera skärmar utan tydlig anledning.
- `lib/features/home/presentation/screens/home_screen__content_part.dart` och `lib/features/home/presentation/widgets/home_story_progress_card*.dart` äger home-vyns konsumtion av theme- och story-assets.
- `lib/features/story/presentation/screens/story_map_screen*.dart` äger storykartan, dess landmarks, preview-bilder och bakgrundslager.

## Path- och fallback-regler

- Referera bara till filer under `assets/` i runtime-kod. `_incoming/`, `artifacts/` och andra råkällor får inte användas som runtime-paths.
- När en theme bundle ändras ska hela paketet tänkas ihop: `background`, `quest_hero` och `character` ska vara konsekventa och ligga under samma theme-mapp.
- Om en dekorativ bild inte är kritisk för funktionaliteten, använd en tydlig fallback som redan finns i repo:t eller en enkel färgyta via `errorBuilder` i stället för att låta vyn krascha eller bli tom utan förklaring.
- Om samma bildfamilj visas både på Home och Story Map ska båda konsumtionsytorna kontrolleras innan ändringen anses klar.

## Cache sizing och decode-hygien

- När en bild renderas i känd logisk storlek ska `imageCacheExtent(context, logicalSize)` användas för `cacheWidth` och eller `cacheHeight` i bildtunga ytor.
- Behåll befintliga cache-hjälpare och lägg inte in råa stora dekoder bara för att "det fungerar" på en enhet.
- Dekorativa bilder ska normalt vara `excludeFromSemantics: true` när de inte bär läsbar information.

## Startup och runtime-pitfalls

- Nya theme- eller story-assets kan kräva full omstart av `flutter run`; Hot Reload eller Hot Restart räcker inte alltid när asset-manifestet har ändrats.
- För Android-verifiering ska Pixel_6 sync eller install användas när assetändringen påverkar rendering, startup eller device-specifikt beteende.
- Om ett theme-spår läggs till eller byts ut, verifiera också `resolveTheme(...)`- och fallback-beteendet i `app_theme_config.dart` så att gamla sparade teman inte pekar på saknade filer.

## Minsta verifiering

- Börja med `QA: Analyze` när runtime-kod ändras.
- Använd `test/widget/app_home_test.dart` när home hero, storykort eller temaägda hero-assets påverkas.
- Använd `test/unit/services/story_progression_service_test.dart` när nästa biome, story-state eller preview-koppling ändras.
- Eskalera till `integration_test/app_smoke_test.dart --dart-define=FULL_SMOKE=false` eller Pixel_6 sync när startup, manifest eller device-rendering faktiskt berörs.