#!/usr/bin/env python3
"""Derive the wardrobe manifest from the art instead of from magic numbers.

Every wearable item costs four edits today: the image, an entry in
`InventoryConfig.allItems`, a character correction in `game_character.dart` and a
`case 'item_x':` in the hit-shape switch. The position is written as
`Alignment(0.0, -2.8)` -- a number nobody can read, because it is multiplied by
`height * (1 - renderScale) * 0.5` at draw time.

This script reads the opaque bounding box of each WebP (the art is the source of
truth) and writes two files:

  assets/wardrobe/manifest.json            -- reviewable, for humans and diffs
  lib/domain/entities/wardrobe_manifest.g.dart -- `const`, so the app parses no
                                                 JSON at startup and stays fully
                                                 offline

What is derived and what is not:

  * `anchor`    -- derived: where the visible part of the image actually is, as a
                   fraction of the image (0.5/0.5 = dead centre). An item drawn
                   with lots of transparent padding around it no longer needs a
                   hand-tuned offset to land right.
  * `hitShape`  -- derived: the opaque box plus a small padding, as factors of the
                   image. Tapping a hat is then tapping the hat, not a guess based
                   on its slot.
  * `zOrder`    -- derived: the slot order (`back` under `front`), the same six
                   layers the character draws.
  * `target`    -- derived: where the item's anchor should land on the character,
                   as a fraction of its height. Read once out of the hand-tuned
                   `offset`/`renderScale` pair (that is `legacy` below, kept only
                   so an audit can hold the two against each other), so switching
                   the renderer over moved nothing but rounding. An item with no
                   offset of its own inherits its slot's `slotAnchors` value.

Usage:
    python3 scripts/prepare_wardrobe_items.py           # write the files
    python3 scripts/prepare_wardrobe_items.py --check   # fail if they are stale

Requires Pillow with WebP support: `pip install Pillow`. The script is a
developer tool: CI never runs it, and the app never reads it.
"""

from __future__ import annotations

import argparse
import json
import re
import statistics
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # pragma: no cover - developer setup issue
    sys.exit("Pillow is required: pip install Pillow")

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "lib" / "domain" / "entities" / "inventory_item.dart"
HIT_SHAPE_OVERRIDES = ROOT / "assets" / "wardrobe" / "hit_shape_overrides.json"
MANIFEST_JSON = ROOT / "assets" / "wardrobe" / "manifest.json"
MANIFEST_DART = ROOT / "lib" / "domain" / "entities" / "wardrobe_manifest.g.dart"

# The layers the character draws, bottom to top. Order is behaviour, not taste:
# shoes under the shirt, a map on top of it, a hat above the face. Must match
# `_slotLayers` in `game_character.dart`; `wardrobe_slots_audit_test` enforces it.
SLOT_ORDER = ["back", "feet", "body", "face", "head", "accessory", "front"]

# 2: every item gained `target`/`slotAnchor`, and the manifest learned
# `slotAnchors`. The Dart class grew required fields, so an old reader cannot
# silently ignore them.
SCHEMA_VERSION = 2

# Padding around the opaque box when the hit shape is derived. Enough for a
# seven-year-old's finger without swallowing the neighbouring item.
HIT_SHAPE_PADDING = 0.02


def _catalog_entries() -> list[dict[str, object]]:
    """Parse the `allItems` list in `inventory_item.dart`.

    A dev script reading one Dart file it also validates is a fair trade: the
    alternative is a second hand-maintained list that drifts. The output is
    cross-checked against the catalog by `wardrobe_manifest_audit_test`, so
    drift fails CI instead of reaching a child.
    """
    source = CATALOG.read_text(encoding="utf-8")
    start = source.index("allItems")
    body = source[start:]
    end = body.index("  ];")
    body = body[:end]

    entries: list[dict[str, object]] = []
    for block in re.finditer(r"InventoryItem\((.*?)\n    \),", body, re.S):
        chunk = block.group(1)

        def take(name: str) -> str | None:
            match = re.search(rf"{name}:\s*'([^']+)'", chunk)
            return match.group(1) if match else None

        item_id = take("id")
        if item_id is None:
            continue

        # `slot:` is sometimes followed by a comment before the value.
        slot_match = re.search(r"slot:\s*(?://[^\n]*\n\s*)*'([^']+)'", chunk)
        offset_match = re.search(
            r"offset:\s*Alignment\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*,?\s*\)",
            chunk,
        )
        scale_match = re.search(r"renderScale:\s*([\d.]+)", chunk)

        entries.append(
            {
                "id": item_id,
                "name": take("name") or item_id,
                "slot": slot_match.group(1) if slot_match else "",
                "asset": take("assetPath") or "",
                "showInWardrobe": "showInWardrobe: false" not in chunk,
                # None, not (0, 0): an item without a hand-tuned offset should
                # inherit its slot's anchor, not land on the character's centre.
                "offset": [
                    float(offset_match.group(1)),
                    float(offset_match.group(2)),
                ]
                if offset_match
                else None,
                "renderScale": float(scale_match.group(1))
                if scale_match
                else 0.5,
            }
        )

    return entries


