import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/level_up_event.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import 'achievement_service_provider.dart';
import 'audio_service_provider.dart';
import 'local_storage_repository_provider.dart';
import 'quest_progression_service_provider.dart';

// region UserState Class

class UserState {
  const UserState({
    this.activeUser,
    this.allUsers = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastReward,
    this.lastQuestCompletion,
    this.lastLevelUp,
    this.questStatus,
    this.questNotice,
    this.newlyUnlockedItem,
  });

  final UserProgress? activeUser;
  final List<UserProgress> allUsers;
  final bool isLoading;
  final String? errorMessage;
  final AchievementReward? lastReward;
  final QuestCompletionEvent? lastQuestCompletion;
  final LevelUpEvent? lastLevelUp;
  final QuestStatus? questStatus;
  final String? questNotice;
  final InventoryItem? newlyUnlockedItem;

  static const Object _unset = Object();

  UserState copyWith({
    Object? activeUser = _unset,
    List<UserProgress>? allUsers,
    bool? isLoading,
    String? errorMessage,
    AchievementReward? lastReward,
    Object? lastQuestCompletion = _unset,
    Object? lastLevelUp = _unset,
    Object? questStatus = _unset,
    Object? questNotice = _unset,
    Object? newlyUnlockedItem = _unset,
  }) {
    return UserState(
      activeUser:
          activeUser == _unset ? this.activeUser : activeUser as UserProgress?,
      allUsers: allUsers ?? this.allUsers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastReward: lastReward,
      lastQuestCompletion: lastQuestCompletion == _unset
          ? this.lastQuestCompletion
          : lastQuestCompletion as QuestCompletionEvent?,
      lastLevelUp: lastLevelUp == _unset
          ? this.lastLevelUp
          : lastLevelUp as LevelUpEvent?,
      questStatus: questStatus == _unset
          ? this.questStatus
          : questStatus as QuestStatus?,
      questNotice:
          questNotice == _unset ? this.questNotice : questNotice as String?,
      newlyUnlockedItem: newlyUnlockedItem == _unset
          ? this.newlyUnlockedItem
          : newlyUnlockedItem as InventoryItem?,
    );
  }
}

