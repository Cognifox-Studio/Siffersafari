import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  group('[Unit] Question step profile audit', () {
    test('rapporterar grade-mappad frågemix per räknesätt och step', () {
      const sampleCount = 40;
      final generator = QuestionGeneratorService(random: Random(17));

      for (final grade in List<int>.generate(9, (index) => index + 1)) {
        final ageGroup = DifficultyConfig.effectiveAgeGroup(
          fallback: _fallbackAgeGroupForGrade(grade),
          gradeLevel: grade,
        );
        final difficulty = DifficultyConfig.effectiveDifficulty(
          fallback: DifficultyLevel.medium,
          gradeLevel: grade,
        );
        final buffer = StringBuffer(
          'Question profile Åk $grade (${difficulty.name})',
        );

        for (final operation
            in DifficultyConfig.visibleOperationsForGrade(grade)) {
          var previousRangeMax = -1;

          for (var step = 1;
              step <= DifficultyConfig.maxDifficultyStep;
              step++) {
            final expectedRange = DifficultyConfig.curriculumNumberRangeForStep(
              gradeLevel: grade,
              operationType: operation,
              difficultyStep: step,
            );
            expect(
              expectedRange.max,
              greaterThanOrEqualTo(previousRangeMax),
              reason:
                  'Range-max ska vara monotont ökande för Åk $grade ${operation.name}',
            );
            previousRangeMax = expectedRange.max;

            final summary = _collectSummary(
              generator: generator,
              ageGroup: ageGroup,
              operation: operation,
              difficulty: difficulty,
              gradeLevel: grade,
              difficultyStep: step,
              sampleCount: sampleCount,
            );

            expect(
              summary.unknownCount,
              0,
              reason:
                  'Okända prompttyper genererades för Åk $grade ${operation.name} step $step',
            );

            buffer.writeln(summary.summaryLine());
          }
        }

        // ignore: avoid_print
        print(buffer.toString());
      }
    });

    test('rapporterar Mix-specialer per årskurs, difficulty-label och step',
        () {
      const sampleCount = 60;

      for (final grade in List<int>.generate(9, (index) => index + 1)) {
        final ageGroup = DifficultyConfig.effectiveAgeGroup(
          fallback: _fallbackAgeGroupForGrade(grade),
          gradeLevel: grade,
        );

        for (final difficulty in DifficultyLevel.values) {
          final generator = QuestionGeneratorService(
            random: Random(1000 + grade * 100 + difficulty.index),
          );
          final buffer = StringBuffer(
            'Mix profile Åk $grade (${difficulty.name})',
          );

          for (var step = 1;
              step <= DifficultyConfig.maxDifficultyStep;
              step++) {
            final summary = _collectSummary(
              generator: generator,
              ageGroup: ageGroup,
              operation: OperationType.mixed,
              difficulty: difficulty,
              gradeLevel: grade,
              difficultyStep: step,
              sampleCount: sampleCount,
            );

            expect(
              summary.unknownCount,
              0,
              reason:
                  'Okända Mix-prompttyper genererades för Åk $grade ${difficulty.name} step $step',
            );

            buffer.writeln(summary.summaryLine());
          }

          // ignore: avoid_print
          print(buffer.toString());
        }
      }
    });
  });
}

class _AuditSummary {
  _AuditSummary({
    required this.gradeLevel,
    required this.operation,
    required this.difficulty,
    required this.difficultyStep,
    required this.minOperand,
    required this.maxOperand,
    required this.categoryCounts,
    required this.categorySamples,
    required this.unknownCount,
    required this.total,
  });

  final int gradeLevel;
  final OperationType operation;
  final DifficultyLevel difficulty;
  final int difficultyStep;
  final int minOperand;
  final int maxOperand;
  final Map<String, int> categoryCounts;
  final Map<String, String> categorySamples;
  final int unknownCount;
  final int total;

  String summaryLine() {
    final categories = categoryCounts.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return a.key.compareTo(b.key);
      });

    final categoryLabel = categories
        .map(
          (entry) =>
              '${entry.key}=${((entry.value / total) * 100).toStringAsFixed(0)}%',
        )
        .join(', ');

    final sampleCategory = categories.isEmpty ? null : categories.first.key;
    final sampleText = sampleCategory == null
        ? ''
        : ' | ex: ${categorySamples[sampleCategory] ?? ''}';

    return '  ${operation.name.padRight(14)} step ${difficultyStep.toString().padLeft(2)} '
        'range=$minOperand-$maxOperand '
        '[$categoryLabel]$sampleText';
  }
}

