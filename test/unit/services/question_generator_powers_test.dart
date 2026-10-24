import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] Åk 8 Potenser widen (#57)', () {
    test('hard step can produce larger bank-like bases/exponents', () {
      final service = QuestionGeneratorService(
        random: Random(7),
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      final seen = <String>{};
      for (var attempt = 0; attempt < 400; attempt++) {
        final question = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.hard,
          difficultyStep: 9,
          gradeLevel: 8,
          wordProblemsEnabledOverride: false,
          missingNumberEnabledOverride: false,
        );

        final prompt = question.promptText;
        if (prompt == null || !prompt.startsWith('Potenser = ?')) {
          continue;
        }

        expect(question.correctAnswer, greaterThan(0));
        expect(question.correctAnswer, lessThanOrEqualTo(10000));
        expect(question.operand1, greaterThan(0));
        expect(question.operand2, greaterThanOrEqualTo(2));
        seen.add('${question.operand1}^${question.operand2}');
      }

      expect(seen, isNotEmpty, reason: 'Expected some Potenser prompts.');
      expect(
        seen.any((entry) {
          final parts = entry.split('^');
          final base = int.parse(parts[0]);
          final exp = int.parse(parts[1]);
          return base >= 15 || exp >= 5;
        }),
        isTrue,
        reason: 'Hard step should reach larger bank-like powers, got $seen',
      );
    });
  });
}
