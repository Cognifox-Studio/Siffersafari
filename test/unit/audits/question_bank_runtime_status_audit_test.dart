import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// Explicit ship/don't-ship contract for `supported_prompt_family_with_exceptions`.
/// Keeps `with_exceptions` actionable: every bank row must classify as
/// supported family or named deferred exception.
class _ExceptionMatrix {
  const _ExceptionMatrix({
    required this.supportedRuntimeFamilies,
    required this.deferredBankIds,
    required this.deferredReasonById,
    required this.forbiddenRuntimeMarkers,
  });

  final List<String> supportedRuntimeFamilies;
  final Set<String> deferredBankIds;
  final Map<String, String> deferredReasonById;
  final List<String> forbiddenRuntimeMarkers;
}

const _exceptionMatrices = <String, _ExceptionMatrix>{
  '4:statistics': _ExceptionMatrix(
    supportedRuntimeFamilies: [
      'Typvärde',
      'Median',
      'Medelvärde',
      'Variationsbredd',
      'Tabell (statistik)',
      'Diagram (stapel)',
    ],
    deferredBankIds: {
      'g4_statistics_001',
      'g4_statistics_002',
      'g4_statistics_003',
      'g4_statistics_004',
      'g4_statistics_005',
      'g4_statistics_010',
    },
    deferredReasonById: {
      'g4_statistics_001': 'external_diagram_context',
      'g4_statistics_002': 'external_diagram_context',
      'g4_statistics_003': 'external_diagram_context',
      'g4_statistics_004': 'day_delta_without_embedded_table',
      'g4_statistics_005': 'day_delta_without_embedded_table',
      'g4_statistics_010': 'day_delta_without_embedded_table',
    },
    forbiddenRuntimeMarkers: [],
  ),
  '8:proportionality': _ExceptionMatrix(
    supportedRuntimeFamilies: ['Proportionalitet = ?'],
    deferredBankIds: {
      'g8_proportionality_003',
      'g8_proportionality_005',
      'g8_proportionality_008',
      'g8_proportionality_009',
      'g8_proportionality_010',
      'g8_proportionality_011',
      'g8_proportionality_012',
      'g8_proportionality_013',
      'g8_proportionality_014',
      'g8_proportionality_015',
      'g8_proportionality_018',
      'g8_proportionality_019',
      'g8_proportionality_026',
      'g8_proportionality_028',
      'g8_proportionality_030',
      'g8_proportionality_033',
      'g8_proportionality_034',
      'g8_proportionality_037',
      'g8_proportionality_038',
      'g8_proportionality_039',
      'g8_proportionality_040',
    },
    deferredReasonById: {
      'g8_proportionality_003': 'decimal_coefficient',
      'g8_proportionality_005': 'decimal_coefficient',
      'g8_proportionality_008': 'table_context',
      'g8_proportionality_009': 'graph_context',
      'g8_proportionality_010': 'incomplete_word_prompt',
      'g8_proportionality_011': 'incomplete_word_prompt',
      'g8_proportionality_012': 'incomplete_word_prompt',
      'g8_proportionality_013': 'incomplete_word_prompt',
      'g8_proportionality_014': 'incomplete_word_prompt',
      'g8_proportionality_015': 'incomplete_word_prompt',
      'g8_proportionality_018': 'decimal_coefficient',
      'g8_proportionality_019': 'decimal_coefficient',
      'g8_proportionality_026': 'decimal_quantity',
      'g8_proportionality_028': 'decimal_quantity',
      'g8_proportionality_030': 'decimal_quantity',
      'g8_proportionality_033': 'decimal_coefficient',
      'g8_proportionality_034': 'decimal_coefficient',
      'g8_proportionality_037': 'decimal_coefficient',
      'g8_proportionality_038': 'decimal_coefficient',
      'g8_proportionality_039': 'decimal_coefficient',
      'g8_proportionality_040': 'decimal_coefficient',
    },
    forbiddenRuntimeMarkers: [
      '0.',
      'Graf →',
      'Tabell →',
      'är det proportionellt',
    ],
  ),
  '9:geometry': _ExceptionMatrix(
    supportedRuntimeFamilies: ['Geometri = ?'],
    deferredBankIds: {
      'g9_geometry_009',
      'g9_geometry_010',
      'g9_geometry_015',
      'g9_geometry_016',
      'g9_geometry_017',
      'g9_geometry_018',
      'g9_geometry_020',
      'g9_geometry_024',
      'g9_geometry_025',
      'g9_geometry_026',
    },
    deferredReasonById: {
      'g9_geometry_009': 'pi_circle_area',
      'g9_geometry_010': 'pi_circle_circumference',
      'g9_geometry_015': 'pi_cylinder_volume',
      'g9_geometry_016': 'scale_context',
      'g9_geometry_017': 'scale_context',
      'g9_geometry_018': 'scale_context',
      'g9_geometry_020': 'incomplete_trapezoid_formula',
      'g9_geometry_024': 'pi_circle_area',
      'g9_geometry_025': 'pi_circle_circumference',
      'g9_geometry_026': 'pi_cylinder_volume',
    },
    forbiddenRuntimeMarkers: [
      'cirkel',
      'cylinder',
      'Skala',
      'π',
      'trapets',
    ],
  ),
};

