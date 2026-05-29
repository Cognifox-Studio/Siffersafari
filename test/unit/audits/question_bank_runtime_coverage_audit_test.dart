import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

Map<String, dynamic> _loadQuestionBank(int grade) {
  final file = File('docs/grade_${grade}_question_bank.json');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'docs/grade_${grade}_question_bank.json must exist.',
  );

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

List<String> _sectionPrompts(Map<String, dynamic> bank, String sectionId) {
  final sections = List<Map<String, dynamic>>.from(bank['sections'] as List);
  final matches =
      sections.where((section) => section['id'] == sectionId).toList();

  expect(
    matches,
    isNotEmpty,
    reason: 'Section $sectionId must exist in grade ${bank['grade']} bank.',
  );

  final questions = List<Map<String, dynamic>>.from(
    matches.single['questions'] as List,
  );

  return questions.map((question) => question['prompt'] as String).toList();
}

bool _generatesPrompt({
  required int seed,
  required int gradeLevel,
  required OperationType operationType,
  required int difficultyStep,
  required bool Function(String prompt) matches,
  int attempts = 160,
  bool wordProblemsEnabled = false,
  bool? missingNumberEnabled,
  double? missingNumberChance,
}) {
  final service = QuestionGeneratorService(random: Random(seed));

  for (var attempt = 0; attempt < attempts; attempt++) {
    final question = service.generateQuestion(
      ageGroup: _ageGroupForGrade(gradeLevel),
      operationType: operationType,
      difficulty: DifficultyLevel.medium,
      difficultyStep: difficultyStep,
      gradeLevel: gradeLevel,
      wordProblemsEnabledOverride: wordProblemsEnabled,
      missingNumberEnabledOverride: missingNumberEnabled,
      missingNumberChanceOverride: missingNumberChance,
    );

    final prompt = question.promptText;
    if (prompt != null && matches(prompt)) {
      return true;
    }
  }

  return false;
}

AgeGroup _ageGroupForGrade(int grade) {
  if (grade <= 3) return AgeGroup.young;
  if (grade <= 6) return AgeGroup.middle;
  return AgeGroup.older;
}

void main() {
  group('[Unit] Question bank runtime coverage', () {
    test(
        'grade 1 representable compare-number families exist in bank and runtime',
        () {
      final bank = _loadQuestionBank(1);
      final prompts = _sectionPrompts(bank, 'compare_numbers');

      expect(
        prompts.any((prompt) => prompt.startsWith('Vilket tal kommer före ')),
        isTrue,
      );
      expect(
        prompts.any((prompt) => prompt.startsWith('Vilket tal kommer efter ')),
        isTrue,
      );
      expect(
        prompts.any(
          (prompt) => prompt.startsWith('Vilket tal saknas i ordningen: '),
        ),
        isTrue,
      );
      expect(
        prompts.any((prompt) => prompt.startsWith('Vilket är störst: ')),
        isTrue,
      );
      expect(
        prompts.any((prompt) => prompt.startsWith('Vilket är minst: ')),
        isTrue,
      );

      expect(
        _generatesPrompt(
          seed: 0,
          gradeLevel: 1,
          operationType: OperationType.addition,
          difficultyStep: 4,
          matches: (prompt) => prompt.startsWith('Vilket tal kommer efter '),
        ),
        isTrue,
      );
      expect(
        _generatesPrompt(
          seed: 0,
          gradeLevel: 1,
          operationType: OperationType.addition,
          difficultyStep: 4,
          matches: (prompt) =>
              prompt.startsWith('Vilket tal saknas i ordningen: '),
        ),
        isTrue,
      );
      expect(
        _generatesPrompt(
          seed: 0,
          gradeLevel: 1,
          operationType: OperationType.addition,
          difficultyStep: 4,
          matches: (prompt) => prompt.startsWith('Vilket är störst: '),
        ),
        isTrue,
      );
      expect(
        _generatesPrompt(
          seed: 0,
          gradeLevel: 1,
          operationType: OperationType.subtraction,
          difficultyStep: 4,
          matches: (prompt) => prompt.startsWith('Vilket tal kommer före '),
        ),
        isTrue,
      );
      expect(
        _generatesPrompt(
          seed: 0,
          gradeLevel: 1,
          operationType: OperationType.subtraction,
          difficultyStep: 4,
          matches: (prompt) =>
              prompt.startsWith('Vilket tal saknas i ordningen: '),
        ),
        isTrue,
      );
      expect(
        _generatesPrompt(
          seed: 0,
          gradeLevel: 1,
          operationType: OperationType.subtraction,
          difficultyStep: 4,
          matches: (prompt) => prompt.startsWith('Vilket är minst: '),
        ),
        isTrue,
      );
    });

    test('grade 2 missing-number multiplication and division stay bank-backed',
        () {
      final bank = _loadQuestionBank(2);
      final prompts = _sectionPrompts(bank, 'missing_number');

      expect(
        prompts.any(
          (prompt) => prompt.startsWith('? × ') || prompt.contains(' × ? = '),
        ),
        isTrue,
      );
      expect(
        prompts.any(
          (prompt) => prompt.startsWith('? ÷ ') || prompt.contains(' ÷ ? = '),
        ),
        isTrue,
      );

      expect(
        _generatesPrompt(
          seed: 7,
          gradeLevel: 2,
          operationType: OperationType.multiplication,
          difficultyStep: 3,
          matches: (prompt) =>
              prompt.startsWith('? × ') || prompt.contains(' × ? = '),
          missingNumberEnabled: true,
          missingNumberChance: 1.0,
        ),
        isTrue,
      );
      expect(
        _generatesPrompt(
          seed: 11,
          gradeLevel: 2,
          operationType: OperationType.division,
          difficultyStep: 3,
          matches: (prompt) =>
              prompt.startsWith('? ÷ ') || prompt.contains(' ÷ ? = '),
          missingNumberEnabled: true,
          missingNumberChance: 1.0,
        ),
        isTrue,
      );
    });
  });
}
