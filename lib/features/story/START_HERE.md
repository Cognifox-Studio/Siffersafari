# Story

Ansvar: visa djungelkartan, nuvarande stopp och vad som kommer nast. Storyn ar read-only i UI och byggs fran quest- och user-state.

## Borja har

- `presentation/screens/story_map_screen.dart`
- `../../core/providers/story_progress_provider.dart`
- `../../core/services/story_progression_service.dart`
- `../../core/services/quest_progression_service.dart`

## Viktig tumregel

`story_map_screen.dart` ager visningen. De intilliggande `story_map_screen__*_part.dart` ar bara interna delar av samma skarm.

`StoryProgress.nextBiome` visas aven pa sista stoppet och nar episoden ar klar (med avslutningscopy). Hemkortet och resultatpanelens “Sedan”-kort laser samma preview.

## Sparar

Ingen egen feature-lagring. Story lases fram fran befintlig quest- och userdata.

## Bra forsta test

- `test/unit/services/story_progression_service_test.dart`
- `test/widget/app_home_test.dart` for karta + biome-teaser i UI
