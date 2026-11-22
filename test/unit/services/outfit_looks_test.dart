import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/services/outfit_looks.dart';

void main() {
  final catalog = InventoryConfig.allItems;
  final slotById = {for (final item in catalog) item.id: item.slot};

  group('[Unit] Färdiga outfits – data', () {
    test('varje look har ett unikt id och ett namn', () {
      final ids = outfitLooks.map((look) => look.id).toList();

      expect(ids.toSet().length, ids.length);
      expect(outfitLooks.every((look) => look.name.isNotEmpty), isTrue);
    });

    test('bara riktiga plagg, och aldrig lägerplatser', () {
      for (final look in outfitLooks) {
        for (final id in look.itemIds) {
          expect(
            slotById.containsKey(id),
            isTrue,
            reason: '${look.name} pekar på okänt plagg: $id',
          );
          expect(
            slotById[id],
            isNot('camp'),
            reason: 'Lägerplatser bärs inte på kroppen',
          );
        }
      }
    });

    test('inga dubbletter inom samma slot', () {
      for (final look in outfitLooks) {
        final slots = look.itemIds.map((id) => slotById[id]).toList();

        expect(
          slots.toSet().length,
          slots.length,
          reason: '${look.name} skulle stapla plagg i samma slot',
        );
      }
    });
  });

  group('[Unit] Färdiga outfits – applicering', () {
    final safari = outfitLooks.firstWhere((look) => look.id == 'safari');

    test('äger barnet allt blir det hela looken i basoutfiten', () {
      final outfit = lookOutfit(
        look: safari,
        catalog: catalog,
        unlockedIds: safari.itemIds.toSet(),
      );

      expect(outfit.length, safari.itemIds.length);
      expect(outfit.keys.every((key) => key.startsWith('idle_')), isTrue);
      expect(outfit['idle_item_safari_hat'], 'item_safari_hat');
    });

    test('äger barnet inget blir outfiten tom', () {
      final outfit = lookOutfit(
        look: safari,
        catalog: catalog,
        unlockedIds: const <String>{},
      );

      expect(outfit, isEmpty);
    });

    test('äger barnet en del tas bara den delen på', () {
      final outfit = lookOutfit(
        look: safari,
        catalog: catalog,
        unlockedIds: const {'item_map_safari', 'item_shoes_safari'},
      );

      expect(outfit.values.toSet(), {'item_map_safari', 'item_shoes_safari'});
    });

    test('okänt id ignoreras i stället för att krascha', () {
      const broken = OutfitLook(
        id: 'broken',
        name: 'Trasig',
        itemIds: ['item_som_inte_finns', 'item_hat_pirate'],
      );

      final outfit = lookOutfit(
        look: broken,
        catalog: catalog,
        unlockedIds: const {'item_som_inte_finns', 'item_hat_pirate'},
      );

      expect(outfit.values.toList(), ['item_hat_pirate']);
    });
  });
}
