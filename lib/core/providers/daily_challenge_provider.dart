import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/daily_challenge_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';

import 'local_storage_repository_provider.dart';

/// Provider for the pure daily challenge service (no I/O).
final dailyChallengeServiceProvider = Provider<DailyChallengeService>(
  (_) => const DailyChallengeService(),
);

/// Immutable state for the daily challenge notifier.
class DailyChallengeState {
  const DailyChallengeState({
    this.isCompleted = false,
    this.streakCount = 0,
  });

  final bool isCompleted;

  /// Number of consecutive days the user has completed the daily challenge.
  final int streakCount;
}

/// Notifier that tracks whether today's challenge has been completed
/// and the current consecutive-day streak.
///
/// Scoped per-user via [dailyChallengeProvider] family.
class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  DailyChallengeNotifier({
    required DailyChallengeService service,
    required LocalStorageRepository repository,
    required String userId,
  })  : _service = service,
        _repository = repository,
        _userId = userId,
        super(const DailyChallengeState()) {
    _loadState();
  }

  final DailyChallengeService _service;
  final LocalStorageRepository _repository;
  final String _userId;

  void _loadState() {
    if (_userId.isEmpty) return;
    final completionKey =
        SettingsKeys.dailyChallengeCompletion(_userId, _service.todayKey());
    final isCompleted = _repository.getSetting(completionKey) == true;
    final streakCount = _readPersistedStreak();
    state = DailyChallengeState(
      isCompleted: isCompleted,
      streakCount: streakCount,
    );
  }

  int _readPersistedStreak() {
    try {
      final raw =
          _repository.getSetting(SettingsKeys.dailyChallengeStreak(_userId));
      if (raw is Map) {
        return (raw['streak'] as int?) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  int _computeNewStreak(String todayKey) {
    try {
      final raw =
          _repository.getSetting(SettingsKeys.dailyChallengeStreak(_userId));
      if (raw is Map) {
        final lastDate = raw['lastDate'] as String?;
        final count = (raw['streak'] as int?) ?? 0;
        if (lastDate == todayKey) {
          // Already completed today – preserve current streak count.
          return count;
        }
        if (lastDate == _yesterdayKey()) {
          // Consecutive day – increment streak.
          return count + 1;
        }
      }
    } catch (_) {}
    // No prior data or gap > 1 day – start a streak of 1.
    return 1;
  }

  String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-'
        '${yesterday.month.toString().padLeft(2, '0')}-'
        '${yesterday.day.toString().padLeft(2, '0')}';
  }

  Future<void> markCompleted() async {
    if (_userId.isEmpty) return;
    final todayKey = _service.todayKey();
    final completionKey =
        SettingsKeys.dailyChallengeCompletion(_userId, todayKey);

    // Only recalculate streak if not already marked done today.
    final newStreak =
        state.isCompleted ? state.streakCount : _computeNewStreak(todayKey);

    try {
      await _repository.saveSetting(completionKey, true);
      await _repository.saveSetting(
        SettingsKeys.dailyChallengeStreak(_userId),
        {'streak': newStreak, 'lastDate': todayKey},
      );
    } catch (_) {
      // Storage unavailable – update in-memory state only.
    }

    state = DailyChallengeState(isCompleted: true, streakCount: newStreak);
  }
}

/// Daily challenge state (completion + streak) for [userId].
final dailyChallengeProvider = StateNotifierProvider.family<
    DailyChallengeNotifier, DailyChallengeState, String>(
  (ref, userId) => DailyChallengeNotifier(
    service: ref.watch(dailyChallengeServiceProvider),
    repository: ref.watch(localStorageRepositoryProvider),
    userId: userId,
  ),
);
