import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

const _runtimeSectionStatuses = <int, Map<String, String>>{
  1: {
    'addition': 'supported_core_arithmetic',
    'subtraction': 'supported_core_arithmetic',
    'number_bonds_to_10': 'supported_core_arithmetic',
    'compare_numbers': 'supported_prompt_family',
    'word_problems': 'supported_prompt_family_with_exceptions',
  },
  2: {
    'addition_with_tens_transition': 'supported_core_arithmetic',
    'subtraction': 'supported_core_arithmetic',
    'multiplication': 'supported_core_arithmetic',
    'division': 'supported_core_arithmetic',
    'missing_number': 'supported_prompt_family',
  },
  3: {
    'addition': 'supported_core_arithmetic',
    'subtraction': 'supported_core_arithmetic',
    'multiplication': 'supported_core_arithmetic',
    'division': 'supported_core_arithmetic',
  },
  4: {
    'addition_large_numbers': 'supported_core_arithmetic',
    'subtraction_large_numbers': 'supported_core_arithmetic',
    'multiplication': 'supported_core_arithmetic',
    'division': 'supported_core_arithmetic',
    'statistics': 'supported_prompt_family_with_exceptions',
  },
  5: {
    'addition_av_stora_tal': 'supported_core_arithmetic',
    'subtraktion_av_stora_tal': 'supported_core_arithmetic',
    'multiplication': 'supported_core_arithmetic',
    'division': 'supported_core_arithmetic',
    'negative_numbers': 'supported_prompt_family',
    'mean': 'supported_prompt_family',
  },
  6: {
    'percentage_change': 'deferred_answer_policy',
    'negative_numbers': 'supported_prompt_family',
    'diagram_interpretation': 'deferred_representation',
    'multiplication': 'supported_core_arithmetic',
    'division': 'supported_core_arithmetic',
    'multi_step_word_problems': 'deferred_answer_policy',
  },
  7: {
    'order_of_operations': 'supported_prompt_family',
    'equations': 'supported_prompt_family',
    'simplify_expressions': 'deferred_symbolic_output',
    'percentage': 'supported_prompt_family',
  },
  8: {
    'powers': 'supported_prompt_family',
    'proportionality': 'supported_prompt_family_with_exceptions',
    'linear_relationships': 'deferred_representation',
    'compound_percent_change': 'deferred_answer_policy',
  },
  9: {
    'functions': 'deferred_representation',
    'equations': 'supported_prompt_family',
    'geometry': 'supported_prompt_family_with_exceptions',
    'probability': 'deferred_representation',
  },
};

Map<String, dynamic> _loadQuestionBank(int grade) {
  final file = File('docs/grade_${grade}_question_bank.json');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'docs/grade_${grade}_question_bank.json must exist.',
  );

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _sections(Map<String, dynamic> bank) {
  return List<Map<String, dynamic>>.from(bank['sections'] as List);
}

Map<String, dynamic> _section(Map<String, dynamic> bank, String sectionId) {
  return _sections(bank).singleWhere((section) => section['id'] == sectionId);
}

Set<String> _sectionIds(Map<String, dynamic> bank) {
  return _sections(bank).map((section) => section['id'] as String).toSet();
}

List<Map<String, dynamic>> _questions(Map<String, dynamic> section) {
  return List<Map<String, dynamic>>.from(section['questions'] as List);
}

bool _sectionListedAsSupportingContext(
  Map<String, dynamic> bank,
  String sectionId,
) {
  final coverage = Map<String, dynamic>.from(bank['coverage'] as Map);
  final requiring = List<Map<String, dynamic>>.from(
    coverage['requiresSupportingContext'] as List? ?? const [],
  );

  return requiring.any((entry) => entry['sectionId'] == sectionId);
}

bool _hasSupportingContextSignals(Map<String, dynamic> section) {
  return _questions(section).any(
    (question) =>
        question['requiresSupportingContext'] == true ||
        question['requiresCompletedPrompt'] == true,
  );
}

bool _hasAnswerPolicySignals(Map<String, dynamic> section) {
  final defaultResponseType = section['defaultResponseType'] as String;
  return defaultResponseType.contains('text') ||
      _questions(section)
          .any((question) => question['answerPolicyNote'] != null);
}

bool _needsSymbolicOutput(Map<String, dynamic> section) {
  final defaultResponseType = section['defaultResponseType'] as String;
  return defaultResponseType.contains('text') &&
      _questions(section).any((question) => question['correctAnswer'] == null);
}