def _hit_shape_overrides() -> dict[str, tuple[float, float, float]]:
    """Hand-tuned tap targets, kept as data instead of as code.

    They used to be a `case 'item_x':` switch in the renderer, which meant every
    new item was an edit in a widget and the only guard was a test that grepped
    the source for `case '` lines. The values were tuned for a seven-year-old's
    finger (a hat's target is wider than its art), so they are worth keeping --
    they simply live in JSON next to the manifest now.
    """
    if not HIT_SHAPE_OVERRIDES.exists():
        return {}

    payload = json.loads(HIT_SHAPE_OVERRIDES.read_text(encoding="utf-8"))
    items = payload.get("items", {})
    return {
        item_id: (
            float(values["widthFactor"]),
            float(values["heightFactor"]),
            float(values["paddingFactor"]),
        )
        for item_id, values in items.items()
    }


def _art(asset: str) -> dict[str, object] | None:
    path = ROOT / asset
    if not path.exists():
        print(f"  ! missing file: {asset}", file=sys.stderr)
        return None

    with Image.open(path) as image:
        width, height = image.size
        alpha = image.convert("RGBA").getchannel("A")
        box = alpha.getbbox()

    if box is None:  # fully transparent: the item would be invisible
        print(f"  ! fully transparent: {asset}", file=sys.stderr)
        return None

    x0, y0, x1, y1 = box
    box_w, box_h = x1 - x0, y1 - y0

    return {
        "image": {"width": width, "height": height},
        "opaqueBbox": [x0, y0, box_w, box_h],
        "anchor": {
            "x": round((x0 + box_w / 2) / width, 4),
            "y": round((y0 + box_h / 2) / height, 4),
        },
        "hitShape": {
            "widthFactor": round(min(1.0, box_w / width + HIT_SHAPE_PADDING), 4),
            "heightFactor": round(min(1.0, box_h / height + HIT_SHAPE_PADDING), 4),
            "paddingFactor": HIT_SHAPE_PADDING,
        },
    }


def _anchored_target(
    offset: list[float] | None,
    render_scale: float,
    anchor: dict[str, float],
    image: dict[str, int],
) -> tuple[float, float]:
    """Where the old hand-tuned pair actually put the item's anchor point.

    Mirrors `anchoredItemOffset` in `lib/domain/services/wardrobe_layout.dart`,
    run backwards: instead of anchor -> offset, this reads the legacy offset and
    reports the point on the character the anchor landed on. Every value is a
    fraction of the character's height, so the numbers survive a resize.
    """
    if offset is None:
        return (0.0, 0.0)

    box = render_scale
    width = float(image["width"])
    height = float(image["height"])
    aspect = width / height if height else 1.0

    if aspect >= 1.0:
        draw_w, draw_h = box, box / aspect
    else:
        draw_w, draw_h = box * aspect, box

    anchor_from_box_x = (box - draw_w) / 2 + anchor["x"] * draw_w - box / 2
    anchor_from_box_y = (box - draw_h) / 2 + anchor["y"] * draw_h - box / 2

    # `Alignment(ox, oy)` * `(1 - scale) / 2` is the legacy offset.
    factor = (1.0 - box) / 2
    return (
        offset[0] * factor + anchor_from_box_x,
        offset[1] * factor + anchor_from_box_y,
    )


def _slot_anchors(items: list[dict[str, object]]) -> dict[str, tuple[float, float]]:
    """The middle of where each slot's items sit, in character-height fractions.

    The median rather than the mean: one item that was nudged somewhere odd
    should not drag the whole slot with it. A new item that gives only its slot
    lands here.
    """
    grouped: dict[str, list[tuple[float, float]]] = {}
    for item in items:
        if item.get("targetSource") != "legacy":
            continue
        target = item["target"]
        assert isinstance(target, dict)
        grouped.setdefault(str(item["slot"]), []).append(
            (float(target["x"]), float(target["y"]))
        )

    return {
        slot: (
            round(statistics.median(p[0] for p in points), 4),
            round(statistics.median(p[1] for p in points), 4),
        )
        for slot, points in grouped.items()
    }


