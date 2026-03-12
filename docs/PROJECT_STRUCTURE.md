# Project Structure (As-Is)

Denna fil beskriver faktisk struktur i repo:t (uppdaterad 2026-03-11).

## Root

- `lib/` appkod
- `test/` unit + widget tests
- `integration_test/` end-to-end tester
- `assets/` produktionsassets
- `scripts/` verktygsskript
- `docs/` dokumentation
- `.github/` CI/CD och templates
- `android/` Android-konfiguration

Byggartefakter som inte ar kallkod:
- `build/`
- `.dart_tool/`

## lib/

- `main.dart`: entrypoint + bootstrap
- `core/`
  - `config/`: difficulty och feature-konfiguration
  - `constants/`: nycklar, IDs, UI-konstanter
  - `di/`: GetIt-registrering
  - `providers/`: Riverpod state och service providers
  - `services/`: appnara tjanster (generator, audio, progression, update)
  - `theme/`: teman och tokens
  - `utils/`: layout, transitions, validering m.m.
- `domain/`
  - `constants/`: inlarning/traningskonstanter
  - `entities/`: modeller (`Question`, `QuizSession`, `UserProgress`, `StoryProgress`)
  - `enums/`: age/difficulty/theme/operation/mastery
  - `services/`: domanlogik (adaptive difficulty, feedback, PIN, export, backup)
- `data/`
  - `repositories/`: `LocalStorageRepository` (Hive)
- `presentation/`
  - `screens/`: appens huvudskarmar
  - `dialogs/`: dialogkomponenter
  - `widgets/`: ateranvandbara UI-komponenter

## Viktiga skarmar

- `app_entry_screen.dart`
- `launch_splash_gate.dart`
- `onboarding_screen.dart`
- `first_run_setup_screen.dart`
- `profile_picker_screen.dart`
- `home_screen.dart`
- `quiz_screen.dart`
- `results_screen.dart`
- `story_map_screen.dart`
- `settings_screen.dart`
- `parent_pin_screen.dart`
- `pin_recovery_screen.dart`
- `parent_dashboard_screen.dart`
- `privacy_policy_screen.dart`

## Providers (exempel)

- `userProvider`
- `quizProvider`
- `storyProgressProvider`
- `parentSettingsProvider`
- `wordProblemsEnabledProvider`
- `missingNumberEnabledProvider`

## test/

- `unit/logic/`: difficulty/curriculum/progression
- `unit/services/`: achievements, pin, backup, quest/story
- `unit/audits/`: offline-krav, mix-distribution
- `widget/`: home/onboarding/quiz/results/parent/accessibility

## integration_test/

- `app_smoke_test.dart`
- `parent_features_test.dart`
- `parent_pin_security_question_flow_test.dart`
- `screenshots_test.dart`
- `test_utils.dart`

## assets/

- `characters/ville/` (svg, rive, config)
- `characters/loke/` (svg, rive-guide/spec)
- `ui/lottie/` (UI-effekter)
- `animations/` (ovriga Lottie)
- `images/` (teman/brand/icon)
- `sounds/` (wav-effekter/musik)

## scripts/

Exempel:
- `flutter_pixel6.ps1`
- `extract_integration_screenshots.ps1`
- `generate_ville_svg_parts.dart`
- `generate_lottie_effects.dart`
- `generate_rive_blueprint.dart`
- `generate_android_launcher_icons.dart`

## .github/

- `workflows/flutter.yml` CI analyze + test
- `workflows/build.yml` release build + release upload
- `workflows/release-guard.yml` release sanity + storlekskontroll
- `instructions/` och `prompts/` for team/Copilot-stod

## Namngivning (faktiskt anvand i repo)

- Dart-filer: `snake_case.dart`
- Screens: `*_screen.dart`
- Services: `*_service.dart`
- Providers: `*Provider` eller `*Notifier`
- Tests: `*_test.dart`

## Se ocksa

- `docs/ARCHITECTURE.md`
- `docs/SERVICES_API.md`
- `docs/README.md`
