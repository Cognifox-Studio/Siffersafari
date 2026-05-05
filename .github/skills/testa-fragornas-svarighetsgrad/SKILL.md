---
name: testa-fragornas-svarighetsgrad
description: 'Run and analyze the difficulty mix audits to verify balanced question generation. Use when question generation, grade balancing or audit tolerances change.'
argument-hint: 'Beskriv om ändringen gäller generatorn, nivågränser eller en specifik audit.'
---

# Testa frågornas svarighetsgrad

Denna skill används för att verifiera att proportionerna av svårighetsgrader och frågetyper är rimliga när `QuestionGeneratorService` eller närliggande konfiguration ändras.

## Arbetsflöde
1. Kör i första hand `flutter test test/unit/audits/difficulty_mix_audit_test.dart` eller motsvarande workspace-task.
2. Om ändringen påverkar bredare distribution eller promptmix: kör även `flutter test test/unit/audits/mix_distribution_audit_test.dart`.
3. Analysera utdata och rapportera vilka kategorier eller operationer som driver utanför toleransen.
4. Om mixen är fel: peka ut sannolik rotorsak i generatorn eller konfigurationen och föreslå riktad justering.
5. Säkerställ att inga okända promptnycklar eller fallback-kategorier genereras oavsiktligt.
