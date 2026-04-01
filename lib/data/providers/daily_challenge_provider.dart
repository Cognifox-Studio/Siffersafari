import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/settings_keys.dart';
import '../../core/providers/local_storage_repository_provider.dart';
import '../../core/services/daily_challenge_service.dart';
import '../repositories/local_storage_repository.dart';

/// Provider for the pure daily challenge service (no I/O).
final dailyChallengeServiceProvider = Provider<DailyChallengeService>(
  (_) => const DailyChallengeService(),
);

/// Notifier that tracks whether today's challenge has been completed.
///
/// Scoped per-user via [dailyChallengeProvider] family.
class DailyChallengeNotifier extends StateNotifier<bool> {
  DailyChallengeNotifier({
    required DailyChallengeService service,
    required LocalStorageRepository repository,
    required String userId,
  })  : _service = service,
        _repository = repository,
        _userId = userId,
        super(false) {
    _loadCompletionStatus();
  }

  final DailyChallengeService _service;
  final LocalStorageRepository _repository;
  final String _userId;

  void _loadCompletionStatus() {
    if (_userId.isEmpty) return;
    final key =
        SettingsKeys.dailyChallengeCompletion(_userId, _service.todayKey());
    try {
      state = _repository.getSetting(key) == true;
    } catch (_) {
      state = false;
    }
  }

  Future<void> markCompleted() async {
    if (_userId.isEmpty) return;
    final key =
        SettingsKeys.dailyChallengeCompletion(_userId, _service.todayKey());
    try {
      await _repository.saveSetting(key, true);
    } catch (_) {
      // Storage unavailable – update in-memory state only.
    }
    state = true;
  }
}

/// Whether today's daily challenge is completed for [userId].
final dailyChallengeProvider =
    StateNotifierProvider.family<DailyChallengeNotifier, bool, String>(
  (ref, userId) => DailyChallengeNotifier(
    service: ref.watch(dailyChallengeServiceProvider),
    repository: ref.watch(localStorageRepositoryProvider),
    userId: userId,
  ),
);
