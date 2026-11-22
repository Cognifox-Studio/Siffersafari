import 'package:flutter_test/flutter_test.dart';
import '../../test_utils.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/domain/services/parent_pin_service.dart';

void main() {
  group('[Unit] ParentPinService – PIN authentication', () {
    test('verifyPin returns false when no PIN is set', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      final isCorrect = await service.verifyPin('1234');
      expect(isCorrect, isFalse);
    });

    test('setPin + verifyPin accepts correct PIN and resets attempts',
        () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      await service.setPin('1234');

      final wrong = await service.verifyPin('0000');
      expect(wrong, isFalse);
      expect(service.getRemainingAttempts(), 4);

      final ok = await service.verifyPin('1234');
      expect(ok, isTrue);
      expect(service.getRemainingAttempts(), 5);
    });

    test('wrong PIN triggers lockout after 5 attempts', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      await service.setPin('1234');

      for (var i = 0; i < 4; i++) {
        final ok = await service.verifyPin('0000');
        expect(ok, isFalse);
      }

      await expectLater(
        () => service.verifyPin('0000'),
        throwsA(
          isA<PinLockoutException>().having(
            (e) => e.remainingMinutes,
            'remainingMinutes',
            5,
          ),
        ),
      );

      await expectLater(
        () => service.verifyPin('1234'),
        throwsA(
          isA<PinLockoutException>().having(
            (e) => e.remainingMinutes,
            'remainingMinutes',
            inInclusiveRange(1, 5),
          ),
        ),
      );
    });

    test('expired lockout is cleared on next verification', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      await service.setPin('1234');

      // Simulate a past lockout.
      await storage.saveSetting(
        SettingsKeys.parentPinLockoutUntil,
        DateTime.now()
            .subtract(const Duration(seconds: 1))
            .millisecondsSinceEpoch,
      );
      await storage.saveSetting(SettingsKeys.parentPinFailedAttempts, 5);

      final ok = await service.verifyPin('0000');
      expect(ok, isFalse);

      // Lockout cleared, attempts reset then incremented to 1 for the wrong try.
      expect(service.getRemainingAttempts(), 4);
      expect(service.getLockoutRemainingMinutes(), isNull);
    });
  });

  group('[Unit] ParentPinService – Security question recovery', () {
    test('setupPinRecovery stores security question + hashed answer', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      await service.setupPinRecovery(
        securityQuestion: 'Q',
        securityAnswer: 'My Answer',
      );

      expect(service.hasRecoveryConfigured(), isTrue);
      expect(service.getSecurityQuestion(), 'Q');

      final raw = storage.getSetting(SettingsKeys.parentPinRecoveryConfig);
      expect(raw, isA<Map>());
      final rawMap = raw as Map;
      expect(rawMap['securityQuestion'], 'Q');
      final hash = rawMap['securityAnswerHash'] as String;
      expect(hash.isNotEmpty, isTrue);
      expect(hash, isNot('my answer'));
    });

    test('verifySecurityAnswer is case-insensitive', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      await service.setupPinRecovery(
        securityQuestion: 'Q',
        securityAnswer: 'My Answer',
      );

      final correct = await service.verifySecurityAnswer('MY ANSWER');
      expect(correct, isTrue);

      final wrong = await service.verifySecurityAnswer('fel svar');
      expect(wrong, isFalse);
    });

    test('clearRecoveryConfig removes config', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);

      await service.setupPinRecovery(
        securityQuestion: 'Q',
        securityAnswer: 'My Answer',
      );

      expect(service.hasRecoveryConfigured(), isTrue);
      await service.clearRecoveryConfig();
      expect(service.hasRecoveryConfigured(), isFalse);
    });
  });

  group('[Unit] ParentPinService – Security answer rate limiting', () {
    Future<ParentPinService> serviceWithRecovery() async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);
      await service.setPin('1234');
      await service.setupPinRecovery(
        securityQuestion: 'Favoritdjur?',
        securityAnswer: 'Hund',
      );
      return service;
    }

    test('rätt svar nollställer antalet försök', () async {
      final service = await serviceWithRecovery();

      expect(await service.verifySecurityAnswer('katt'), isFalse);
      expect(service.getRemainingSecurityAnswerAttempts(), 4);

      expect(await service.verifySecurityAnswer('hund'), isTrue);
      expect(service.getRemainingSecurityAnswerAttempts(), 5);
    });

    test('fem felaktiga svar låser säkerhetsfrågan', () async {
      final service = await serviceWithRecovery();

      for (var i = 0; i < 4; i++) {
        expect(await service.verifySecurityAnswer('katt'), isFalse);
      }

      await expectLater(
        () => service.verifySecurityAnswer('katt'),
        throwsA(isA<PinLockoutException>()),
      );

      // Even the correct answer is rejected while locked out — otherwise the
      // lockout would not actually gate recovery.
      await expectLater(
        () => service.verifySecurityAnswer('hund'),
        throwsA(isA<PinLockoutException>()),
      );

      expect(service.getSecurityAnswerLockoutRemainingMinutes(), isNotNull);
      expect(service.getRemainingSecurityAnswerAttempts(), 0);
    });

    test('utgången låsning rensas vid nästa försök', () async {
      final storage = InMemoryLocalStorageRepository();
      final service = ParentPinService(storage);
      await service.setPin('1234');
      await service.setupPinRecovery(
        securityQuestion: 'Favoritdjur?',
        securityAnswer: 'Hund',
      );

      await storage.saveSetting(
        SettingsKeys.parentSecurityAnswerLockoutUntil,
        DateTime.now().subtract(const Duration(seconds: 1)).millisecondsSinceEpoch,
      );
      await storage.saveSetting(
        SettingsKeys.parentSecurityAnswerFailedAttempts,
        5,
      );

      expect(await service.verifySecurityAnswer('katt'), isFalse);
      expect(service.getSecurityAnswerLockoutRemainingMinutes(), isNull);
      expect(service.getRemainingSecurityAnswerAttempts(), 4);
    });

    test('säkerhetsfrågan delar inte räknare med PIN-låsningen', () async {
      final service = await serviceWithRecovery();

      // Burn the PIN counter without tripping its lockout.
      for (var i = 0; i < 4; i++) {
        expect(await service.verifyPin('0000'), isFalse);
      }

      // Recovery is still available and unaffected.
      expect(service.getRemainingSecurityAnswerAttempts(), 5);
      expect(await service.verifySecurityAnswer('hund'), isTrue);
      expect(service.getLockoutRemainingMinutes(), isNull);
    });
  });
}
