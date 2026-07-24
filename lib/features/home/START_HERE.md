# Home

Ansvar: hubben efter profilval. Har avgors om barnet ska fortsatta ett quiz, oppna storykartan eller starta ett nytt pass.

## Borja har

- `presentation/screens/home_screen.dart`
- `providers/home_read_model_provider.dart`
- `presentation/home_read_model.dart`
- `providers/home_session_status_provider.dart`

## Laser fran

- `userProvider`
- `quizProvider`
- `storyProgressProvider`
- `dailyChallengeProvider`

## Sparar

Home sparar inget direkt. Den laser state och navigerar vidare till quiz, story, settings eller parent flow.

## Bra forsta test

- `test/widget/app_home_test.dart`
- `test/unit/logic/home_read_model_test.dart`