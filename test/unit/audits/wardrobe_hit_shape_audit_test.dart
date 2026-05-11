import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';

void main() {
  group('Wardrobe hit shape audit', () {
    test(
      '[Unit] WardrobeHitShapeAudit – all active wardrobe items have explicit hit shapes',
      () {
        final source = _gameCharacterSource();
        final activeSlots = _extractSlotLayers(source);
        final explicitItemIds = _extractExplicitHitShapeItemIds(source);

        final activeWardrobeItemIds = InventoryConfig.allItems
            .where((item) => activeSlots.contains(item.slot))
            .map((item) => item.id)
            .toSet();

        final missingExplicitCases =
            activeWardrobeItemIds.difference(explicitItemIds).toList()..sort();

        expect(
          missingExplicitCases,
          isEmpty,
          reason:
              'Aktiva wardrobe-items saknar explicit hit-shape-case i GameCharacter:\n'
              '${missingExplicitCases.join('\n')}',
        );
      },
    );

    test(
      '[Unit] WardrobeHitShapeAudit – explicit hit shapes reference known inventory items only',
      () {
        final explicitItemIds =
            _extractExplicitHitShapeItemIds(_gameCharacterSource());
        final knownItemIds =
            InventoryConfig.allItems.map((item) => item.id).toSet();

        final unknownItemIds = explicitItemIds.difference(knownItemIds).toList()
          ..sort();

        expect(
          unknownItemIds,
          isEmpty,
          reason:
              'GameCharacter innehåller explicita hit-shape-case för okända item-ID:n:\n'
              '${unknownItemIds.join('\n')}',
        );
      },
    );
  });
}

String _gameCharacterSource() {
  return File(_gameCharacterPath).readAsStringSync();
}

Set<String> _extractSlotLayers(String source) {
  final match = RegExp(
    r'_slotLayers\s*=\s*<String>\[(.*?)\];',
    dotAll: true,
  ).firstMatch(source);
  if (match == null) {
    fail(
      'Kunde inte hitta _slotLayers i lib/presentation/widgets/game_character.dart',
    );
  }

  return RegExp(r"'([^']+)'")
      .allMatches(match.group(1)!)
      .map((match) => match.group(1)!)
      .toSet();
}

Set<String> _extractExplicitHitShapeItemIds(String source) {
  return RegExp(r"case '(item_[^']+)':")
      .allMatches(source)
      .map((match) => match.group(1)!)
      .toSet();
}

final _gameCharacterPath =
    '${Directory.current.path}${Platform.pathSeparator}lib${Platform.pathSeparator}presentation${Platform.pathSeparator}widgets${Platform.pathSeparator}game_character.dart';
