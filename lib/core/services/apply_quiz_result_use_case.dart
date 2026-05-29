import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/user_quest_state_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/level_up_event.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';

part 'apply_quiz_result_history_writer.dart';
part 'apply_quiz_result_level_reward_unlocker.dart';
part 'apply_quiz_result_progress_merger.dart';
part 'apply_quiz_result_quest_coordinator.dart';
part 'apply_quiz_result_use_case_helpers.dart';

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
    final existingHistory = _repository.getCompletedQuizSessionById(
      userId: user.userId,
      sessionId: session.sessionId,
    );
    if (existingHistory != null) {
      return _buildAlreadyAppliedResult(user.userId);
    }

    final merge = _QuizProgressMerger(_achievementService).merge(
      user: user,
      session: session,
    );
    final questResult = await _QuestResultCoordinator(_questStateService).apply(
      previousUser: user,
      updatedUser: merge.updatedUser,
    );
    final unlockResult = _LevelRewardUnlocker().apply(
      user: merge.updatedUser,
      oldLevel: merge.oldLevel,
    );

    await _QuizResultHistoryWriter(_repository).saveCompletedSession(
      userId: user.userId,
      session: session,
      reward: merge.reward,
      completedAt: merge.completedAt,
    );

    try {
      await _repository.saveUserProgress(unlockResult.finalUser);
    } catch (_) {
      await _repository.deleteQuizSession(session.sessionId);
      rethrow;
    }

    return ApplyQuizResultResult(
      finalUser: unlockResult.finalUser,
      reward: merge.reward,
      questStatus: questResult.questStatus,
      questCompletion: questResult.resolvedQuestCompletion,
      newlyUnlockedItem: unlockResult.newlyUnlockedItem,
      levelUpEvent: unlockResult.levelUpEvent,
      questNotice: questResult.questNotice,
    );
  }

  Future<ApplyQuizResultResult> _buildAlreadyAppliedResult(
    String userId,
  ) async {
    final finalUser = _repository.getUserProgress(userId);
    if (finalUser == null) {
      throw StateError(
        'Cannot resolve already applied quiz result for $userId',
      );
    }

    final reconciliation = await _questStateService.reconcileQuestPointer(
      finalUser,
    );

    return ApplyQuizResultResult(
      finalUser: finalUser,
      reward: _emptyAchievementReward,
      questStatus: reconciliation.questStatus,
      questNotice: reconciliation.questNotice,
    );
  }
}
