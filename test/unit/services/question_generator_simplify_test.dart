import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Åk 7 Förenkla evaluate-at-x (#51)', () {
    test('Mix kan ge Förenkla = ? med heltalssvar', () {
      final service = QuestionGeneratorService(random: Random(12));
      Question? found;

      for (var i = 0; i < 600; i++) {
        final q = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 7,
          gradeLevel: 7,
        );
        final text = q.promptText ?? '';
        if (text.startsWith('Förenkla = ?')) {
          found = q;
          break;
        }
      }

      expect(found, isNotNull);
      expect(found!.promptText!, contains('när x ='));
      expect(found.wrongAnswers, hasLength(3));
    });
  });
}
