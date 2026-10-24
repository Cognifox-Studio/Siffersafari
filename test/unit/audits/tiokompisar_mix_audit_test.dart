import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] Tiokompisar Mix audit (#59)', () {
    test('Åk 1 Mix early steps still produce number bonds to 10', () {
      const n = 800;
      var bonds = 0;

      for (final seed in const [11, 29, 47]) {
        final service = QuestionGeneratorService(
          random: Random(seed),
          wordProblemsEnabled: false,
          missingNumberEnabled: false,
        );

        for (var i = 0; i < n; i++) {
          final question = service.generateQuestion(
            ageGroup: AgeGroup.young,
            operationType: OperationType.mixed,
            difficulty: DifficultyLevel.easy,
            difficultyStep: 2 + (i % 3),
            gradeLevel: 1,
            wordProblemsEnabledOverride: false,
            missingNumberEnabledOverride: false,
          );

          if (question.operationType == OperationType.addition &&
              question.correctAnswer == 10 &&
              question.operand1 >= 0 &&
              question.operand2 >= 0 &&
              question.operand1 <= 10 &&
              question.operand2 <= 10 &&
              question.operand1 + question.operand2 == 10 &&
              question.promptText == null) {
            bonds++;
          }
        }
      }

      final rate = bonds / (n * 3);
      expect(
        rate,
        greaterThanOrEqualTo(0.05),
        reason:
            'Facit claims tiokompisar for Åk1; Mix starved them (rate=${rate.toStringAsFixed(3)}, bonds=$bonds).',
      );
    });
  });
}
