import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/user_quest_state_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/level_up_event.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';

class QuestCompletionSummary {
  const QuestCompletionSummary({
    required this.completedQuestId,
    required this.completedQuestTitle,
    required this.completedQuestDescription,
    this.nextQuestTitle,
  });

  final String completedQuestId;
  final String completedQuestTitle;
  final String completedQuestDescription;
  final String? nextQuestTitle;
}

class ApplyQuizResultResult {
  const ApplyQuizResultResult({
    required this.finalUser,
    required this.reward,
    required this.questStatus,
    this.questCompletion,
    this.newlyUnlockedItem,
    this.levelUpEvent,
    this.questNotice,
  });

  final UserProgress finalUser;
  final AchievementReward reward;
  final QuestStatus questStatus;
  final QuestCompletionSummary? questCompletion;
  final InventoryItem? newlyUnlockedItem;
  final LevelUpEvent? levelUpEvent;
  final String? questNotice;
}

class ApplyQuizResultUseCase {
  const ApplyQuizResultUseCase({
    required LocalStorageRepository repository,
    required AchievementService achievementService,
    required UserQuestStateService questStateService,
  })  : _repository = repository,
        _achievementService = achievementService,
        _questStateService = questStateService;

  final LocalStorageRepository _repository;
  final AchievementService _achievementService;
  final UserQuestStateService _questStateService;

  Future<ApplyQuizResultResult> execute({
    required UserProgress user,
    required QuizSession session,
  }) async {
    QuestCompletionSummary? questCompletion;
    final now = DateTime.now();
    final oldLevel = user.level;

    final updatedStreak = _calculateStreak(
      currentStreak: user.currentStreak,
      lastSessionDate: user.lastSessionDate,
      now: now,
    );

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

    final updatedUser = user.copyWith(
      totalQuizzesTaken: user.totalQuizzesTaken + 1,
      totalQuestionsAnswered:
          user.totalQuestionsAnswered + session.totalQuestions,
      totalCorrectAnswers: user.totalCorrectAnswers + session.correctAnswers,
      currentStreak: updatedStreak,
      longestStreak: updatedLongestStreak,
      totalPoints: user.totalPoints + session.totalPoints + reward.bonusPoints,
      lastSessionDate: now,
      masteryLevels: updatedMastery,
      achievements: updatedAchievements,
      operationDifficultySteps: updatedDifficultySteps,
    );

    final initialReconciliation =
        await _questStateService.reconcileQuestPointer(user);
    final completedQuestIds = _questStateService.readCompletedQuestIds(
      user.userId,
    );
    final currentQuestId = _questStateService.readCurrentQuestId(user.userId) ??
        _questStateService.firstQuestIdFor(user);

    final beforeQuestStatus = _questStateService.getQuestStatusWith(
      user: updatedUser,
      currentQuestId: currentQuestId,
      completedQuestIds: completedQuestIds,
    );

    if (beforeQuestStatus.isCompleted &&
        !completedQuestIds.contains(beforeQuestStatus.quest.id)) {
      final updatedCompleted = {
        ...completedQuestIds,
        beforeQuestStatus.quest.id,
      };
      final nextId = _questStateService.nextQuestIdFor(
        user: updatedUser,
        currentQuestId: beforeQuestStatus.quest.id,
      );
      await _questStateService.setQuestState(
        userId: user.userId,
        currentQuestId: nextId ?? beforeQuestStatus.quest.id,
        completedQuestIds: updatedCompleted,
      );
      questCompletion = QuestCompletionSummary(
        completedQuestId: beforeQuestStatus.quest.id,
        completedQuestTitle: beforeQuestStatus.quest.title,
        completedQuestDescription: beforeQuestStatus.quest.description,
      );
    }

    final finalReconciliation =
        await _questStateService.reconcileQuestPointer(updatedUser);
    final questStatus = finalReconciliation.questStatus;

    await _repository.saveQuizSession({
      'sessionId': session.sessionId,
      'userId': user.userId,
      'operationType': session.operationType.name,
      'difficulty': session.difficulty.name,
      'correctAnswers': session.correctAnswers,
      'totalQuestions': session.totalQuestions,
      'successRate': session.successRate,
      'points': session.totalPoints,
      'bonusPoints': reward.bonusPoints,
      'pointsWithBonus': session.totalPoints + reward.bonusPoints,
      'startTime': (session.startTime ?? now).toIso8601String(),
      'endTime': (session.endTime ?? now).toIso8601String(),
      'isComplete': true,
    });

    await _repository.deleteQuizSession(
      _repository.inProgressQuizSessionId(
        userId: user.userId,
        operationTypeName: session.operationType.name,
      ),
    );

    InventoryItem? newlyUnlockedItem;
    var finalUnlockedItems = updatedUser.unlockedItems;

    if (updatedUser.level > oldLevel) {
      newlyUnlockedItem = InventoryConfig.nextLevelUnlock(finalUnlockedItems);
      if (newlyUnlockedItem != null) {
        finalUnlockedItems = [...finalUnlockedItems, newlyUnlockedItem.id];
      }
    }

    final finalUser = updatedUser.copyWith(unlockedItems: finalUnlockedItems);
    await _repository.saveUserProgress(finalUser);

    final resolvedQuestCompletion = questCompletion == null
        ? null
        : QuestCompletionSummary(
            completedQuestId: questCompletion.completedQuestId,
            completedQuestTitle: questCompletion.completedQuestTitle,
            completedQuestDescription:
                questCompletion.completedQuestDescription,
            nextQuestTitle:
                questStatus.quest.id == questCompletion.completedQuestId
                    ? null
                    : questStatus.quest.title,
          );

    return ApplyQuizResultResult(
      finalUser: finalUser,
      reward: reward,
      questStatus: questStatus,
      questCompletion: resolvedQuestCompletion,
      newlyUnlockedItem: newlyUnlockedItem,
      levelUpEvent: finalUser.level > oldLevel
          ? LevelUpEvent(
              oldLevel: oldLevel,
              newLevel: finalUser.level,
              newTitle: finalUser.levelTitle,
            )
          : null,
      questNotice:
          finalReconciliation.questNotice ?? initialReconciliation.questNotice,
    );
  }

  int _calculateStreak({
    required int currentStreak,
    required DateTime? lastSessionDate,
    required DateTime now,
  }) {
    if (lastSessionDate == null) return 1;

    final lastDate = DateTime(
      lastSessionDate.year,
      lastSessionDate.month,
      lastSessionDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    final difference = today.difference(lastDate).inDays;

    if (difference == 0) return currentStreak;
    if (difference == 1) return currentStreak + 1;
    return 1;
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
