---
name: granska-legacy-hive-format
description: 'Audit remaining legacy Hive persistence formats, versionless keys and migration surfaces. Use when checking old quiz/session data, deciding whether a migration is still needed, or validating cleanup of backward compatibility.'
argument-hint: 'Beskriv vilken yta som ska granskas: SRS-keys, in-progress sessions, settings, quiz history eller profiler.'
---

# Granska legacy Hive-format

## När den ska användas
- När ett gammalt Hive-format eller en gammal nyckel ska pensioneras men evidens saknas.
- När `v2|` eller andra versionsprefix ska jämföras mot äldre data på disk.
- När sessioner, settings eller quiz history kan bära både gamla och nya format samtidigt.

## Repo-ankare
- `docs/SESSION_BRIEF.md`
- `docs/ARCHITECTURE.md`
- `.github/instructions/regler-for-att-spara-saker-permanent-i-telefonen.instructions.md`
- `.github/instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md`
- `lib/data/repositories/local_storage_repository.dart`
- `lib/core/providers/quiz_provider.dart`
- `test/unit/logic/quiz_progression_edge_cases_test.dart`
- `test/unit/logic/quiz_provider_srs_test.dart`

## Arbetsordning
1. Läs `docs/SESSION_BRIEF.md` först och kontrollera vilken legacy-yta som fortfarande är öppen.
2. Avgränsa till en enda persistence-yta: SRS-keys, in-progress, settings, quiz history eller user progress.
3. Sök efter versionslösa nycklar, displaytext-baserade identifierare, regex-gissningar, alias-prefix och fallback-parsering i repository, provider och test.
4. Skilj mellan verifierad bakåtkompatibilitet som fortfarande behövs och kompatibilitetskod som bara antas vara nödvändig.
5. Om bevis saknas: föreslå en liten read-only audit eller ett fokuserat test innan cleanup.
6. Om ett format verkligen ska pensioneras: peka vidare till `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md` eller närmaste relevanta QA-skill.

## Frågor att besvara
- Vilket gammalt format kan fortfarande förekomma på disk?
- Var normaliseras eller migreras det idag?
- Finns ett riktat test som bevisar beteendet?
- Ska formatet migreras, behållas eller avskrivas med evidens?

## Stoppa dessa misstag
- Radera alias eller fallback utan bevis att gammal data inte längre kan finnas.
- Gissa legacy-format från displaytext när ett versionsprefix kan användas.
- Blanda ihop live-problem i Hive med rena runtime-buggar i UI.
- Göra bred cleanup innan en enda persistence-yta har verifierats.