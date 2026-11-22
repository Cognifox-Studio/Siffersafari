import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Network-capable packages that are deliberately allowed.
///
/// Keep this list short and justify every entry. Adding an entry here is the
/// moment to also update `docs/PRIVACY_POLICY.md`, `site/privacy-policy/` and
/// the Play data-safety declaration.
const Set<String> _allowedNetworkPackages = <String>{
  // Bundled for the opt-in cloud-backup scaffold (docs/FIREBASE_CLOUD_BACKUP.md).
  // Inert until `lib/firebase_options.dart` is configured; core gameplay never
  // touches it.
  'firebase_core',
};

/// Packages that would break the offline-only promise of the core experience.
///
/// This replaces the previous "grep lib/ for http" approach, which happily
/// passed while `firebase_auth` and `cloud_firestore` sat in `pubspec.yaml`.
const Set<String> _forbiddenPackages = <String>{
  'amplitude_flutter',
  'cloud_firestore',
  'dio',
  'facebook_app_events',
  'firebase_analytics',
  'firebase_auth',
  'firebase_crashlytics',
  'flutter_facebook_auth',
  'google_mobile_ads',
  'google_sign_in',
  'graphql_flutter',
  'http',
  'mixpanel_flutter',
  'sentry_flutter',
  'socket_io_client',
  'web_socket_channel',
};

/// Direct networking APIs that must not appear in `lib/`.
final List<RegExp> _forbiddenCodePatterns = <RegExp>[
  RegExp(r'package:http/'),
  RegExp(r'package:dio/'),
  RegExp(r'\bHttpClient\s*\('),
  RegExp(r'\bWebSocket\s*\('),
  RegExp(r'\bRawDatagramSocket\b'),
  RegExp(r'\bSocketException\b'),
  RegExp(r'\bInternetAddress\b'),
];

/// Hardcoded endpoints. Checked only outside comments, so documentation may
/// still link to URLs.
final RegExp _urlPattern = RegExp(r'https?://');

void main() {
  group('[Unit] Offline requirements – Audit', () {
    test('pubspec har inga natverkspaket utanfor allowlist', () {
      final declared = _dependenciesFromPubspec();
      expect(
        declared,
        isNotEmpty,
        reason: 'Kunde inte lasa dependencies fran pubspec.yaml',
      );

      final forbidden = declared.intersection(_forbiddenPackages);
      expect(
        forbidden,
        isEmpty,
        reason:
            'Offline-first policy broken: ${forbidden.join(', ')} ar ett '
            'natverkspaket. Lagg tillbaka det bara tillsammans med en '
            'integritetsgenomgang (docs/PRIVACY_POLICY.md + site/privacy-policy/).',
      );

      expect(
        _allowedNetworkPackages.intersection(_forbiddenPackages),
        isEmpty,
        reason: 'Ett paket kan inte vara bade allowlistat och forbjudet.',
      );
    });

    test('lib/ innehaller inga tydliga natverksanrop', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final violations = <String>[];
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final path = file.path.replaceAll('\\', '/');
        final lines = file.readAsLinesSync();

        for (var index = 0; index < lines.length; index++) {
          final line = lines[index];
          final lineNumber = index + 1;

          for (final pattern in _forbiddenCodePatterns) {
            if (pattern.hasMatch(line)) {
              violations.add('$path:$lineNumber -> ${pattern.pattern}');
            }
          }

          // Comments may reference URLs; only real code may not.
          if (_isComment(line)) continue;
          if (_urlPattern.hasMatch(line)) {
            violations.add('$path:$lineNumber -> hardkodad URL');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Offline-first policy broken. Found forbidden patterns: '
            '${violations.join(', ')}',
      );
    });
  });
}

bool _isComment(String line) {
  final trimmed = line.trimLeft();
  return trimmed.startsWith('//') || trimmed.startsWith('///');
}

/// Reads the top-level `dependencies:` keys from `pubspec.yaml`.
///
/// Implemented as a tiny textual scan so the audit does not need `package:yaml`
/// as a dev dependency.
Set<String> _dependenciesFromPubspec() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) return <String>{};

  final names = <String>{};
  var insideDependencies = false;

  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.replaceAll('\t', '  ');
    if (line.trim().isEmpty) continue;

    final indent = line.length - line.trimLeft().length;

    if (indent == 0) {
      insideDependencies = line.trimRight() == 'dependencies:';
      continue;
    }

    if (!insideDependencies) continue;

    // Top-level dependency entries sit at two spaces: `  http: ^1.2.0`
    if (indent != 2) continue;

    final match = RegExp(r'^([A-Za-z0-9_]+):').firstMatch(line.trimLeft());
    if (match != null) names.add(match.group(1)!);
  }

  return names;
}
