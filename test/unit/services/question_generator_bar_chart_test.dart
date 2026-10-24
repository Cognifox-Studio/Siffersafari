import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Åk 6 ASCII diagram (#37)', () {
    test('Mix kan generera Diagram (stapel) med dag-etiketter', () {
      final service = QuestionGeneratorService(random: Random(77));
      Question? found;

      for (var i = 0; i < 800; i++) {
        final q = service.generateQuestion(
          ageGroup: AgeGroup.middle,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 7,
          gradeLevel: 6,
        );
        final text = q.promptText ?? '';
        if (text.startsWith('Diagram (stapel) = ?')) {
          found = q;
          break;
        }
      }

      expect(found, isNotNull);
      final prompt = found!.promptText!;
      expect(prompt, contains('Dag 1:'));
      expect(prompt, contains('Fråga:'));
      // Bars stay short even when values vary.
      for (final line in prompt.split('\n')) {
        if (!line.contains(':')) continue;
        final starRun = RegExp(r'\*+').firstMatch(line);
        if (starRun != null) {
          expect(starRun.group(0)!.length, lessThanOrEqualTo(20));
        }
      }
    });
  });
}
