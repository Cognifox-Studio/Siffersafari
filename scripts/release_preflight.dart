// One-command release preflight, cross-platform.
//
// Usage:
//   dart run scripts/release_preflight.dart
//
// Exits non-zero on the first failure. This is a drop-in replacement for
// scripts/release_preflight.ps1 (kept for Windows muscle memory), so macOS and
// Linux contributors have the same gate without a PowerShell install.

import 'dart:io';

const int _maxApkBytes = 80 * 1024 * 1024;

Future<void> main() async {
  exitCode = await _run();
}

Future<int> _run() async {
  final repoRoot = _repoRoot();
  Directory.current = repoRoot;

  _step('pubspec version');
  final version = _readVersion();
  if (version == null) {
    stderr.writeln('Could not read version from pubspec.yaml');
    return 1;
  }
  stdout.writeln('version: $version');

  _step('flutter pub get');
  if (!await _runCommand(_flutter, const ['pub', 'get'])) return 1;

  _step('flutter analyze lib test');
  if (!await _runCommand(_flutter, const ['analyze', 'lib', 'test'])) return 1;

  _step('fast release unit tests');
  final ok = await _runCommand(_flutter, const [
    'test',
    'test/unit/logic/spaced_repetition_test.dart',
    'test/unit/logic/quiz_provider_srs_test.dart',
    'test/unit/audits/question_bank_runtime_status_audit_test.dart',
  ]);
  if (!ok) return 1;

  _step('debug APK size budget (80 MiB)');
  if (!await _runCommand(_flutter, const ['build', 'apk', '--debug'])) return 1;

  final apk = File('build/app/outputs/flutter-apk/app-debug.apk');
  if (!apk.existsSync()) {
    stderr.writeln('Missing APK at ${apk.path}');
    return 1;
  }

  final size = apk.lengthSync();
  stdout.writeln('APK size: $size bytes (max $_maxApkBytes)');
  if (size > _maxApkBytes) {
    stderr.writeln('APK exceeds budget ($_maxApkBytes bytes)');
    return 1;
  }

  stdout.writeln('Preflight OK for $version');
  return 0;
}

String get _flutter => Platform.isWindows ? 'flutter.bat' : 'flutter';

Directory _repoRoot() {
  // `Platform.script` points at this file for `dart run scripts/<file>.dart`.
  final scriptUri = Platform.script;
  if (scriptUri.scheme == 'file') {
    final scriptFile = File.fromUri(scriptUri);
    if (scriptFile.existsSync()) {
      return scriptFile.parent.parent;
    }
  }
  return Directory.current;
}

String? _readVersion() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) return null;

  final match = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true)
      .firstMatch(pubspec.readAsStringSync());
  return match?.group(1);
}

void _step(String label) {
  stdout.writeln('== $label ==');
}

Future<bool> _runCommand(String executable, List<String> arguments) async {
  try {
    final process = await Process.start(
      executable,
      arguments,
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    return await process.exitCode == 0;
  } on ProcessException catch (e) {
    stderr.writeln('Failed to run `$executable`: ${e.message}');
    return false;
  }
}
