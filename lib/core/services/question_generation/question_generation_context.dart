import 'dart:math';

import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/services/question_generation/question_request.dart';
import 'package:siffersafari/core/services/question_mix_policy.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// Resolved mix policy, steps, and format flags for pipeline dispatch.
class QuestionGenerationContext {
  const QuestionGenerationContext({
    required this.request,
    required this.mixBaselineStep,
    required this.clampedMixStep,
    required this.operation,
    required this.step,
    required this.mixPolicy,
    required this.shouldTryWordProblemAddSub,
    required this.shouldTryWordProblemMulDiv,
    required this.shouldTryMissingNumber,
    required this.shouldTryGrade1NumberSense,
    required this.wordProblemsEnabled,
    required this.wordProblemsChance,
    required this.missingNumberEnabled,
    required this.missingNumberChance,
  });

  final QuestionRequest request;
  final int mixBaselineStep;
  final int clampedMixStep;
  final OperationType operation;
  final int step;
  final QuestionMixPolicy mixPolicy;
  final bool shouldTryWordProblemAddSub;
  final bool shouldTryWordProblemMulDiv;
  final bool shouldTryMissingNumber;
  final bool shouldTryGrade1NumberSense;
  final bool wordProblemsEnabled;
  final double wordProblemsChance;
  final bool missingNumberEnabled;
  final double missingNumberChance;

  DifficultyLevel get difficulty => request.difficulty;
  int? get gradeLevel => request.gradeLevel;

  static QuestionGenerationContext build({
    required Random random,
    required OperationType Function({
      required int? gradeLevel,
      required int mixBaselineStep,
    }) getRandomOperation,
    required QuestionRequest request,
    required bool wordProblemsEnabled,
    required double wordProblemsChance,
    required bool missingNumberEnabled,
    required double missingNumberChance,
  }) {
    final difficulty = request.difficulty;
    final difficultyStepsByOperation = request.difficultyStepsByOperation;
    final difficultyStep = request.difficultyStep;
    final gradeLevel = request.gradeLevel;
    final operationType = request.operationType;

    final mixBaselineStep = difficultyStepsByOperation != null
        ? (difficultyStepsByOperation[OperationType.addition] ??
            DifficultyConfig.initialStepForDifficulty(difficulty))
        : (difficultyStep ??
            DifficultyConfig.initialStepForDifficulty(difficulty));

    final clampedMixStep =
        DifficultyConfig.clampDifficultyStep(mixBaselineStep);

    final operation = operationType == OperationType.mixed
        ? getRandomOperation(
            gradeLevel: gradeLevel,
            mixBaselineStep: clampedMixStep,
          )
        : operationType;

    final roll = random.nextDouble();
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
        random.nextDouble() < missingNumberChance;

    final shouldTryGrade1NumberSense = gradeLevel == 1 &&
        step <= 6 &&
        (operation == OperationType.addition ||
            operation == OperationType.subtraction) &&
        random.nextDouble() < 0.18;

    return QuestionGenerationContext(
      request: request,
      mixBaselineStep: mixBaselineStep,
      clampedMixStep: clampedMixStep,
      operation: operation,
      step: step,
      mixPolicy: mixPolicy,
      shouldTryWordProblemAddSub: shouldTryWordProblemAddSub,
      shouldTryWordProblemMulDiv: shouldTryWordProblemMulDiv,
      shouldTryMissingNumber: shouldTryMissingNumber,
      shouldTryGrade1NumberSense: shouldTryGrade1NumberSense,
      wordProblemsEnabled: wordProblemsEnabled,
      wordProblemsChance: wordProblemsChance,
      missingNumberEnabled: missingNumberEnabled,
      missingNumberChance: missingNumberChance,
    );
  }
}
