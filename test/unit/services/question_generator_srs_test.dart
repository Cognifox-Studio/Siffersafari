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

    test('returnerar null för legacy Mix-nyckel utan v2-prompt', () {
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

    test('parsar giltig v2-nyckel för standardmönster utan promptText', () {
      final question = service.tryGenerateFromSrsKey(
        'v2|multiplication|4|7|28|4 × 7 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.multiplication);
      expect(question.operand1, 4);
      expect(question.operand2, 7);
      expect(question.correctAnswer, 28);
      expect(question.promptText, isNull);
    });

    test('parsar giltig v2-nyckel med specialprompt', () {
      final question = service.tryGenerateFromSrsKey(
        'v2|addition|3|5|8|Anna har 3 äpplen, får 5 till. Totalt? = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.addition);
      expect(question.operand1, 3);
      expect(question.operand2, 5);
      expect(question.correctAnswer, 8);
      expect(question.promptText, 'Anna har 3 äpplen, får 5 till. Totalt? = ?');
    });

    test('parsar giltig v2-nyckel där promptText innehåller pipes', () {
      final question = service.tryGenerateFromSrsKey(
        'v2|multiplication|0|0|10|Tabell\nA | B\n1 | 2\nTotal? = ?',
        DifficultyLevel.hard,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.multiplication);
      expect(question.operand1, 0);
      expect(question.operand2, 0);
      expect(question.correctAnswer, 10);
      expect(question.promptText, 'Tabell\nA | B\n1 | 2\nTotal? = ?');
    });

    test('parsar Mix-promptfamilj från v2-nyckel', () {
      final question = service.tryGenerateFromSrsKey(
        'v2|mixed|200|20|135|Procentuell förändring = ?\nPriset sänks med 20% från 200. Vad blir nya priset?',
        DifficultyLevel.medium,
      );

      expect(question, isNotNull);
      expect(question!.operationType, OperationType.mixed);
      expect(question.correctAnswer, 135);
      expect(
        question.promptText,
        startsWith('Procentuell förändring = ?'),
      );
    });

    test('avvisar Mix-nyckel utan prompttext', () {
      final question = service.tryGenerateFromSrsKey(
        'v2|mixed|2|3|5|2 ? 3 = ?',
        DifficultyLevel.easy,
      );

      expect(question, isNull);
    });
  });
}
