import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Åk 9 sannolikhet bag/table (#40)', () {
    test('Mix kan ge Sannolikhet = ? med %-svar', () {
      final service = QuestionGeneratorService(random: Random(55));
      Question? found;

      for (var i = 0; i < 700; i++) {
        final q = service.generateQuestion(
          ageGroup: AgeGroup.older,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.hard,
          difficultyStep: 8,
          gradeLevel: 9,
        );
        final text = q.promptText ?? '';
        if (text.startsWith('Sannolikhet = ?')) {
          found = q;
          break;
        }
      }

      expect(found, isNotNull);
      expect(found!.correctAnswer, inInclusiveRange(0, 100));
      expect(found.wrongAnswers, hasLength(3));
    });
  });
}
