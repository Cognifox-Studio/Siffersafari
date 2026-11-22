import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/services/outfit_shuffler.dart';

void main() {
  InventoryItem item(String id, String slot) => InventoryItem(
        id: id,
        slot: slot,
        assetPath: 'assets/images/items/$id.webp',
        name: id,
      );

  group('[Unit] OutfitShuffler', () {
    test('ett plagg per slot', () {
      final available = [
        item('hat_a', 'head'),
        item('hat_b', 'head'),
        item('glasses', 'face'),
        item('shoes', 'feet'),
      ];

      final outfit = OutfitShuffler.shuffle(
        available: available,
        random: Random(7),
      );

      expect(outfit.length, 3, reason: 'Två hattar får aldrig plockas samtidigt');
      final slots = outfit.values.map((id) {
        return available.firstWhere((entry) => entry.id == id).slot;
      }).toList();
      expect(slots.toSet().length, slots.length, reason: 'En per slot');
    });

    test('använder bara det barnet äger', () {
      final available = [item('hat_a', 'head'), item('shoes', 'feet')];
      final allowed = available.map((entry) => entry.id).toSet();

      for (var seed = 0; seed < 20; seed++) {
        final outfit = OutfitShuffler.shuffle(
          available: available,
          random: Random(seed),
        );
        expect(allowed.containsAll(outfit.values), isTrue);
      }
    });

    test('nycklarna är basoutfit så plaggen syns i alla poser', () {
      final outfit = OutfitShuffler.shuffle(
        available: [item('hat_a', 'head')],
        random: Random(1),
      );

      expect(outfit.keys.single, 'idle_hat_a');
      expect(outfit.values.single, 'hat_a');
    });

    test('samma frö ger samma outfit', () {
      final available = [
        item('hat_a', 'head'),
        item('hat_b', 'head'),
        item('glasses', 'face'),
      ];

      final first = OutfitShuffler.shuffle(
        available: available,
        random: Random(42),
      );
      final second = OutfitShuffler.shuffle(
        available: available,
        random: Random(42),
      );

      expect(first, second);
    });

    test('tom garderob ger tom outfit', () {
      expect(
        OutfitShuffler.shuffle(available: const [], random: Random(1)),
        isEmpty,
      );
    });
  });
}
