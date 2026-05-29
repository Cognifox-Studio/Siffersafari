import 'dart:math';

import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:uuid/uuid.dart';

import '../config/app_features.dart';
import '../config/difficulty_config.dart';
import 'question_mix_policy.dart';

part 'question_generator_service_helpers.dart';
part 'question_generator_service_impl.dart';

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
    with _QuestionGeneratorServiceHelpers, _QuestionGeneratorServiceImpl {
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

  /// Generate a list of questions for a quiz session
  List<Question> generateQuestions({
    required AgeGroup ageGroup,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required int count,
    Map<OperationType, int>? difficultyStepsByOperation,
    int? difficultyStep,
    int? gradeLevel,
  }) {
    final questions = <Question>[];

    for (var i = 0; i < count; i++) {
      final question = generateQuestion(
        ageGroup: ageGroup,
        operationType: operationType,
        difficulty: difficulty,
        difficultyStepsByOperation: difficultyStepsByOperation,
        difficultyStep: difficultyStep,
        gradeLevel: gradeLevel,
      );
      questions.add(question);
    }

    return questions;
  }

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

    // Use a stable baseline step for “special” Mix question types (M4).
    // We base this on addition's step to avoid the selected random operation
    // skewing how often these appear.
    final mixBaselineStep = difficultyStepsByOperation != null
        ? (difficultyStepsByOperation[OperationType.addition] ??
            DifficultyConfig.initialStepForDifficulty(difficulty))
        : (difficultyStep ??
            DifficultyConfig.initialStepForDifficulty(difficulty));

    final clampedMixStep =
        DifficultyConfig.clampDifficultyStep(mixBaselineStep);

    final operation = operationType == OperationType.mixed
        ? _getRandomOperation(
            gradeLevel: gradeLevel,
            mixBaselineStep: clampedMixStep,
          )
        : operationType;

    final roll = _random.nextDouble();
    final mixPolicy = QuestionMixPolicy(
      requestedOperation: operationType,
      selectedOperation: operation,
      gradeLevel: gradeLevel,
      clampedStep: clampedMixStep,
      roll: roll,
      wordProblemsEnabled: wordProblemsEnabled,
      wordProblemsChance: wordProblemsChance,
    );
    final shouldTryWordProblemAddSub = mixPolicy.shouldTryWordProblemAddSub;
    final shouldTryWordProblemMulDiv = mixPolicy.shouldTryWordProblemMulDiv;

    final step = difficultyStepsByOperation != null
        ? (difficultyStepsByOperation[operation] ??
            DifficultyConfig.initialStepForDifficulty(difficulty))
        : (difficultyStep ??
            DifficultyConfig.initialStepForDifficulty(difficulty));

    final shouldTryMissingNumber = missingNumberEnabled &&
        gradeLevel != null &&
        gradeLevel >= 2 &&
        gradeLevel <= 3 &&
        ((operation == OperationType.addition ||
                operation == OperationType.subtraction) ||
            ((operation == OperationType.multiplication ||
                    operation == OperationType.division) &&
                step >= 3)) &&
        _random.nextDouble() < missingNumberChance;

    final shouldTryGrade1NumberSense = gradeLevel == 1 &&
        step <= 6 &&
        (operation == OperationType.addition ||
            operation == OperationType.subtraction) &&
        _random.nextDouble() < 0.18;

    if (mixPolicy.shouldTryM4Statistics) {
      // Use addition's step/range as the base for value scaling.
      final statsStep = mixBaselineStep;

      final statsRange = DifficultyConfig.curriculumNumberRangeForStep(
        gradeLevel: gradeLevel!,
        operationType: OperationType.addition,
        difficultyStep: statsStep,
      );

      return _generateM4StatisticsQuestion(
        statsRange,
        difficulty,
        difficultyStep: statsStep,
      );
    }

    if (mixPolicy.shouldTryM4Probability) {
      final probStep = mixBaselineStep;

      return _generateM4ProbabilityQuestion(
        difficulty,
        difficultyStep: probStep,
      );
    }

    if (mixPolicy.shouldTryLowGradeStatistics) {
      return _generateLowGradeStatisticsQuestion(
        difficulty,
        difficultyStep: mixBaselineStep,
      );
    }

    if (mixPolicy.shouldTryLowGradeChance) {
      return _generateLowGradeChanceQuestion(
        difficulty,
        difficultyStep: mixBaselineStep,
      );
    }

    if (mixPolicy.shouldTryM4Percent) {
      final percentStep = mixBaselineStep;

      // Reuse the M5a generator (quiz-format, heltalssvar).
      return _generateM5aPercentQuestion(
        difficulty,
        difficultyStep: percentStep,
      );
    }

    if (mixPolicy.shouldTryM4NegativeNumbers) {
      final negStep = mixBaselineStep;

      return _generateM4NegativeNumbersQuestion(
        difficulty,
        difficultyStep: negStep,
      );
    }

    if (mixPolicy.shouldTryM5aPercent) {
      final percentStep = mixBaselineStep;

      return _generateM5aPercentQuestion(
        difficulty,
        difficultyStep: percentStep,
      );
    }

    if (mixPolicy.shouldTryM5aPower) {
      final powerStep = mixBaselineStep;

      return _generateM5aPowerQuestion(
        difficulty,
        difficultyStep: powerStep,
      );
    }

    if (mixPolicy.shouldTryM5aProportionality) {
      final proportionalityStep = mixBaselineStep;

      return _generateM5aProportionalityQuestion(
        difficulty,
        difficultyStep: proportionalityStep,
      );
    }

    if (mixPolicy.shouldTryM5aEquation) {
      final equationStep = mixBaselineStep;

      return _generateM5aEquationQuestion(
        difficulty,
        gradeLevel: gradeLevel!,
        difficultyStep: equationStep,
      );
    }

    if (mixPolicy.shouldTryM5aPrecedence) {
      final precedenceStep = mixBaselineStep;

      return _generateM5aPrecedenceQuestion(
        difficulty,
        difficultyStep: precedenceStep,
      );
    }

    if (mixPolicy.shouldTryM5bLinearFunction) {
      final linearStep = mixBaselineStep;

      return _generateM5bLinearFunctionQuestion(
        difficulty,
        difficultyStep: linearStep,
      );
    }

    if (mixPolicy.shouldTryM5bGeometricTransformation) {
      final transformStep = mixBaselineStep;

      return _generateM5bGeometricTransformationQuestion(
        difficulty,
        gradeLevel: gradeLevel!,
        difficultyStep: transformStep,
      );
    }

    if (mixPolicy.shouldTryM5bAdvancedStatistics) {
      final statsStep = mixBaselineStep;

      return _generateM5bAdvancedStatisticsQuestion(
        difficulty,
        difficultyStep: statsStep,
      );
    }

    if (mixPolicy.shouldTryM4Time) {
      final timeStep = mixBaselineStep;

      return _generateM4TimeQuestion(
        difficulty,
        gradeLevel: gradeLevel!,
        difficultyStep: timeStep,
      );
    }

    final range = gradeLevel == null
        ? DifficultyConfig.getNumberRangeForStep(
            ageGroup,
            operation,
            step,
          )
        : DifficultyConfig.curriculumNumberRangeForStep(
            gradeLevel: gradeLevel,
            operationType: operation,
            difficultyStep: step,
          );

    switch (operation) {
      case OperationType.addition:
        if (shouldTryGrade1NumberSense) {
          return _generateGrade1AdditionNumberSenseQuestion(
            range,
            difficulty,
            difficultyStep: step,
          );
        }
        if (shouldTryMissingNumber) {
          return _generateAdditionMissingNumber(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        if (shouldTryWordProblemAddSub) {
          return _generateAdditionWordProblem(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        return _generateAddition(
          range,
          difficulty,
          gradeLevel: gradeLevel,
          difficultyStep: step,
        );
      case OperationType.subtraction:
        if (shouldTryGrade1NumberSense) {
          return _generateGrade1SubtractionNumberSenseQuestion(
            range,
            difficulty,
            difficultyStep: step,
          );
        }
        if (shouldTryMissingNumber) {
          return _generateSubtractionMissingNumber(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        if (shouldTryWordProblemAddSub) {
          return _generateSubtractionWordProblem(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        return _generateSubtraction(
          range,
          difficulty,
          gradeLevel: gradeLevel,
          difficultyStep: step,
        );
      case OperationType.multiplication:
        if (shouldTryMissingNumber) {
          return _generateMultiplicationMissingNumber(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        if (shouldTryWordProblemMulDiv) {
          return _generateMultiplicationWordProblem(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        if (gradeLevel != null && gradeLevel >= 4) {
          return _generateMultiplicationCurriculum(
            range,
            difficulty,
            difficultyStep: step,
          );
        }
        return _generateMultiplication(
          range,
          difficulty,
          gradeLevel: gradeLevel,
          difficultyStep: step,
        );
      case OperationType.division:
        if (shouldTryMissingNumber) {
          return _generateDivisionMissingNumber(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        if (shouldTryWordProblemMulDiv) {
          return _generateDivisionWordProblem(
            range,
            difficulty,
            gradeLevel: gradeLevel,
            difficultyStep: step,
          );
        }
        if (gradeLevel != null && gradeLevel >= 4) {
          return _generateDivisionCurriculum(
            range,
            difficulty,
            difficultyStep: step,
          );
        }
        return _generateDivision(
          range,
          difficulty,
          gradeLevel: gradeLevel,
          difficultyStep: step,
        );
      case OperationType.mixed:
        return generateQuestion(
          ageGroup: ageGroup,
          operationType: _getRandomOperation(
            gradeLevel: gradeLevel,
            mixBaselineStep: clampedMixStep,
          ),
          difficulty: difficulty,
          difficultyStepsByOperation: difficultyStepsByOperation,
          difficultyStep: difficultyStep,
          gradeLevel: gradeLevel,
          wordProblemsEnabledOverride: wordProblemsEnabledOverride,
          wordProblemsChanceOverride: wordProblemsChanceOverride,
          missingNumberEnabledOverride: missingNumberEnabledOverride,
          missingNumberChanceOverride: missingNumberChanceOverride,
        );
    }
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
