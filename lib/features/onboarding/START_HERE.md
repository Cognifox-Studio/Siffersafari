# Onboarding

Ansvar: forsta-gangen-flodet fram till att spelaren har arskurs, effektiv age group och appen kan ga vidare till home.

## Borja har

- `presentation/screens/onboarding_screen.dart`
- `presentation/screens/initial_profile_setup_screen.dart`
- `providers/onboarding_controller_provider.dart`
- `../../app/bootstrap/presentation/startup_flow_gate.dart`

## Sparar

- onboardingstatus i `settings`
- arskurs + effektiv `ageGroup` + default allowed operations via `userProvider`

Namn och figur skapas tidigare i `profiles/` (`create_user_dialog.dart`).

## Bra forsta test

- `test/widget/app_onboarding_test.dart`
