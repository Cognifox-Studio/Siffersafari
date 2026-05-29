import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestionGeneratorService – bank-driven missing numbers', () {
    test('grade 2 multiplication can generate missing-number prompts', () {
      final service = QuestionGeneratorService(random: Random(7));

      final question = service.generateQuestion(
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.medium,
        difficultyStep: 3,
        gradeLevel: 2,
        wordProblemsEnabledOverride: false,
        missingNumberEnabledOverride: true,
        missingNumberChanceOverride: 1.0,
      );

      expect(question.promptText, isNotNull);
      expect(
        question.promptText,
        anyOf(startsWith('? × '), contains(' × ? = ')),
      );
      expect(question.correctAnswer, greaterThan(0));
    });

    test('grade 2 division can generate missing-number prompts', () {
      final service = QuestionGeneratorService(random: Random(11));

      final question = service.generateQuestion(
        ageGroup: AgeGroup.young,
        operationType: OperationType.division,
        difficulty: DifficultyLevel.medium,
        difficultyStep: 3,
        gradeLevel: 2,
        wordProblemsEnabledOverride: false,
        missingNumberEnabledOverride: true,
        missingNumberChanceOverride: 1.0,
      );

      expect(question.promptText, isNotNull);
      expect(
        question.promptText,
        anyOf(startsWith('? ÷ '), contains(' ÷ ? = ')),
      );
      expect(question.correctAnswer, greaterThan(0));
    });

    test('grade 2 multiplication stays standard before step 3', () {
      final service = QuestionGeneratorService(random: Random(19));

      final question = service.generateQuestion(
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        difficultyStep: 2,
        gradeLevel: 2,
        wordProblemsEnabledOverride: false,
        missingNumberEnabledOverride: true,
        missingNumberChanceOverride: 1.0,
      );

      expect(question.promptText, isNull);
    });
  });

  group('[Unit] QuestionGeneratorService – grade 1 number sense from bank', () {
    test('grade 1 addition can generate after-number prompts', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (var attempt = 0; attempt < 60; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.addition,
          difficulty: DifficultyLevel.easy,
          difficultyStep: 2,
          gradeLevel: 1,
          wordProblemsEnabledOverride: false,
        );

        if (question.promptText == null) {
          continue;
        }

        expect(question.promptText, startsWith('Vilket tal kommer efter '));
        expect(question.correctAnswer, question.operand1 + 1);
        return;
      }

      fail('Ingen Åk 1 efter-fråga genererades inom 60 försök.');
    });

    test('grade 1 subtraction can generate before-number prompts', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (var attempt = 0; attempt < 60; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.subtraction,
          difficulty: DifficultyLevel.easy,
          difficultyStep: 2,
          gradeLevel: 1,
          wordProblemsEnabledOverride: false,
        );

        if (question.promptText == null) {
          continue;
        }

        expect(question.promptText, startsWith('Vilket tal kommer före '));
        expect(question.correctAnswer, question.operand1 - 1);
        return;
      }

      fail('Ingen Åk 1 före-fråga genererades inom 60 försök.');
    });

    test('grade 1 number-sense prompts stay inside current range', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (final operation in [
        OperationType.addition,
        OperationType.subtraction,
      ]) {
        for (var attempt = 0; attempt < 20; attempt++) {
          final question = service.generateQuestion(
            ageGroup: AgeGroup.young,
            operationType: operation,
            difficulty: DifficultyLevel.medium,
            difficultyStep: 4,
            gradeLevel: 1,
            wordProblemsEnabledOverride: false,
          );

          if (question.promptText == null) {
            continue;
          }

          expect(question.correctAnswer, greaterThanOrEqualTo(0));
          expect(question.correctAnswer, lessThanOrEqualTo(20));
          for (final wrongAnswer in question.wrongAnswers) {
            expect(wrongAnswer, greaterThanOrEqualTo(0));
            expect(wrongAnswer, lessThanOrEqualTo(20));
          }
        }
      }
    });

    test('grade 1 addition can generate ascending sequence prompts', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (var attempt = 0; attempt < 140; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.addition,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 4,
          gradeLevel: 1,
          wordProblemsEnabledOverride: false,
        );

        if (question.promptText == null ||
            !question.promptText!
                .startsWith('Vilket tal saknas i ordningen: ')) {
          continue;
        }

        expect(question.correctAnswer, equals(question.operand1 + 2));
        expect(question.operand2, equals(question.operand1 + 3));
        return;
      }

      fail('Ingen Åk 1 stigande talföljd genererades inom 140 försök.');
    });

    test('grade 1 subtraction can generate descending sequence prompts', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (var attempt = 0; attempt < 140; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.subtraction,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 4,
          gradeLevel: 1,
          wordProblemsEnabledOverride: false,
        );

        if (question.promptText == null ||
            !question.promptText!
                .startsWith('Vilket tal saknas i ordningen: ')) {
          continue;
        }

        expect(question.correctAnswer, equals(question.operand1 - 2));
        expect(question.operand2, equals(question.operand1 - 3));
        return;
      }

      fail('Ingen Åk 1 fallande talföljd genererades inom 140 försök.');
    });

    test('grade 1 addition can generate compare-largest prompts', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (var attempt = 0; attempt < 120; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.addition,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 4,
          gradeLevel: 1,
          wordProblemsEnabledOverride: false,
        );

        if (question.promptText == null ||
            !question.promptText!.startsWith('Vilket är störst: ')) {
          continue;
        }

        expect(
          question.correctAnswer,
          greaterThan(
            question.operand1 == question.correctAnswer
                ? question.operand2 - 1
                : question.operand1 - 1,
          ),
        );
        expect(
          question.correctAnswer,
          equals(max(question.operand1, question.operand2)),
        );
        return;
      }

      fail('Ingen Åk 1 störst-fråga genererades inom 120 försök.');
    });

    test('grade 1 subtraction can generate compare-smallest prompts', () {
      final service = QuestionGeneratorService(random: Random(0));

      for (var attempt = 0; attempt < 120; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.subtraction,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 4,
          gradeLevel: 1,
          wordProblemsEnabledOverride: false,
        );

        if (question.promptText == null ||
            !question.promptText!.startsWith('Vilket är minst: ')) {
          continue;
        }

        expect(
          question.correctAnswer,
          equals(min(question.operand1, question.operand2)),
        );
        return;
      }

      fail('Ingen Åk 1 minst-fråga genererades inom 120 försök.');
    });
  });
}
