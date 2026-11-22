import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/streak_resolver.dart';
import 'package:siffersafari/core/services/user_quest_state_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/level_up_event.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';

part 'apply_quiz_result__helpers_part.dart';
part 'apply_quiz_result__history_writer_part.dart';
part 'apply_quiz_result__level_reward_unlocker_part.dart';
part 'apply_quiz_result__progress_merger_part.dart';
part 'apply_quiz_result__quest_coordinator_part.dart';

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
    this.streakOutcome,
  });

  final UserProgress finalUser;
  final AchievementReward reward;
  final QuestStatus questStatus;
  final QuestCompletionSummary? questCompletion;
  final InventoryItem? newlyUnlockedItem;
  final LevelUpEvent? levelUpEvent;
  final String? questNotice;

  /// How the finished session changed the streak, including a spent grace day.
  final StreakOutcome? streakOutcome;
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

    final now = DateTime.now();
    final merge = _QuizProgressMerger(_achievementService).merge(
      user: user,
      session: session,
      graceAvailable: isGraceAvailable(
        lastGraceUsedAt: _graceUsedAt(user.userId),
        now: now,
      ),
    );
    final questResult = await _QuestResultCoordinator(_questStateService).apply(
      previousUser: user,
      updatedUser: merge.updatedUser,
    );
    final unlockResult = _LevelRewardUnlocker().apply(
      user: merge.updatedUser,
      oldLevel: merge.oldLevel,
    );

    // ROI #87: award a collectible when the story path ends (nextBiome teaser).
    final episodeComplete = questResult.resolvedQuestCompletion != null &&
        questResult.resolvedQuestCompletion!.nextQuestTitle == null;
    final episodeReward = _applyEpisodeCompleteAchievement(
      user: unlockResult.finalUser,
      reward: merge.reward,
      episodeComplete: episodeComplete,
    );

    await _QuizResultHistoryWriter(_repository).saveCompletedSession(
      userId: user.userId,
      session: session,
      reward: episodeReward.reward,
      completedAt: merge.completedAt,
    );

    try {
      await _repository.saveUserProgress(episodeReward.user);
    } catch (_) {
      await _repository.deleteQuizSession(session.sessionId);
      rethrow;
    }

    // Only after the progress is safely stored: a failed save must not burn a
    // grace day or claim that a streak was lost.
    await _recordStreakOutcome(
      userId: user.userId,
      outcome: merge.streakOutcome,
      now: merge.completedAt,
    );

    return ApplyQuizResultResult(
      finalUser: episodeReward.user,
      reward: episodeReward.reward,
      questStatus: questResult.questStatus,
      questCompletion: questResult.resolvedQuestCompletion,
      newlyUnlockedItem: unlockResult.newlyUnlockedItem,
      levelUpEvent: unlockResult.levelUpEvent,
      questNotice: questResult.questNotice,
      streakOutcome: merge.streakOutcome,
    );
  }

  DateTime? _graceUsedAt(String userId) {
    final raw = _repository.getSetting(SettingsKeys.streakGraceUsed(userId));
    if (raw is DateTime) return raw;
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  /// Remembers what the streak did, so the home screen can be kind about it.
  Future<void> _recordStreakOutcome({
    required String userId,
    required StreakOutcome outcome,
    required DateTime now,
  }) async {
    if (outcome.graceUsed) {
      await _repository.saveSetting(
        SettingsKeys.streakGraceUsed(userId),
        now.toIso8601String(),
      );
    }

    if (outcome.broken && outcome.previousStreak > 1) {
      await _repository.saveSetting(
        SettingsKeys.streakBrokenFrom(userId),
        outcome.previousStreak,
      );
      return;
    }

    if (!outcome.broken) {
      // The streak is alive again; the comeback line has nothing left to say.
      await _repository.deleteSetting(SettingsKeys.streakBrokenFrom(userId));
    }
  }

  ({UserProgress user, AchievementReward reward})
      _applyEpisodeCompleteAchievement({
    required UserProgress user,
    required AchievementReward reward,
    required bool episodeComplete,
  }) {
    const id = AppConstants.episodeCompleteAchievement;
    const bonus = 100;
    if (!episodeComplete || user.achievements.contains(id)) {
      return (user: user, reward: reward);
    }

    return (
      user: user.copyWith(
        achievements: [...user.achievements, id],
        totalPoints: user.totalPoints + bonus,
      ),
      reward: AchievementReward(
        unlockedIds: [...reward.unlockedIds, id],
        bonusPoints: reward.bonusPoints + bonus,
      ),
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
