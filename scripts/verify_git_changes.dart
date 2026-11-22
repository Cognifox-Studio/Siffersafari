// Review the working tree before committing or cutting a release.
//
// Usage:
//   dart run scripts/verify_git_changes.dart
//
// Shows staged/unstaged/untracked changes and flags likely-accidental commits
// (generated previews under artifacts/). Cross-platform replacement for
// scripts/verify_git_changes.ps1, which needed PowerShell 5.1.

import 'dart:io';

Future<void> main() async {
  final staged = _gitLines(const ['diff', '--cached', '--name-status']);
  final stagedNames = _gitLines(const ['diff', '--cached', '--name-only']);
  final unstaged = _gitLines(const ['diff', '--name-status']);
  final unstagedNames = _gitLines(const ['diff', '--name-only']);
  final untracked = _gitLines(const [
    'ls-files',
    '--others',
    '--exclude-standard',
  ]);

  _header('Git status report');

  stdout.writeln('\nStaged changes:');
  _printAll(staged);

  stdout.writeln('\nUnstaged changes:');
  _printAll(unstaged);

  stdout.writeln('\nUntracked files:');
  _printAll(untracked);

  final touched = <String>{...stagedNames, ...unstagedNames};
  final warnings = _scanTouchedFiles(touched);

  stdout.writeln('\nSummary');
  stdout.writeln('=' * 80);
  stdout.writeln('  Staged:   ${stagedNames.length} file(s)');
  stdout.writeln('  Unstaged: ${unstagedNames.length} file(s)');

  if (warnings.isEmpty) {
    stdout.writeln('\n  All changes look good!');
  } else {
    stdout.writeln('\n  Check these before committing:');
    for (final warning in warnings) {
      stdout.writeln('  $warning');
    }
    stdout.writeln('\n  Use: git restore --staged <file>');
    stdout.writeln('   or: git reset HEAD <file>');
  }

  if (stagedNames.isNotEmpty && unstagedNames.isEmpty) {
    stdout.writeln('\n  Ready to commit: git commit -m "<message>"');
  } else if (stagedNames.isEmpty && unstagedNames.isNotEmpty) {
    stdout.writeln('\n  Unstaged changes - review and stage if needed: git add <file>');
  } else if (stagedNames.isEmpty && unstagedNames.isEmpty) {
    stdout.writeln('\n  No changes to commit.');
  }
}

List<String> _scanTouchedFiles(Set<String> touched) {
  final warnings = <String>[];

  // artifacts/ holds local UI dumps and previews; they should not be committed.
  final artifactChanges = touched
      .where((path) =>
          path.startsWith('artifacts/') &&
          path != 'artifacts/asset_pipeline_manifest.json')
      .toList()
    ..sort();

  if (artifactChanges.isNotEmpty) {
    warnings.add('artifacts/ should not be committed (local preview only):');
    for (final path in artifactChanges) {
      warnings.add('  -> $path');
    }
  }

  final codegen = touched.where((path) => path == 'lib/gen/assets.g.dart');
  if (codegen.isNotEmpty) {
    stdout.writeln('\n  [OK] lib/gen/assets.g.dart (auto-generated, OK)');
  }

  final runtimeAssets = touched
      .where((path) =>
          path.startsWith('assets/characters/') ||
          path.startsWith('assets/images/') ||
          path.startsWith('assets/sounds/'))
      .toList()
    ..sort();

  if (runtimeAssets.isNotEmpty) {
    stdout.writeln('\n  [OK] assets/* (runtime assets, OK)');
    for (final path in runtimeAssets) {
      stdout.writeln('    $path');
    }
  }

  return warnings;
}

void _header(String label) {
  stdout.writeln(label);
  stdout.writeln('=' * 80);
}

void _printAll(List<String> lines) {
  if (lines.isEmpty) {
    stdout.writeln('  (none)');
    return;
  }
  for (final line in lines) {
    stdout.writeln('  $line');
  }
}

/// Runs git and returns its non-empty output lines. Never throws: a missing
/// repo or git binary yields an empty list plus a note on stderr.
List<String> _gitLines(List<String> arguments) {
  try {
    final result = Process.runSync(
      'git',
      arguments,
      stdoutEncoding: const SystemEncoding(),
      runInShell: Platform.isWindows,
    );

    if (result.exitCode != 0) {
      final err = result.stderr.toString().trim();
      if (err.isNotEmpty) stderr.writeln('git ${arguments.join(' ')}: $err');
      return const [];
    }

    return result.stdout
        .toString()
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.isNotEmpty)
        .toList();
  } on ProcessException catch (e) {
    stderr.writeln('Failed to run git: ${e.message}');
    return const [];
  }
}
