import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';

void main() {
  group('[Unit] InventoryConfig reward unlock order', () {
    test('reward catalog är internt konsekvent', () {
      expect(InventoryConfig.validateRewardCatalog(), isEmpty);
    });

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

    test('includes the explorer shirt as a wearable body item', () {
      final item = InventoryConfig.allItems.firstWhere(
        (entry) => entry.id == 'item_shirt_explorer',
      );

      expect(item.slot, 'body');
      expect(item.showInWardrobe, isTrue);
    });

    test('includes camp-only props in the explicit reward order', () {
      final campItems = InventoryConfig.allItems
          .where((item) => item.slot == 'camp')
          .map((item) => item.id)
          .toSet();

      expect(campItems, isNotEmpty);
      expect(
        InventoryConfig.levelUnlockOrderIds.toSet().containsAll(campItems),
        isTrue,
      );
    });

    test('camp souvenir album follows reward order and excludes wearables', () {
      expect(
        InventoryConfig.campSouvenirItems.map((item) => item.id),
        [
          'item_camp_fruit_glade',
          'item_camp_bridge',
          'item_camp_cartography',
          'item_camp_temple_gate',
          'item_camp_treasure_cache',
        ],
      );
      expect(
        InventoryConfig.campSouvenirItems.every(
          (item) => item.slot == 'camp' && !item.showInWardrobe,
        ),
        isTrue,
      );
    });

    test('unlockedCampSouvenirCount only counts camp-slot items', () {
      expect(
        InventoryConfig.unlockedCampSouvenirCount(const [
          'item_safari_hat',
          'item_camp_fruit_glade',
          'item_pet_zebra_companion',
        ]),
        1,
      );
    });
  });
}
