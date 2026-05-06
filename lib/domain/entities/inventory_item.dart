class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.slot,
    required this.assetPath,
    required this.name,
  });

  final String id;
  final String slot; // e.g. 'head', 'accessory'
  final String assetPath;
  final String name;
}

class InventoryConfig {
  static const List<InventoryItem> allItems = [
    // --- Wave 1: Safari ---
    InventoryItem(
      id: 'item_hat_safari',
      slot: 'head',
      assetPath: 'assets/images/items/item_hat_safari.png',
      name: 'Safarihatt',
    ),
    InventoryItem(
      id: 'item_binoculars_safari',
      slot: 'accessory',
      assetPath: 'assets/images/items/item_binoculars_safari.png',
      name: 'Kikare',
    ),
    InventoryItem(
      id: 'item_compass_safari',
      slot: 'accessory',
      assetPath: 'assets/images/items/item_compass_safari.png',
      name: 'Kompass',
    ),
    InventoryItem(
      id: 'item_map_safari',
      slot: 'accessory',
      assetPath: 'assets/images/items/item_map_safari.png',
      name: 'Karta',
    ),

    // --- Wave 2: Pirate & Explorer ---
    InventoryItem(
      id: 'item_hat_pirate',
      slot: 'head',
      assetPath: 'assets/images/items/item_hat_pirate.png',
      name: 'Pirathatt',
    ),
    InventoryItem(
      id: 'item_shirt_explorer',
      slot: 'body',
      assetPath: 'assets/images/items/item_shirt_explorer.png',
      name: 'Upptäckarskjorta',
    ),
    InventoryItem(
      id: 'item_glasses_nerd',
      slot: 'face',
      assetPath: 'assets/images/items/item_glasses_nerd.png',
      name: 'Smarta glasögon',
    ),
    InventoryItem(
      id: 'item_backpack_adventure',
      slot: 'back',
      assetPath: 'assets/images/items/item_backpack_adventure.png',
      name: 'Äventyrsryggsäck',
    ),
  ];
}