def build() -> dict[str, object]:
    overrides = _hit_shape_overrides()
    items: list[dict[str, object]] = []
    for entry in _catalog_entries():
        art = _art(str(entry["asset"]))
        slot = str(entry["slot"])
        if art is None:
            continue

        override = overrides.get(str(entry["id"]))

        items.append(
            {
                "id": entry["id"],
                "name": entry["name"],
                "slot": slot,
                "zOrder": SLOT_ORDER.index(slot) if slot in SLOT_ORDER else -1,
                "showInWardrobe": entry["showInWardrobe"],
                "asset": entry["asset"],
                **art,
                "hitShapeOverride": None
                if override is None
                else {
                    "widthFactor": override[0],
                    "heightFactor": override[1],
                    "paddingFactor": override[2],
                },
                # Kept for the audit that proves the swap is a no-op.
                "legacy": {
                    "offset": entry["offset"],
                    "renderScale": entry["renderScale"],
                },
            }
        )

    # Position: read the hand-tuned pair once, then keep only where it landed.
    # An item that gives just its slot inherits the slot's anchor instead.
    for item in items:
        image = item["image"]
        anchor = item["anchor"]
        legacy = item["legacy"]
        assert isinstance(image, dict)
        assert isinstance(anchor, dict)
        assert isinstance(legacy, dict)

        target_x, target_y = _anchored_target(
            legacy["offset"],
            float(legacy["renderScale"]),
            anchor,
            image,
        )
        item["target"] = {
            "x": round(target_x, 4),
            "y": round(target_y, 4),
        }
        item["targetSource"] = "legacy" if legacy["offset"] is not None else "slot"

    slot_anchors = _slot_anchors(items)
    for item in items:
        slot_anchor = slot_anchors.get(str(item["slot"]), (0.0, 0.0))
        item["slotAnchor"] = {"x": slot_anchor[0], "y": slot_anchor[1]}
        if item["targetSource"] == "slot":
            item["target"] = {"x": slot_anchor[0], "y": slot_anchor[1]}

    return {
        "schemaVersion": SCHEMA_VERSION,
        "generatedBy": "scripts/prepare_wardrobe_items.py",
        "slotOrder": SLOT_ORDER,
        "slotAnchors": {
            slot: {"x": point[0], "y": point[1]}
            for slot, point in sorted(slot_anchors.items())
        },
        "items": items,
    }


