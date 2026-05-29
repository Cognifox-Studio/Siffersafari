import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';

void main() {
  group('[Unit] SettingsKeys registry audit', () {
    test('alla samplade user-nycklar känns igen som user-scope', () {
      const userId = 'u1';

      for (final key in SettingsKeys.userScopedSampleKeys(userId)) {
        expect(
          SettingsKeys.isUserScopedKey(userId, key),
          isTrue,
          reason: '$key ska rensas när användaren tas bort',
        );
      }
    });

    test('globala nycklar räknas inte som user-scope', () {
      for (final key in SettingsKeys.globalKeys()) {
        expect(SettingsKeys.isUserScopedKey('u1', key), isFalse);
      }
    });

    test('andra användares nycklar matchar inte fel user', () {
      final otherUserKeys = SettingsKeys.userScopedSampleKeys('u2');

      for (final key in otherUserKeys) {
        expect(SettingsKeys.isUserScopedKey('u1', key), isFalse);
      }
    });
  });
}
