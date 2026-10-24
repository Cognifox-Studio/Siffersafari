import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Rimlighet estimate (#38)', () {
    test('Mix kan ge Rimlighet = ? med heltalssvar', () {
      final service = QuestionGeneratorService(random: Random(19));
      Question? found;

      for (var i = 0; i < 600; i++) {
        final q = service.generateQuestion(
          ageGroup: AgeGroup.middle,
          operationType: OperationType.mixed,
          difficulty: DifficultyLevel.medium,
          difficultyStep: 6,
          gradeLevel: 5,
        );
        final text = q.promptText ?? '';
        if (text.startsWith('Rimlighet = ?')) {
          found = q;
          break;
        }
      }

      expect(found, isNotNull);
      expect(found!.correctAnswer, greaterThan(0));
      expect(found.wrongAnswers, hasLength(3));
      expect(found.wrongAnswers, isNot(contains(found.correctAnswer)));
      expect(
        found.promptText!,
        anyOf(contains('Uppskatta'), contains('närmast')),
      );
    });
  });
}
