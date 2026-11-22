import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/wardrobe_manifest.g.dart';

/// Tap targets come from the manifest, which is generated from the art.
///
/// This used to be a `case 'item_x':` switch in the renderer, checked by
/// grepping the source for `case '` lines -- a test that could only tell you
/// that someone had edited the switch, not that the target made sense. The
/// checks below are about the numbers instead.
void main() {
  group('Wardrobe hit shape audit', () {
    test('[Unit] varje plagg har ett tapptarget i manifestet', () {
      final drawnSlots = _extractSlotLayers(_gameCharacterSource());

      final missing = <String>[
        for (final item in InventoryConfig.allItems)
          if (drawnSlots.contains(item.slot) &&
              wardrobeEntryFor(item.id) == null)
            item.id,
      ];

      expect(
        missing,
        isEmpty,
        reason: 'Plagg som ritas men saknar manifestpost får inget '
            'tapptarget:\n${missing.join('\n')}',
      );
    });

    test('[Unit] tapptarget ligger inom bilden', () {
      final broken = <String>[];

      for (final entry in wardrobeManifest) {
        if (entry.hitWidth <= 0 || entry.hitWidth > 1) {
          broken.add('${entry.id}: bredd ${entry.hitWidth}');
        }
        if (entry.hitHeight <= 0 || entry.hitHeight > 1) {
          broken.add('${entry.id}: höjd ${entry.hitHeight}');
        }
        if (entry.hitPadding < 0) {
          broken.add('${entry.id}: padding ${entry.hitPadding}');
        }
      }

      expect(
        broken,
        isEmpty,
        reason: 'Ett tapptarget utanför bilden går inte att träffa:\n'
            '${broken.join('\n')}',
      );
    });

    test('[Unit] handjusterade tapptarget vinner över de uppmätta', () {
      final safariHat = wardrobeEntryFor('item_safari_hat');
      expect(safariHat, isNotNull);

      // 0.9/0.46 is tuned for a seven-year-old's finger; the measured box of
      // the art is smaller. If the override ever disappears, taps get harder
      // for the youngest players -- silently.
      expect(safariHat!.hitWidth, greaterThan(safariHat.hitWidthFactor));
      expect(safariHat.hitWidth, 0.9);
      expect(safariHat.hitOverrideWidthFactor, isNotNull);
    });

    test('[Unit] alla manifestposter pekar på kända plagg', () {
      final known = InventoryConfig.allItems.map((item) => item.id).toSet();
      final unknown = wardrobeManifest
          .map((entry) => entry.id)
          .where((id) => !known.contains(id))
          .toList();

      expect(unknown, isEmpty, reason: 'Okända id:n: ${unknown.join(', ')}');
    });
  });
}

List<String> _extractSlotLayers(String source) {
  final match = RegExp(
    r'_slotLayers\s*=\s*<String>\[(.*?)\];',
    dotAll: true,
  ).firstMatch(source);
  if (match == null) {
    fail('Kunde inte hitta _slotLayers i game_character.dart');
  }

  return RegExp(r"'([^']+)'")
      .allMatches(match.group(1)!)
      .map((match) => match.group(1)!)
      .toList(growable: false);
}

String _gameCharacterSource() {
  final path = [
    Directory.current.path,
    'lib',
    'presentation',
    'widgets',
    'game_character.dart',
  ].join(Platform.pathSeparator);

  return File(path).readAsStringSync();
}
