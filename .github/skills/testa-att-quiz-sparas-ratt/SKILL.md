---
name: testa-att-quiz-sparas-ratt
description: 'Protect offline-first quiz persistence and merge into permanent user state. Use when changing in-progress session storage, resume or replay, results application or quiz history behavior.'
argument-hint: 'Beskriv vilket steg i quizlivscykeln som ändrats: start, svar, avbrott, resume, finish, merge eller historik.'
---

# Testa att quiz sparas rätt

## Nar den ska anvandas
- Nar `QuizNotifier`, `UserNotifier`, `LocalStorageRepository` eller resultatskarmen andras.
- Nar in-progress state, replay, resume, quiz history eller merge till permanent state andras.
- Nar offline-first-regressioner riskerar att skapa dubbla sessioner eller tappa profiluppdateringar.

## Repo-ankare
- `lib/core/providers/quiz_provider.dart`
- `lib/core/providers/user_provider.dart`
- `lib/data/repositories/local_storage_repository.dart`
- `lib/features/quiz/presentation/screens/results_screen.dart`
- `test/unit/logic/quiz_progression_edge_cases_test.dart`
- `test/unit/logic/user_quest_completion_event_test.dart`
- `test/widget/app_quiz_flow_test.dart`

## Last kontrakt

### Start eller restart
- `startSession(...)` och `startCustomSession(...)` ska direkt resetta den deterministiska in-progress-nyckeln `inprogress_<userId>_<operation>`.
- Legacy in-progress-poster for samma user och operation ska purgas.
- Reset-posten ska vara `isComplete=false` med nollstallda answered counts.

### In-progress-persistens
- Efter forsta svaret ska samma deterministiska post skrivas over, inte dupliceras.
- In-progress-posten ska lagra answered-so-far och derived `successRate` for det som faktiskt ar besvarat.
- Det far finnas hogst en in-progress-post per `userId + operation`.

### Avbrott och stang quiz
- Att lamna quiz fore resultat far logga analytics, men far inte skapa en complete history-post.
- Senaste in-progress-state ska finnas kvar tills en ny start skriver over den eller en lyckad completion rensar den.

### Resume, replay och focused restart
- Replay eller custom/focused restart far inte ga runt samma persistensregler.
- Att starta samma operation igen ska skriva over tidigare deterministisk in-progress-post i stallet for att lamna stale dubletter.
- Om ett nytt resumeflode laggs till ska det fa ett fokuserat test; anta inte att ett generellt quizflode redan verifierar det.

### Finish och merge till permanent state
- `UserNotifier.applyQuizResult(...)` ska merga sessionens andringar tillbaka till permanent user state.
- `difficultyStepsByOperation` fran sessionen ska mergas in i `user.operationDifficultySteps` utan att tappa ororda operationer.
- En complete history-post ska sparas med `session.sessionId` och `isComplete=true`.
- Kvarvarande deterministisk in-progress-post for samma user och operation ska rensas efter lyckad completion.
- Permanent state ska spegla uppdaterade stats, mastery, achievements och quest/story progression.

### History-invarianter
- Complete sessions far samexistera med en in-progress-nyckel under lopande spel, men inte efter lyckad completion av samma operation eller session.
- Korrupta `quiz_history`-poster ska hoppas over eller purgas defensivt.
- Dashboard- och history-lasningar ska tolerera gammal eller ogiltig data.

## Riktad verifiering
1. Om start/reset-pathen andras:
   - kor `test/unit/logic/quiz_progression_edge_cases_test.dart`
   - verifiera purge av legacy in-progress-poster och zeroed reset underlag
2. Om answer-persistens andras:
   - verifiera att forsta svaret skriver answered-so-far till samma deterministiska nyckel
3. Om merge till user profile andras:
   - kor `test/unit/logic/user_quest_completion_event_test.dart`
   - verifiera merge av `operationDifficultySteps` och att avslutad session landar i permanent state
4. Om replay eller fullt UI-flode andras:
   - kor `test/widget/app_quiz_flow_test.dart`
   - verifiera start -> resultat -> spela igen utan dubletter eller tappad session
5. Om andringen ror faktisk Hive-serialisering, app-lifecycle eller bred regressionsrisk:
   - eskalera till `QA: Analyze` plus bredare quizfokuserad test eller integration

## Stoppa dessa regressioner
- Dubbletter av in-progress sessions for samma user och operation
- `applyQuizResult(...)` som sparar complete history men missar att rensa in-progress-nyckeln
- Session-state som uppdateras i minnet men inte mergas tillbaka till `UserProgress`
- Replay/starta igen som skapar nytt quiz men hoppar over persistens eller merge