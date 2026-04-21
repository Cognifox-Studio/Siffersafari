# Session Status Brief

> Syfte: Sammanfattar aktuellt projektläge, pågående arbete, och nästa steg för att underlätta kontextöverföring mellan sessioner.
>
> Uppdateras efter större milestones. Historiska beslut finns i `docs/DECISIONS_LOG.md`.

---

## Nuläge (2026-04-18)

**Version:** 1.3.1+9 → bygger mot v1.3.2  
**Tester:** 188/188 ✅ (unit, inkl. 18 nya SRS-tester)  
**flutter analyze:** 0 fel ✅  
**Integration smoke:** 3/3 passed (FULL_SMOKE=false) ✅  
**Release APK:** app-release.apk (73.1 MB) uppladdad till GitHub Release v1.3.1 ✅  
**Git:** tagged v1.3.1 @ ce75334, pushed to origin ✅

### Senaste leveranser

**2026-04-18 — v1.3.2 ROI-plan (5 faser)**

- **Fas C – Onboarding null-grade fallback**: `_finish()` använder `effectiveGrade = _gradeLevel ?? 1`; användare kan starta utan att ha valt årskurs
- **Fas B – SRS-injektionstester**: 18 nya unit-tester i `test/unit/services/question_generator_srs_test.dart` (12 tester) och `test/unit/logic/quiz_provider_srs_test.dart` (6 tester)
- **Fas A – Nivåuppgångs-celebration**:
  - `LevelUpEvent`-entitet (`oldLevel`, `newLevel`, `newTitle`)
  - `UserState.lastLevelUp` (sentinel-pattern, clearas vid navigation)
  - `applyQuizResult` detekterar nivåkorsning och populerar `lastLevelUp`
  - `_LevelUpBanner`-widget visas överst i ResultsScreen
  - Analytics-event `level_up` loggas med `{old_level, new_level, title}`
- **Fas D – Streak-break feedback**: `DailyChallengeState.streakWasReset` sätts true om `previousStreak > 1 && newStreak == 1`; DailyChallengeCard visar "Din streak startade om…"-text
- **Fas E – SRS-status i resultatskärm**: StatsCard visar "Sparade för repetition: N frågor" om `wrongAnswers > 0` och SRS är aktiverat

**2026-04-18 — Analytics + SRS due-fråge-injektion**

- `parent_mode_opened` och `quiz_abandoned` analytics-event
- SRS due-fråge-injektion: `tryGenerateFromSrsKey`, cap `totalQuestions ~/3`, pendingDueKeys-flöde
- Integrationstester fixade (enstegs-onboarding 1/1)

**2026-04-05 — Daily Challenge streak + combo-multiplikator**

- `DailyChallengeState` med `isCompleted` och `streakCount`
- `DailyChallengeCard` visar 🔥 N dagar-badge när `streak > 1`
- Combo-multiplikator: 1.0x / 1.5× / 2.0× vid 3+/5+ rätt i rad

---

## Nästa steg

### Kvar för v1.3.2-release
- **Bumpa pubspec** till `version: 1.3.2+10`
- **Manuell emulatorverifiering**: nivåuppgångsbanner, streak-reset-meddelande, SRS-rad i resultatskärm (kräver `Pixel_6 sync/install`)
- **Tagga v1.3.2** och ladda upp ny APK till GitHub Release

### SRS-begränsning att notera
- `tryGenerateFromSrsKey` hanterar endast enkla aritmetikfrågor (t.ex. `4 × 7 = ?`)
- Ordproblem, M4-statistik, sannolikhet, negativa tal etc. parseras inte → fallback till slumpmässig generering

---

## Stabila beslut (sammanfattning)
Se `docs/DECISIONS_LOG.md` för fullständig historik. Nyckelbeslut:
- SVG-first för mascot-runtime (Rive = research/future)
- Riverpod + GetIt + Hive
- Feature-first UI-struktur (`lib/features/`)
- Hybrid adaptiv svårighet (micro + macro + cooldown)
- Daily Challenge personaliseras via `getTodaysChallengeForUser` (mastery + operationDifficultySteps)
