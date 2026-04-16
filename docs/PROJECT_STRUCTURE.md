# Project Structure (As-Is)

Denna fil beskriver faktisk struktur i repo:t (uppdaterad 2026-04-04).

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
  - `bootstrap/presentation/screens/`: `startup_splash_gate.dart`, `startup_router_screen.dart`
- `features/`: feature-agda skarmar, dialoger och widgets (feature-first struktur)
  - `home/presentation/screens/`: `home_screen.dart`
  - `home/presentation/widgets/`: `home_story_progress_card.dart`
  - `quiz/presentation/screens/`: `quiz_screen.dart`, `results_screen.dart`
  - `quiz/presentation/dialogs/`: `feedback_dialog.dart`
  - `story/presentation/screens/`: `story_map_screen.dart`
  - `parent/presentation/screens/`: `parent_dashboard_screen.dart`, `parent_pin_screen.dart`, `pin_recovery_screen.dart`
  - `profiles/presentation/screens/`: `profile_selection_screen.dart`
  - `profiles/presentation/dialogs/`: `create_user_dialog.dart`
  - `onboarding/presentation/screens/`: `onboarding_screen.dart`, `initial_profile_setup_screen.dart`
  - `settings/presentation/screens/`: `settings_screen.dart`, `privacy_policy_screen.dart`
- `presentation/`
  - `screens/`: tom (alla skarmar ar nu i features/)
  - `dialogs/`: tom (alla dialoger ar nu i features/)
  - `widgets/`: ateranvandbara UI-komponenter: `answer_button.dart`, `daily_challenge_card.dart`, `mascot_character.dart`, `progress_indicator_bar.dart`, `question_card.dart`, `star_rating.dart`, `theme_mascot.dart`, `themed_background_scaffold.dart`
  - `providers.dart`: barrel-export av alla providers for presentation-lagret

## Viktiga skarmar (med faktisk sökväg)

- `lib/app/bootstrap/presentation/startup_splash_gate.dart`
- `lib/app/bootstrap/presentation/startup_router_screen.dart`
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

**State providers (för presentation-lagret):**
- `userProvider` – UserState och UserNotifier
- `quizProvider` – QuizState och QuizNotifier
- `dailyChallengeProvider` (family, per userId) – DailyChallengeState och DailyChallengeNotifier
- `storyProgressProvider` – StoryProgress beräknad från quest-status
- `parentSettingsProvider` – ParentSettings

**Settings providers:**
- `wordProblemsEnabledProvider` – toggle för textuppgifter
- `missingNumberEnabledProvider` – toggle för missing-number varianter
- `spacedRepetitionEnabledProvider` – toggle för spaced repetition

**Service providers (används via DI):**
- `appAnalyticsProvider` – AppAnalyticsService
- `appThemeProvider` – AppTheme
- `audioServiceProvider` – AudioService
- `adaptiveDifficultyServiceProvider` – AdaptiveDifficultyService
- `feedbackServiceProvider` – FeedbackService
- `achievementServiceProvider` – AchievementService
- `dailyChallengeServiceProvider` – DailyChallengeService
- `questionGeneratorServiceProvider` – QuestionGeneratorService
- `questProgressionServiceProvider` – QuestProgressionService
- `storyProgressionServiceProvider` – StoryProgressionService
- `parentPinServiceProvider` – ParentPinService
- `dataExportServiceProvider` – DataExportService
- `spacedRepetitionServiceProvider` – SpacedRepetitionService
- `localStorageRepositoryProvider` – LocalStorageRepository

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

- `characters/mascot/` (svg, rive, config)
- `characters/loke/` (svg, rive-guide/spec)
- `ui/lottie/` (UI-effekter)
- `animations/` (ovriga animation-JSON/referenser, inte godkand mascot-runtime)
- `images/` (teman/brand/icon)
- `sounds/` (wav-effekter/musik)

## scripts/

Exempel:
- `flutter_pixel6.ps1`
- `extract_integration_screenshots.ps1`
- `generate_mascot_svg_parts.dart`
- `generate_lottie_effects.dart`
- `generate_rive_blueprint.dart`
- `verify_mascot_rive_runtime.ps1`
- `generate_android_launcher_icons.dart`

## Aktuell animationsregel

- SVG/spec/blueprint kan genereras i repo:t
- godkanda UI-effekter genereras som Lottie
- riktig karaktarsanimation i appen kraver fortfarande manuell `.riv`-export i Rive Editor

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
