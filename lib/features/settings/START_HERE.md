# Settings

Ansvar: vanliga inställningar för aktiv profil — tema, ljud/musik, profilbyte, radera profil/all data och privacy policy.

## Börja här

- `presentation/screens/settings_screen.dart`
- `presentation/screens/privacy_policy_screen.dart`
- `../../core/providers/user_provider.dart`
- `../../core/theme/app_theme_config.dart`

## Läser / sparar

Settings läser och sparar via `userProvider` (tema, ljud, musik, aktiv profil). Privacy policy är read-only.
Haptik i quiz följer `soundEnabled` (ingen separat vibration-toggle).

Föräldratoggles (TTS, textproblem, allowed operations) ligger i `parent/`, inte här.

## Bra första test

- `test/widget/settings_screen_test.dart`
- `test/unit/logic/user_profile_cleanup_test.dart` för radera profil / all data