const _runtimeSectionStatuses = <int, Map<String, String>>{
  1: {
    'addition': 'supported_core_arithmetic',
    'subtraction': 'supported_core_arithmetic',
    'number_bonds_to_10': 'supported_core_arithmetic',
    'compare_numbers': 'supported_prompt_family',
    'word_problems': 'supported_prompt_family',
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
    'percentage_change': 'supported_prompt_family',
    'negative_numbers': 'supported_prompt_family',
    'diagram_interpretation': 'supported_prompt_family',
    'multiplication': 'supported_core_arithmetic',
    'division': 'supported_core_arithmetic',
    'multi_step_word_problems': 'supported_prompt_family',
  },
  7: {
    'order_of_operations': 'supported_prompt_family',
    'equations': 'supported_prompt_family',
    'simplify_expressions': 'supported_prompt_family',
    'percentage': 'supported_prompt_family',
  },
  8: {
    'powers': 'supported_prompt_family',
    'proportionality': 'supported_prompt_family_with_exceptions',
    'linear_relationships': 'supported_prompt_family',
    'compound_percent_change': 'supported_prompt_family',
  },
  9: {
    'functions': 'supported_prompt_family',
    'equations': 'supported_prompt_family',
    'geometry': 'supported_prompt_family_with_exceptions',
    'probability': 'supported_prompt_family',
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
            prompt.startsWith('Vilket tal saknas i ordningen: ') ||
            prompt.startsWith('Sortera minst till störst: '),
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
    case '6:diagram_interpretation':
      _assertPromptRuntime(
        gradeLevel: 6,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) => prompt.startsWith('Diagram (stapel) = ?'),
      );
    case '6:percentage_change':
      _assertPromptRuntime(
        gradeLevel: 6,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Procentuell förändring = ?'),
      );
    case '6:multi_step_word_problems':
      _assertPromptRuntime(
        gradeLevel: 6,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Flerstegsproblem = ?'),
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
    case '7:simplify_expressions':
      _assertPromptRuntime(
        gradeLevel: 7,
        operationType: OperationType.mixed,
        difficultyStep: 7,
        matches: (prompt) => prompt.startsWith('Förenkla = ?'),
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
    case '8:compound_percent_change':
      _assertPromptRuntime(
        gradeLevel: 8,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Sammansatt procent = ?'),
      );
    case '8:linear_relationships':
      _assertPromptRuntime(
        gradeLevel: 8,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Linjär funktion = ?'),
      );
    case '9:functions':
      _assertPromptRuntime(
        gradeLevel: 9,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Linjär funktion = ?'),
      );
    case '9:probability':
      _assertPromptRuntime(
        gradeLevel: 9,
        operationType: OperationType.mixed,
        difficultyStep: 8,
        matches: (prompt) => prompt.startsWith('Sannolikhet = ?'),
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

    test(
      'with_exceptions sections publish an actionable ship/dont-ship matrix',
      () {
        for (var grade = 1; grade <= 9; grade++) {
          final bank = _loadQuestionBank(grade);
          final statuses = _runtimeSectionStatuses[grade]!;

          for (final entry in statuses.entries) {
            if (entry.value != 'supported_prompt_family_with_exceptions') {
              continue;
            }

            final key = '$grade:${entry.key}';
            final matrix = _exceptionMatrices[key];
            expect(
              matrix,
              isNotNull,
              reason: 'Missing exception matrix for $key (#52–54).',
            );

            final section = _section(bank, entry.key);
            final bankIds =
                _questions(section).map((q) => q['id'] as String).toSet();

            expect(
              matrix!.deferredBankIds.difference(bankIds),
              isEmpty,
              reason: '$key deferred ids must exist in the bank.',
            );
            expect(
              matrix.deferredReasonById.keys.toSet(),
              equals(matrix.deferredBankIds),
              reason: '$key every deferred id needs an explicit reason.',
            );

            final uncovered = bankIds.difference(matrix.deferredBankIds);
            expect(
              uncovered,
              isNotEmpty,
              reason: '$key must keep at least one shippable bank row.',
            );

            // Runtime family proof already covered by supported-section audit;
            // here we lock that generated prompts never leak deferred markers.
            if (matrix.forbiddenRuntimeMarkers.isEmpty) {
              continue;
            }

            final service = QuestionGeneratorService(
              random: Random(42),
              wordProblemsEnabled: false,
              missingNumberEnabled: false,
            );
            for (var attempt = 0; attempt < 240; attempt++) {
              final question = service.generateQuestion(
                ageGroup: _ageGroupForGrade(grade),
                operationType: OperationType.mixed,
                difficulty: DifficultyLevel.medium,
                difficultyStep: grade >= 9 ? 8 : 8,
                gradeLevel: grade,
                wordProblemsEnabledOverride: false,
                missingNumberEnabledOverride: false,
              );
              final prompt = question.promptText;
              if (prompt == null) {
                continue;
              }
              final isFamily = matrix.supportedRuntimeFamilies
                  .any((family) => prompt.startsWith(family) || prompt.contains(family));
              if (!isFamily) {
                continue;
              }
              for (final marker in matrix.forbiddenRuntimeMarkers) {
                expect(
                  prompt.toLowerCase().contains(marker.toLowerCase()),
                  isFalse,
                  reason:
                      '$key runtime prompt must not contain deferred marker "$marker": $prompt',
                );
              }
            }
          }
        }
      },
    );
  });
}
