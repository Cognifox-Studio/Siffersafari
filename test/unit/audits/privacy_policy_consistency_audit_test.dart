import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Siffersafari publishes its privacy policy twice: as Markdown in `docs/` and
/// as a static page under `site/` (deployed by privacy-policy-pages.yml). The
/// two drifted once — the published page claimed "no Firebase" and "no network
/// transmission" while the app was adding an opt-in Firebase backup — so this
/// audit pins the claims that must agree.
void main() {
  group('[Unit] Privacy policy consistency – Audit', () {
    final markdown = File('docs/PRIVACY_POLICY.md');
    final published = File('site/privacy-policy/index.html');

    test('bada policy-filerna finns', () {
      expect(markdown.existsSync(), isTrue, reason: markdown.path);
      expect(published.existsSync(), isTrue, reason: published.path);
    });

    test('bada namner den opt-in-baserade molnbackupen', () {
      for (final file in [markdown, published]) {
        final content = file.readAsStringSync();
        expect(
          content.contains('Firebase'),
          isTrue,
          reason:
              '${file.path} maste beskriva den valfria Firebase-backupen. '
              'Publiceras en policy utan det lovar appen mer an den gor.',
        );
        expect(
          content.toLowerCase().contains('cloud backup') ||
              content.toLowerCase().contains('molnbackup'),
          isTrue,
          reason: '${file.path} maste namna cloud backup / molnbackup.',
        );
      }
    });

    test('bada namner BCrypt for PIN-hashning', () {
      for (final file in [markdown, published]) {
        expect(
          file.readAsStringSync().contains('BCrypt'),
          isTrue,
          reason: '${file.path} maste behalla PIN-sakerhetsformuleringen.',
        );
      }
    });

    test('ingen policy lovar total natverksfrihet', () {
      const forbiddenAbsoluteClaims = <String>[
        // The exact sentence that contradicted the Firebase work.
        'No analytics platforms such as Google Analytics, Firebase, or Mixpanel',
        'No network transmission is used for profile or progress data',
        // False: the Hive boxes are not encrypted (no HiveAesCipher anywhere).
        'Hive encrypted box',
      ];

      for (final file in [markdown, published]) {
        final content = file.readAsStringSync();
        for (final claim in forbiddenAbsoluteClaims) {
          expect(
            content.contains(claim),
            isFalse,
            reason: '${file.path} innehaller en osann/absolut formulering: "$claim"',
          );
        }
      }
    });
  });
}
