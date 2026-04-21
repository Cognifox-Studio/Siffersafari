# Arkitektur (As-Is)

Detta dokument beskriver aktuell implementation i repo:t (uppdaterad 2026-04-04).

## Snabboversikt

- Plattform: Flutter (Android-first)
- Arkitektur: hybrid (`app`, `features`, kvarvarande `presentation`, `core`, `domain`, `data`)
- State: Riverpod (`StateNotifierProvider` + `Provider`)
- DI: GetIt
- Persistens: Hive (`user_progress`, `settings`, `quiz_history`)
- Animation:
  - SVG-first for mascot-runtime i produkt-UI
   - Flutter-styrda reaktioner ovanpa composite-SVG i `GameCharacter`
  - Lottie for godkanda UI-effekter
  - optional `.riv`-filer och blueprint-material finns kvar som framtida enhancement-spor, men ar inte en aktiv runtime-dependency i appens huvudfloden

## Namngivningsbaseline

- Tekniska filnamn ar engelska och använder `snake_case.dart`.
- Feature-agd UI ligger i `lib/features/<feature>/presentation/widgets/`.
- `lib/presentation/widgets/` innehaller bara delad UI och app-shell-komponenter.

## Startup och bootstrap

1. `main()` i `lib/main.dart`
2. Global felhantering (Flutter/Platform/Isolate)
3. `initializeDependencies(initializeHive: false)` for tidig DI-registrering
4. `_initializeAsync()`:
   - `Hive.initFlutter()`
   - `initializeDependencies(openQuizHistoryBox: false)`
   - `quiz_history` oppnas i bakgrunden
5. `ProviderScope` + `SiffersafariApp`
6. `StartupSplashGate` -> `StartupFlowGate`

## Lager och ansvar

### app/ + features/ + presentation/

UI-lagret ar feature-first:
- `lib/app/bootstrap/` for startup och routing in i appen
- `lib/features/` for alla featureagda skarmar, dialoger och widgets
- `lib/presentation/screens/` och `lib/presentation/dialogs/` ar tomma (migration klar)
- `lib/presentation/widgets/` innehaller delade UI-komponenter
- `lib/features/daily_challenge/` innehaller featureagd state och UI for daglig utmaning

Viktiga skarmar (med faktisk sokväg):
- `app/bootstrap/presentation/startup_splash_gate.dart`
- `app/bootstrap/presentation/startup_flow_gate.dart`
- `features/onboarding/presentation/screens/onboarding_screen.dart`
- `features/onboarding/presentation/screens/initial_profile_setup_screen.dart`
- `features/profiles/presentation/screens/profile_selection_screen.dart`
- `features/home/presentation/screens/home_screen.dart`
- `features/quiz/presentation/screens/quiz_screen.dart`
- `features/quiz/presentation/screens/results_screen.dart`
- `features/story/presentation/screens/story_map_screen.dart`
- `features/settings/presentation/screens/settings_screen.dart`
- `features/settings/presentation/screens/privacy_policy_screen.dart`
- `features/parent/presentation/screens/parent_pin_screen.dart`
- `features/parent/presentation/screens/pin_recovery_screen.dart`
- `features/parent/presentation/screens/parent_dashboard_screen.dart`

### core/

Teknisk app-logik, providers, tema och utilities.

Viktiga delar:
- `core/di/injection.dart`
- `core/providers/quiz_provider.dart`
- `core/providers/user_provider.dart`
- `core/services/question_generator_service.dart`
- `core/services/audio_service.dart`
- `core/services/achievement_service.dart`
- `core/services/app_update_service.dart`
- `core/services/quest_progression_service.dart`
- `core/services/story_progression_service.dart`
- `core/services/daily_challenge_service.dart`
- `core/services/app_analytics_service.dart`

### domain/

Flutter-fri domanlogik: entiteter, enums och rena tjanster.

Viktiga tjanster:
- `AdaptiveDifficultyService`
- `FeedbackService`
- `ParentPinService`
- `SpacedRepetitionService`
- `DataExportService`

### data/

Repository-implementation for lokal lagring:
- `LocalStorageRepository` (Hive access + typed helpers)

## Huvudfloden i produkten

1. Barn valjer/skapar profil
2. Home visar rekommenderad progression + storystatus + daglig utmaning (`DailyChallengeCard`)
3. Quiz startas via `QuizNotifier.startSession(...)` (ev. med `isDailyChallenge: true`)
4. Svar hanteras i `QuizNotifier.submitAnswer(...)`
   - ljudfeedback
   - poang/streak
   - combo-multiplikator (1.5× vid 3+ streak, 2.0× vid 5+ streak) via `_comboMultiplierForStreak(...)`
   - adaptiv difficulty step per raknesatt
   - spaced repetition-review per fraga nar funktionen ar aktiverad
   - lokal analytics-event
   - in-progress persistens
5. Resultat visas i `ResultsScreen`
6. `UserNotifier.applyQuizResult(...)` uppdaterar:
   - user stats
   - mastery
   - achievements
   - quest/story progression
   - permanent quizhistorik

## Parent mode (sakerhet och styrning)

- PIN verifiering via BCrypt-hash i `ParentPinService`
- lockout efter 5 felaktiga forsok (5 minuter)
- security question-baserad recovery
- dashboard med statistik och export
- app update-check via GitHub Releases API + OTA-installation pa Android

## Persistensmodell

Hive-boxar:
- `user_progress`: `UserProgress` profiler
- `settings`: aktiv profil, onboardingstatus, parent settings, quest state, PIN data
- `quiz_history`: sessioner (in-progress + complete)

Designval:
- in-progress session sparas med deterministisk nyckel per `userId + operation`
- legacy in-progress entries rensas for att undvika dubbelrakning
- quizhistory valideras defensivt innan den anvands

## Test och kvalitet

Aktiva testlager:
- unit: logik, services, audits
- widget: huvudfloden i UI
- integration: smoke, parent features, PIN recovery, screenshots

CI/workflows:
- `.github/workflows/flutter.yml`: analyze + test
- `.github/workflows/build.yml`: release build + signering + GitHub Release
- `.github/workflows/release-guard.yml`: snabb releasevalidering + APK size guard

## Kanda tekniska noteringar

- Vissa dokument i repo:t innehaller historiska stegplaner. Denna fil beskriver endast nulaget.
- Vissa terminalmiljoer visar svenska tecken felaktigt (mojibake). Filinnehall i repo:t ar uppdaterat i UTF-8.
- `assets/characters/mascot/rive/mascot_character.riv` ar fortfarande placeholder/demo-material och inte del av nuvarande produkt-runtime.
- Om Rive aterintroduceras i produkt-UI senare ska det goras som ett explicit nytt integrationssteg, inte som dold fallback.

## Relaterade dokument

- `docs/PROJECT_STRUCTURE.md`
- `docs/SERVICES_API.md`
- `docs/DECISIONS_LOG.md`
- `docs/SESSION_BRIEF.md`
