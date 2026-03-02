import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_storage_repository.dart';
import '../config/app_features.dart';
import 'local_storage_repository_provider.dart';

String missingNumberEnabledKey(String userId) =>
    'missing_number_enabled_$userId';

class MissingNumberEnabledNotifier extends StateNotifier<bool> {
  MissingNumberEnabledNotifier(this._repository, this._userId)
      : super(_readInitialValue(repository: _repository, userId: _userId));

  final LocalStorageRepository _repository;
  final String _userId;

  static bool _readInitialValue({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    final raw = repository.getSetting(
      missingNumberEnabledKey(userId),
      defaultValue: AppFeatures.missingNumberEnabled,
    );
    return raw is bool ? raw : AppFeatures.missingNumberEnabled;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _repository.saveSetting(missingNumberEnabledKey(_userId), enabled);
  }
}

final missingNumberEnabledProvider =
    StateNotifierProvider.family<MissingNumberEnabledNotifier, bool, String>(
  (ref, userId) {
    final repository = ref.watch(localStorageRepositoryProvider);
    return MissingNumberEnabledNotifier(repository, userId);
  },
);
