part of 'question_generator_service.dart';

mixin _QuestionGeneratorServicePipeline on _QuestionGeneratorServiceImpl {
  Question dispatchQuestionGeneration(QuestionGenerationContext ctx) {
    final ageGroup = ctx.request.ageGroup;
    final difficulty = ctx.difficulty;
    final gradeLevel = ctx.gradeLevel;
    final difficultyStepsByOperation = ctx.request.difficultyStepsByOperation;
    final difficultyStep = ctx.request.difficultyStep;
    final mixBaselineStep = ctx.mixBaselineStep;
    final clampedMixStep = ctx.clampedMixStep;
    final operation = ctx.operation;
    final step = ctx.step;
    final mixPolicy = ctx.mixPolicy;
    final shouldTryWordProblemAddSub = ctx.shouldTryWordProblemAddSub;
    final shouldTryWordProblemMulDiv = ctx.shouldTryWordProblemMulDiv;
    final shouldTryMissingNumber = ctx.shouldTryMissingNumber;
    final shouldTryGrade1NumberSense = ctx.shouldTryGrade1NumberSense;

    if (mixPolicy.shouldTryM4Statistics) {
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
        final host = this as QuestionGeneratorService;
        return host.generateQuestion(
          ageGroup: ageGroup,
          operationType: _getRandomOperation(
            gradeLevel: gradeLevel,
            mixBaselineStep: clampedMixStep,
          ),
          difficulty: difficulty,
          difficultyStepsByOperation: difficultyStepsByOperation,
          difficultyStep: difficultyStep,
          gradeLevel: gradeLevel,
          wordProblemsEnabledOverride:
              ctx.request.wordProblemsEnabledOverride,
          wordProblemsChanceOverride: ctx.request.wordProblemsChanceOverride,
          missingNumberEnabledOverride:
              ctx.request.missingNumberEnabledOverride,
          missingNumberChanceOverride:
              ctx.request.missingNumberChanceOverride,
        );
    }
  }
}
