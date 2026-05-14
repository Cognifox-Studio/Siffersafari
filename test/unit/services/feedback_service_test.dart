import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';

void main() {
  group('[Unit] FeedbackService', () {
    late FeedbackService service;

    setUp(() {
      service = FeedbackService();
    });

    test('ger extra additionstips vid fel svar', () {
      const question = Question(
        id: 'q_add_tip',
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        operand1: 7,
        operand2: 3,
        correctAnswer: 10,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 8,
        ageGroup: AgeGroup.middle,
      );

      expect(feedback.isCorrect, isFalse);
      expect(feedback.message, contains('Rätt svar: 10'));
      expect(feedback.numberLine?.start, 7);
      expect(feedback.numberLine?.jump, 3);
      expect(feedback.numberLine?.end, 10);
      expect(
        feedback.message,
        contains('💡 Börja på 7 och räkna 3 steg till.'),
      );
    });

    test('ger subtraktionstips vid fel svar', () {
      const question = Question(
        id: 'q_sub_tip',
        operationType: OperationType.subtraction,
        difficulty: DifficultyLevel.easy,
        operand1: 7,
        operand2: 3,
        correctAnswer: 4,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 5,
        ageGroup: AgeGroup.middle,
      );

      expect(feedback.isCorrect, isFalse);
      expect(feedback.numberLine?.operationType, OperationType.subtraction);
      expect(feedback.numberLine?.start, 7);
      expect(feedback.numberLine?.jump, 3);
      expect(feedback.numberLine?.end, 4);
      expect(
        feedback.message,
        contains('💡 Börja på 7 och räkna 3 steg tillbaka.'),
      );
    });

    test('ger grupperad hjälp för multiplikation vid fel svar', () {
      const question = Question(
        id: 'q_mul_tip',
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        operand1: 7,
        operand2: 3,
        correctAnswer: 21,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 20,
        ageGroup: AgeGroup.middle,
      );

      expect(feedback.isCorrect, isFalse);
      expect(feedback.numberLine, isNull);
      expect(feedback.groupModel?.groupCount, 3);
      expect(feedback.groupModel?.groupValue, 7);
      expect(feedback.groupModel?.totalValue, 21);
      expect(
        feedback.message,
        contains('💡 Se det som 3 grupper med 7 i varje.'),
      );
    });

    test('ger delningshjälp för division vid fel svar', () {
      const question = Question(
        id: 'q_div_tip',
        operationType: OperationType.division,
        difficulty: DifficultyLevel.easy,
        operand1: 12,
        operand2: 3,
        correctAnswer: 4,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 5,
        ageGroup: AgeGroup.middle,
      );

      expect(feedback.isCorrect, isFalse);
      expect(feedback.numberLine, isNull);
      expect(feedback.groupModel?.groupCount, 3);
      expect(feedback.groupModel?.groupValue, 4);
      expect(feedback.groupModel?.totalValue, 12);
      expect(
        feedback.message,
        contains('💡 Dela 12 i 3 lika grupper.'),
      );
    });

    test('ger samma additionstips vid långsam men korrekt lösning', () {
      const question = Question(
        id: 'q_add_slow_tip',
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        operand1: 7,
        operand2: 3,
        correctAnswer: 10,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 10,
        ageGroup: AgeGroup.middle,
        responseTime: const Duration(seconds: 9),
      );

      expect(feedback.isCorrect, isTrue);
      expect(feedback.message, contains('Rätt svar: 10'));
      expect(feedback.numberLine?.start, 7);
      expect(feedback.numberLine?.jump, 3);
      expect(feedback.numberLine?.end, 10);
      expect(
        feedback.message,
        contains('💡 Börja på 7 och räkna 3 steg till.'),
      );
    });

    test('ger inte additionstips vid snabb korrekt lösning', () {
      const question = Question(
        id: 'q_add_fast_tip',
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        operand1: 7,
        operand2: 3,
        correctAnswer: 10,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 10,
        ageGroup: AgeGroup.middle,
        responseTime: const Duration(seconds: 3),
      );

      expect(feedback.isCorrect, isTrue);
      expect(feedback.numberLine, isNull);
      expect(
        feedback.message,
        isNot(contains('💡 Börja på 7 och räkna 3 steg till.')),
      );
    });

    test('ger samma subtraktionstips vid långsam men korrekt lösning', () {
      const question = Question(
        id: 'q_sub_slow_tip',
        operationType: OperationType.subtraction,
        difficulty: DifficultyLevel.easy,
        operand1: 9,
        operand2: 4,
        correctAnswer: 5,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 5,
        ageGroup: AgeGroup.middle,
        responseTime: const Duration(seconds: 9),
      );

      expect(feedback.isCorrect, isTrue);
      expect(feedback.numberLine?.operationType, OperationType.subtraction);
      expect(feedback.numberLine?.start, 9);
      expect(feedback.numberLine?.jump, 4);
      expect(feedback.numberLine?.end, 5);
      expect(
        feedback.message,
        contains('💡 Börja på 9 och räkna 4 steg tillbaka.'),
      );
    });

    test('ger grupperad multiplikationshjälp vid långsam men korrekt lösning',
        () {
      const question = Question(
        id: 'q_mul_slow_tip',
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        operand1: 3,
        operand2: 4,
        correctAnswer: 12,
      );

      final feedback = service.buildFeedback(
        question: question,
        userAnswer: 12,
        ageGroup: AgeGroup.middle,
        responseTime: const Duration(seconds: 9),
      );

      expect(feedback.isCorrect, isTrue);
      expect(feedback.groupModel?.groupCount, 3);
      expect(feedback.groupModel?.groupValue, 4);
      expect(
        feedback.message,
        contains('💡 Se det som 3 grupper med 4 i varje.'),
      );
    });
  });
}
