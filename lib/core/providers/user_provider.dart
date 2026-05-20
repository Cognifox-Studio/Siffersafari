import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/apply_quiz_result_use_case.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/core/services/user_audio_settings_service.dart';
import 'package:siffersafari/core/services/user_quest_state_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/level_up_event.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';

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
    LocalStorageRepository repository,
    AchievementService achievementService,
    AudioService audioService,
    QuestProgressionService questProgressionService, {
    UserAudioSettingsService? userAudioSettingsService,
    UserQuestStateService? userQuestStateService,
    ApplyQuizResultUseCase? applyQuizResultUseCase,
  })  : _repository = repository,
        _audioService = audioService,
        _userAudioSettingsService = userAudioSettingsService ??
            UserAudioSettingsService(repository, audioService),
        _userQuestStateService = userQuestStateService ??
            UserQuestStateService(repository, questProgressionService),
        _applyQuizResultUseCase = applyQuizResultUseCase ??
            ApplyQuizResultUseCase(
              repository: repository,
              achievementService: achievementService,
              questStateService: userQuestStateService ??
                  UserQuestStateService(repository, questProgressionService),
            ),
        super(const UserState());

  final LocalStorageRepository _repository;
  final AudioService _audioService;
  final UserAudioSettingsService _userAudioSettingsService;
  final UserQuestStateService _userQuestStateService;
  final ApplyQuizResultUseCase _applyQuizResultUseCase;

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

      QuestStatus? questStatus;
      String? questNotice = state.questNotice;

      if (activeUser != null) {
        _userAudioSettingsService.syncAudioSettings(activeUser);
        final reconciliation =
            await _userQuestStateService.reconcileQuestPointer(activeUser);
        questStatus = reconciliation.questStatus;
        questNotice = reconciliation.questNotice ?? questNotice;
      }

      state = state.copyWith(
        allUsers: users,
        activeUser: activeUser,
        questStatus: questStatus,
        questNotice: questNotice,
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

    _userAudioSettingsService.syncAudioSettings(user);
    final reconciliation =
        await _userQuestStateService.reconcileQuestPointer(user);

    await _repository.setActiveUserId(userId);
    state = state.copyWith(
      activeUser: user,
      questStatus: reconciliation.questStatus,
      questNotice: reconciliation.questNotice ?? state.questNotice,
    );
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
    final reconciliation =
        await _userQuestStateService.reconcileQuestPointer(user);
    await loadUsers();
    _userAudioSettingsService.syncAudioSettings(user);
    state = state.copyWith(
      activeUser: user,
      questStatus: reconciliation.questStatus,
      questNotice: reconciliation.questNotice ?? state.questNotice,
    );
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

    final result = await _applyQuizResultUseCase.execute(
      user: user,
      session: session,
    );
    await loadUsers();
    _userAudioSettingsService.syncAudioSettings(result.finalUser);

    final resolvedQuestCompletion = result.questCompletion == null
        ? null
        : QuestCompletionEvent(
            completedQuestId: result.questCompletion!.completedQuestId,
            completedQuestTitle: result.questCompletion!.completedQuestTitle,
            completedQuestDescription:
                result.questCompletion!.completedQuestDescription,
            nextQuestTitle: result.questCompletion!.nextQuestTitle,
          );

    state = state.copyWith(
      activeUser: result.finalUser,
      lastReward: result.reward,
      lastQuestCompletion: resolvedQuestCompletion,
      lastLevelUp: result.levelUpEvent,
      questStatus: result.questStatus,
      questNotice: result.questNotice ?? state.questNotice,
      newlyUnlockedItem: result.newlyUnlockedItem,
    );
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
