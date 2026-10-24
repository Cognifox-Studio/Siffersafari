# Home

Ansvar: hubben efter profilval. Här avgörs om barnet ska fortsätta ett quiz, öppna storykartan eller starta ett nytt pass.

## Börja här

- `presentation/screens/home_screen.dart`
- `providers/home_read_model_provider.dart`
- `presentation/home_read_model.dart`
- `providers/home_session_status_provider.dart`
- `presentation/widgets/camp_scene_view.dart`
- `presentation/widgets/camp_collection_album.dart`
- `presentation/widgets/home_story_progress_card.dart`
- `presentation/widgets/home_badge_album.dart`

## Läser från

- `userProvider`
- `quizProvider`
- `storyProgressProvider`
- `InventoryConfig.campSouvenirItems` för camp-albumet (ingen egen lagring)
- `InventoryConfig.visibleCampPedestalItems` för vilka souvenirs som syns på piedestalerna
- `AchievementCatalog` / `achievementServiceProvider` för badgealbumet

## Sparar

Home sparar inget direkt. Den läser state och navigerar vidare till quiz, story, settings eller parent flow.
Resume-CTA visar räknesätt + progress via `homeResumeQuizSessionProvider` (t.ex. “Fortsätt Plus (3/10)”).

Camp-badgen syns även vid 0 saker (teaser “Samla”) och öppnar ett read-only souveniralbum för `slot == 'camp'`. Tomt camp visar garderobs-CTA. Piedestalerna visar endast upplåsta camp-souvenirer; lediga platser är låsta placeholders (inga wardrobe-fillers). Garderoben öppnas via maskoten eller CTA. Badgealbumet bygger på `UserProgress.achievements` med PNG-tiles; låsta brickor visar `unlockHint` vid tryck (SnackBar).

## Bra första test

- `test/widget/app_home_test.dart`
- `test/widget/collect_albums_test.dart`
- `test/unit/logic/home_read_model_test.dart`
- `test/unit/logic/inventory_reward_unlock_test.dart` för camp-souvenirkatalogen
