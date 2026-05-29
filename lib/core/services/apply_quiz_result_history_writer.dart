part of 'apply_quiz_result_use_case.dart';

class _QuizResultHistoryWriter {
  const _QuizResultHistoryWriter(this._repository);

  final LocalStorageRepository _repository;

  Future<void> saveCompletedSession({
    required String userId,
    required QuizSession session,
    required AchievementReward reward,
    required DateTime completedAt,
  }) async {
    await _repository.saveQuizSession({
      'sessionId': session.sessionId,
      'userId': userId,
      'operationType': session.operationType.name,
      'difficulty': session.difficulty.name,
      'correctAnswers': session.correctAnswers,
      'totalQuestions': session.totalQuestions,
      'successRate': session.successRate,
      'points': session.totalPoints,
      'bonusPoints': reward.bonusPoints,
      'pointsWithBonus': session.totalPoints + reward.bonusPoints,
      'startTime': (session.startTime ?? completedAt).toIso8601String(),
      'endTime': (session.endTime ?? completedAt).toIso8601String(),
      'isComplete': true,
    });

    await _repository.deleteQuizSession(
      _repository.inProgressQuizSessionId(
        userId: userId,
        operationTypeName: session.operationType.name,
      ),
    );
  }
}
