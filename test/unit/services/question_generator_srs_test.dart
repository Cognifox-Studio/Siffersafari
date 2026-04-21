import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestionGeneratorService.tryGenerateFromSrsKey', () {
    late QuestionGeneratorService service;

    setUp(() {
      service = QuestionGeneratorService();
    });

    test('parsar giltig multiplikationsnyckel', () {
      final question = service.tryGenerateFromSrsKey(
        'multiplication|4 × 7 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.multiplication);
      expect(question.operand1, 4);
      expect(question.operand2, 7);
      expect(question.correctAnswer, 28);
      expect(question.wrongAnswers, hasLength(3));
      expect(question.wrongAnswers, isNot(contains(28)));
    });

    test('parsar giltig additionsnyckel', () {
      final question = service.tryGenerateFromSrsKey(
        'addition|5 + 3 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.addition);
      expect(question.correctAnswer, 8);
    });

    test('parsar giltig subtraktionsnyckel', () {
      final question = service.tryGenerateFromSrsKey(
        'subtraction|10 - 4 = ?',
        DifficultyLevel.medium,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.subtraction);
      expect(question.correctAnswer, 6);
      expect(question.difficulty, DifficultyLevel.medium);
    });

    test('parsar giltig divisionsnyckel', () {
      final question = service.tryGenerateFromSrsKey(
        'division|12 ÷ 3 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.division);
      expect(question.correctAnswer, 4);
    });

    test('returnerar null för division med noll', () {
      final question = service.tryGenerateFromSrsKey(
        'division|5 ÷ 0 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null för OperationType.mixed', () {
      final question = service.tryGenerateFromSrsKey(
        'mixed|4 ? 7 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null för okänd operation', () {
      final question = service.tryGenerateFromSrsKey(
        'percent|50 % 100 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null när pipe saknas', () {
      final question = service.tryGenerateFromSrsKey(
        'multiplication 4 × 7 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null när "= ?" saknas', () {
      final question = service.tryGenerateFromSrsKey(
        'multiplication|4 × 7',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null för tom sträng', () {
      final question = service.tryGenerateFromSrsKey(
        '',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null när operand inte är ett heltal', () {
      final question = service.tryGenerateFromSrsKey(
        'addition|abc + 3 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });

    test('returnerar null när separator-symbolen är fel', () {
      // Använder + men säger multiplication
      final question = service.tryGenerateFromSrsKey(
        'multiplication|4 + 7 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });
  });
}
