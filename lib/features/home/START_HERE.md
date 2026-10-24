# Home

Ansvar: hubben efter profilval. Har avgors om barnet ska fortsatta ett quiz, oppna storykartan eller starta ett nytt pass.

## Borja har

- `presentation/screens/home_screen.dart`
- `providers/home_read_model_provider.dart`
- `presentation/home_read_model.dart`
- `providers/home_session_status_provider.dart`
- `presentation/widgets/camp_scene_view.dart`
- `presentation/widgets/camp_collection_album.dart`
- `presentation/widgets/home_story_progress_card.dart`
- `presentation/widgets/home_badge_album.dart`

## Laser fran

- `userProvider`
- `quizProvider`
- `storyProgressProvider`
- `InventoryConfig.campSouvenirItems` for camp-albumet (ingen egen lagring)
- `InventoryConfig.visibleCampPedestalItems` for vilka props som syns pa piedestalerna

## Sparar

Home sparar inget direkt. Den laser state och navigerar vidare till quiz, story, settings eller parent flow.

Camp-badgen syns aven vid 0 saker (teaser “Samla”) och oppnar ett read-only souveniralbum for `slot == 'camp'`. Tomt camp visar garderobs-CTA. Piedestalerna prioriterar upplastade camp-souvenirer och fyller resten med andra props (inte pets). Garderoben oppnas via maskoten eller CTA. Badgealbumet bygger pa `UserProgress.achievements`; lasta brickor visar `unlockHint` vid tryck (SnackBar).

## Bra forsta test

- `test/widget/app_home_test.dart`
- `test/unit/logic/home_read_model_test.dart`
- `test/unit/logic/inventory_reward_unlock_test.dart` for camp-souvenirkatalogen
