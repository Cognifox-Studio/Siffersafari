#!/usr/bin/env python3
"""Refresh an existing SVG-first character from its current config."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


SCRIPT_ROOT = Path(__file__).resolve().parents[1]
if str(SCRIPT_ROOT) not in sys.path:
    sys.path.insert(0, str(SCRIPT_ROOT))

from tools import create_character as cc


STYLE_TO_THEME = {
    defaults["style"]: theme
    for theme, defaults in cc.THEME_DEFAULTS.items()
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Refresh an existing SVG-first character from its current config.",
    )
    parser.add_argument("--slug", required=True, help="Existing character slug/id to refresh.")
    parser.add_argument(
        "--brief",
        help="Optional replacement brief. If omitted, the existing inspiration text is reused.",
    )
    parser.add_argument(
        "--theme",
        choices=sorted(cc.THEME_DEFAULTS.keys()),
        help="Optional theme override. Otherwise inferred from the current visual spec.",
    )
    parser.add_argument(
        "--output-root",
        help="Optional alternate root for generated files. Useful for dry verification.",
    )
    parser.add_argument(
        "--skip-pipeline",
        action="store_true",
        help="Skip running tools/pipeline.py validate/manifest after writing files.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the refresh plan without writing files.",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"Missing required file: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit(f"Expected a JSON object in {path}")
    return data


def infer_theme(existing_visual: dict[str, Any], explicit_theme: str | None, brief: str) -> str:
    if explicit_theme is not None:
        return explicit_theme

    style = existing_visual.get("style")
    if isinstance(style, str) and style in STYLE_TO_THEME:
        return STYLE_TO_THEME[style]

    return cc.detect_theme(brief, None)


def completed_palette(existing_palette: dict[str, str], theme: str) -> dict[str, str]:
    palette = dict(existing_palette)
    defaults = cc.THEME_DEFAULTS[theme]["colors"]

    if "skin" not in palette:
        palette["skin"] = defaults["skin"]
    if "hair" not in palette:
        palette["hair"] = defaults["hair"]
    if "hat" not in palette:
        palette["hat"] = defaults["hat"]
    if "shirt" not in palette:
        palette["shirt"] = defaults["shirt"]
    if "overallsPrimary" not in palette:
        palette["overallsPrimary"] = defaults["overallsPrimary"]
    if "backpack" not in palette:
        palette["backpack"] = defaults["backpack"]
    if "shoe" not in palette:
        palette["shoe"] = defaults["shoe"]
    if "outline" not in palette:
        palette["outline"] = defaults["outline"]

    palette.setdefault("hatShadow", cc.darken(palette["hat"], 0.18))
    palette.setdefault("hatBand", cc.THEME_DEFAULTS[theme]["colors"]["accent"])
    palette.setdefault("overallsSecondary", cc.darken(palette["overallsPrimary"], 0.22))
    palette.setdefault("strap", cc.darken(palette["backpack"], 0.24))
    palette.setdefault("lace", cc.THEME_DEFAULTS[theme]["colors"]["accent"])
    palette.setdefault("sole", cc.lighten(palette["shoe"], 0.78))
    palette.setdefault("blush", cc.mix(palette["skin"], "#FF9AA2", 0.35))
    palette.setdefault("shadow", "#0000001A")
    palette.setdefault("eyes", cc.darken(palette["outline"], 0.18))
    palette.setdefault("mouth", cc.darken(palette["outline"], 0.18))
    return palette


def refresh_visual_spec(
    existing_visual: dict[str, Any],
    slug: str,
    name: str,
    brief: str,
    theme: str,
    palette: dict[str, str],
) -> dict[str, Any]:
    generated = cc.build_visual_spec(
        slug=slug,
        name=name,
        brief=brief,
        theme=theme,
        palette=palette,
        proportions=cc.default_proportions(theme),
    )
    refreshed = dict(existing_visual)
    refreshed.update(generated)
    refreshed["version"] = existing_visual.get("version", generated["version"])
    return refreshed


def main() -> None:
    args = parse_args()
    cc.ensure_yaml_available()

    output_root = Path(args.output_root).resolve() if args.output_root else SCRIPT_ROOT
    slug = cc.slugify(args.slug)

    visual_path = output_root / "assets" / "characters" / slug / "config" / f"{slug}_visual_spec.json"
    animation_path = output_root / "assets" / "characters" / slug / "config" / f"{slug}_animation_spec.json"
    existing_visual = load_json(visual_path)
    animation_spec = load_json(animation_path)

    name = existing_visual.get("name", slug)
    if not isinstance(name, str) or not name:
        raise SystemExit(f"Expected a non-empty character name in {visual_path}")

    existing_brief = existing_visual.get("inspiration")
    if isinstance(existing_brief, str) and existing_brief.strip():
        brief = args.brief or existing_brief.strip()
    elif args.brief:
        brief = args.brief.strip()
    else:
        brief = name

    theme = infer_theme(existing_visual, args.theme, brief)
    palette = completed_palette(existing_visual.get("colors", {}), theme)
    refreshed_visual = refresh_visual_spec(existing_visual, slug, name, brief, theme, palette)
    svg_parts = cc.part_svg_map(palette, theme, brief)
    blueprint = cc.build_blueprint(slug, name, brief, animation_spec)
    guide = cc.build_guide_markdown(slug, name, brief, animation_spec)

    plan = {
        "name": name,
        "slug": slug,
        "theme": theme,
        "brief": brief,
        "output_root": str(output_root),
        "preserve_animation_spec": True,
        "updated_files": {
            "visual_spec": f"assets/characters/{slug}/config/{slug}_visual_spec.json",
            "svg_parts": [f"assets/characters/{slug}/svg/{slug}_{part}.svg" for part in cc.SVG_PART_ORDER],
            "rive_blueprint": f"artifacts/{slug}_rive_blueprint.json",
            "rive_guide": f"artifacts/{slug.upper()}_RIVE_GUIDE.md",
            "manifest": "artifacts/asset_pipeline_manifest.json",
            "codegen": "lib/gen/assets.g.dart",
        },
    }

    if args.dry_run:
        print(json.dumps(plan, indent=2))
        return

    character_root = output_root / "assets" / "characters" / slug
    svg_dir = character_root / "svg"
    rive_dir = character_root / "rive"
    artifacts_dir = output_root / "artifacts"

    cc.write_json(visual_path, refreshed_visual)
    for part_name in cc.SVG_PART_ORDER:
        cc.write_text(svg_dir / f"{slug}_{part_name}.svg", svg_parts[part_name])

    cc.write_text(svg_dir / "README.md", cc.svg_readme(slug, name))
    cc.write_text(rive_dir / "README.md", cc.rive_readme(slug, name, animation_spec))
    cc.write_json(artifacts_dir / f"{slug}_rive_blueprint.json", blueprint)
    cc.write_text(artifacts_dir / f"{slug.upper()}_RIVE_GUIDE.md", guide)

    print(f"Refreshed character '{name}' ({slug}) in {output_root}")

    should_run_pipeline = (
        output_root == SCRIPT_ROOT
        and not args.skip_pipeline
        and (output_root / "tools" / "pipeline.py").exists()
    )
    if should_run_pipeline:
        cc.run_pipeline(output_root)
        print("Pipeline validate + manifest completed.")
    else:
        print("Skipped pipeline validate/manifest.")


if __name__ == "__main__":
    main()
