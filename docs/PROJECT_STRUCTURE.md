<!--
typ: reference
syfte: Faktisk mapp- och filstruktur
uppdaterad: 2026-05-02
-->
# Project Structure (As-Is)

Denna fil beskriver faktisk struktur i repo:t (uppdaterad 2026-05-02).

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
  - `services/`: appnara tjanster (generator, audio, progression, update, daily challenge, analytics)
  - `theme/`: teman och tokens
  - `utils/`: layout, transitions, validering m.m.
- `domain/`
  - `constants/`: inlarning/traningskonstanter
  - `entities/`: modeller (`Question`, `QuizSession`, `UserProgress`, `StoryProgress`)
  - `enums/`: age/difficulty/theme/operation/mastery
  - `services/`: domanlogik (adaptive difficulty, feedback, PIN, export, backup)
- `data/`
  - `repositories/`: `LocalStorageRepository` (Hive)
- `app/`
  - `bootstrap/presentation/`: `startup_splash_gate.dart`, `startup_flow_gate.dart`
- `features/`: feature-agda skarmar, dialoger och widgets (feature-first struktur)
  - `daily_challenge/presentation/widgets/`: `daily_challenge_card.dart`
  - `daily_challenge/providers/`: `daily_challenge_provider.dart`
  - `home/presentation/screens/`: `home_screen.dart`
  - `home/presentation/widgets/`: `home_story_progress_card.dart`
  - `quiz/presentation/screens/`: `quiz_screen.dart`, `results_screen.dart`
  - `quiz/presentation/dialogs/`: `feedback_dialog.dart`
  - `quiz/presentation/widgets/`: `answer_button.dart`, `question_card.dart`
  - `story/presentation/screens/`: `story_map_screen.dart`
  - `parent/presentation/screens/`: `parent_dashboard_screen.dart`, `parent_pin_screen.dart`, `pin_recovery_screen.dart`
  - `profiles/presentation/screens/`: `profile_selection_screen.dart`
  - `profiles/presentation/dialogs/`: `create_user_dialog.dart`
  - `onboarding/presentation/screens/`: `onboarding_screen.dart`, `initial_profile_setup_screen.dart`
  - `settings/presentation/screens/`: `settings_screen.dart`, `privacy_policy_screen.dart`
- `presentation/`
  - `widgets/`: ateranvandbara UI-komponenter: `game_character.dart`, `mascot_reaction_view.dart`, `progress_indicator_bar.dart`, `star_rating.dart`, `themed_background_scaffold.dart`
  - historiska `screens/` och `dialogs/` finns inte langre; ny UI ligger i `lib/features/**/presentation/**`

## Namngivningsbaseline

- Tekniska filnamn ar engelska och anvander `snake_case.dart`.
- Feature-agd UI ligger i featuremappen i stallet for `lib/presentation/widgets/`.
- `lib/presentation/widgets/` ar reserverad for verkligt delad UI.

## Viktiga skarmar (med faktisk sÃ¶kvÃ¤g)

- `lib/app/bootstrap/presentation/startup_splash_gate.dart`
- `lib/app/bootstrap/presentation/startup_flow_gate.dart`
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart`
- `lib/features/profiles/presentation/screens/profile_selection_screen.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/quiz/presentation/screens/quiz_screen.dart`
- `lib/features/quiz/presentation/screens/results_screen.dart`
- `lib/features/story/presentation/screens/story_map_screen.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `lib/features/settings/presentation/screens/privacy_policy_screen.dart`
- `lib/features/parent/presentation/screens/parent_pin_screen.dart`
- `lib/features/parent/presentation/screens/pin_recovery_screen.dart`
- `lib/features/parent/presentation/screens/parent_dashboard_screen.dart`

## Providers (exempel)

**State providers (fÃ¶r presentation-lagret):**
- `userProvider` â€“ UserState och UserNotifier
- `quizProvider` â€“ QuizState och QuizNotifier
- `dailyChallengeProvider` (family, per userId) â€“ DailyChallengeState och DailyChallengeNotifier
- `storyProgressProvider` â€“ StoryProgress berÃ¤knad frÃ¥n quest-status
- `parentSettingsProvider` â€“ ParentSettings

**Settings providers:**
- `wordProblemsEnabledProvider` â€“ toggle fÃ¶r textuppgifter
- `missingNumberEnabledProvider` â€“ toggle fÃ¶r missing-number varianter
- `spacedRepetitionEnabledProvider` â€“ toggle fÃ¶r spaced repetition

**Service providers (anvÃ¤nds via DI):**
- `appAnalyticsProvider` â€“ AppAnalyticsService
- `appThemeProvider` â€“ AppTheme
- `audioServiceProvider` â€“ AudioService
- `adaptiveDifficultyServiceProvider` â€“ AdaptiveDifficultyService
- `feedbackServiceProvider` â€“ FeedbackService
- `achievementServiceProvider` â€“ AchievementService
- `dailyChallengeServiceProvider` â€“ DailyChallengeService
- `questionGeneratorServiceProvider` â€“ QuestionGeneratorService
- `questProgressionServiceProvider` â€“ QuestProgressionService
- `storyProgressionServiceProvider` â€“ StoryProgressionService
- `parentPinServiceProvider` â€“ ParentPinService
- `dataExportServiceProvider` â€“ DataExportService
- `spacedRepetitionServiceProvider` â€“ SpacedRepetitionService
- `localStorageRepositoryProvider` â€“ LocalStorageRepository

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
- `integration_test_utils.dart`

## assets/

- `characters/loke/` (png)
- `images/` (teman/brand/icon)
- `sounds/` (wav-effekter/musik)

## scripts/

Exempel:
- `flutter_pixel6.ps1`
- `extract_integration_screenshots.ps1`
- `generate_android_launcher_icons.dart`

## Aktuell animationsregel

- Karaktärer och animationer hanteras enbart via procedurgenererade transformationer på PNG, varken `SVG`, `Lottie` eller `Rive` assets tillåts som core mascot-runtime.

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

