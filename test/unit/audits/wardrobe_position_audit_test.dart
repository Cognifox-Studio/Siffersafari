import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/wardrobe_manifest.g.dart';
import 'package:siffersafari/domain/services/wardrobe_layout.dart';

/// How far an item may move when the hand-tuned pair is replaced by the anchor.
///
/// The two models are only equal for a character without a nudge: a nudge
/// scales the box, and the legacy offset was stored as a multiple of
/// `(1 - scale) / 2`, so a five percent box change moves a big offset by a few
/// percent. 0.06 of the character's height is the ceiling that is actually
/// reached (hats on Signe and Astrid, ~12 px on a 200 px character).
const double _allowedDrift = 0.06;

/// The per-character nudges from `_getCharacterAdjustments`. Copied on purpose:
/// this test exists to notice when that table and the manifest disagree.
const Map<String, ({double dx, double dy, double scale})> _characters = {
  'loke': (dx: 0.0, dy: 0.0, scale: 1.0),
  'signe': (dx: 0.0, dy: 0.35, scale: 0.95),
  'astrid': (dx: 0.15, dy: 0.15, scale: 1.05),
};

/// The item's box distance from the character's centre, as the renderer drew it
/// before the manifest was read.
({double dx, double dy}) _legacyOffset(
  InventoryItem item,
  ({double dx, double dy, double scale}) nudge,
) {
  final factor = (1.0 - item.renderScale * nudge.scale) / 2;
  return (
    dx: (item.offset.x + nudge.dx) * factor,
    dy: (item.offset.y + nudge.dy) * factor,
  );
}

/// The same distance, as the renderer computes it now.
({double dx, double dy}) _anchoredOffset(
  InventoryItem item,
  WardrobeManifestEntry entry,
  ({double dx, double dy, double scale}) nudge,
) {
  final layoutScale = item.renderScale * nudge.scale;
  final factor = (1.0 - layoutScale) / 2;
  final anchored = anchoredItemOffset(
    layoutScale: layoutScale,
    imageAspect: entry.imageWidth / entry.imageHeight,
    anchorX: entry.anchorX,
    anchorY: entry.anchorY,
    targetX: entry.targetX,
    targetY: entry.targetY,
  );
  return (
    dx: anchored.dx + nudge.dx * factor,
    dy: anchored.dy + nudge.dy * factor,
  );
}

({double dx, double dy}) _drift(
  InventoryItem item,
  WardrobeManifestEntry entry,
  ({double dx, double dy, double scale}) nudge,
) {
  final legacy = _legacyOffset(item, nudge);
  final anchored = _anchoredOffset(item, entry, nudge);
  return (
    dx: (anchored.dx - legacy.dx).abs(),
    dy: (anchored.dy - legacy.dy).abs(),
  );
}

void main() {
  group('[Audit] Plaggen ligger där de låg', () {
    test('manifestet beskriver varje plagg i InventoryConfig.allItems', () {
      final manifestIds = wardrobeManifest.map((item) => item.id).toSet();
      final missing = InventoryConfig.allItems
          .map((item) => item.id)
          .where((id) => !manifestIds.contains(id))
          .toList();

      expect(
        missing,
        isEmpty,
        reason: 'Kör python3 scripts/prepare_wardrobe_items.py',
      );
    });

    test('Loke, som inte knuffar något, står helt stilla', () {
      // Without a nudge the box keeps its size, so the anchor math must return
      // what the hand-tuned pair returned. Only two things may differ: manifest
      // values rounded to four decimals, and stage props (camp, pet) that never
      // had an offset of their own -- they now inherit their slot's anchor,
      // which lands within a thousandth of the dead centre they used to get.
      final nudge = _characters['loke']!;
      for (final item in InventoryConfig.allItems) {
        final entry = wardrobeEntryFor(item.id);
        if (entry == null || entry.imageHeight <= 0) {
          continue;
        }

        final drift = _drift(item, entry, nudge);
        expect(
          drift.dx,
          lessThanOrEqualTo(0.005),
          reason: '${item.id} flyttade sig i sidled',
        );
        expect(
          drift.dy,
          lessThanOrEqualTo(0.005),
          reason: '${item.id} flyttade sig i höjdled',
        );
      }
    });

    test('Signe och Astrid flyttar inget mer än några procent', () {
      final worst = <String, double>{};

      for (final character in _characters.entries) {
        for (final item in InventoryConfig.allItems) {
          final entry = wardrobeEntryFor(item.id);
          if (entry == null || entry.imageHeight <= 0) {
            continue;
          }

          final drift = _drift(item, entry, character.value);
          final worstAxis = drift.dx > drift.dy ? drift.dx : drift.dy;
          if (worstAxis > (_allowedDrift * 0.5)) {
            worst['${item.id}/${character.key}'] = worstAxis;
          }
        }
      }

      // Recorded so a shift shows up in CI as a number, not as "got eyes".
      expect(
        worst.values.every((value) => value <= _allowedDrift),
        isTrue,
        reason: 'Största avvikelsen: $worst',
      );
    });
  });
}
