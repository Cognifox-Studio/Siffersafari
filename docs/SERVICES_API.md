# Services API (As-Is)

Detta dokument beskriver de centrala tjansterna i aktuell implementation (uppdaterad 2026-04-04).

## Oversikt

Services finns i tva lager:
- `lib/core/services/`: appnara/tekniska tjanster
- `lib/domain/services/`: Flutter-fria domantjanster

## Core services

### QuestionGeneratorService
Fil: `lib/core/services/question_generator_service.dart`

Ansvar:
- generera fragor per age group, grade, operation och difficulty/step
- hantera mix-fragor och curriculum-gates
- stod for word problems och missing-number varianter

Anvands av:
- `QuizNotifier` (start + nasta fraga)

### DailyChallengeService
Fil: `lib/core/services/daily_challenge_service.dart`

Ansvar:
- generera dagens utmaning (operation + svårighetsgrad) deterministiskt baserat på dag-av-året
- `getTodaysChallenge()`: enkel rotation genom alla operationer, difficulty alternerar easy/medium per dag
- `getTodaysChallengeForUser(...)`: personaliserad utmaning baserad på användarens mastery och operationDifficultySteps
  - väljer operation från pool av 2 operationer med lägst `_learningScoreForOperation` (mastery + difficultyStep)
  - svårighetsgrad anpassas per operation baserat på mastery och step via `_difficultyForOperation`
- `DailyChallenge` innehåller `operation`, `difficulty`, `dateKey` (YYYY-MM-DD) och `title`

Anvands av:
- `DailyChallengeNotifier` (via `dailyChallengeProvider`)
- `HomeScreen` (använder `getTodaysChallengeForUser` för personalisering)
- `DailyChallengeCard` (`features/daily_challenge/presentation/widgets/`)

### AppAnalyticsService
Fil: `lib/core/services/app_analytics_service.dart`

Ansvar:
- logga lokala funnel-events (quiz_start, quiz_completed, daily_start, daily_completed, parent_mode_opened)
- lagra events lokalt i Hive (max 500 st)
- ingen molnsynkning – offline-first

Anvands av:
- `QuizNotifier`
- `HomeScreen`
- `ParentDashboardScreen`

### AudioService
Fil: `lib/core/services/audio_service.dart`

Ansvar:
- spela click/correct/wrong/celebration/music
- respektera profilernas sound/music settings

Anvands av:
- quizflow, results, home

### AchievementService
Fil: `lib/core/services/achievement_service.dart`

Ansvar:
- evaluera session + userprogress
- returnera upplasta achievements och bonus

Anvands av:
- `UserNotifier.applyQuizResult(...)`

### QuestProgressionService
Fil: `lib/core/services/quest_progression_service.dart`

Ansvar:
- bygga quest-path utifran grade/age
- ge current status och next quest
- filtrera path pa tillatna operationer

Anvands av:
- `UserNotifier`
- story-providerlagret

### StoryProgressionService
Fil: `lib/core/services/story_progression_service.dart`

Ansvar:
- mappa quest-status till UI-fardig storymodell
- satta node states (completed/current/upcoming)
- skapa chapter/landmark metadata

Anvands av:
- `storyProgressProvider`

### AppUpdateService
Fil: `lib/core/services/app_update_service.dart`

Ansvar:
- hamta senaste release via GitHub API
- jamfora installerad version med release-tag
- starta OTA-installation pa Android via `ota_update`

Anvands av:
- `ParentDashboardScreen`

## Domain services

### AdaptiveDifficultyService
Fil: `lib/domain/services/adaptive_difficulty_service.dart`

Ansvar:
- foresla nasta `difficultyStep` (inte bara easy/medium/hard)
- hybridmodell med micro/macro-signal + cooldown

Anvands av:
- `QuizNotifier.submitAnswer(...)`

### FeedbackService
Fil: `lib/domain/services/feedback_service.dart`

Ansvar:
- skapa `FeedbackResult` efter varje svar
- inkludera poang/snabbbonus/streak, alderanpassad text och `comboMultiplier`
- `comboMultiplier` sätts av `QuizNotifier._comboMultiplierForStreak(...)`: 1.0 normalt, 1.5× vid 3+ streak, 2.0× vid 5+ streak

Anvands av:
- `QuizNotifier.submitAnswer(...)`
- `FeedbackDialog` (visar orange badge vid multiplier ≥ 1.5)

### ParentPinService
Fil: `lib/domain/services/parent_pin_service.dart`

Ansvar:
- lagra PIN som BCrypt-hash
- verifiera PIN med lockout efter upprepade fel
- hantera security-question recovery

Anvands av:
- `ParentPinScreen`
- `PinRecoveryScreen`

### DataExportService
Fil: `lib/domain/services/data_export_service.dart`

Ansvar:
- exportera profildata/metadata till JSON-filer
- lista och radera exporterade filer

Anvands av:
- `ParentDashboardScreen`

### SpacedRepetitionService
Fil: `lib/domain/services/spaced_repetition_service.dart`

Ansvar:
- repetitionsintervall och due-berakning

Anvands av:
- `QuizNotifier.startSession(...)`
- `QuizNotifier.startCustomSession(...)`
- `QuizNotifier.submitAnswer(...)`

## Repository-kontrakt

### LocalStorageRepository
Fil: `lib/data/repositories/local_storage_repository.dart`

Ansvar:
- CRUD for `UserProgress`
- quizhistorik (in-progress + complete)
- settings helpers (active user, onboarding, quest state, operation filters)
- defensiv validering/rensning av korrupt sessiondata

## Providers

Providers är Riverpod-baserade state-hanterare som konsumerar services och repository.

### DailyChallengeNotifier
Fil: `lib/features/daily_challenge/providers/daily_challenge_provider.dart`

Ansvar:
- spåra completion-status för dagens utmaning per användare
- hantera consecutive-day streak-räknare
- persistera streak-data i Hive (`{streak, lastDate}`)
- `DailyChallengeState` innehåller `isCompleted` och `streakCount`

Beteende:
- vid `markCompleted()`: räknar upp streak vid consecutiv dag (yesterday → today)
- bevarar streak vid dubbelmarkering (samma dag)
- nollställer till streak=1 vid gap > 1 dag

Provider:
- `dailyChallengeProvider` (family, scopad per userId)

Anvands av:
- `HomeScreen` (visar streak-badge när streak > 1)
- `DailyChallengeCard` (visar completion-status)
- `ResultsScreen` (markerar completed vid quiz-slut)

### QuizNotifier
Fil: `lib/core/providers/quiz_provider.dart`

Ansvar:
- hantera quiz-sessions (`startSession`, `submitAnswer`, `nextQuestion`)
- beräkna combo-multiplikator via `_comboMultiplierForStreak`: 1.0 normalt, 1.5× vid 3+ streak, 2.0× vid 5+ streak
- in-progress persistens och defensiv validering
- integration med AdaptiveDifficultyService, FeedbackService, SpacedRepetitionService

### UserNotifier
Fil: `lib/core/providers/user_provider.dart`

Ansvar:
- hantera användarprofiler och aktiv användare
- `applyQuizResult`: uppdatera mastery, achievements, quest/story progression
- persistera UserProgress i Hive

## DI och providers

- DI: `lib/core/di/injection.dart`
- Providers: `lib/core/providers/*.dart`

Notera:
- Providers konsumerar services/repository via Riverpod.
- DI registrerar singleton/lazy-singleton for globala tjanster.
- `dailyChallengeProvider` är en family-provider scopad per userId.
- `appAnalyticsProvider` är en global provider.
