# Plan: ROI-förbättringar Siffersafari (v1.3.2)

> Status: **Revised** (beslut fattade 2026-04-18)
> Källa: ROI-analys 2026-04-18, sparad i `/memories/session/plan.md`

## TL;DR

Fem konkreta förbättringar sorterade på ROI:

1. Onboarding null-grade fallback (~30 min)
2. SRS-injektionstester (~1 h)
3. Nivåuppgångs-celebration (~1.5 h)
4. Streak-break feedback (~30 min)
5. SRS-status i resultatskärm (~45 min)

Total uppskattad insats: ~4 h. Alla faser är oberoende och kan köras i valfri ordning.

---

## Fas A — Nivåuppgångs-celebration (~1.5 h)

### Kontext

`UserProgress` har `level` (200 poäng/nivå), `levelTitle` (10 titlar) och `pointsToNextLevel` — men inget i kodbasen visar att barnet gick upp en nivå. `applyQuizResult` i [user_provider.dart](../lib/core/providers/user_provider.dart) beräknar `updatedUser` med nya poäng men jämför aldrig gammal vs ny nivå.

### Steg

1. **Skapa `LevelUpEvent`-entitet** — `lib/domain/entities/level_up_event.dart` (NY)
   - Fält: `int oldLevel`, `int newLevel`, `String newTitle`
   - Equatable-klass

2. **Detektera nivåuppgång i `applyQuizResult`** — [user_provider.dart](../lib/core/providers/user_provider.dart)
   - Spara `final oldLevel = user.level;` före poänguppdatering
   - Efter `updatedUser`-skapande: om `updatedUser.level > oldLevel` → skapa `LevelUpEvent`
   - Lägg till `LevelUpEvent? lastLevelUp` i `UserState` + `copyWith`
   - Sätt fältet i `state = state.copyWith(...)` i slutet av `applyQuizResult`

3. **Visa overlay i `ResultsScreen`** — [results_screen.dart](../lib/features/quiz/presentation/screens/results_screen.dart)
   - I `didChangeDependencies` efter `applyQuizResult`: läs `userState.lastLevelUp`
   - Om ej null: visa overlay med SVG/Flutter-animerad konfetti + "Nivå N! Du är nu {title}"
   - Återanvänd `playCelebrationSound()`

4. **Analytics-event** — logga `level_up` med `{old_level, new_level, title}`

### Filer

- `lib/domain/entities/level_up_event.dart` — NY
- `lib/core/providers/user_provider.dart` — UserState + applyQuizResult
- `lib/features/quiz/presentation/screens/results_screen.dart` — overlay

### Verifiering

- Unit: `applyQuizResult` med poäng som korsar nivågräns → `lastLevelUp != null`
- Unit: utan nivåkorsning → `lastLevelUp == null`
- Widget: ResultsScreen visar level-up text vid nivåuppgång
- Manuell Pixel_6: spela quiz tills nivå 2, bekräfta celebration

---

## Fas B — SRS-injektionstester (~1 h)

### Kontext

`tryGenerateFromSrsKey`, `_getDueKeysForSession` och `pendingDueKeys`-konsumering i `goToNextQuestion` har 0 tester. Enda SRS-testet ([spaced_repetition_test.dart](../test/unit/logic/spaced_repetition_test.dart)) testar bara `scheduleNextReview`.

### Steg

1. **Tester för `tryGenerateFromSrsKey`** — `test/unit/services/question_generator_srs_test.dart` (NY)
   - `"multiplication|4 × 7 = ?"` → Question med correctAnswer 28
   - `"addition|5 + 3 = ?"` → Question med correctAnswer 8
   - Ogiltig nyckel (inget pipe, fel format, okänd operation) → null
   - `OperationType.mixed` i nyckel → null
   - Tom sträng → null

2. **Tester för `_getDueKeysForSession`** — `test/unit/logic/quiz_provider_srs_test.dart` (NY)
   - Testa indirekt via `QuizNotifier.startSession`
   - Mock `SpacedRepetitionService.getDueQuestionIds` med kända nycklar
   - Verifiera `pendingDueKeys` cap (`totalQuestions ~/ 3`)
   - Verifiera operationsfiltrering (multiplication-nycklar bort för addition-session)
   - Verifiera att `OperationType.mixed` tar alla nycklar

3. **Test för `goToNextQuestion`-konsumering**
   - Starta session med kända due-keys → anropa `goToNextQuestion` → verifiera att `pendingDueKeys` minskar
   - Verifiera fallback till slumpmässig generering vid oparsebar due-key

### Filer

- `test/unit/services/question_generator_srs_test.dart` — NY
- `test/unit/logic/quiz_provider_srs_test.dart` — NY
- `test/test_utils.dart` — eventuellt utöka med mock för `SpacedRepetitionService`

### Verifiering

- `flutter test test/unit/services/question_generator_srs_test.dart`
- `flutter test test/unit/logic/quiz_provider_srs_test.dart`
- `flutter test` (alla tester gröna)

