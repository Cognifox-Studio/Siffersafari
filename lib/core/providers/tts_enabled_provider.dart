import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';

import 'local_storage_repository_provider.dart';

class TtsEnabledNotifier extends StateNotifier<bool> {
  TtsEnabledNotifier(this._repository, this._userId)
      : super(
          QuizFeatureSettings.readTextToSpeechEnabled(
            repository: _repository,
            userId: _userId,
          ),
        );

  final LocalStorageRepository _repository;
  final String _userId;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await QuizFeatureSettings.saveTextToSpeechEnabled(
      repository: _repository,
      userId: _userId,
      enabled: enabled,
    );
  }
}

final ttsEnabledProvider =
    StateNotifierProvider.family<TtsEnabledNotifier, bool, String>(
  (ref, userId) {
    final repository = ref.watch(localStorageRepositoryProvider);
    return TtsEnabledNotifier(repository, userId);
  },
);
