import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';

/// Guards the cheapest part of the wardrobe: the files on disk.
///
/// The wardrobe once shipped three images nobody referenced -- byte-identical
/// copies of the `_nobg` versions, 200 KB of APK for nothing. Those are easy to
/// introduce (rename an asset, forget the old one) and impossible to notice by
/// playing the game, so they are checked here instead.
void main() {
  group('[Unit] Garderobens bildfiler', () {
    test('varje plagg pekar på en fil som finns', () {
      final missing = <String>[
        for (final item in InventoryConfig.allItems)
          if (!File(item.assetPath).existsSync())
            '${item.id} -> ${item.assetPath}',
      ];

      expect(
        missing,
        isEmpty,
        reason: 'Plagg utan bild blir en tom ruta i garderoben:\n'
            '${missing.join('\n')}',
      );
    });

    test('inga bilder i assets/images/items saknar plagg', () {
      final referenced = InventoryConfig.allItems
          .map((item) => item.assetPath)
          .toSet();
      final onDisk = Directory('assets/images/items')
          .listSync()
          .whereType<File>()
          .map((file) => file.path.replaceAll('\\', '/'))
          .toSet();

      final orphans = onDisk.difference(referenced).toList()..sort();

      expect(
        orphans,
        isEmpty,
        reason: 'Bilder utan plagg packas in i APK:n utan att något barn '
            'någonsin ser dem:\n${orphans.join('\n')}',
      );
    });

    test('de två hattarna är olika plagg, inte en dubblett av filen', () {
      final safariHat = InventoryConfig.allItems
          .firstWhere((item) => item.id == 'item_safari_hat');
      final explorerHat = InventoryConfig.allItems
          .firstWhere((item) => item.id == 'item_hat_safari');

      // They do look alike by name -- "Safarihatt" and "Utforskarhatt" -- and
      // that has tempted a cleanup before. They are two rewards with two
      // different images, so the ids must stay apart: renaming one would need a
      // migration of every profile's unlockedItems.
      expect(safariHat.slot, explorerHat.slot);
      expect(safariHat.assetPath, isNot(explorerHat.assetPath));
      expect(safariHat.name, isNot(explorerHat.name));
    });
  });
}
