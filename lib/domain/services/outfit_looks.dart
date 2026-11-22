import 'package:siffersafari/domain/entities/inventory_item.dart';

/// A named outfit a child can put on with one tap.
class OutfitLook {
  const OutfitLook({
    required this.id,
    required this.name,
    required this.itemIds,
  });

  /// Stable id, used for widget keys and tests.
  final String id;

  /// Child-facing name, e.g. `Safari`.
  final String name;

  /// The items that make up the look, in the order they were designed.
  final List<String> itemIds;
}

/// Three looks built from the wardrobe that ships today.
///
/// "Slumpa" gives variation; these give *identity*. A child who can say "today
/// I'm the scientist" keeps playing longer than one wearing a random hat -- and
/// a look is a reason to go looking for the pieces that are still missing.
///
/// One item per slot is a hard rule here as well: the backpack and the
/// binoculars are both worn as `accessory`, so a look may only use one of them.
const outfitLooks = <OutfitLook>[
  OutfitLook(
    id: 'safari',
    name: 'Safari',
    itemIds: [
      'item_safari_hat',
      'item_shirt_explorer',
      'item_binoculars_safari',
      'item_map_safari',
      'item_shoes_safari',
      'item_pet_zebra_companion',
    ],
  ),
  OutfitLook(
    id: 'scientist',
    name: 'Forskare',
    itemIds: [
      'item_hat_safari',
      'item_glasses_nerd',
      'item_compass_safari',
      'item_shirt_explorer',
      'item_shoes_safari',
    ],
  ),
  OutfitLook(
    id: 'pirate',
    name: 'Pirat',
    itemIds: [
      'item_hat_pirate',
      'item_map_safari',
      'item_shirt_explorer',
      'item_shoes_safari',
      'item_backpack_adventure',
    ],
  ),
];

/// The parts of [look] the child owns, ready for `applyBaseOutfit`.
///
/// A look never fails: it puts on the pieces the child has and leaves the rest
/// for later, which turns a locked item into something to look forward to
/// instead of a locked door. Only one item per slot is kept (a look must never
/// stack two hats), unknown ids are ignored so a renamed item cannot break the
/// wardrobe, and the result uses the base-outfit format `idle_<itemId>`.
Map<String, String> lookOutfit({
  required OutfitLook look,
  required Iterable<InventoryItem> catalog,
  required Set<String> unlockedIds,
}) {
  final slotById = <String, String>{
    for (final item in catalog) item.id: item.slot,
  };

  final usedSlots = <String>{};
  final outfit = <String, String>{};

  for (final id in look.itemIds) {
    if (!unlockedIds.contains(id)) continue;
    final slot = slotById[id];
    if (slot == null) continue;
    if (!usedSlots.add(slot)) continue;
    outfit['idle_$id'] = id;
  }

  return outfit;
}
