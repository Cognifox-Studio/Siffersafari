# Profiles

Ansvar: profilval, skapa profil och byte av aktiv spelare.

## Borja har

- `presentation/screens/profile_selection_screen.dart`
- `presentation/dialogs/create_user_dialog.dart`
- `../../core/providers/user_provider.dart`

## Sparar

- profiler i `user_progress`
- aktiv profil i `settings`

Skapa-profil samlar namn + figur och startar med `AgeGroup.young`. Arskurs (och effektiv age group) sattes i `onboarding/`.

## Bra forsta test

- `test/unit/logic/user_profile_cleanup_test.dart`
- `integration_test/app_smoke_test.dart`
