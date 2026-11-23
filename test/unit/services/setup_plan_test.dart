import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/setup_plan.dart';

void main() {
  group('[Unit] Startplan', () {
    test('Åk 1 får bara plus och minus och inga textfrågor', () {
      final plan = SetupPlan.forGrade(1);

      expect(plan.operations, [OperationType.addition,
        OperationType.subtraction]);
      expect(plan.readingHelp, isFalse);
      expect(plan.gradeLabel, 'Årskurs 1');
    });

    test('Åk 3 får alla fyra räknesätten och läshjälp', () {
      final plan = SetupPlan.forGrade(3);

      expect(plan.operations, OperationType.values.toList());
      expect(plan.readingHelp, isTrue);
      expect(plan.operationsLabel,
          'plusraketer, minusgrottor, gånger-djungeln, delat-isbanan');
    });

    test('«Vet inte än» börjar försiktigt och säger det', () {
      final plan = SetupPlan.forGrade(null);

      expect(plan.gradeWasGuessed, isTrue);
      expect(plan.gradeLabel, 'Årskurs 1 – vi börjar försiktigt');
      expect(plan.operations, [OperationType.addition,
        OperationType.subtraction]);
    });

    test('planen går att läsa upp som en mening', () {
      final plan = SetupPlan.forGrade(4);

      expect(
        plan.spokenSummary,
        'Årskurs 4. Räknesätt: plusraketer, minusgrottor, '
        'gånger-djungeln, delat-isbanan. Läshjälp på. '
        'Allt kan ändras i Föräldraläge.',
      );
    });

    test('tre rader: årskurs, räknesätt och frågor', () {
      final plan = SetupPlan.forGrade(2);

      expect(plan.lines.map((line) => line.label),
          ['Årskurs', 'Räknesätt', 'Frågor']);
      expect(plan.lines[2].value, 'Läshjälp på');
    });

    test('trasig årskurs kläms in i 1–9 i stället för att krascha', () {
      expect(SetupPlan.forGrade(0).grade, 1);
      expect(SetupPlan.forGrade(42).grade, 9);
    });
  });
}
