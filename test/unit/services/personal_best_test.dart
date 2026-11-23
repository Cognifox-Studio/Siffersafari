import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/personal_best.dart';

Map<String, dynamic> _round({
  required String operation,
  required int correct,
  required int total,
  String id = 's1',
  bool complete = true,
}) {
  return <String, dynamic>{
    'sessionId': id,
    'operationType': operation,
    'correctAnswers': correct,
    'totalQuestions': total,
    'isComplete': complete,
  };
}

void main() {
  group('[Unit] Personbästa', () {
    test('bästa rundan per räknesätt, inte den senaste', () {
      final best = personalBestsFrom([
        _round(operation: 'multiplication', correct: 9, total: 10, id: 'a'),
        _round(operation: 'multiplication', correct: 5, total: 10, id: 'b'),
        _round(operation: 'addition', correct: 8, total: 10, id: 'c'),
      ]);

      expect(best[OperationType.multiplication]!.correct, 9);
      expect(best[OperationType.addition]!.correct, 8);
      expect(best[OperationType.division], isNull);
    });

    test('en avbruten runda räknas aldrig som personbästa', () {
      final best = personalBestsFrom([
        _round(
          operation: 'division',
          correct: 10,
          total: 10,
          complete: false,
        ),
      ]);

      expect(best, isEmpty);
    });

    test('rundan som just tog slut jämförs inte med sig själv', () {
      final history = [
        _round(operation: 'addition', correct: 6, total: 10, id: 'old'),
        _round(operation: 'addition', correct: 9, total: 10, id: 'now'),
      ];

      expect(
        isNewPersonalBest(
          operationType: 'addition',
          correct: 9,
          total: 10,
          history: history,
          excludeSessionId: 'now',
        ),
        isTrue,
      );
      expect(
        isNewPersonalBest(
          operationType: 'addition',
          correct: 9,
          total: 10,
          history: history,
        ),
        isFalse,
      );
    });

    test('första rundan är inget personbästa -- det finns inget att slå', () {
      expect(
        isNewPersonalBest(
          operationType: 'subtraction',
          correct: 10,
          total: 10,
          history: const [],
        ),
        isFalse,
      );
    });

    test('fler rätta svar vinner över ett mindre men perfekt pass', () {
      final best = personalBestsFrom([
        _round(operation: 'mixed', correct: 5, total: 5, id: 'small'),
        _round(operation: 'mixed', correct: 8, total: 10, id: 'big'),
      ]);

      expect(best[OperationType.mixed]!.correct, 8);
      expect(best[OperationType.mixed]!.total, 10);
    });

    test('texten räknar rätta svar först', () {
      const best = PersonalBest(
        operation: OperationType.multiplication,
        correct: 9,
        total: 10,
      );

      expect(best.label, '9 av 10 i gånger-djungeln');
      expect(best.accuracy, closeTo(0.9, 0.0001));
    });

    test('okända räknesätt och trasiga rader ignoreras', () {
      final best = personalBestsFrom([
        _round(operation: 'geometry', correct: 9, total: 10),
        _round(operation: 'addition', correct: 4, total: 0, id: 'empty'),
        <String, dynamic>{'isComplete': true},
      ]);

      expect(best, isEmpty);
    });
  });
}