---

## Fas C — Onboarding null-grade fallback (~30 min)

### Kontext

[onboarding_screen.dart](../lib/features/onboarding/presentation/screens/onboarding_screen.dart) `_finish()` (rad ~81–92) sparar `_gradeLevel` som-den-är. Om barnet trycker "Starta" utan val → `null`. Konsekvenser:

- Inga textuppgifter (kräver gradeLevel)
- Inga saknade tal (kräver gradeLevel)
- Benchmark-sektion i föräldravyn gömmer sig
- `question_generator_service` faller tillbaka till generiska ranges

### Beslut

✅ **Fallback åk 1** — minsta friktion, kan ändras i föräldraläge.

### Steg

1. I `_finish()`:
   - `final effectiveGrade = _gradeLevel ?? 1;`
   - Använd `effectiveGrade` i `saveUser`, `setAllowedOperations`, `saveWordProblemsEnabled`

### Filer

- `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

### Verifiering

- Widget-test: pumpa OnboardingScreen, tryck "Starta" utan val → `gradeLevel == 1`
- `flutter analyze`

---

## Fas D — Streak-break feedback (~30 min)

### Kontext

[daily_challenge_provider.dart](../lib/features/daily_challenge/providers/daily_challenge_provider.dart) `_computeNewStreak` (rad ~67–92) returnerar `1` om gap > 1 dag — tyst. `DailyChallengeCard` visar streak-badge endast vid `streak > 1`. Barnet ser sin streak försvinna utan förklaring.

### Beslut

✅ **Visa i DailyChallengeCard** — enklast, rätt kontext.

### Steg

1. **Exponera info i `DailyChallengeState`**
   - Lägg till `bool streakWasReset` i `DailyChallengeState`
   - I `markCompleted`: om `previousStreak > 1 && newStreak == 1` → `streakWasReset = true`

2. **Visa feedback i `DailyChallengeCard`**
   - Om `streakWasReset == true` && `streak <= 1`: kort text "Din streak startade om — spela idag för att börja en ny!"
   - Använd `subtleOnPrimary`-färg

### Filer

- `lib/features/daily_challenge/providers/daily_challenge_provider.dart` — state + logik
- `lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart` — meddelande

### Verifiering

- Unit: DailyChallengeNotifier med gap > 1 dag → `streakWasReset == true`
- Widget: DailyChallengeCard visar reset-meddelande
- `flutter analyze`

---

## Fas E — SRS-status i resultatskärm (~45 min)

### Kontext

[results_screen.dart](../lib/features/quiz/presentation/screens/results_screen.dart) visar stjärnor, poäng, tid, svåraste frågor, "Spela igen" och "Snabbträna" — men nämner inte SRS. Barnet vet inte att frågor sparats för repetition.

### Steg

1. **Räkna schemalagda frågor**
   - I `didChangeDependencies` efter `applyQuizResult`: räkna fel-svar i `session.answers` (dessa schemaläggs)

2. **Visa i stats-kortet**
   - Ny rad: `_buildStatRow(context, 'Sparade för repetition', '$count frågor')`
   - Visa bara om `count > 0` && `spacedRepetitionEnabled`
   - Ikon: `Icons.history_edu`

3. **Koppla till feature-flag**
   - Läs `QuizFeatureSettings.spacedRepetitionEnabled` för userId

### Filer

- `lib/features/quiz/presentation/screens/results_screen.dart`

### Verifiering

- Widget: ResultsScreen med fel i session → visar "Sparade för repetition"
- Widget: 100% rätt → visar inte raden
- `flutter analyze`

---

## Exekveringsordning

Alla faser är oberoende. Rekommenderad sekvens (lägst risk först):

| # | Fas | Insats | Motivering |
|---|-----|--------|------------|
| 1 | C — Onboarding null-grade | ~30 min | Snabbast, fixar befintlig bugg |
| 2 | B — SRS-injektionstester | ~1 h | Skyddar ny kod, ingen UI-ändring |
| 3 | A — Nivåuppgångs-celebration | ~1.5 h | Störst UX-påverkan |
| 4 | D — Streak-break feedback | ~30 min | Liten UX-förbättring |
| 5 | E — SRS-status i resultat | ~45 min | Synliggör SRS-värde |

## Slutverifiering

1. `flutter analyze` — 0 fel
2. `flutter test` — alla tester gröna (170+ befintliga + ~8–12 nya)
3. Pixel_6 sync/install — manuell verifiering av nivåuppgång, streak-break, SRS-rad i resultat
4. Uppdatera `docs/SESSION_BRIEF.md` med leveranser
5. Tagga `v1.3.2` om allt grönt

## Scope-avgränsning

**Inkluderat:** 5 faser ovan.

**Exkluderat (separata insatser):**

- Trend-visualisering i föräldra-dashboard (~3–4 h)
- Story-map narrativ-loop med bonus-uppdrag (~4–6 h)
- `question_generator_service`-refaktorering (~2880 rader, ingen funktionell påverkan)
