import 'package:flutter/material.dart';

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.slot,
    required this.assetPath,
    required this.name,
    this.offset = Alignment.center,
    this.renderScale = 0.5,
    this.showInWardrobe = true,
  });

  final String id;
  final String slot; // e.g. 'head', 'accessory'
  final String assetPath;
  final String name;
  final Alignment offset;
  final double renderScale;
  final bool showInWardrobe;
}

class InventoryConfig {
  static const List<InventoryItem> allItems = [
    // --- Wave 1: Safari ---
    InventoryItem(
      id: 'item_safari_hat',
      slot: 'head',
      assetPath: 'assets/images/items/item_safari_hat.png',
      name: 'Riktig Safarihatt',
      offset: Alignment(0.0, -2.8),
      renderScale: 0.85,
    ),
    InventoryItem(
      id: 'item_hat_safari',
      slot: 'head',
      assetPath: 'assets/images/items/item_hat_safari.png',
      name: 'Safarihatt',
      offset: Alignment(0.0, -2.8),
      renderScale: 0.85,
    ),
    InventoryItem(
      id: 'item_binoculars_safari',
      slot: 'accessory',
      assetPath: 'assets/images/items/item_binoculars_safari_nobg.png',
      name: 'Kikare',
      offset: Alignment(1.6, 0.35),
      renderScale: 0.4,
    ),
    InventoryItem(
      id: 'item_compass_safari',
      slot: 'accessory',
      assetPath: 'assets/images/items/item_compass_safari_nobg.png',
      name: 'Kompass',
      offset: Alignment(0.0, 0.3),
      renderScale: 0.35,
    ),
    InventoryItem(
      id: 'item_map_safari',
      slot: 'front', // Map ritas överst med den nya front-slotten
      assetPath:
          'assets/images/items/item_map_safari_nobg.png', // Korrigerad till transparent
      name: 'Karta',
      offset: Alignment(-1.35, 0.15),
      renderScale: 0.45,
    ),

    InventoryItem(
      id: 'item_shoes_safari',
      slot: 'feet',
      assetPath: 'assets/images/items/item_shoes_safari.png',
      name: 'Safariskor',
      offset: Alignment(0.0, 2.8),
      renderScale: 0.65,
    ),

    // --- Wave 2: Pirate & Explorer ---
    InventoryItem(
      id: 'item_hat_pirate',
      slot: 'head',
      assetPath: 'assets/images/items/item_hat_pirate_nobg.png',
      name: 'Pirathatt',
      offset: Alignment(0.0, -2.8), // Samma position som safarihatten
      renderScale: 0.85, // Samma skala som safarihatten
    ),
    InventoryItem(
      id: 'item_glasses_nerd',
      slot: 'face',
      assetPath: 'assets/images/items/item_glasses_nerd_nobg.png',
      name: 'Smarta glasögon',
      offset: Alignment(0.0, -0.8), // Flyttad upp mot ögonen
      renderScale: 0.9, // Uppskalad för att täcka Lokes stora ögon
    ),
    InventoryItem(
      id: 'item_backpack_adventure',
      slot:
          'accessory', // Byt från 'back' till 'accessory' så den ritas framför Loke
      assetPath: 'assets/images/items/item_backpack_adventure_nobg.png',
      name: 'Äventyrsryggsäck',
      offset: Alignment(
        -2.0,
        1.4,
      ), // Knuffad ut till vänster för att hamna under utsträckta handen
      renderScale: 0.6,
    ),
    InventoryItem(
      id: 'item_shirt_explorer',
      slot: 'body',
      assetPath: 'assets/images/items/item_shirt_explorer_nobg.png',
      name: 'Äventyrsskjorta',
      offset: Alignment(0.0, 0.45),
      renderScale: 0.95,
    ),
    // --- Nyutvecklad grafik ---
    InventoryItem(
      id: 'item_camera_safari',
      slot: 'accessory',
      assetPath: 'assets/images/items/item_camera_safari_nobg.png',
      name: 'Safariskamera',
      offset: Alignment(1.4, 0.45), // Placerad nära handen/magen
      renderScale: 0.45,
    ),
    InventoryItem(
      id: 'item_camp_fruit_glade',
      slot: 'camp',
      assetPath: 'assets/images/story/map_fruit_glade.png',
      name: 'Fruktgläntan',
      renderScale: 0.58,
      showInWardrobe: false,
    ),
    InventoryItem(
      id: 'item_camp_bridge',
      slot: 'camp',
      assetPath: 'assets/images/story/map_bridge.png',
      name: 'Repbron',
      renderScale: 0.62,
      showInWardrobe: false,
    ),
    InventoryItem(
      id: 'item_camp_cartography',
      slot: 'camp',
      assetPath: 'assets/images/story/map_cartography_camp.png',
      name: 'Kartlägret',
      renderScale: 0.62,
      showInWardrobe: false,
    ),
    InventoryItem(
      id: 'item_camp_temple_gate',
      slot: 'camp',
      assetPath: 'assets/images/story/map_temple_gate.png',
      name: 'Tempelporten',
      renderScale: 0.62,
      showInWardrobe: false,
    ),
    InventoryItem(
      id: 'item_camp_treasure_cache',
      slot: 'camp',
      assetPath: 'assets/images/story/map_treasure_cache.png',
      name: 'Skattgömman',
      renderScale: 0.6,
      showInWardrobe: false,
    ),
    InventoryItem(
      id: 'item_pet_zebra_companion',
      slot: 'pet',
      assetPath: 'assets/images/items/item_pet_zebra_companion_nobg.png',
      name: 'Zebravän',
      renderScale: 0.8,
      showInWardrobe: false,
    ),
  ];

