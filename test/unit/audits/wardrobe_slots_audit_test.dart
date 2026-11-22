import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/wardrobe_manifest.g.dart';

/// Every wearable item must land on a layer the character actually draws.
///
/// This is not theoretical: `item_shoes_safari` lived in the slot `feet`, and
/// `feet` was missing from `_slotLayers`. A child could unlock the shoes, put
/// them on, see the tile light up -- and nothing on the character. Nothing in
/// the app said so, because an item in an unknown slot is simply skipped.
void main() {
  group('[Unit] Garderobens slots', () {
    test('varje plagg i garderoben har en slot som ritas', () {
      final drawnSlots = _extractSlotLayers(_gameCharacterSource());

      final unrendered = <String>[
        for (final item in InventoryConfig.wardrobeItems)
          if (!drawnSlots.contains(item.slot)) '${item.id} (${item.slot})',
      ];

      expect(
        unrendered,
        isEmpty,
        reason: 'Dessa plagg går att ta på men ritas aldrig:\n'
            '${unrendered.join('\n')}\n'
            'Ritade slots: ${drawnSlots.join(', ')}',
      );
    });

    test('manifestets z-ordning är samma som karaktärens lagerordning', () {
      final drawnSlots = _extractSlotLayers(_gameCharacterSource());

      expect(
        wardrobeZOrder,
        drawnSlots,
        reason: 'prepare_wardrobe_items.py och game_character.dart har glidit '
            'isär — ett plagg skulle hamna på fel djup',
      );
    });

    test('varje plagg som bärs har ett z-värde', () {
      final withoutZ = wardrobeManifest
          .where((entry) => entry.showInWardrobe && entry.zOrder < 0)
          .map((entry) => entry.id)
          .toList();

      expect(
        withoutZ,
        isEmpty,
        reason: 'Plagg i garderoben saknar lager: ${withoutZ.join(', ')}',
      );
    });

    test('manifestet beskriver exakt katalogens plagg', () {
      expect(
        wardrobeManifest.map((entry) => entry.id).toList(),
        InventoryConfig.allItems.map((item) => item.id).toList(),
        reason: 'Kör om scripts/prepare_wardrobe_items.py — manifestet är '
            'genererat ur katalogen och får inte glida isär',
      );

      for (final entry in wardrobeManifest) {
        final item =
            InventoryConfig.allItems.firstWhere((item) => item.id == entry.id);

        expect(entry.slot, item.slot, reason: 'slot för ${entry.id}');
        expect(entry.asset, item.assetPath, reason: 'asset för ${entry.id}');
        expect(entry.name, item.name, reason: 'namn för ${entry.id}');
      }
    });
  });
}

/// The slot layers, read from source. The list is private, and the point of the
/// test is to check what the renderer *says*, not what a helper exposes.
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
