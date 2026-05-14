import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';

void main() {
  group('[Unit] InventoryConfig reward unlock order', () {
    test('covers all inventory items exactly once', () {
      final knownItemIds =
          InventoryConfig.allItems.map((item) => item.id).toSet();

      expect(
        InventoryConfig.levelUnlockOrderIds,
        hasLength(InventoryConfig.allItems.length),
      );
      expect(InventoryConfig.levelUnlockOrderIds.toSet(), knownItemIds);
    });

    test('returns the first locked reward item from the explicit order', () {
      final nextItem = InventoryConfig.nextLevelUnlock(
        InventoryConfig.levelUnlockOrderIds.take(1),
      );

      expect(nextItem?.id, InventoryConfig.levelUnlockOrderIds[1]);
    });

    test('returns the first unlocked camp companion from the same order', () {
      final companion = InventoryConfig.firstUnlockedCampCompanion(
        const ['item_hat_safari', 'item_pet_zebra_companion'],
      );

      expect(companion?.id, 'item_pet_zebra_companion');
      expect(companion?.showInWardrobe, isFalse);
    });
  });
}
