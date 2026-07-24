# Story

Ansvar: visa djungelkartan, nuvarande stopp och vad som kommer nast. Storyn ar read-only i UI och byggs fran quest- och user-state.

## Borja har

- `presentation/screens/story_map_screen.dart`
- `../../core/providers/story_progress_provider.dart`
- `../../core/services/story_progression_service.dart`
- `../../core/services/quest_progression_service.dart`

## Viktig tumregel

`story_map_screen.dart` ager visningen. De intilliggande `story_map_screen__*_part.dart` ar bara interna delar av samma skarm.

## Sparar

Ingen egen feature-lagring. Story lases fram fran befintlig quest- och userdata.

## Bra forsta test

- `test/unit/services/story_progression_service_test.dart`