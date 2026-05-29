<!--
typ: reference
syfte: Faktisk mapp- och filstruktur
uppdaterad: 2026-05-26
-->
# Project Structure (As-Is)

Denna fil beskriver faktisk struktur i repo:t (uppdaterad 2026-05-26).

## Root

- `lib/` appkod
- `test/` unit + widget tests
- `integration_test/` end-to-end tester
- `assets/` produktionsassets
- `scripts/` verktygsskript
- `tools/` mindre import- och underhållsverktyg
- `docs/` dokumentation, inklusive `KUNSKAPSNIVA_PER_AK.md`, kanoniska `curriculum_facit.json` och `grade_*_question_bank.json`
- `.github/` CI/CD och templates
- `android/` Android-konfiguration
- `fastlane/` Play Store metadata och listing-sync
- `play/` release notes for Play-upload

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
  - `services/`: appnara tjanster (generator, generator-helpers, audio, progression, update, daily challenge, analytics)
  - `theme/`: teman och tokens
  - `utils/`: layout, transitions, bild-cache sizing, validering m.m.
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
  - `home/providers/`: home-sessionstatus och `home_read_model_provider.dart` som bro mellan lagring/quiz-state och UI
  - `home/presentation/screens/`: `home_screen.dart` med part-filer för innehåll och ljudkontroller
  - `home/presentation/`: `home_read_model.dart`
  - `home/presentation/widgets/`: `home_story_progress_card.dart`
  - `inventory/presentation/screens/`: `wardrobe_screen.dart`
  - `onboarding/providers/`: onboarding-controller och completion-status
  - `parent/providers/`: foraldravyns harledda quizhistorik
  - `quiz/presentation/screens/`: `quiz_screen.dart`, `results_screen.dart` med separat resultatplanering i part-fil
  - `quiz/presentation/dialogs/`: `feedback_dialog.dart`
  - `quiz/presentation/widgets/`: `answer_button.dart`, `question_card.dart`
  - `story/presentation/screens/`: `story_map_screen.dart` med karta/read-model i part-filer
  - `parent/presentation/screens/`: `parent_dashboard_screen.dart`, `parent_pin_screen.dart`, `pin_recovery_screen.dart` med dashboard-read-model i part-fil
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

## Viktiga skarmar (med faktisk sökväg)

- `lib/app/bootstrap/presentation/startup_splash_gate.dart`
- `lib/app/bootstrap/presentation/startup_flow_gate.dart`
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- `lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart`
- `lib/features/profiles/presentation/screens/profile_selection_screen.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/inventory/presentation/screens/wardrobe_screen.dart`
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
- `spacedRepetitionServiceProvider` – SpacedRepetitionService
- `localStorageRepositoryProvider` – LocalStorageRepository

## test/

- `unit/logic/`: difficulty/curriculum/progression
- `unit/services/`: achievements, pin, backup, quest/story
- `unit/audits/`: offline-krav, mix-distribution, curriculum-facit-synk
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

## tools/

- `import_question_banks.py`: importerar en manuell uppgiftstabell till `docs/grade_*_question_bank.json`

## Aktuell animationsregel

- Karaktärer och animationer hanteras enbart via procedurgenererade transformationer på PNG, varken `SVG`, `Lottie` eller `Rive` assets tillåts som core mascot-runtime.

## .github/

- `AGENTS.md` snabb routingyta för repoets anpassade agenter
- `agents/` repo-specifika agenter som `Beast Mode`, `Plan`, `Customization Maintainer`, `UI Reviewer` och `release-manager`
- `instructions/` smala arbetsregler kopplade till filtyper och kodområden
- `prompts/` workspace-prompter för audit, routing och QA-slice
- `skills/` repo-specifika arbetsflöden för QA, docs, release, COPPA och assets
- `hooks/` lätta guardrails för customization-arbete via hookdefinitioner och små PowerShell-skript
- `workflows/ci.yaml` PR-core-smoke samt full smoke + audit på huvudgrenen
- `workflows/flutter.yml` grundläggande analyze + test
- `workflows/android-smoke.yml` Android-smoke för APK-flödet
- `workflows/build.yml` release build + release upload
- `workflows/play-closed-beta.yml` Play closed beta-flöde
- `workflows/play-store-listing.yml` separat Play Store listing-sync
- `workflows/privacy-policy-pages.yml` publicering av privacy policy-sidor
- `workflows/release-guard.yml` release sanity + storlekskontroll

## fastlane/

- `Appfile` package-konfiguration for Play Store
- `Fastfile` lane for metadata-sync mot Google Play
- `metadata/android/` versionerad listing-copy per locale samt valfria bilder/screenshots

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

