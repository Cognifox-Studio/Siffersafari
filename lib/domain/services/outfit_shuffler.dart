import 'dart:math';

import 'package:siffersafari/domain/entities/inventory_item.dart';

/// Builds a random, complete-looking outfit from what the child owns.
///
/// Pure on purpose: the fun part is the combination, and a seeded [Random] makes
/// it possible to test that a shuffled outfit never breaks the rules — one item
/// per slot, nothing locked, nothing unequipped by accident.
class OutfitShuffler {
  OutfitShuffler._();

  /// A random base outfit: at most one item per slot.
  ///
  /// [available] should already be filtered to unlocked, wardrobe-visible items.
  /// Keys use the base-outfit format (`idle_<itemId>`) that [OutfitResolver]
  /// treats as "worn in every pose".
  static Map<String, String> shuffle({
    required List<InventoryItem> available,
    required Random random,
  }) {
    if (available.isEmpty) return const <String, String>{};

    final bySlot = <String, List<InventoryItem>>{};
    for (final item in available) {
      bySlot.putIfAbsent(item.slot, () => <InventoryItem>[]).add(item);
    }

    final outfit = <String, String>{};
    for (final items in bySlot.values) {
      final picked = items[random.nextInt(items.length)];
      outfit['idle_${picked.id}'] = picked.id;
    }
    return outfit;
  }
}
