import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Naming structure audit', () {
    test('[Unit] NamingStructureAudit – retired paths stay retired', () {
      final violations = <String>[];

      for (final file in _collectAuditFiles()) {
        final relativePath = _relativePath(file.path);
        final content = file.readAsStringSync();

        for (final pattern in _retiredPatterns) {
          if (content.contains(pattern)) {
            violations.add('$relativePath -> $pattern');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Retired names or paths hittades i aktiva filer:\n${violations.join('\n')}',
      );
    });

    test('[Unit] NamingStructureAudit – canonical files exist', () {
      for (final path in _canonicalPaths) {
        expect(
          File(path).existsSync(),
          isTrue,
          reason: 'Saknad kanonisk fil: $path',
        );
      }
    });
  });
}

Iterable<File> _collectAuditFiles() sync* {
  final root = Directory.current;
  final allowedExtensions = {'.dart', '.md'};

  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;

    final relativePath = _relativePath(entity.path);
    if (_excludedPaths.contains(relativePath)) continue;
    if (relativePath.startsWith('build/')) continue;
    if (relativePath.startsWith('.dart_tool/')) continue;

    final extensionIndex = relativePath.lastIndexOf('.');
    if (extensionIndex == -1) continue;
    final extension = relativePath.substring(extensionIndex);
    if (!allowedExtensions.contains(extension)) continue;

    yield entity;
  }
}

String _relativePath(String absolutePath) {
  final normalized = absolutePath.replaceAll('\\', '/');
  final rootPath = Directory.current.path.replaceAll('\\', '/');
  return normalized.startsWith(rootPath)
      ? normalized.substring(rootPath.length + 1)
      : normalized;
}

const _excludedPaths = {
  'docs/NAMING_STRUCTURE_REFACTOR_PLAN.md',
  'test/unit/audits/naming_structure_audit_test.dart',
};

const _canonicalPaths = {
  '.github/prompts/continue-session.prompt.md',
  '.github/prompts/qa-quick-select.prompt.md',
  '.github/prompts/siffersafari-team.prompt.md',
  '.github/prompts/workspace-cleanup-plan.prompt.md',
  'integration_test/integration_test_utils.dart',
  'artifacts/mascot_rive_guide.md',
  'artifacts/loke_rive_guide.md',
  'artifacts/skogshjalte_rive_guide.md',
  'artifacts/creature_rig.riv',
  'artifacts/puppet_rig.riv',
  'artifacts/simple_character_rig.riv',
  'artifacts/state_machine_character_demo.riv',
  'lib/features/quiz/presentation/widgets/answer_button.dart',
  'lib/features/quiz/presentation/widgets/question_card.dart',
  'lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart',
  'lib/features/daily_challenge/providers/daily_challenge_provider.dart',
  'lib/core/config/quiz_feature_settings.dart',
  'lib/presentation/widgets/game_character.dart',
  'lib/presentation/widgets/mascot_reaction_view.dart',
  'lib/app/bootstrap/presentation/startup_flow_gate.dart',
};

const _retiredPatterns = {
  '.github/prompts/multiplikation-team.prompt.md',
  '.github/prompts/fortsätt.prompt.md',
  '.github/prompts/qa-snabbval.prompt.md',
  '.github/prompts/Prompt.md',
  '.github/prompts/Prompt boost',
  'integration_test/test_utils.dart',
  'MASCOT_RIVE_GUIDE.md',
  'LOKE_RIVE_GUIDE.md',
  'SKOGSHJALTE_RIVE_GUIDE.md',
  'Creature Rig.riv',
  'Puppet Rig.riv',
  'Simple Character Rig.riv',
  'State Machine Character Demo.riv',
  'lib/presentation/widgets/mascot_character.dart',
  'lib/presentation/widgets/theme_mascot.dart',
  'lib/presentation/widgets/themed_character.dart',
  'lib/presentation/widgets/answer_button.dart',
  'lib/presentation/widgets/question_card.dart',
  'lib/presentation/widgets/daily_challenge_card.dart',
  'lib/app/bootstrap/presentation/startup_router_screen.dart',
  'lib/core/providers/daily_challenge_provider.dart',
  'lib/shared/settings/quiz_feature_settings.dart',
  'lib/presentation/providers.dart',
  'StoryProgressionService.build(',
  'goToNextQuestion(',
  'AppUpdateService.installUpdate(',
  'Future<void> _finish() async {',
};
