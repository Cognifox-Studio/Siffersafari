import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/cloud_backup_service.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] CloudBackupService – opt-in contract', () {
    late InMemoryLocalStorageRepository repository;
    late FirebaseCloudBackupService service;

    setUp(() {
      repository = InMemoryLocalStorageRepository();
      // Mirrors the wiring in lib/core/di/injection.dart.
      service = FirebaseCloudBackupService(
        () {
          final raw = repository.getSetting(SettingsKeys.cloudBackupOptInAt);
          return raw != null && raw.toString().isNotEmpty;
        },
        (optedIn) => optedIn
            ? repository.saveSetting(
                SettingsKeys.cloudBackupOptInAt,
                DateTime.now().toIso8601String(),
              )
            : repository.deleteSetting(SettingsKeys.cloudBackupOptInAt),
      );
    });

    test('är avstängt som standard', () {
      expect(service.isOptedIn, isFalse);
      expect(service.isProjectConfigured, isFalse);
      expect(service.isRuntimeReady, isFalse);
    });

    test('setOptedIn(true/false) persisterar valet', () async {
      await service.setOptedIn(true);
      expect(service.isOptedIn, isTrue);
      expect(
        repository.getSetting(SettingsKeys.cloudBackupOptInAt),
        isA<String>(),
      );

      await service.setOptedIn(false);
      expect(service.isOptedIn, isFalse);
      expect(
        repository.getSetting(SettingsKeys.cloudBackupOptInAt),
        isNull,
      );
    });

    test('ensureSignedIn vägrar utan opt-in och konfiguration', () async {
      await expectLater(service.ensureSignedIn(), throwsStateError);

      await service.setOptedIn(true);
      // Still unconfigured in the repo (firebase_options.dart is a placeholder).
      await expectLater(service.ensureSignedIn(), throwsStateError);
    });

    test('DisabledCloudBackupService gör inget anspråk på opt-in', () async {
      const disabled = DisabledCloudBackupService();

      expect(disabled.isOptedIn, isFalse);
      await expectLater(disabled.setOptedIn(true), throwsUnsupportedError);
      await expectLater(disabled.ensureSignedIn(), throwsUnsupportedError);
    });
  });
}