AgeGroup _ageGroupForGrade(int grade) {
  if (grade <= 3) return AgeGroup.young;
  if (grade <= 6) return AgeGroup.middle;
  return AgeGroup.older;
}

bool _generatesQuestion({
  required int seed,
  required int gradeLevel,
  required OperationType operationType,
  required int difficultyStep,
  required bool Function(Question question) matches,
  int attempts = 240,
  bool wordProblemsEnabled = false,
  bool missingNumberEnabled = false,
  double? missingNumberChance,
}) {
  final service = QuestionGeneratorService(
    random: Random(seed),
    wordProblemsEnabled: wordProblemsEnabled,
    missingNumberEnabled: missingNumberEnabled,
  );

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

    if (matches(question)) {
      return true;
    }
  }

  return false;
}

void _assertArithmeticRuntime({
  required int gradeLevel,
  required OperationType operationType,
  required int difficultyStep,
  required bool Function(Question question) predicate,
}) {
  expect(
    _generatesQuestion(
      seed: 0,
      gradeLevel: gradeLevel,
      operationType: operationType,
      difficultyStep: difficultyStep,
      wordProblemsEnabled: false,
      missingNumberEnabled: false,
      matches: (question) {
        if (question.promptText != null) {
          return false;
        }

        final computedAnswer = switch (operationType) {
          OperationType.addition => question.operand1 + question.operand2,
          OperationType.subtraction => question.operand1 - question.operand2,
          OperationType.multiplication => question.operand1 * question.operand2,
          OperationType.division => question.operand2 == 0
              ? null
              : question.operand1 ~/ question.operand2,
          OperationType.mixed => null,
        };

        if (computedAnswer == null ||
            question.correctAnswer != computedAnswer) {
          return false;
        }

        return predicate(question);
      },
    ),
    isTrue,
    reason:
        'Expected runtime arithmetic coverage for Åk $gradeLevel ${operationType.name} at step $difficultyStep.',
  );
}

void _assertPromptRuntime({
  required int gradeLevel,
  required OperationType operationType,
  required int difficultyStep,
  required bool Function(String prompt) matches,
  int attempts = 320,
  bool wordProblemsEnabled = false,
  bool missingNumberEnabled = false,
  double? missingNumberChance,
}) {
  expect(
    _generatesQuestion(
      seed: 0,
      gradeLevel: gradeLevel,
      operationType: operationType,
      difficultyStep: difficultyStep,
      attempts: attempts,
      wordProblemsEnabled: wordProblemsEnabled,
      missingNumberEnabled: missingNumberEnabled,
      missingNumberChance: missingNumberChance,
      matches: (question) {
        final prompt = question.promptText;
        return prompt != null && matches(prompt);
      },
    ),
    isTrue,
    reason:
        'Expected runtime prompt-family coverage for Åk $gradeLevel ${operationType.name}.',
  );
}

