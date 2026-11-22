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
  * `legacy`    -- carried over untouched: the hand-tuned `offset`/`renderScale`
                   from today's catalog. They stay the source of truth until the
                   renderer is switched over, so running this script cannot change
                   how the game looks.

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
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:  # pragma: no cover - developer setup issue
    sys.exit("Pillow is required: pip install Pillow")

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "lib" / "domain" / "entities" / "inventory_item.dart"
HIT_SHAPES = (
    ROOT / "lib" / "presentation" / "widgets"
    / "game_character__inventory_helpers_part.dart"
)
MANIFEST_JSON = ROOT / "assets" / "wardrobe" / "manifest.json"
MANIFEST_DART = ROOT / "lib" / "domain" / "entities" / "wardrobe_manifest.g.dart"

# The layers the character draws, bottom to top. Order is behaviour, not taste:
# shoes under the shirt, a map on top of it, a hat above the face. Must match
# `_slotLayers` in `game_character.dart`; `wardrobe_slots_audit_test` enforces it.
SLOT_ORDER = ["back", "feet", "body", "face", "head", "accessory", "front"]

SCHEMA_VERSION = 1

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
                "offset": [
                    float(offset_match.group(1)),
                    float(offset_match.group(2)),
                ]
                if offset_match
                else [0.0, 0.0],
                "renderScale": float(scale_match.group(1))
                if scale_match
                else 0.5,
            }
        )

    return entries


def _hit_shape_overrides() -> dict[str, tuple[float, float, float]]:
    """Read the hand-tuned hit shapes out of the renderer.

    They were a `case 'item_x':` switch -- the last place where adding an item
    cost an edit in the widget. Their values are worth keeping (a hat's tap
    target was tuned for a seven-year-old's finger, not measured), so they move
    into the manifest as overrides instead of being thrown away with the switch.
    """
    source = HIT_SHAPES.read_text(encoding="utf-8")
    start = source.index("_getInteractiveHitShape")
    # Stop at the slot fallback: those are per-slot defaults, not per-item.
    end = source.index("switch (slot)", start)
    body = source[start:end]
    # Comments may sit between a case and its return; they carry no values.
    body = "\n".join(
        line for line in body.splitlines() if not line.strip().startswith("//")
    )

    pattern = re.compile(
        r"((?:\s*case '[^']+':)+)\s*"
        r"return \(widthFactor: ([\d.]+), heightFactor: ([\d.]+), "
        r"paddingFactor: ([\d.]+)\);"
    )

    overrides: dict[str, tuple[float, float, float]] = {}
    for match in pattern.finditer(body):
        case_block = match.group(1)
        values = (float(match.group(2)), float(match.group(3)), float(match.group(4)))
        for item_id in re.findall(r"case '([^']+)':", case_block):
            overrides[item_id] = values

    return overrides


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
                # Hand-tuned values stay the source of truth until the renderer
                # is switched over; they live here so the switch is one diff.
                "legacy": {
                    "offset": entry["offset"],
                    "renderScale": entry["renderScale"],
                },
            }
        )

    return {
        "schemaVersion": SCHEMA_VERSION,
        "generatedBy": "scripts/prepare_wardrobe_items.py",
        "slotOrder": SLOT_ORDER,
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
        "// from each WebP's opaque bounding box, z-order from the slot. `legacy`",
        "// holds the hand-tuned offset/scale that the renderer still uses, so this",
        "// file changes nothing on screen until `GameCharacter` reads it.",
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
        offset = legacy["offset"]
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
            f"anchor=({anchor['x']}, {anchor['y']})"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