def _dart(manifest: dict[str, object]) -> str:
    items = manifest["items"]
    assert isinstance(items, list)

    lines = [
        "// GENERATED FILE - do not edit by hand.",
        "// Run: python3 scripts/prepare_wardrobe_items.py",
        "//",
        "// The wardrobe is described by the art: anchor point and hit shape come",
        "// from each WebP's opaque bounding box, z-order from the slot, and",
        "// `target` is where the anchor should land on the character. The",
        "// hand-tuned `offset`/`renderScale` pair is kept below only so an audit",
        "// can hold `target` against it.",
        "",
        "/// Manifest schema version. Bump together with the generator.",
        f"const int wardrobeManifestSchemaVersion = {manifest['schemaVersion']};",
        "",
        "/// Drawing order of the slots, bottom to top.",
        "const List<String> wardrobeZOrder = <String>[",
        *[f"  '{slot}'," for slot in manifest["slotOrder"]],
        "];",
        "",
        "/// One wearable item, as derived from its image.",
        "class WardrobeManifestEntry {",
        "  const WardrobeManifestEntry({",
        "    required this.id,",
        "    required this.name,",
        "    required this.slot,",
        "    required this.zOrder,",
        "    required this.showInWardrobe,",
        "    required this.asset,",
        "    required this.imageWidth,",
        "    required this.imageHeight,",
        "    required this.anchorX,",
        "    required this.anchorY,",
        "    required this.targetX,",
        "    required this.targetY,",
        "    required this.hitWidthFactor,",
        "    required this.hitHeightFactor,",
        "    required this.hitPaddingFactor,",
        "    this.hitOverrideWidthFactor,",
        "    this.hitOverrideHeightFactor,",
        "    this.hitOverridePaddingFactor,",
        "    required this.offsetX,",
        "    required this.offsetY,",
        "    required this.renderScale,",
        "  });",
        "",
        "  final String id;",
        "  final String name;",
        "  final String slot;",
        "",
        "  /// Layer in the character stack; -1 when the item is not worn.",
        "  final int zOrder;",
        "  final bool showInWardrobe;",
        "  final String asset;",
        "  final int imageWidth;",
        "  final int imageHeight;",
        "",
        "  /// Where the visible part of the image sits, as a fraction of it.",
        "  final double anchorX;",
        "  final double anchorY;",
        "",
        "  /// Tap target measured from the art, as factors of the image.",
        "  final double hitWidthFactor;",
        "  final double hitHeightFactor;",
        "  final double hitPaddingFactor;",
        "",
        "  /// Hand-tuned tap target, when someone has tuned one for small fingers.",
        "  final double? hitOverrideWidthFactor;",
        "  final double? hitOverrideHeightFactor;",
        "  final double? hitOverridePaddingFactor;",
        "",
        "  /// What the renderer should use: the hand-tuned value, else the art.",
        "  double get hitWidth => hitOverrideWidthFactor ?? hitWidthFactor;",
        "  double get hitHeight => hitOverrideHeightFactor ?? hitHeightFactor;",
        "  double get hitPadding =>",
        "      hitOverridePaddingFactor ?? hitPaddingFactor;",
        "",
        "  /// Where the item's anchor point should land, measured from the",
        "  /// character's centre as a fraction of its height.",
        "  final double targetX;",
        "  final double targetY;",
        "",
        "  /// Hand-tuned values carried over from `InventoryConfig`.",
        "  final double offsetX;",
        "  final double offsetY;",
        "  final double renderScale;",
        "}",
        "",
        "/// Every item in `InventoryConfig.allItems`, described by its art.",
        "const List<WardrobeManifestEntry> wardrobeManifest = <WardrobeManifestEntry>[",
    ]

    for item in items:
        assert isinstance(item, dict)
        image = item["image"]
        anchor = item["anchor"]
        hit = item["hitShape"]
        legacy = item["legacy"]
        override = item.get("hitShapeOverride")
        assert isinstance(image, dict)
        assert isinstance(anchor, dict)
        assert isinstance(hit, dict)
        assert isinstance(legacy, dict)
        # The renderer reads `target`; these two are only a paper trail.
        offset = legacy["offset"] or [0.0, 0.0]
        assert isinstance(offset, list)

        lines += [
            "  WardrobeManifestEntry(",
            f"    id: '{item['id']}',",
            f"    name: '{item['name']}',",
            f"    slot: '{item['slot']}',",
            f"    zOrder: {item['zOrder']},",
            f"    showInWardrobe: {str(item['showInWardrobe']).lower()},",
            f"    asset: '{item['asset']}',",
            f"    imageWidth: {image['width']},",
            f"    imageHeight: {image['height']},",
            f"    anchorX: {anchor['x']},",
            f"    anchorY: {anchor['y']},",
            f"    targetX: {item['target']['x']},",
            f"    targetY: {item['target']['y']},",
            f"    hitWidthFactor: {hit['widthFactor']},",
            f"    hitHeightFactor: {hit['heightFactor']},",
            f"    hitPaddingFactor: {hit['paddingFactor']},",
            *[
                f"    {name}: {value},"
                for name, value in (
                    (
                        "hitOverrideWidthFactor",
                        override["widthFactor"] if override else None,
                    ),
                    (
                        "hitOverrideHeightFactor",
                        override["heightFactor"] if override else None,
                    ),
                    (
                        "hitOverridePaddingFactor",
                        override["paddingFactor"] if override else None,
                    ),
                )
                if value is not None
            ],
            f"    offsetX: {offset[0]},",
            f"    offsetY: {offset[1]},",
            f"    renderScale: {legacy['renderScale']},",
            "  ),",
        ]

    lines += [
        "];",
        "",
        "final Map<String, WardrobeManifestEntry> _wardrobeById =",
        "    <String, WardrobeManifestEntry>{",
        "  for (final entry in wardrobeManifest) entry.id: entry,",
        "};",
        "",
        "/// The manifest entry for [itemId], or null when the id is unknown.",
        "///",
        "/// Callers fall back rather than crash: an item id in an old profile can",
        "/// outlive the catalog that produced it.",
        "WardrobeManifestEntry? wardrobeEntryFor(String itemId) =>",
        "    _wardrobeById[itemId];",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if the generated files are stale instead of writing them",
    )
    args = parser.parse_args()

    manifest = build()
    json_text = json.dumps(manifest, indent=2, ensure_ascii=False) + "\n"
    dart_text = _dart(manifest)

    if args.check:
        stale = [
            path
            for path, expected in ((MANIFEST_JSON, json_text), (MANIFEST_DART, dart_text))
            if not path.exists() or path.read_text(encoding="utf-8") != expected
        ]
        if stale:
            print("Stale manifest files, run the script without --check:")
            for path in stale:
                print(f"  {path.relative_to(ROOT)}")
            return 1
        print("Wardrobe manifest is up to date.")
        return 0

    MANIFEST_JSON.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_JSON.write_text(json_text, encoding="utf-8")
    MANIFEST_DART.write_text(dart_text, encoding="utf-8")

    items = manifest["items"]
    assert isinstance(items, list)
    print(f"Wrote {len(items)} items to:")
    print(f"  {MANIFEST_JSON.relative_to(ROOT)}")
    print(f"  {MANIFEST_DART.relative_to(ROOT)}")
    for item in items:
        assert isinstance(item, dict)
        anchor = item["anchor"]
        assert isinstance(anchor, dict)
        print(
            f"  {item['id']:<28} {item['slot']:<10} z={item['zOrder']} "
            f"anchor=({anchor['x']}, {anchor['y']}) "
            f"target=({item['target']['x']}, {item['target']['y']})"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