class QuestCompletionEvent {
  const QuestCompletionEvent({
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

// endregion

// region UserNotifier Class

/// Manages user profile state: active user, user list, quest progress, and achievements.
///
/// Key responsibilities:
/// - Load and cache user profiles from local storage.
/// - Select the active user and sync audio settings.
/// - Reconcile quest pointers when grade/age-group changes.
/// - Apply quiz results, calculate streaks, and unlock achievements.
///
/// Use [loadUsers] to refresh from storage; [applyQuizResult] to record session completion.
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(
    this._repository,
    this._achievementService,
    this._audioService,
    this._questProgressionService,
  ) : super(const UserState());

  final LocalStorageRepository _repository;
  final AchievementService _achievementService;
  final AudioService _audioService;
  final QuestProgressionService _questProgressionService;

  static const _baseOperations = <OperationType>{
    OperationType.addition,
    OperationType.subtraction,
    OperationType.multiplication,
    OperationType.division,
  };

  Set<OperationType> _readParentAllowedOperations(String userId) {
    final rawList = _repository.getAllowedOperationNames(userId);
    if (rawList.isNotEmpty) {
      final ops = rawList
          .map(_operationFromName)
          .whereType<OperationType>()
          .where(_baseOperations.contains)
          .toSet();

      if (ops.isNotEmpty) return ops;
    }

    return {..._baseOperations};
  }

  OperationType? _operationFromName(String name) {
    for (final op in OperationType.values) {
      if (op.name == name) return op;
    }
    return null;
  }

  Set<OperationType> _effectiveAllowedOperationsFor(UserProgress user) {
    final parentAllowed = _readParentAllowedOperations(user.userId);
    return DifficultyConfig.effectiveAllowedOperations(
      parentAllowedOperations: parentAllowed,
      gradeLevel: user.gradeLevel,
    );
  }

  Set<String> _readCompletedQuestIds(String userId) {
    return _repository.getCompletedQuestIds(userId);
  }

  String? _readCurrentQuestId(String userId) {
    return _repository.getCurrentQuestId(userId);
  }

  QuestStatus _getQuestStatus(UserProgress user) {
    return _getQuestStatusWith(
      user: user,
      currentQuestId: _readCurrentQuestId(user.userId),
      completedQuestIds: _readCompletedQuestIds(user.userId),
    );
  }

  QuestStatus _getQuestStatusWith({
    required UserProgress user,
    required String? currentQuestId,
    required Set<String> completedQuestIds,
  }) {
    return _questProgressionService.getCurrentStatus(
      user: user,
      currentQuestId: currentQuestId,
      completedQuestIds: completedQuestIds,
      allowedOperations: _effectiveAllowedOperationsFor(user),
    );
  }

  Future<void> _ensureQuestInitialized(UserProgress user) async {
    final current = _readCurrentQuestId(user.userId);
    if (current != null) return;

    final allowedOps = _effectiveAllowedOperationsFor(user);
    await _repository.setCurrentQuestId(
      user.userId,
      _questProgressionService.firstQuestId(
        user,
        allowedOperations: allowedOps,
      ),
    );
    await _repository.setCompletedQuestIds(user.userId, <String>{});
  }

  Future<void> _setQuestState({
    required String userId,
    required String currentQuestId,
    required Set<String> completedQuestIds,
  }) async {
    await _repository.setCurrentQuestId(userId, currentQuestId);
    await _repository.setCompletedQuestIds(userId, completedQuestIds);
  }

  /// Ensures the persisted quest pointer is valid for the user's current
  /// quest path (grade/age-group) and not already completed.
  Future<void> _reconcileQuestPointer(UserProgress user) async {
    await _ensureQuestInitialized(user);

    final completed = _readCompletedQuestIds(user.userId);
    final current = _readCurrentQuestId(user.userId);

    final status = _getQuestStatusWith(
      user: user,
      currentQuestId: current,
      completedQuestIds: completed,
    );

    if (current != status.quest.id) {
      await _repository.setCurrentQuestId(user.userId, status.quest.id);
      final label = user.gradeLevel != null
          ? 'Årskurs ${user.gradeLevel}'
          : user.ageGroup.displayName;

      final charId = user.selectedCharacterId;
      final charName = charId.isNotEmpty
          ? charId[0].toUpperCase() + charId.substring(1)
          : AppConstants.mascotName;

      state = state.copyWith(
        questNotice: '$charName anpassade uppdraget till $label.',
      );
    }
  }

  void clearQuestNotice() {
    if (state.questNotice == null) return;
    state = state.copyWith(questNotice: null);
  }

  void clearLastQuestCompletion() {
    if (state.lastQuestCompletion == null) return;
    state = state.copyWith(lastQuestCompletion: null);
  }

  void clearLastLevelUp() {
    if (state.lastLevelUp == null) return;
    state = state.copyWith(lastLevelUp: null, newlyUnlockedItem: null);
  }

  double _readAudioLevelSetting(String key) {
    final raw = _repository.getSetting(key);
    if (raw is! num) return AppAudioLevel.high.factor;

    final volume = raw.toDouble().clamp(0.0, 1.0);
    if (volume <= 0.01) return AppAudioLevel.high.factor;
    return volume;
  }

  void _syncAudioSettings(UserProgress user) {
    _audioService.setSoundVolume(
      _readAudioLevelSetting(SettingsKeys.soundVolume(user.userId)),
    );
    _audioService.setMusicVolume(
      _readAudioLevelSetting(SettingsKeys.musicVolume(user.userId)),
    );
    _audioService.setSoundEnabled(user.soundEnabled);
    _audioService.setMusicEnabled(user.musicEnabled);
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final users = _repository.getAllUserProfiles();

      final storedActiveUserId = _repository.getActiveUserId();
      final storedActiveUser = storedActiveUserId is String
          ? users.cast<UserProgress?>().firstWhere(
                (u) => u?.userId == storedActiveUserId,
                orElse: () => null,
              )
          : null;

      final activeUser =
          storedActiveUser ?? (users.length == 1 ? users.first : null);

      if (activeUser != null) {
        _syncAudioSettings(activeUser);
        await _reconcileQuestPointer(activeUser);
      }

      final questStatus =
          activeUser == null ? null : _getQuestStatus(activeUser);

      state = state.copyWith(
        allUsers: users,
        activeUser: activeUser,
        questStatus: questStatus,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> selectUser(String userId) async {
    UserProgress? user;
    for (final u in state.allUsers) {
      if (u.userId == userId) {
        user = u;
        break;
      }
    }

    user ??= _repository.getUserProgress(userId);
    if (user == null) return;

    _syncAudioSettings(user);
    await _reconcileQuestPointer(user);

    final questStatus = _getQuestStatus(user);
    await _repository.setActiveUserId(userId);
    state = state.copyWith(activeUser: user, questStatus: questStatus);
  }

  Future<void> createUser({
    required String userId,
    required String name,
    required AgeGroup ageGroup,
    String avatarEmoji = '🧒',
    int? gradeLevel,
    String selectedCharacterId = 'loke',
  }) async {
    final newUser = UserProgress(
      userId: userId,
      name: name,
      ageGroup: ageGroup,
      avatarEmoji: avatarEmoji,
      gradeLevel: gradeLevel,
      selectedCharacterId: selectedCharacterId,
    );

    await saveUser(newUser);
  }

  Future<void> saveUser(UserProgress user) async {
    await _repository.saveUserProgress(user);
    await _repository.setActiveUserId(user.userId);
    await _reconcileQuestPointer(user);
    await loadUsers();
    _syncAudioSettings(user);
    state = state.copyWith(activeUser: user);
  }

  Future<void> setSoundLevel(AppAudioLevel level) async {
    final user = state.activeUser;
    if (user == null) return;

    if (level != AppAudioLevel.off) {
      await _repository.saveSetting(
        SettingsKeys.soundVolume(user.userId),
        level.factor,
      );
      _audioService.setSoundVolume(level.factor);
    }

    final enabled = level != AppAudioLevel.off;
    if (user.soundEnabled != enabled) {
      await saveUser(user.copyWith(soundEnabled: enabled));
      return;
    }

    _audioService.setSoundEnabled(enabled);
  }

  Future<void> setMusicLevel(AppAudioLevel level) async {
    final user = state.activeUser;
    if (user == null) return;

    if (level != AppAudioLevel.off) {
      await _repository.saveSetting(
        SettingsKeys.musicVolume(user.userId),
        level.factor,
      );
      _audioService.setMusicVolume(level.factor);
    }

    final enabled = level != AppAudioLevel.off;
    if (user.musicEnabled != enabled) {
      await saveUser(user.copyWith(musicEnabled: enabled));
      return;
    }

    _audioService.setMusicEnabled(enabled);
  }

  Future<void> deleteUser(String userId) async {
    final currentActiveUserId =
        state.activeUser?.userId ?? _repository.getActiveUserId();

    await _repository.deleteUserData(userId);

    if (currentActiveUserId == userId) {
      final remainingUsers = _repository.getAllUserProfiles();
      if (remainingUsers.isEmpty) {
        await _repository.clearActiveUserId();
      } else {
        await _repository.setActiveUserId(remainingUsers.first.userId);
      }
    }

    await loadUsers();
  }

  Future<void> clearAllData() async {
    await _repository.clearAllData();
    state = state.copyWith(
      activeUser: null,
      allUsers: const [],
      isLoading: false,
      errorMessage: null,
      lastReward: null,
      lastQuestCompletion: null,
      lastLevelUp: null,
      questStatus: null,
      questNotice: null,
      newlyUnlockedItem: null,
    );
  }

  /// Persist the selected character slug (e.g. 'loke')
  /// for the currently active user.
  Future<void> setCharacter(String characterSlug) async {
    final user = state.activeUser;
    if (user == null) return;
    final updated = user.copyWith(selectedCharacterId: characterSlug);
    await saveUser(updated);
  }

  /// Unlocks an inventory item for the active user.
  Future<void> unlockItem(String itemId) async {
    final user = state.activeUser;
    if (user == null || user.unlockedItems.contains(itemId)) return;

    final updatedItems = List<String>.from(user.unlockedItems)..add(itemId);
    final updatedUser = user.copyWith(unlockedItems: updatedItems);
    await saveUser(updatedUser);
  }

  /// Equips an inventory item in a specific slot (e.g. 'head', 'hand') for the active user.
  Future<void> equipItem(String slot, String itemId) async {
    final user = state.activeUser;
    if (user == null) return;

    final updatedEquipped = Map<String, String>.from(user.equippedItems);
    updatedEquipped[slot] = itemId;
    final updatedUser = user.copyWith(equippedItems: updatedEquipped);
    await saveUser(updatedUser);
  }

  /// Unequips any item in the specified slot for the active user.
  Future<void> unequipItem(String slot) async {
    final user = state.activeUser;
    if (user == null) return;

    final updatedEquipped = Map<String, String>.from(user.equippedItems);
    updatedEquipped.remove(slot);
    final updatedUser = user.copyWith(equippedItems: updatedEquipped);
    await saveUser(updatedUser);
  }

  /// Saves the custom drag-and-drop position and transformation for an item.
  Future<void> setCustomItemOffset(
    String itemSlug,
    double dx,
    double dy, {
    double scale = 1.0,
    double rotation = 0.0,
  }) async {
    final user = state.activeUser;
    if (user == null) return;

    final updatedOffsets = Map<String, String>.from(user.customItemOffsets);
    updatedOffsets[itemSlug] = 'n,$dx,$dy,$scale,$rotation';
    final updatedUser = user.copyWith(customItemOffsets: updatedOffsets);

    // Optimistisk uppdatering: uppdatera state direkt så UI inte snäpper
    // tillbaka innan den långsamma async-kedjan i saveUser hinner färdigt.
    state = state.copyWith(activeUser: updatedUser);

    await saveUser(updatedUser);
  }

  /// Clears all custom item offsets (resets to defaults).
  Future<void> clearCustomItemOffsets() async {
    final user = state.activeUser;
    if (user == null) return;

    final updatedUser = user.copyWith(customItemOffsets: const {});
    await saveUser(updatedUser);
  }

  Future<void> applyQuizResult(QuizSession session) async {
    final user = state.activeUser;
    if (user == null) {
      return;
    }

    QuestCompletionEvent? questCompletion;

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
      user: user.copyWith(
        currentStreak: updatedStreak,
      ),
      session: session,
    );

    final updatedAchievements = [
      ...user.achievements,
      ...reward.unlockedIds.where((id) => !user.achievements.contains(id)),
    ];

    // Merge updated difficulty steps from the session into user profile,
    // preserving steps for operations not played in this session.
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

    await _reconcileQuestPointer(user);
    final completedQuestIds = _readCompletedQuestIds(user.userId);
    final currentQuestId = _readCurrentQuestId(user.userId) ??
        _questProgressionService.firstQuestId(
          user,
          allowedOperations: _effectiveAllowedOperationsFor(user),
        );

    final beforeQuestStatus = _getQuestStatusWith(
      user: updatedUser,
      currentQuestId: currentQuestId,
      completedQuestIds: completedQuestIds,
    );

    final allowedOps = _effectiveAllowedOperationsFor(updatedUser);

    // If current quest is completed, mark it done and advance.
    if (beforeQuestStatus.isCompleted &&
        !completedQuestIds.contains(beforeQuestStatus.quest.id)) {
      final updatedCompleted = {
        ...completedQuestIds,
        beforeQuestStatus.quest.id,
      };
      final nextId = _questProgressionService.nextQuestId(
        user: updatedUser,
        currentQuestId: beforeQuestStatus.quest.id,
        allowedOperations: allowedOps,
      );
      await _setQuestState(
        userId: user.userId,
        currentQuestId: nextId ?? beforeQuestStatus.quest.id,
        completedQuestIds: updatedCompleted,
      );
      questCompletion = QuestCompletionEvent(
        completedQuestId: beforeQuestStatus.quest.id,
        completedQuestTitle: beforeQuestStatus.quest.title,
        completedQuestDescription: beforeQuestStatus.quest.description,
      );
    }

    // If grade/age-group changed earlier, ensure the quest pointer still
    // matches the user's current path.
    await _reconcileQuestPointer(updatedUser);

    final questStatus = _getQuestStatus(updatedUser);

    // Save a lightweight quiz history record (for parent/teacher dashboard).
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

    // Remove any leftover in-progress record so benchmark underlag doesn't
    // double-count the finished session.
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
    await loadUsers();
    _syncAudioSettings(finalUser);

    final resolvedQuestCompletion = questCompletion == null
        ? null
        : QuestCompletionEvent(
            completedQuestId: questCompletion.completedQuestId,
            completedQuestTitle: questCompletion.completedQuestTitle,
            completedQuestDescription:
                questCompletion.completedQuestDescription,
            nextQuestTitle:
                questStatus.quest.id == questCompletion.completedQuestId
                    ? null
                    : questStatus.quest.title,
          );

    state = state.copyWith(
      activeUser: finalUser,
      lastReward: reward,
      lastQuestCompletion: resolvedQuestCompletion,
      lastLevelUp: finalUser.level > oldLevel
          ? LevelUpEvent(
              oldLevel: oldLevel,
              newLevel: finalUser.level,
              newTitle: finalUser.levelTitle,
            )
          : null,
      questStatus: questStatus,
      newlyUnlockedItem: newlyUnlockedItem,
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

    if (difference == 0) return currentStreak; // Same day
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

// endregion

// region Provider Definition

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(localStorageRepositoryProvider);
  final achievementService = ref.watch(achievementServiceProvider);
  final audioService = ref.watch(audioServiceProvider);
  final questProgressionService = ref.watch(questProgressionServiceProvider);
  return UserNotifier(
    repository,
    achievementService,
    audioService,
    questProgressionService,
  );
});

// endregion
