import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/parent_settings_provider.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import '../../test_utils.dart';

void main() {
  test(
    '[Unit] ParentSettingsNotifier – isolerar tillåtna räknesätt per profil',
    () async {
      final repository = InMemoryLocalStorageRepository();

      final container = ProviderContainer(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(parentSettingsProvider('u1').notifier)
          .setAllowedOperations({
        OperationType.addition,
        OperationType.division,
      });
      await container
          .read(parentSettingsProvider('u2').notifier)
          .setAllowedOperations({OperationType.multiplication});

      expect(
        container.read(parentSettingsProvider('u1')),
        {OperationType.addition, OperationType.division},
      );
      expect(
        container.read(parentSettingsProvider('u2')),
        {OperationType.multiplication},
      );
      expect(
        repository.getAllowedOperationNames('u1'),
        ['addition', 'division'],
      );
      expect(
        repository.getAllowedOperationNames('u2'),
        ['multiplication'],
      );
    },
  );

  test(
    '[Unit] ParentSettingsNotifier – laddar sparade val för rätt userId',
    () async {
      final repository = InMemoryLocalStorageRepository();
      await repository.saveSetting('allowed_ops_u1', ['subtraction']);
      await repository.saveSetting('allowed_ops_u2', ['division']);

      final container = ProviderContainer(
        overrides: [
          localStorageRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(parentSettingsProvider('u1')), {
        OperationType.subtraction,
      });
      expect(container.read(parentSettingsProvider('u2')), {
        OperationType.division,
      });
    },
  );
}
