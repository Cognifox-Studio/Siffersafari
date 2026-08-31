# Settings

Ansvar: vanliga installningar for aktiv profil — tema, ljud/vibration, profilbyte, radera profil/all data och privacy policy.

## Borja har

- `presentation/screens/settings_screen.dart`
- `presentation/screens/privacy_policy_screen.dart`
- `../../core/providers/user_provider.dart`
- `../../core/theme/app_theme_config.dart`

## Laser / sparar

Settings laser och sparar via `userProvider` (tema, ljud, vibration, aktiv profil). Privacy policy ar read-only.

Foraldratoggles (TTS, textproblem, allowed operations) ligger i `parent/`, inte har.

## Bra forsta test

- `test/widget/settings_screen_test.dart`
- `test/unit/logic/user_profile_cleanup_test.dart` for radera profil / all data
