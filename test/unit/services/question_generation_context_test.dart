import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generation/question_generation_context.dart';
import 'package:siffersafari/core/services/question_generation/question_request.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] QuestionGenerationContext', () {
    test('build resolves operation and mix policy for addition', () {
      final ctx = QuestionGenerationContext.build(
        random: Random(1),
        getRandomOperation: ({
          required int? gradeLevel,
          required int mixBaselineStep,
        }) =>
            OperationType.addition,
        request: QuestionRequest(
          ageGroup: AgeGroup.young,
          operationType: OperationType.addition,
          difficulty: DifficultyLevel.easy,
          gradeLevel: 2,
        ),
        wordProblemsEnabled: false,
        wordProblemsChance: 0,
        missingNumberEnabled: false,
        missingNumberChance: 0,
      );

      expect(ctx.operation, OperationType.addition);
      expect(ctx.mixPolicy.selectedOperation, OperationType.addition);
      expect(ctx.step, greaterThan(0));
    });
  });
}
