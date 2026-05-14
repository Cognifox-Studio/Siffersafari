import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/tts_enabled_provider.dart';

import '../../test_utils.dart';

void main() {
  test(
    '[Unit] TtsEnabledNotifier – sparar uppläsning per profil',
    () async {
      final repository = InMemoryLocalStorageRepository();

      final container = ProviderContainer(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(ttsEnabledProvider('u1')), isFalse);

      await container.read(ttsEnabledProvider('u1').notifier).setEnabled(true);

      expect(container.read(ttsEnabledProvider('u1')), isTrue);
      expect(
        repository.getSetting(SettingsKeys.textToSpeechEnabled('u1')),
        isTrue,
      );
    },
  );
}
