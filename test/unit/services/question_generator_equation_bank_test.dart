import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestionGeneratorService – upper-grade bank equations', () {
    test('grade 7 mixed can generate bank-like equation prompts', () {
      final service = QuestionGeneratorService(
        random: Random(0),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      for (var attempt = 0; attempt < 240; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 7,
          gradeLevel: 7,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        if (question.promptText == null ||
            !question.promptText!.startsWith('Ekvation = ?')) {
          continue;
        }

        expect(question.correctAnswer, greaterThan(0));
        expect(question.promptText, contains('x'));
        expect(question.explanation, contains('x = ${question.correctAnswer}'));
        return;
      }

      fail('Ingen Åk 7-ekvation genererades inom 240 försök.');
    });

    test('grade 9 mixed can generate division-style equation prompts', () {
      final service = QuestionGeneratorService(
        random: Random(11),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      for (var attempt = 0; attempt < 320; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.hard,
          difficultyStep: 8,
          gradeLevel: 9,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        if (question.promptText == null ||
            !question.promptText!.startsWith('Ekvation = ?')) {
          continue;
        }

        if (!question.promptText!.contains('/')) {
          continue;
        }

        expect(question.correctAnswer, greaterThan(0));
        expect(question.promptText, contains('x'));
        expect(question.explanation, contains('x = ${question.correctAnswer}'));
        return;
      }

      fail('Ingen Åk 9-ekvation med division genererades inom 320 försök.');
    });

    test('grade 8 mixed does not generate equation prompts from bank gap', () {
      final service = QuestionGeneratorService(
        random: Random(0),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      for (var attempt = 0; attempt < 320; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 8,
          gradeLevel: 8,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        expect(
          question.promptText?.startsWith('Ekvation = ?') ?? false,
          isFalse,
        );
      }
    });
  });
}
