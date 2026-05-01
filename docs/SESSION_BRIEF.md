# Session Status Brief

> Syfte: Sammanfattar aktuellt projektl�ge, p�g�ende arbete, och n�sta steg f�r att underl�tta kontext�verf�ring mellan sessioner.
>
> Uppdateras efter st�rre milestones. Historiska beslut finns i `docs/DECISIONS_LOG.md`.

---

## Nul�ge (2026-04-26)

**Version:** 1.3.4 (Mergad & Taggad)
**Tester:** Alla 190 tester passerar ?  
**flutter analyze:** 0 fel ?  
**Integration smoke:** 3/3 passed (FULL_SMOKE=false) ?  
**Release APK:** Byggs och laddas upp just nu via GitHub Actions (v1.3.4) ?  
**Git:** Taggad v1.3.4 och pushat till origin main ?

### Senaste leveranser

**2026-04-18 � Teknisk sanering och Mocks-centralisering**
- **Borttagning av Lottie/Rive**: Omfattande rensning av gamla Lottie- och Rive-beroenden fr�n pubspec.yaml, testfiler och `tools/pipeline.py`. Endast procedurgenererade SVG-karakt�rer �r nu kvar som prim�r asset-runtime.
- **Centraliserade Mocks**: Flyttade utspridda fakes/mocks (_MockAudioService, _InMemoryLocalStorageRepository etc.) till gemensamma 	est/test_utils.dart f�r att undvika kodduplicering och underl�tta framtida tester.
- **Pipeline-patch**: Skriptet 	ools/pipeline.py �r lagat efter SVG-saneringen och bygger konsekvent om ssets.g.dart utan krascher, alla filsystemscheck-tester passerar gr�nt utan krav p� .riv-filer.


**2026-04-18 � v1.3.2 ROI-plan (5 faser)**

- **Fas C � Onboarding null-grade fallback**: `_finish()` anv�nder `effectiveGrade = _gradeLevel ?? 1`; anv�ndare kan starta utan att ha valt �rskurs
- **Fas B � SRS-injektionstester**: 18 nya unit-tester i `test/unit/services/question_generator_srs_test.dart` (12 tester) och `test/unit/logic/quiz_provider_srs_test.dart` (6 tester)
- **Fas A � Niv�uppg�ngs-celebration**:
  - `LevelUpEvent`-entitet (`oldLevel`, `newLevel`, `newTitle`)
  - `UserState.lastLevelUp` (sentinel-pattern, clearas vid navigation)
  - `applyQuizResult` detekterar niv�korsning och populerar `lastLevelUp`
  - `_LevelUpBanner`-widget visas �verst i ResultsScreen
  - Analytics-event `level_up` loggas med `{old_level, new_level, title}`
- **Fas D � Streak-break feedback**: `DailyChallengeState.streakWasReset` s�tts true om `previousStreak > 1 && newStreak == 1`; DailyChallengeCard visar "Din streak startade om�"-text
- **Fas E � SRS-status i resultatsk�rm**: StatsCard visar "Sparade f�r repetition: N fr�gor" om `wrongAnswers > 0` och SRS �r aktiverat

**2026-04-18 � Analytics + SRS due-fr�ge-injektion**

- `parent_mode_opened` och `quiz_abandoned` analytics-event
- SRS due-fr�ge-injektion: `tryGenerateFromSrsKey`, cap `totalQuestions ~/3`, pendingDueKeys-fl�de
- Integrationstester fixade (enstegs-onboarding 1/1)

**2026-04-05 � Daily Challenge streak + combo-multiplikator**

- `DailyChallengeState` med `isCompleted` och `streakCount`
- `DailyChallengeCard` visar ?? N dagar-badge n�r `streak > 1`
- Combo-multiplikator: 1.0x / 1.5� / 2.0� vid 3+/5+ r�tt i rad

---

## N�sta steg

### Efter v1.3.4
- Verifiera att GitHub Actions bygger och laddar upp APK:n f�r release v1.3.4
- Planera in n�sta steg (t.ex. vidareutveckla SRS f�r fler operat�rer)

### SRS-begr�nsning att notera
- `tryGenerateFromSrsKey` hanterar endast enkla aritmetikfr�gor (t.ex. `4 � 7 = ?`)
- Ordproblem, M4-statistik, sannolikhet, negativa tal etc. parseras inte ? fallback till slumpm�ssig generering

---

## Stabila beslut (sammanfattning)
Se `docs/DECISIONS_LOG.md` f�r fullst�ndig historik. Nyckelbeslut:
- SVG-first f�r mascot-runtime (Rive = research/future)
- Riverpod + GetIt + Hive
- Feature-first UI-struktur (`lib/features/`)
- Hybrid adaptiv sv�righet (micro + macro + cooldown)
- Daily Challenge personaliseras via `getTodaysChallengeForUser` (mastery + operationDifficultySteps)
