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

  group('[Unit] AppUpdateService - checksum parsing', () {
    final service = AppUpdateService();

    test('extracts first checksum when no filename is provided', () {
      const content =
          'f2ca1bb6c7e907d06dafe4687e579fce9f6f6d3dba95f4ce37c3f8f3f7fca8af  app-release.apk';

      expect(
        service.extractSha256FromText(content),
        'f2ca1bb6c7e907d06dafe4687e579fce9f6f6d3dba95f4ce37c3f8f3f7fca8af',
      );
    });

    test('prefers checksum line matching apk filename', () {
      const content = '''
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  other.apk
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb  app-release.apk
''';

      expect(
        service.extractSha256FromText(content, apkFileName: 'app-release.apk'),
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      );
    });

    test('returns null when no sha256 hash exists', () {
      const content = 'this file has no checksum at all';
      expect(service.extractSha256FromText(content), isNull);
    });
  });
}