  // Keep reward progression independent from render/grid ordering.
  static const List<String> levelUnlockOrderIds = [
    'item_safari_hat',
    'item_hat_safari',
    'item_binoculars_safari',
    'item_compass_safari',
    'item_map_safari',
    'item_shoes_safari',
    'item_hat_pirate',
    'item_glasses_nerd',
    'item_backpack_adventure',
    'item_shirt_explorer',
    'item_camera_safari',
    'item_camp_fruit_glade',
    'item_camp_bridge',
    'item_camp_cartography',
    'item_camp_temple_gate',
    'item_camp_treasure_cache',
    'item_pet_zebra_companion',
  ];

  static final Map<String, InventoryItem> _itemsById = {
    for (final item in allItems) item.id: item,
  };

  static final List<InventoryItem> wardrobeItems =
      allItems.where((item) => item.showInWardrobe).toList(growable: false);

  static List<String> validateRewardCatalog() {
    final errors = <String>[];
    final knownItemIds = <String>{};

    for (final item in allItems) {
      if (!knownItemIds.add(item.id)) {
        errors.add('Duplicate inventory item id: ${item.id}');
      }
      if (item.name.trim().isEmpty) {
        errors.add('Inventory item ${item.id} saknar namn');
      }
      if (item.assetPath.trim().isEmpty) {
        errors.add('Inventory item ${item.id} saknar assetPath');
      }
    }

    final rewardIds = levelUnlockOrderIds.toSet();
    final unknownRewardIds = rewardIds.difference(knownItemIds);
    final missingRewardIds = knownItemIds.difference(rewardIds);

    if (levelUnlockOrderIds.length != rewardIds.length) {
      errors.add('levelUnlockOrderIds innehåller dubbletter');
    }
    if (unknownRewardIds.isNotEmpty) {
      errors.add('Okända reward ids: ${unknownRewardIds.join(', ')}');
    }
    if (missingRewardIds.isNotEmpty) {
      errors.add(
        'Items saknas i rewardordningen: ${missingRewardIds.join(', ')}',
      );
    }

    return List<String>.unmodifiable(errors);
  }

  static InventoryItem? nextLevelUnlock(Iterable<String> unlockedItemIds) {
    final unlocked = unlockedItemIds.toSet();

    for (final itemId in levelUnlockOrderIds) {
      if (!unlocked.contains(itemId)) {
        return _itemsById[itemId];
      }
    }

    return null;
  }

  static InventoryItem? firstUnlockedCampCompanion(
    Iterable<String> unlockedItemIds,
  ) {
    final unlocked = unlockedItemIds.toSet();

    for (final itemId in levelUnlockOrderIds) {
      if (!unlocked.contains(itemId)) continue;

      final item = _itemsById[itemId];
      if (item != null && item.slot == 'pet') {
        return item;
      }
    }

    return null;
  }
}
