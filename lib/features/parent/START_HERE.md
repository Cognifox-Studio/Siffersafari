# Parent

Ansvar: vuxenlaget. Har ligger PIN-flodet, foraldrainstallningar och oversikten over barnets quizhistorik.

## Borja har

- `presentation/screens/parent_pin_screen.dart`
- `presentation/screens/pin_recovery_screen.dart`
- `presentation/screens/parent_dashboard_screen.dart`
- `providers/parent_quiz_history_provider.dart`
- `../../core/providers/parent_settings_provider.dart`

## Sparar

- PIN och security question i `settings`
- foraldrainstallningar i `settings`
- dashboarden laser quizhistorik men ager den inte

## Bra forsta test

- `test/widget/app_parent_mode_test.dart`
- `test/unit/services/parent_pin_service_test.dart`
- `test/unit/logic/parent_settings_provider_test.dart`