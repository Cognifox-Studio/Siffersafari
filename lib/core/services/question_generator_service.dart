import 'dart:math';

import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:uuid/uuid.dart';

import '../config/app_features.dart';
import '../config/difficulty_config.dart';

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
class QuestionGeneratorService with _QuestionGeneratorServiceImpl {
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

    final shouldTryMissingNumber = missingNumberEnabled &&
        gradeLevel != null &&
        gradeLevel >= 2 &&
        gradeLevel <= 3 &&
        (operation == OperationType.addition ||
            operation == OperationType.subtraction) &&
        _random.nextDouble() < missingNumberChance;

    final roll = _random.nextDouble();

    // Mix distribution for M4 (Åk 4–6): keep “special” items present but not
    // dominating, and scale them slightly with internal step.
    final isM4Mix = operationType == OperationType.mixed &&
        gradeLevel != null &&
        gradeLevel >= 4 &&
        gradeLevel <= 6;
    final isM5aMix = operationType == OperationType.mixed &&
        gradeLevel != null &&
        gradeLevel >= 7 &&
        gradeLevel <= 9;

    final statsChance = clampedMixStep <= 3
        ? 0.10
        : clampedMixStep <= 6
            ? 0.12
            : 0.12;
    final probabilityChance = clampedMixStep <= 3
        ? 0.10
        : clampedMixStep <= 6
            ? 0.12
            : 0.12;

    final shouldTryM4Statistics = isM4Mix && roll < statsChance;
    final shouldTryM4Probability = isM4Mix &&
        roll >= statsChance &&
        roll < (statsChance + probabilityChance);

    // Skolverket (centralt innehåll Åk 4–6) inkluderar procent.
    // Vi introducerar detta försiktigt (endast Åk 5–6, höga steps) som Mix-special.
    final shouldTryM4Percent = isM4Mix &&
        (gradeLevel == 5 || gradeLevel == 6) &&
        clampedMixStep >= 9 &&
        roll >= (statsChance + probabilityChance) &&
        roll < (statsChance + probabilityChance + 0.06);

    // Skolverket (Åk 4–6) nämner negativa tal. Vi introducerar detta sent i
    // mellanstadiet (Åk 5–6, höga steps) som Mix-special för att inte påverka
    // kärn-flödets +/−-regler.
    final shouldTryM4NegativeNumbers = isM4Mix &&
        (gradeLevel == 5 || gradeLevel == 6) &&
        clampedMixStep >= 9 &&
        roll >= (statsChance + probabilityChance + 0.06) &&
        roll < (statsChance + probabilityChance + 0.10);

    final shouldTryM5aPercent = isM5aMix && clampedMixStep >= 4 && roll < 0.18;
    final shouldTryM5aPower = isM5aMix &&
        gradeLevel >= 8 &&
        clampedMixStep >= 7 &&
        roll >= 0.18 &&
        roll < 0.30;
    final shouldTryM5aPrecedence =
        isM5aMix && clampedMixStep >= 6 && roll >= 0.30 && roll < 0.42;

    final shouldTryWordProblemAddSub = wordProblemsEnabled &&
        gradeLevel != null &&
        gradeLevel >= 1 &&
        gradeLevel <= 3 &&
        roll < wordProblemsChance &&
        (operation == OperationType.addition ||
            operation == OperationType.subtraction);

    // Conservative rollout: only Åk 3 for ×/÷ text problems.
    // In Mix mode, we delay these a bit so ×/÷ can be introduced first without
    // adding extra reading load immediately.
    final shouldTryWordProblemMulDiv = wordProblemsEnabled &&
        gradeLevel == 3 &&
        (operationType != OperationType.mixed || clampedMixStep >= 7) &&
        roll < wordProblemsChance &&
        (operation == OperationType.multiplication ||
            operation == OperationType.division);

    final step = difficultyStepsByOperation != null
        ? (difficultyStepsByOperation[operation] ??
            DifficultyConfig.initialStepForDifficulty(difficulty))
        : (difficultyStep ??
            DifficultyConfig.initialStepForDifficulty(difficulty));

