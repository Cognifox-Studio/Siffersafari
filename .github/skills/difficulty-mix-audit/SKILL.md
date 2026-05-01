---
description: "Run and analyze the difficulty mix audit to ensure balanced question generation"
applyTo: "test/unit/audits/*_audit_test.dart, lib/core/services/question_generator_service.dart, specs/**"
---

# Difficulty Mix Audit

Denna skill används för att verifiera att proportionerna av svårighetsgrader och fråga-typer är korrekta, särskilt när `question_generator_service.dart` eller speccarna i `specs/` modifieras.

## Arbetsflöde

1. Kör enhetstestet för distribution genom terminalen eller en färdig VS Code Task:
   ```sh
   flutter test test/unit/audits/mix_distribution_audit_test.dart
   ```
2. Analysera utdata noggrant. Rapportera tillbaka andelen "special", "stats", och "prob" gentemot de förväntade resultaten för de valda årskurserna och stegen.
3. Om distributionen utanför toleransen (tolerance = 0.03):
    - Identifiera vilken prompt eller operation som genereras för ofta/sällan.
    - Föreslå åtgärder i `QuestionGeneratorService` eller relaterade konfigurationer.
4. Säkerställ att inga okända prompts (`otherPrompt`) genereras oavsiktligt. Leta efter saknade/felstavade nycklar om så är fallet.
