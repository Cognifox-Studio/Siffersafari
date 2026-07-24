import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestionGeneratorService - grade 9 geometry bank', () {
    test('grade 9 mixed can generate bank-like geometry prompts', () {
      final service = QuestionGeneratorService(
        random: Random(0),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      for (var attempt = 0; attempt < 360; attempt++) {
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
            !question.promptText!.startsWith('Geometri = ?')) {
          continue;
        }

        expect(question.correctAnswer, greaterThan(0));
        expect(
          question.promptText,
          anyOf(
            contains('Pythagoras'),
            contains('Area av'),
            contains('Omkrets av'),
            contains('Volym av'),
          ),
        );
        expect(question.explanation, contains('${question.correctAnswer}'));
        return;
      }

      fail('Ingen Åk 9-geometri genererades inom 360 försök.');
    });

    test('grade 8 mixed keeps geometric transformation prompts', () {
      final service = QuestionGeneratorService(
        random: Random(11),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      for (var attempt = 0; attempt < 360; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.hard,
          difficultyStep: 8,
          gradeLevel: 8,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        if (question.promptText == null) {
          continue;
        }

        if (question.promptText!.startsWith('Geometri = ?')) {
          fail('Åk 8 ska inte generera den nya Åk 9-geometrifamiljen.');
        }

        if (question.promptText!.startsWith('Geometrisk transformation = ?')) {
          expect(question.correctAnswer, isNotNull);
          return;
        }
      }

      fail(
        'Ingen geometrisk transformation genererades för Åk 8 inom 360 försök.',
      );
    });
  });
}
