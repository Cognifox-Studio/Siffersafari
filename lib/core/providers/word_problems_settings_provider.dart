import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_storage_repository.dart';
import '../config/app_features.dart';
import 'local_storage_repository_provider.dart';

String wordProblemsEnabledKey(String userId) => 'word_problems_enabled_$userId';

class WordProblemsEnabledNotifier extends StateNotifier<bool> {
  WordProblemsEnabledNotifier(this._repository, this._userId)
      : super(_readInitialValue(repository: _repository, userId: _userId));

  final LocalStorageRepository _repository;
  final String _userId;

  static bool _defaultValue({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    final user = repository.getUserProgress(userId);
    if (user?.gradeLevel == 1) return false;
    return AppFeatures.wordProblemsEnabled;
  }

  static bool _readInitialValue({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    final fallback = _defaultValue(repository: repository, userId: userId);
    final raw = repository.getSetting(
      wordProblemsEnabledKey(userId),
      defaultValue: fallback,
    );
    return raw is bool ? raw : fallback;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _repository.saveSetting(wordProblemsEnabledKey(_userId), enabled);
  }
}

final wordProblemsEnabledProvider =
    StateNotifierProvider.family<WordProblemsEnabledNotifier, bool, String>(
  (ref, userId) {
    final repository = ref.watch(localStorageRepositoryProvider);
    return WordProblemsEnabledNotifier(repository, userId);
  },
);