_AuditSummary _collectSummary({
  required QuestionGeneratorService generator,
  required AgeGroup ageGroup,
  required OperationType operation,
  required DifficultyLevel difficulty,
  required int gradeLevel,
  required int difficultyStep,
  required int sampleCount,
}) {
  final categoryCounts = <String, int>{};
  final categorySamples = <String, String>{};
  final operandSizes = <int>[];
  var unknownCount = 0;

  for (var index = 0; index < sampleCount; index++) {
    final question = generator.generateQuestion(
      ageGroup: ageGroup,
      operationType: operation,
      difficulty: difficulty,
      difficultyStep: difficultyStep,
      gradeLevel: gradeLevel,
    );
    final category = _classifyQuestion(question);
    if (category == 'other_prompt') {
      unknownCount++;
    }

    categoryCounts.update(category, (count) => count + 1, ifAbsent: () => 1);
    categorySamples.putIfAbsent(category, () => _sampleText(question));
    operandSizes.add(max(question.operand1.abs(), question.operand2.abs()));
  }

  operandSizes.sort();

  return _AuditSummary(
    gradeLevel: gradeLevel,
    operation: operation,
    difficulty: difficulty,
    difficultyStep: difficultyStep,
    minOperand: operandSizes.first,
    maxOperand: operandSizes.last,
    categoryCounts: categoryCounts,
    categorySamples: categorySamples,
    unknownCount: unknownCount,
    total: sampleCount,
  );
}

String _classifyQuestion(Question question) {
  final prompt = question.promptText;
  if (prompt == null) return 'standard';

  if (prompt.startsWith('Klockan visar') || prompt.startsWith('Klockan var')) {
    return 'time';
  }
  if (prompt.startsWith('Typvärde') ||
      prompt.startsWith('Median') ||
      prompt.startsWith('Medelvärde') ||
      prompt.startsWith('Variationsbredd') ||
      prompt.startsWith('Tabell (statistik)') ||
      prompt.startsWith('Diagram (stapel)') ||
      prompt.startsWith('Sannolikhet (diagram)') ||
      prompt.startsWith('Enhetskonvertering') ||
      prompt.startsWith('Area') ||
      prompt.startsWith('Omkrets')) {
    return 'm4_stats';
  }
  if (prompt.startsWith('Chans (%)')) return 'm4_prob_percent';
  if (prompt.startsWith('Sannolikhet (konkret)')) return 'low_probability';
  if (prompt.startsWith('Skillnad i chans')) return 'm4_prob_compare';
  if (prompt.startsWith('Kombinationer')) return 'm4_combinatorics';
  if (prompt.startsWith('Procent = ?')) return 'm_percent';
  if (prompt.startsWith('Negativa tal = ?')) return 'm_negative';
  if (prompt.startsWith('Potenser = ?')) return 'm_power';
  if (prompt.startsWith('Proportionalitet = ?')) return 'm_proportionality';
  if (prompt.startsWith('Ekvation = ?')) return 'm_equation';
  if (prompt.startsWith('Prioriteringsregler = ?')) return 'm_precedence';
  if (prompt.startsWith('Linjär funktion = ?')) return 'm_linear';
  if (prompt.startsWith('Geometrisk transformation = ?') ||
      prompt.startsWith('Geometri = ?')) {
    return 'm_geometric';
  }
  if (prompt.startsWith('Statistik = ?')) return 'm_advanced_stats';

  final isMissingNumber = prompt.startsWith('? +') ||
      prompt.contains('+ ? =') ||
      prompt.startsWith('? -') ||
      prompt.contains('- ? =') ||
      prompt.startsWith('? ×') ||
      prompt.contains('× ? =') ||
      prompt.startsWith('? ÷') ||
      prompt.contains('÷ ? =');
  if (isMissingNumber) return 'missing_number';

  final isNumberSense = prompt.startsWith('Vilket tal kommer före ') ||
      prompt.startsWith('Vilket tal kommer efter ') ||
      prompt.startsWith('Vilket tal saknas i ordningen: ') ||
      prompt.startsWith('Vilket är störst: ') ||
      prompt.startsWith('Vilket är minst: ');
  if (isNumberSense) return 'number_sense';

  if (question.operationType == OperationType.addition ||
      question.operationType == OperationType.subtraction ||
      question.operationType == OperationType.multiplication ||
      question.operationType == OperationType.division) {
    return 'word_problem';
  }

  return 'other_prompt';
}

String _sampleText(Question question) {
  final source = question.promptText ?? question.displayQuestionText;
  final firstLine = source.split('\n').first.trim();
  return firstLine.length <= 56
      ? firstLine
      : '${firstLine.substring(0, 53)}...';
}

AgeGroup _fallbackAgeGroupForGrade(int grade) {
  if (grade <= 3) return AgeGroup.young;
  if (grade <= 6) return AgeGroup.middle;
  return AgeGroup.older;
}