    if (shouldTryM4Statistics) {
      // Use addition's step/range as the base for value scaling.
      final statsStep = mixBaselineStep;

      final statsRange = DifficultyConfig.curriculumNumberRangeForStep(
        gradeLevel: gradeLevel,
        operationType: OperationType.addition,
        difficultyStep: statsStep,
      );

      return _generateM4StatisticsQuestion(
        statsRange,
        difficulty,
        difficultyStep: statsStep,
      );
    }

    if (shouldTryM4Probability) {
      final probStep = mixBaselineStep;

      return _generateM4ProbabilityQuestion(
        difficulty,
        difficultyStep: probStep,
      );
    }

    if (shouldTryM4Percent) {
      final percentStep = mixBaselineStep;

      // Reuse the M5a generator (quiz-format, heltalssvar).
      return _generateM5aPercentQuestion(
        difficulty,
        difficultyStep: percentStep,
      );
    }

    if (shouldTryM4NegativeNumbers) {
      final negStep = mixBaselineStep;

      return _generateM4NegativeNumbersQuestion(
        difficulty,
        difficultyStep: negStep,
      );
    }

    if (shouldTryM5aPercent) {
      final percentStep = mixBaselineStep;

      return _generateM5aPercentQuestion(
        difficulty,
        difficultyStep: percentStep,
      );
    }

    if (shouldTryM5aPower) {
      final powerStep = mixBaselineStep;

      return _generateM5aPowerQuestion(
        difficulty,
        difficultyStep: powerStep,
      );
    }

    if (shouldTryM5aPrecedence) {
      final precedenceStep = mixBaselineStep;

      return _generateM5aPrecedenceQuestion(
        difficulty,
        difficultyStep: precedenceStep,
      );
    }

    // M5b: Introduktion av visualiserad matematik för Åk 7–9 (steg 8+).
    // Börjar med linjära funktioner enbart i textformat.
    final shouldTryM5bLinearFunction =
        isM5aMix && clampedMixStep >= 8 && roll >= 0.42 && roll < 0.52;

    if (shouldTryM5bLinearFunction) {
      final linearStep = mixBaselineStep;

      return _generateM5bLinearFunctionQuestion(
        difficulty,
        difficultyStep: linearStep,
      );
    }

    // M5b delstep 2: Geometriska transformationer (spegling, rotation, translation)
    final shouldTryM5bGeometricTransformation =
        isM5aMix && clampedMixStep >= 8 && roll >= 0.52 && roll < 0.62;

    if (shouldTryM5bGeometricTransformation) {
      final transformStep = mixBaselineStep;

      return _generateM5bGeometricTransformationQuestion(
        difficulty,
        difficultyStep: transformStep,
      );
    }

    // M5b delstep 3: Avancerad statistik (distributioner, outliers, korrelationer)
    final shouldTryM5bAdvancedStatistics =
        isM5aMix && clampedMixStep >= 8 && roll >= 0.62 && roll < 0.72;

    if (shouldTryM5bAdvancedStatistics) {
      final statsStep = mixBaselineStep;

      return _generateM5bAdvancedStatisticsQuestion(
        difficulty,
        difficultyStep: statsStep,
      );
    }

    // M4a: Tid (klockan) för Åk 2–3 i Mix-läge.
    // Keep this rare and step-gated so Mix doesn't feel "special-heavy" when
    // ×/÷ is first introduced (Åk 3).
    final isM4TimeEligible =
        operationType == OperationType.mixed && gradeLevel != null;

    final timeChance = switch (gradeLevel) {
      2 => clampedMixStep <= 4
          ? 0.0
          : clampedMixStep <= 7
              ? 0.03
              : 0.04,
      3 => clampedMixStep <= 3
          ? 0.0
          : clampedMixStep <= 8
              ? 0.02
              : 0.03,
      _ => 0.0,
    };

    // Use a high-roll window to keep it mostly disjoint from other Mix
    // features that use low roll thresholds.
    final shouldTryM4Time = isM4TimeEligible &&
        timeChance > 0 &&
        roll >= (0.85 - timeChance) &&
        roll < 0.85;

    if (shouldTryM4Time) {
      final timeStep = mixBaselineStep;

      return _generateM4TimeQuestion(
        difficulty,
        gradeLevel: gradeLevel,
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
