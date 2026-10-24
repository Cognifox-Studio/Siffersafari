import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Half-of-n text bridge (#36)', () {
    test('Åk 4–6 Mix kan ge Bråk (½) med heltalssvar', () {
      Question? found;
      for (final grade in [3, 4, 5, 6]) {
        final service = QuestionGeneratorService(random: Random(grade * 97));
        for (var i = 0; i < 500; i++) {
          final q = service.generateQuestion(
            ageGroup: grade <= 3 ? AgeGroup.young : AgeGroup.middle,
            operationType: OperationType.mixed,
            difficulty: DifficultyLevel.medium,
            difficultyStep: 6,
            gradeLevel: grade,
          );
          final text = q.promptText ?? '';
          if (text.startsWith('Bråk (½) = ?')) {
            found = q;
            break;
          }
        }
        if (found != null) break;
      }

      expect(found, isNotNull);
      expect(found!.operationType, OperationType.mixed);
      expect(found.operand1.isEven, isTrue);
      expect(found.correctAnswer, found.operand1 ~/ 2);
      expect(found.wrongAnswers, hasLength(3));
      expect(found.wrongAnswers, isNot(contains(found.correctAnswer)));
    });
  });
}
