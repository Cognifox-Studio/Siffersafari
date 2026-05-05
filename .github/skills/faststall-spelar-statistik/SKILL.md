---
name: faststall-spelar-statistik
description: 'Lock the local analytics baseline for the main funnel. Use when adding or changing event names, payloads, trigger points, replay flows or analytics verification.'
argument-hint: 'Beskriv vilken funnelpunkt eller vilket analytics-kontrakt som ändras.'
---

# Analytics Baseline

## När den ska användas
- När `AppAnalyticsService` eller lokala funnel-events ändras.
- När quizstart, replay, daglig utmaning, resultat eller parent mode får nya triggers.
- När docs och kod inte längre använder samma eventnamn eller payload-fält.

## Repo-ankare
- `lib/core/services/app_analytics_service.dart`
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/quiz/presentation/screens/quiz_screen.dart`
- `lib/features/quiz/presentation/screens/results_screen.dart`
- `lib/features/parent/presentation/screens/parent_dashboard_screen.dart`
- `docs/SERVICES_API.md`
- `docs/SESSION_BRIEF.md`

## Låst baslinje
Den lokala analytics-baslinjen ska använda exakt dessa canonical eventnamn i huvudflödet:
- `quiz_start`
- `quiz_abandoned`
- `quiz_completed`
- `daily_start`
- `daily_completed`
- `parent_mode_opened`

Nar level-up ingar i samma andring halls aven `level_up` kvar som stodjande event, men det ersatter aldrig funnel-events.

## Triggerpunkter som gäller
- `quiz_start`: exakt en gang nar en quizsession faktiskt blir aktiv, aven for replay eller focused/custom restart. Startanalytics ska dela samma kodvag som vanlig quizstart, inte spridas ut over flera skarmar.
- `quiz_abandoned`: nar barnet lamnar en aktiv quiz fore avslut.
- `quiz_completed`: exakt en gang nar avslutad session appliceras till resultatflodet.
- `daily_start`: nar daglig utmaning faktiskt startar ett quiz.
- `daily_completed`: nar en daglig quiz markeras som slutford.
- `parent_mode_opened`: exakt en gang nar parent mode faktiskt oppnas. `userId` ska skickas nar den finns.
- `level_up`: exakt en gang per avslutad session dar niva-grans korsas.

## Payload-fält som inte får driva
Använd konsekventa payload-fält för varje event. Om en ändring kräver nya fält ska docs och tester uppdateras i samma slice.

- `quiz_start`
  - `operation`
  - `difficulty`
  - `is_daily_challenge`
  - `grade_level`
- `quiz_abandoned`
  - `operation`
  - `question_index`
  - `total_questions`
- `quiz_completed`
  - `operation`
  - `difficulty`
  - `success_rate`
  - `correct_answers`
  - `wrong_answers`
  - `is_daily_challenge`
- `daily_start`
  - `operation`
  - `difficulty`
  - `date_key`
  - `source`
- `daily_completed`
  - `operation`
  - `difficulty`
  - `success_rate`
- `parent_mode_opened`
  - inga extra `properties` kravs, men `userId` ska sattas nar aktiv anvandare finns
- `level_up`
  - `old_level`
  - `new_level`
  - `title`

## Kand drift som ska stoppas, inte spridas
- Introducera inte fler namnvarianter som `quiz_started` eller `daily_challenge_started`.
- Dubbellogga inte `parent_mode_opened` i bade knapptryck och dashboard-load om avsikten ar en enda funnelpunkt.
- Lat inte replay/starta-igen-floden hoppa over `quiz_start`.

## Riktad verifiering
1. Borja med smalast mojliga test pa den agande kodytan.
2. Om eventnamn eller payload andras: verifiera att lagrad analytics-data innehaller exakt canonical namn och falt.
3. Om startfloden andras: verifiera normal start, daglig start och replay/starta-igen.
4. Om parent mode andras: verifiera att `parent_mode_opened` inte tappade `userId` och inte loggas tva ganger av samma anvandarhandling.
5. Uppdatera `docs/SERVICES_API.md` och `docs/SESSION_BRIEF.md` i samma andring om kontraktet eller nasta steg paverkas.

## Minimum for gront lage
- Kod, tester och docs anvander samma eventnamn.
- Varje event har en tydlig agare i huvudflodet.
- Riktad verifiering visar att eventet faktiskt lagras lokalt med ratt payload.