void _assertSupportedSectionRuntime(int grade, String sectionId) {
  switch ('$grade:$sectionId') {
    case '1:addition':
      _assertArithmeticRuntime(
        gradeLevel: 1,
        operationType: OperationType.addition,
        difficultyStep: 6,
        predicate: (question) => question.correctAnswer <= 20,
      );
    case '1:subtraction':
      _assertArithmeticRuntime(
        gradeLevel: 1,
        operationType: OperationType.subtraction,
        difficultyStep: 6,
        predicate: (question) => question.correctAnswer >= 0,
      );
    case '1:number_bonds_to_10':
      _assertArithmeticRuntime(
        gradeLevel: 1,
        operationType: OperationType.addition,
        difficultyStep: 2,
        predicate: (question) => question.correctAnswer == 10,
      );
    case '1:compare_numbers':
      _assertPromptRuntime(
        gradeLevel: 1,
        operationType: OperationType.addition,
        difficultyStep: 4,
        matches: (prompt) =>
            prompt.startsWith('Vilket tal kommer ') ||
            prompt.startsWith('Vilket är störst: ') ||
            prompt.startsWith('Vilket tal saknas i ordningen: '),
      );
    case '1:word_problems':
      _assertPromptRuntime(
        gradeLevel: 1,
        operationType: OperationType.addition,
        difficultyStep: 4,
        wordProblemsEnabled: true,
        matches: (prompt) =>
            prompt.contains('Hur många') ||
            prompt.contains('Hur många är kvar'),
      );
    case '2:addition_with_tens_transition':
      _assertArithmeticRuntime(
        gradeLevel: 2,
        operationType: OperationType.addition,
        difficultyStep: 6,
        predicate: (question) =>
            (question.operand1 % 10) + (question.operand2 % 10) >= 10,
      );
    case '2:subtraction':
      _assertArithmeticRuntime(
        gradeLevel: 2,
        operationType: OperationType.subtraction,
        difficultyStep: 6,
        predicate: (question) => question.correctAnswer >= 0,
      );
    case '2:multiplication':
      _assertArithmeticRuntime(
        gradeLevel: 2,
        operationType: OperationType.multiplication,
        difficultyStep: 8,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '2:division':
      _assertArithmeticRuntime(
        gradeLevel: 2,
        operationType: OperationType.division,
        difficultyStep: 8,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '2:missing_number':
      _assertPromptRuntime(
        gradeLevel: 2,
        operationType: OperationType.multiplication,
        difficultyStep: 3,
        missingNumberEnabled: true,
        missingNumberChance: 1.0,
        matches: (prompt) =>
            prompt.startsWith('? × ') || prompt.contains(' × ? = '),
      );
      _assertPromptRuntime(
        gradeLevel: 2,
        operationType: OperationType.division,
        difficultyStep: 3,
        missingNumberEnabled: true,
        missingNumberChance: 1.0,
        matches: (prompt) =>
            prompt.startsWith('? ÷ ') || prompt.contains(' ÷ ? = '),
      );
    case '3:addition':
      _assertArithmeticRuntime(
        gradeLevel: 3,
        operationType: OperationType.addition,
        difficultyStep: 8,
        predicate: (question) => question.correctAnswer <= 1000,
      );
    case '3:subtraction':
      _assertArithmeticRuntime(
        gradeLevel: 3,
        operationType: OperationType.subtraction,
        difficultyStep: 8,
        predicate: (question) => question.correctAnswer >= 0,
      );
    case '3:multiplication':
      _assertArithmeticRuntime(
        gradeLevel: 3,
        operationType: OperationType.multiplication,
        difficultyStep: 8,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '3:division':
      _assertArithmeticRuntime(
        gradeLevel: 3,
        operationType: OperationType.division,
        difficultyStep: 8,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '4:addition_large_numbers':
      _assertArithmeticRuntime(
        gradeLevel: 4,
        operationType: OperationType.addition,
        difficultyStep: 10,
        predicate: (question) =>
            max(question.operand1.abs(), question.operand2.abs()) >= 1000,
      );
    case '4:subtraction_large_numbers':
      _assertArithmeticRuntime(
        gradeLevel: 4,
        operationType: OperationType.subtraction,
        difficultyStep: 10,
        predicate: (question) =>
            max(question.operand1.abs(), question.operand2.abs()) >= 1000,
      );
    case '4:multiplication':
      _assertArithmeticRuntime(
        gradeLevel: 4,
        operationType: OperationType.multiplication,
        difficultyStep: 10,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '4:division':
      _assertArithmeticRuntime(
        gradeLevel: 4,
        operationType: OperationType.division,
        difficultyStep: 10,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '4:statistics':
      _assertPromptRuntime(
        gradeLevel: 4,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) =>
            prompt.startsWith('Typvärde') ||
            prompt.startsWith('Median') ||
            prompt.startsWith('Medelvärde') ||
            prompt.startsWith('Variationsbredd') ||
            prompt.startsWith('Tabell (statistik)') ||
            prompt.startsWith('Diagram (stapel)'),
      );
    case '5:addition_av_stora_tal':
      _assertArithmeticRuntime(
        gradeLevel: 5,
        operationType: OperationType.addition,
        difficultyStep: 10,
        predicate: (question) =>
            max(question.operand1.abs(), question.operand2.abs()) >= 10000,
      );
    case '5:subtraktion_av_stora_tal':
      _assertArithmeticRuntime(
        gradeLevel: 5,
        operationType: OperationType.subtraction,
        difficultyStep: 10,
        predicate: (question) =>
            max(question.operand1.abs(), question.operand2.abs()) >= 10000,
      );
    case '5:multiplication':
      _assertArithmeticRuntime(
        gradeLevel: 5,
        operationType: OperationType.multiplication,
        difficultyStep: 10,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '5:division':
      _assertArithmeticRuntime(
        gradeLevel: 5,
        operationType: OperationType.division,
        difficultyStep: 10,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '5:negative_numbers':
      _assertPromptRuntime(
        gradeLevel: 5,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Negativa tal = ?'),
      );
    case '5:mean':
      _assertPromptRuntime(
        gradeLevel: 5,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) => prompt.startsWith('Medelvärde'),
      );
    case '6:negative_numbers':
      _assertPromptRuntime(
        gradeLevel: 6,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Negativa tal = ?'),
      );
    case '6:multiplication':
      _assertArithmeticRuntime(
        gradeLevel: 6,
        operationType: OperationType.multiplication,
        difficultyStep: 10,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '6:division':
      _assertArithmeticRuntime(
        gradeLevel: 6,
        operationType: OperationType.division,
        difficultyStep: 10,
        predicate: (question) => question.correctAnswer > 0,
      );
    case '7:order_of_operations':
      _assertPromptRuntime(
        gradeLevel: 7,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) => prompt.startsWith('Prioriteringsregler = ?'),
      );
    case '7:equations':
      _assertPromptRuntime(
        gradeLevel: 7,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) => prompt.startsWith('Ekvation = ?'),
      );
    case '7:percentage':
      _assertPromptRuntime(
        gradeLevel: 7,
        operationType: OperationType.mixed,
        difficultyStep: 5,
        matches: (prompt) => prompt.startsWith('Procent = ?'),
      );
    case '8:powers':
      _assertPromptRuntime(
        gradeLevel: 8,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) => prompt.startsWith('Potenser = ?'),
      );
    case '8:proportionality':
      _assertPromptRuntime(
        gradeLevel: 8,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Proportionalitet = ?'),
      );
    case '9:equations':
      _assertPromptRuntime(
        gradeLevel: 9,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Ekvation = ?'),
      );
    case '9:geometry':
      _assertPromptRuntime(
        gradeLevel: 9,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Geometri = ?'),
      );
    default:
      fail('Missing runtime proof for Åk $grade section $sectionId.');
  }
}

void main() {
  group('[Unit] Question bank runtime status', () {
    test('every grade-bank section has an explicit runtime status', () {
      for (var grade = 1; grade <= 9; grade++) {
        final bank = _loadQuestionBank(grade);
        final expected = _runtimeSectionStatuses[grade];

        expect(expected, isNotNull, reason: 'Grade $grade needs a status map.');
        expect(
          expected!.keys.toSet(),
          equals(_sectionIds(bank)),
          reason: 'Grade $grade section ids must match the runtime status map.',
        );
      }
    });

    test(
        'deferred sections are justified by bank metadata or answer-model gaps',
        () {
      for (var grade = 1; grade <= 9; grade++) {
        final bank = _loadQuestionBank(grade);
        final statuses = _runtimeSectionStatuses[grade]!;

        for (final entry in statuses.entries) {
          final sectionId = entry.key;
          final status = entry.value;
          if (!status.startsWith('deferred_')) {
            continue;
          }

          final section = _section(bank, sectionId);

          switch (status) {
            case 'deferred_answer_policy':
              expect(
                _hasAnswerPolicySignals(section),
                isTrue,
                reason:
                    'Deferred answer-policy section $sectionId in grade $grade must have explicit policy ambiguity.',
              );
            case 'deferred_symbolic_output':
              expect(
                _needsSymbolicOutput(section),
                isTrue,
                reason:
                    'Deferred symbolic section $sectionId in grade $grade must require more than a plain integer answer.',
              );
            case 'deferred_representation':
              expect(
                _sectionListedAsSupportingContext(bank, sectionId) ||
                    _hasSupportingContextSignals(section) ||
                    (section['defaultResponseType'] as String) == 'mixed',
                isTrue,
                reason:
                    'Deferred representation section $sectionId in grade $grade must show representation/context needs.',
              );
            default:
              fail('Unknown deferred status $status.');
          }
        }
      }
    });

    test('supported sections keep minimum runtime proof obligations', () {
      for (var grade = 1; grade <= 9; grade++) {
        final statuses = _runtimeSectionStatuses[grade]!;

        for (final entry in statuses.entries) {
          if (!entry.value.startsWith('supported_')) {
            continue;
          }

          _assertSupportedSectionRuntime(grade, entry.key);
        }
      }
    });
  });
}
