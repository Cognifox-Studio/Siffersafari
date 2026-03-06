import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/app_update_service.dart';

void main() {
  group('[Unit] AppUpdateService - version comparison', () {
    final service = AppUpdateService();

    test('detects newer stable tag than installed build', () {
      expect(service.isUpdateAvailable('1.1.0+5', 'v1.1.1'), isTrue);
    });

    test('treats same release tag as up to date', () {
      expect(service.isUpdateAvailable('1.1.0+5', 'v1.1.0'), isFalse);
    });

    test('treats prerelease as older than stable release', () {
      expect(service.isUpdateAvailable('1.1.0-beta.1', 'v1.1.0'), isTrue);
    });
  });
}
