import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] Ekvation bare-int contract (#58)', () {
    test('Åk 7 Mix equations ask Vad är x? with integer answer', () {
      final service = QuestionGeneratorService(
        random: Random(3),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      for (var attempt = 0; attempt < 320; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 7,
          gradeLevel: 7,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        final prompt = question.promptText;
        if (prompt == null || !prompt.startsWith('Ekvation = ?')) {
          continue;
        }

        expect(prompt, contains('Vad är x?'));
        expect(question.correctAnswer, isA<int>());
        expect(question.correctAnswer, greaterThan(0));
        return;
      }

      fail('Ingen Ekvation genererades inom 320 försök.');
    });
  });
}
