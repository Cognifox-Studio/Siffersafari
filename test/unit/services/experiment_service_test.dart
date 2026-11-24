import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/experiment_service.dart';
import 'package:siffersafari/domain/services/experiment.dart';

import '../../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
    await repository.clearAllData();
  });

  group('[Unit] Experimenthake i settings', () {
    test('varianten bestäms en gång och ligger kvar', () {
      final service = ExperimentService(repository);

      final first = service.variantFor(
        userId: 'signe',
        experiment: Experiments.weeklyQuest,
      );
      final second = service.variantFor(
        userId: 'signe',
        experiment: Experiments.weeklyQuest,
      );

      expect(first.isNew, isTrue);
      expect(second.isNew, isFalse);
      expect(second.variant, first.variant);
      expect(
        repository.getSetting(
          SettingsKeys.experiment('signe', Experiments.weeklyQuest),
        ),
        first.variant,
      );
    });

    test('en lagrad variant vinner över hashen', () {
      final service = ExperimentService(repository);
      final assigned = service.variantFor(
        userId: 'signe',
        experiment: Experiments.weeklyQuest,
      ).variant;
      final flipped = assigned == 'on' ? 'off' : 'on';

      repository.saveSetting(
        SettingsKeys.experiment('signe', Experiments.weeklyQuest),
        flipped,
      );

      expect(
        service.variantFor(
          userId: 'signe',
          experiment: Experiments.weeklyQuest,
        ).variant,
        flipped,
      );
    });

    test('barnets variant följer inte med till ett syskon', () {
      final service = ExperimentService(repository);

      final signe = service.assignmentsFor('signe');
      final astrid = service.assignmentsFor('astrid');

      expect(signe.keys.toSet(), Experiments.all.keys.toSet());
      expect(astrid.keys.toSet(), Experiments.all.keys.toSet());
      expect(
        repository.getSetting(
          SettingsKeys.experiment('astrid', Experiments.weeklyQuest),
        ),
        astrid[Experiments.weeklyQuest],
      );
    });

    test('experimentnyckeln städas med profilen', () {
      final key = SettingsKeys.experiment('signe', Experiments.weeklyQuest);

      expect(SettingsKeys.isUserScopedKey('signe', key), isTrue);
      expect(SettingsKeys.isUserScopedKey('astrid', key), isFalse);
    });
  });
}
