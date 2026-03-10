import '../constants/learning_constants.dart';
import '../enums/difficulty_level.dart';

/// Adjusts question difficulty based on user performance.
///
/// Uses thresholds defined in [LearningConstants] to decide when to
/// increase, decrease, or maintain difficulty level. Requires a minimum
/// number of recent results (in [LearningConstants.questionsBeforeAdjustment])
/// before making adjustment decisions.
class AdaptiveDifficultyService {
  /// Calculates the success rate from a list of recent quiz results.
  ///
  /// Returns 0.0 if the list is empty, otherwise the ratio of correct
  /// answers to total attempts.
  double calculateSuccessRate(List<bool> recentResults) {
    if (recentResults.isEmpty) return 0.0;
    final correctCount = recentResults.where((r) => r).length;
    return correctCount / recentResults.length;
  }

  /// Suggests a new difficulty step (1–10 scale) based on performance.
  ///
  /// Applies thresholds from [LearningConstants]:
  /// - If success rate ≥ [difficultyIncreaseThreshold], increments step
  /// - If success rate ≤ [difficultyDecreaseThreshold], decrements step
  /// - Otherwise, keeps current step
  ///
  /// Returns a value clamped between [minStep] and [maxStep].
  ///
  /// Hybrid behavior:
  /// - Micro signal: recent streaks (fast reaction)
  /// - Macro signal: rolling success rate (stable confirmation)
  /// - Cooldown: prevents repeated step changes too quickly
  ///
  /// The service applies a step change when:
  /// - Micro and macro agree, or
  /// - No micro signal exists and macro alone indicates a change.
  int suggestDifficultyStep({
    required int currentStep,
    required List<bool> recentResults,
    required int minStep,
    required int maxStep,
    int questionsSinceLastStepChange =
        LearningConstants.cooldownQuestionsAfterStepChange,
  }) {
    final clampedCurrentStep = currentStep.clamp(minStep, maxStep);

    if (questionsSinceLastStepChange <
        LearningConstants.cooldownQuestionsAfterStepChange) {
      return clampedCurrentStep;
    }

    final microStepDelta = _microStepDelta(recentResults);
    final macroStepDelta = _macroStepDelta(recentResults);

    if (microStepDelta != 0 && microStepDelta == macroStepDelta) {
      return (clampedCurrentStep + microStepDelta).clamp(minStep, maxStep);
    }

    if (microStepDelta == 0 && macroStepDelta != 0) {
      return (clampedCurrentStep + macroStepDelta).clamp(minStep, maxStep);
    }

    return clampedCurrentStep;
  }

  /// Suggests a new [DifficultyLevel] (easy/medium/hard) based on performance.
  ///
  /// Requires at least [questionsBeforeAdjustment] recent results before
  /// making a suggestion. Otherwise returns the current difficulty unchanged.
  DifficultyLevel suggestDifficulty({
    required DifficultyLevel currentDifficulty,
    required List<bool> recentResults,
  }) {
    if (recentResults.length < LearningConstants.questionsBeforeAdjustment) {
      return currentDifficulty;
    }

    final successRate = calculateSuccessRate(recentResults);

    if (successRate >= LearningConstants.difficultyIncreaseThreshold) {
      return _increaseDifficulty(currentDifficulty);
    }

    if (successRate <= LearningConstants.difficultyDecreaseThreshold) {
      return _decreaseDifficulty(currentDifficulty);
    }

    return currentDifficulty;
  }

  DifficultyLevel _increaseDifficulty(DifficultyLevel current) {
    switch (current) {
      case DifficultyLevel.easy:
        return DifficultyLevel.medium;
      case DifficultyLevel.medium:
        return DifficultyLevel.hard;
      case DifficultyLevel.hard:
        return DifficultyLevel.hard;
    }
  }

  DifficultyLevel _decreaseDifficulty(DifficultyLevel current) {
    switch (current) {
      case DifficultyLevel.easy:
        return DifficultyLevel.easy;
      case DifficultyLevel.medium:
        return DifficultyLevel.easy;
      case DifficultyLevel.hard:
        return DifficultyLevel.medium;
    }
  }

  int _macroStepDelta(List<bool> recentResults) {
    if (recentResults.length < LearningConstants.questionsBeforeAdjustment) {
      return 0;
    }

    final successRate = calculateSuccessRate(recentResults);
    if (successRate >= LearningConstants.difficultyIncreaseThreshold) {
      return 1;
    }
    if (successRate <= LearningConstants.difficultyDecreaseThreshold) {
      return -1;
    }
    return 0;
  }

  int _microStepDelta(List<bool> recentResults) {
    if (_trailingCorrectCount(recentResults) >=
        LearningConstants.consecutiveCorrectForIncrease) {
      return 1;
    }

    if (_trailingIncorrectCount(recentResults) >=
        LearningConstants.consecutiveIncorrectForDecrease) {
      return -1;
    }

    return 0;
  }

  int _trailingCorrectCount(List<bool> recentResults) {
    var count = 0;
    for (var i = recentResults.length - 1; i >= 0; i--) {
      if (recentResults[i]) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int _trailingIncorrectCount(List<bool> recentResults) {
    var count = 0;
    for (var i = recentResults.length - 1; i >= 0; i--) {
      if (!recentResults[i]) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}
