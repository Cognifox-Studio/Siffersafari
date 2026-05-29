import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('[Unit] Modular boundaries audit', () {
    test('core och data importerar inte feature-lagret', () {
      final violations = <String>[];

      for (final file in _dartFilesUnder(['lib/core', 'lib/data'])) {
        final path = _relativePath(file.path);
        final content = file.readAsStringSync();

        if (content.contains('package:siffersafari/features/') ||
            content.contains('../features/') ||
            content.contains('../../features/')) {
          violations.add(path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Core/data ska vara återanvändbara och inte bero på features.',
      );
    });

    test('feature-till-feature-importer är explicita undantag', () {
      final violations = <String>[];

      for (final file in _dartFilesUnder(['lib/features'])) {
        final path = _relativePath(file.path);
        final sourceFeature = _featureNameForPath(path);
        if (sourceFeature == null) continue;

        for (final targetFeature
            in _importedFeatures(file.readAsStringSync())) {
          if (targetFeature == sourceFeature) continue;

          final edge = '$sourceFeature -> $targetFeature';
          if (!_allowedFeatureEdges.contains(edge)) {
            violations.add('$path imports $targetFeature');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Nya feature-korsimporter ska läggas till som avsiktliga undantag eller flyttas till core/app/shared kontrakt.',
      );
    });

    test(
        'presentation-lagret importerar inte repository eller storage-provider',
        () {
      final violations = <String>[];
      const forbiddenPatterns = [
        'package:siffersafari/core/providers/local_storage_repository_provider.dart',
        'package:siffersafari/data/repositories/',
        'LocalStorageRepository',
        'localStorageRepositoryProvider',
      ];

      for (final file
          in _dartFilesUnder(['lib/features', 'lib/presentation'])) {
        final path = _relativePath(file.path);
        if (!path.contains('/presentation/')) continue;

        final content = file.readAsStringSync();
        if (forbiddenPatterns.any(content.contains)) {
          violations.add(path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Presentation ska läsa härledd provider-state och skicka kommandon, inte prata direkt med storage.',
      );
    });

    test('parameteriserade Riverpod-providers använder autoDispose', () {
      final violations = <String>[];
      const rawFamilyPatterns = [
        'StateNotifierProvider.family',
        'Provider.family',
        'FutureProvider.family',
        'StreamProvider.family',
      ];

      for (final file in _dartFilesUnder(['lib'])) {
        final path = _relativePath(file.path);
        final content = file.readAsStringSync();

        if (rawFamilyPatterns.any(content.contains)) {
          violations.add(path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'User-/parameter-scopeade providers ska inte leva kvar i onödan.',
      );
    });
  });
}

const _allowedFeatureEdges = {
  'home -> daily_challenge',
  'home -> inventory',
  'home -> onboarding',
  'home -> parent',
  'home -> profiles',
  'home -> quiz',
  'home -> settings',
  'home -> story',
  'onboarding -> profiles',
  'parent -> settings',
  'profiles -> home',
  'quiz -> daily_challenge',
  'quiz -> home',
  'quiz -> story',
  'settings -> profiles',
  'story -> home',
  'story -> quiz',
};

Iterable<File> _dartFilesUnder(List<String> roots) sync* {
  for (final rootPath in roots) {
    final root = Directory(rootPath);
    if (!root.existsSync()) continue;

    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        yield entity;
      }
    }
  }
}

String _relativePath(String absolutePath) {
  final normalized = absolutePath.replaceAll('\\', '/');
  final rootPath = Directory.current.path.replaceAll('\\', '/');
  return normalized.startsWith(rootPath)
      ? normalized.substring(rootPath.length + 1)
      : normalized;
}

String? _featureNameForPath(String path) {
  final match = RegExp(r'^lib/features/([^/]+)/').firstMatch(path);
  return match?.group(1);
}

Iterable<String> _importedFeatures(String content) sync* {
  final pattern = RegExp(r'package:siffersafari/features/([^/]+)/');
  for (final match in pattern.allMatches(content)) {
    yield match.group(1)!;
  }
}
