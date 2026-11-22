part of 'apply_quiz_result_use_case.dart';

class _QuizProgressMerger {
  const _QuizProgressMerger(this._achievementService);

  final AchievementService _achievementService;

  _MergedQuizProgress merge({
    required UserProgress user,
    required QuizSession session,
    bool graceAvailable = false,
  }) {
    final now = DateTime.now();
    final oldLevel = user.level;

    final streakOutcome = resolveStreak(
      currentStreak: user.currentStreak,
      lastSessionDate: user.lastSessionDate,
      now: now,
      graceAvailable: graceAvailable,
    );
    final updatedStreak = streakOutcome.streak;
    final updatedLongestStreak =
        updatedStreak > user.longestStreak ? updatedStreak : user.longestStreak;
    final updatedMastery = _updateMastery(
      current: user.masteryLevels,
      session: session,
    );

    final reward = _achievementService.evaluate(
      user: user.copyWith(currentStreak: updatedStreak),
      session: session,
    );
    final updatedAchievements = [
      ...user.achievements,
      ...reward.unlockedIds.where((id) => !user.achievements.contains(id)),
    ];
    final updatedDifficultySteps = {
      ...user.operationDifficultySteps,
      ...session.difficultyStepsByOperation
          .map((op, step) => MapEntry(op.name, step)),
    };

    return _MergedQuizProgress(
      updatedUser: user.copyWith(
        totalQuizzesTaken: user.totalQuizzesTaken + 1,
        totalQuestionsAnswered:
            user.totalQuestionsAnswered + session.totalQuestions,
        totalCorrectAnswers: user.totalCorrectAnswers + session.correctAnswers,
        currentStreak: updatedStreak,
        longestStreak: updatedLongestStreak,
        totalPoints:
            user.totalPoints + session.totalPoints + reward.bonusPoints,
        lastSessionDate: now,
        masteryLevels: updatedMastery,
        achievements: updatedAchievements,
        operationDifficultySteps: updatedDifficultySteps,
      ),
      reward: reward,
      oldLevel: oldLevel,
      completedAt: now,
      streakOutcome: streakOutcome,
    );
  }

  Map<String, double> _updateMastery({
    required Map<String, double> current,
    required QuizSession session,
  }) {
    final key = '${session.operationType.name}_${session.difficulty.name}';
    final previousRate = current[key] ?? 0.0;
    final newRate = session.successRate;
    final updatedRate =
        previousRate == 0.0 ? newRate : (previousRate + newRate) / 2;

    return {
      ...current,
      key: updatedRate,
    };
  }
}
