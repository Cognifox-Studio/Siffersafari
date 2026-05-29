import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestionGeneratorService - grade 8 proportionality bank', () {
    test('grade 8 mixed can generate bank-like proportionality prompts', () {
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

        if (question.promptText == null ||
            !question.promptText!.startsWith('Proportionalitet = ?')) {
          continue;
        }

        expect(question.correctAnswer, isNotNull);
        expect(question.correctAnswer, greaterThanOrEqualTo(0));
        expect(question.explanation, contains('${question.correctAnswer}'));
        expect(question.promptText, isNot(contains('0.')));
        return;
      }

      fail('Ingen Åk 8-proportionalitet genererades inom 320 försök.');
    });

    test('grade 7 mixed does not generate proportionality prompts', () {
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
          gradeLevel: 7,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        expect(
          question.promptText?.startsWith('Proportionalitet = ?') ?? false,
          isFalse,
        );
      }
    });
  });
}