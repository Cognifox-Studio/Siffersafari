<!--
typ: reference
syfte: Retentionens baslinje — fylls med lokala rullningar, inga trackers
uppdaterad: 2026-11-22
-->

# Retention — baslinje

> Planen: [RETENTION_PLAN.md](RETENTION_PLAN.md). Den här filen är bara siffror.

## Var siffrorna kommer ifrån

Allt mäts **lokalt på enheten**. Inga trackers, ingen cloud, ingen export utan
att någon aktivt kopierar texten.

| Källa | Vad den ger |
|---|---|
| `DailyActivityService` (`daily_activity_<userId>`) | En post per dag och profil: antal appöppningar och antal avslutade sessioner. 90 dagar sparas. |
| `AppAnalyticsService` (`analytics_events`) | De senaste 500 händelserna med tidsstämpel, inklusive `app_open`, `streak_extended`, `streak_lost`. |
| `UserProgress` | `currentStreak`, `longestStreak`, `lastSessionDate`, nivå och poäng. |

Rullningen finns för att 500-händersringen töms snabbt i en aktiv familj: den
dagliga räknaren är den enda källan som överlever.

## Definitioner

- **Aktiv dag** — en dag med minst en avslutad session (`sessions > 0`).
- **D1 / D7 / D30** — andel profiler med en aktiv dag N dagar efter sin första
  aktiva dag. Räknas per profil, inte per enhet.
- **Session** — `quiz_started` → `quiz_completed` för samma profil.
- **Svit-kvarhållning** — andel profiler med svit *n* som når *n+1* nästa dag.
- **Comeback** — andel profiler som gör en session inom 7 dagar efter ≥3 dagars
  uppehåll.

## Baslinje

*Tom med flit: den fylls först när en riktig familj/enhet har 30 dagars
rullning. Att skriva in en gissning här skulle göra varje senare jämförelse
meningslös.*

| Mätvärde | Värde | n | Datum | Kommentar |
|---|---|---|---|---|
| D1 | — | 0 | — | kräver 30 dagars rullning |
| D7 | — | 0 | — | |
| D30 | — | 0 | — | |
| Sessioner/vecka (median) | — | 0 | — | |
| Svit-kvarhållning | — | 0 | — | |
| Comeback efter ≥3 dagar | — | 0 | — | |

## Hur baslinjen läses

1. Samla i minst 30 dagar på minst en riktig enhet (emulator duger inte — den
   används inte av ett barn).
2. Läs rullningen per profil, inte per enhet: en familj med tre profiler är tre
   datapunkter, inte en.
3. Skriv in värdena ovan **innan** något experiment i fas 1–2 startar. Annars går
   effekten inte att skilja från en vanlig vecka.

Vyn i föräldradelen som gör steg 2 klickbart kommer med steg 14 i planen; tills
dess läses rullningen via test eller en tillfällig utskrift.
