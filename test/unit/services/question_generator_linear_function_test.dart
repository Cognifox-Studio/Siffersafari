import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Linjär funktion text-bridge (#39)', () {
    test('Åk 8–9 Mix kan ge Linjär funktion = ?', () {
      Question? found;
      for (final grade in [8, 9]) {
        final service = QuestionGeneratorService(random: Random(grade * 41));
        for (var i = 0; i < 500; i++) {
          final q = service.generateQuestion(
            ageGroup: AgeGroup.older,
            operationType: OperationType.mixed,
            difficulty: DifficultyLevel.hard,
            difficultyStep: 8,
            gradeLevel: grade,
          );
          final text = q.promptText ?? '';
          if (text.startsWith('Linjär funktion = ?')) {
            found = q;
            break;
          }
        }
        if (found != null) break;
      }

      expect(found, isNotNull);
      expect(found!.promptText!, contains('y ='));
      expect(found.wrongAnswers, hasLength(3));
    });
  });
}
