import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/entities/question.dart';

void main() {
  group('[Unit] Sortera MC order (#35)', () {
    test('Åk 1 addition kan ge Sortera minst till störst med MC-svar', () {
      final service = QuestionGeneratorService(random: Random(42));
      Question? found;

      for (var i = 0; i < 400; i++) {
        final q = service.generateQuestion(
          ageGroup: AgeGroup.young,
          operationType: OperationType.addition,
          difficulty: DifficultyLevel.easy,
          difficultyStep: 4,
          gradeLevel: 1,
        );
        final text = q.promptText ?? '';
        if (text.startsWith('Sortera minst till störst: ')) {
          found = q;
          break;
        }
      }

      expect(found, isNotNull);
      final prompt = found!.promptText!;
      expect(prompt, contains('Vilket tal kommer'));

      final listLine = prompt.split('\n').first;
      final numbersPart = listLine.split(': ').last;
      final numbers =
          numbersPart.split(', ').map(int.parse).toList(growable: false);
      expect(numbers, hasLength(4));
      expect(numbers.toSet(), hasLength(4));

      final sorted = [...numbers]..sort();
      expect(sorted.contains(found.correctAnswer), isTrue);
      expect(found.wrongAnswers, hasLength(3));
      for (final wrong in found.wrongAnswers) {
        expect(numbers.contains(wrong), isTrue);
        expect(wrong, isNot(found.correctAnswer));
      }
    });
  });
}
