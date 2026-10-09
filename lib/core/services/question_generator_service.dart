import 'dart:math';

import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:uuid/uuid.dart';

import '../config/app_features.dart';
import '../config/difficulty_config.dart';
import 'question_generation/question_generation_context.dart';
import 'question_generation/question_request.dart';

part 'question_generator_service__helpers_part.dart';
part 'question_generator_service__impl_part.dart';
part 'question_generator_service__pipeline_part.dart';

/// Generates randomized math questions for quiz sessions.
///
/// Supports:
/// - Multiple operations (addition, subtraction, multiplication, division)
/// - Difficulty-based number ranges
/// - Word problems (customizable chance)
/// - Missing number formats (fill-in-the-blank)
/// - Age/grade-appropriate variations
///
/// Uses [Random] for reproducible testing (inject custom instance) and
/// [Uuid] for unique question IDs.
class QuestionGeneratorService
    with
        _QuestionGeneratorServiceHelpers,
        _QuestionGeneratorServiceImpl,
        _QuestionGeneratorServicePipeline {
  QuestionGeneratorService({
    Random? random,
    Uuid? uuid,
    bool? wordProblemsEnabled,
    double? wordProblemsChance,
    bool? missingNumberEnabled,
    double? missingNumberChance,
  })  : _random = random ?? Random(),
        _uuid = uuid ?? const Uuid(),
        _wordProblemsEnabled =
            wordProblemsEnabled ?? AppFeatures.wordProblemsEnabled,
        _wordProblemsChance =
            wordProblemsChance ?? AppFeatures.wordProblemsChance,
        _missingNumberEnabled =
            missingNumberEnabled ?? AppFeatures.missingNumberEnabled,
        _missingNumberChance =
            missingNumberChance ?? AppFeatures.missingNumberChance;

  @override
  final Random _random;
  @override
  final Uuid _uuid;

  final bool _wordProblemsEnabled;
  final double _wordProblemsChance;

  final bool _missingNumberEnabled;
  final double _missingNumberChance;

  // region Main Generation Methods

  /// Generate a single question
  Question generateQuestion({
    required AgeGroup ageGroup,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    Map<OperationType, int>? difficultyStepsByOperation,
    int? difficultyStep,
    int? gradeLevel,
    bool? wordProblemsEnabledOverride,
    double? wordProblemsChanceOverride,
    bool? missingNumberEnabledOverride,
    double? missingNumberChanceOverride,
  }) {
    final wordProblemsEnabled =
        wordProblemsEnabledOverride ?? _wordProblemsEnabled;
    final wordProblemsChance =
        wordProblemsChanceOverride ?? _wordProblemsChance;

    final missingNumberEnabled =
        missingNumberEnabledOverride ?? _missingNumberEnabled;
    final missingNumberChance =
        missingNumberChanceOverride ?? _missingNumberChance;

    final ctx = QuestionGenerationContext.build(
      random: _random,
      getRandomOperation: ({
        required int? gradeLevel,
        required int mixBaselineStep,
      }) =>
          _getRandomOperation(
            gradeLevel: gradeLevel,
            mixBaselineStep: mixBaselineStep,
          ),
      request: QuestionRequest(
        ageGroup: ageGroup,
        operationType: operationType,
        difficulty: difficulty,
        difficultyStepsByOperation: difficultyStepsByOperation,
        difficultyStep: difficultyStep,
        gradeLevel: gradeLevel,
        wordProblemsEnabledOverride: wordProblemsEnabledOverride,
        wordProblemsChanceOverride: wordProblemsChanceOverride,
        missingNumberEnabledOverride: missingNumberEnabledOverride,
        missingNumberChanceOverride: missingNumberChanceOverride,
      ),
      wordProblemsEnabled: wordProblemsEnabled,
      wordProblemsChance: wordProblemsChance,
      missingNumberEnabled: missingNumberEnabled,
      missingNumberChance: missingNumberChance,
    );

    return dispatchQuestionGeneration(ctx);
  }

  // endregion

  // region SRS Key Reconstruction

  /// Tries to reconstruct a [Question] from a spaced-repetition review key.
  ///
  /// Keys have the format `"operationType|operand1 SYMBOL operand2 = ?"`.
  /// Returns `null` for complex/unparseable keys (word problems, statistics,
  /// probability, etc.) – those will fall back to random generation.
  Question? tryGenerateFromSrsKey(
    String key,
    DifficultyLevel difficulty,
  ) {
    if (key.startsWith('v2|')) {
      final parts = key.substring(3).split('|');
      if (parts.length >= 5) {
        final opName = parts[0];
        final op1 = int.tryParse(parts[1]);
        final op2 = int.tryParse(parts[2]);
        final correct = int.tryParse(parts[3]);
        // Rejoin the rest in case displayQuestionText contains pipes
        final displayQuestionText = parts.sublist(4).join('|');

        if (op1 != null && op2 != null && correct != null) {
          OperationType? opType;
          for (final op in OperationType.values) {
            if (op.name == opName && op != OperationType.mixed) {
              opType = op;
              break;
            }
          }

          if (opType != null) {
            String? promptText;
            if (displayQuestionText != '$op1 ${opType.symbol} $op2 = ?') {
              promptText = displayQuestionText;
            }

            return Question(
              id: _uuid.v4(),
              operationType: opType,
              difficulty: difficulty,
              operand1: op1,
              operand2: op2,
              correctAnswer: correct,
              promptText: promptText,
              wrongAnswers: _generateWrongAnswers(correct, 3),
            );
          }
        }
      }
    }

    final pipeIndex = key.indexOf('|');
    if (pipeIndex < 1 || pipeIndex >= key.length - 1) return null;

    final opName = key.substring(0, pipeIndex);
    final questionText = key.substring(pipeIndex + 1); // e.g. "4 × 7 = ?"

    if (!questionText.endsWith(' = ?')) return null;

    final expression =
        questionText.substring(0, questionText.length - ' = ?'.length);

    OperationType? opType;
    for (final op in OperationType.values) {
      if (op.name == opName && op != OperationType.mixed) {
        opType = op;
        break;
      }
    }
    if (opType == null) return null;

    final sep = ' ${opType.symbol} ';
    final sepIndex = expression.indexOf(sep);
    if (sepIndex < 0) return null;

    final op1 = int.tryParse(expression.substring(0, sepIndex).trim());
    final op2 =
        int.tryParse(expression.substring(sepIndex + sep.length).trim());
    if (op1 == null || op2 == null) return null;

    final int correct;
    switch (opType) {
      case OperationType.addition:
        correct = op1 + op2;
      case OperationType.subtraction:
        correct = op1 - op2;
      case OperationType.multiplication:
        correct = op1 * op2;
      case OperationType.division:
        if (op2 == 0) return null;
        correct = op1 ~/ op2;
      case OperationType.mixed:
        return null;
    }

    return Question(
      id: _uuid.v4(),
      operationType: opType,
      difficulty: difficulty,
      operand1: op1,
      operand2: op2,
      correctAnswer: correct,
      wrongAnswers: _generateWrongAnswers(correct, 3),
    );
  }

  // endregion
}
