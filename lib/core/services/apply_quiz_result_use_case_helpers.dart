part of 'apply_quiz_result_use_case.dart';

const _emptyAchievementReward = AchievementReward(
  unlockedIds: <String>[],
  bonusPoints: 0,
);

class _MergedQuizProgress {
  const _MergedQuizProgress({
    required this.updatedUser,
    required this.reward,
    required this.oldLevel,
    required this.completedAt,
  });

  final UserProgress updatedUser;
  final AchievementReward reward;
  final int oldLevel;
  final DateTime completedAt;
}

class _QuestResult {
  const _QuestResult({
    required this.questStatus,
    this.resolvedQuestCompletion,
    this.questNotice,
  });

  final QuestStatus questStatus;
  final QuestCompletionSummary? resolvedQuestCompletion;
  final String? questNotice;
}

class _LevelRewardUnlockResult {
  const _LevelRewardUnlockResult({
    required this.finalUser,
    this.newlyUnlockedItem,
    this.levelUpEvent,
  });

  final UserProgress finalUser;
  final InventoryItem? newlyUnlockedItem;
  final LevelUpEvent? levelUpEvent;
}
