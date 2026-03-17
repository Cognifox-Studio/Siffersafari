#!/usr/bin/env python3
"""Simple asset pipeline orchestrator for Siffersafari.

This script is the first practical layer of the spec-driven pipeline described
in docs/TT2_Research_v2.md. It keeps the existing Dart generators as the source
of truth for generated outputs, while adding:

- YAML specs for stable asset IDs and references
- validation of the current repo structure and specs
- manifest generation for future tooling
- direct generation of lib/gen/assets.g.dart for Flutter

Examples:
    python tools/pipeline.py build-all
    python tools/pipeline.py build-svg
    python tools/pipeline.py manifest
    python tools/pipeline.py validate --strict
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

try:
    import yaml
except ImportError:
    yaml = None


ROOT = Path(__file__).resolve().parents[1]
ARTIFACTS_DIR = ROOT / "artifacts"
ASSETS_DIR = ROOT / "assets"
SPECS_DIR = ROOT / "specs"
LIB_GEN_DIR = ROOT / "lib" / "gen"
MANIFEST_PATH = ARTIFACTS_DIR / "asset_pipeline_manifest.json"
GENERATED_DART_PATH = LIB_GEN_DIR / "assets.g.dart"
DART_EXECUTABLE = shutil.which("dart") or shutil.which("dart.bat")


def repo_path(*parts: str) -> Path:
    return ROOT.joinpath(*parts)


SPEC_FILES = {
    "characters": SPECS_DIR / "characters.yaml",
    "ui_effects": SPECS_DIR / "ui_effects.yaml",
    "effects": SPECS_DIR / "effects.yaml",
    "rigs": SPECS_DIR / "rigs.yaml",
    "palettes": SPECS_DIR / "palettes.yaml",
}


@dataclass(frozen=True)
class Step:
    name: str
    command: tuple[str, ...]
    expected_outputs: tuple[Path, ...]


SVG_OUTPUTS = tuple(
    repo_path("assets", "characters", "mascot", "svg", f"{name}.svg")
    for name in (
        "mascot_head",
        "mascot_eyes_open",
        "mascot_eyes_closed",
        "mascot_mouth_smile",
        "mascot_mouth_sad",
        "mascot_mouth_neutral",
        "mascot_body",
        "mascot_arm_left",
        "mascot_arm_right",
        "mascot_leg_left",
        "mascot_leg_right",
        "mascot_antennas",
    )
)

LOTTIE_OUTPUTS = tuple(
    repo_path("assets", "ui", "lottie", f"{name}.json")
    for name in (
        "confetti",
        "stars",
        "success_pulse",
        "error_shake",
    )
)

STEPS = {
    "svg": Step(
        name="SVG parts",
        command=(DART_EXECUTABLE or "dart", "run", "scripts/generate_mascot_svg_parts.dart"),
        expected_outputs=SVG_OUTPUTS,
    ),
    "lottie": Step(
        name="Lottie effects",
        command=(DART_EXECUTABLE or "dart", "run", "scripts/generate_lottie_effects.dart"),
        expected_outputs=LOTTIE_OUTPUTS,
    ),
    "rive": Step(
        name="Rive blueprint",
        command=(DART_EXECUTABLE or "dart", "run", "scripts/generate_rive_blueprint.dart"),
        expected_outputs=(
            repo_path("artifacts", "mascot_rive_blueprint.json"),
            repo_path("artifacts", "MASCOT_RIVE_GUIDE.md"),
        ),
    ),
    "composite": Step(
        name="Mascot composite",
        command=(DART_EXECUTABLE or "dart", "run", "scripts/generate_mascot_composite.dart"),
        expected_outputs=(
            repo_path("assets", "characters", "mascot", "svg", "mascot_composite.svg"),
        ),
    ),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run the asset pipeline for this repo.",
    )
    parser.add_argument(
        "command",
        choices=(
            "build-all",
            "build-svg",
            "build-lottie",
            "build-rive",
            "build-composite",
            "validate",
            "manifest",
            "codegen",
        ),
        help="Pipeline action to run.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print commands without executing them.",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Treat missing future-facing files such as specs/ as errors.",
    )
    return parser.parse_args()


def ensure_repo_layout(strict: bool) -> None:
    required = [
        repo_path("pubspec.yaml"),
        repo_path("scripts", "generate_mascot_svg_parts.dart"),
        repo_path("scripts", "generate_lottie_effects.dart"),
        repo_path("scripts", "generate_rive_blueprint.dart"),
        repo_path("scripts", "generate_mascot_composite.dart"),
        repo_path("assets", "characters", "mascot", "config", "mascot_visual_spec.json"),
        repo_path("assets", "characters", "mascot", "config", "mascot_animation_spec.json"),
    ]
    missing = [path for path in required if not path.exists()]
    if missing:
        joined = "\n".join(f"- {path.relative_to(ROOT)}" for path in missing)
        raise SystemExit(f"Missing required pipeline inputs:\n{joined}")

    if DART_EXECUTABLE is None:
        raise SystemExit("'dart' was not found in PATH.")

    if yaml is None:
        raise SystemExit(
            "PyYAML is required for tools/pipeline.py. Install it with 'pip install pyyaml'."
        )

    if not SPECS_DIR.exists():
        message = "Warning: specs/ does not exist yet. The pipeline can still run current generators."
        if strict:
            raise SystemExit(message)
        print(message)


def read_yaml_file(path: Path) -> dict[str, Any]:
    if yaml is None:
        raise SystemExit(
            "PyYAML is required for tools/pipeline.py. Install it with 'pip install pyyaml'."
        )
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise SystemExit(f"Spec file must contain a top-level object: {path.relative_to(ROOT)}")
    return data


def load_specs(strict: bool) -> dict[str, dict[str, Any]]:
    specs: dict[str, dict[str, Any]] = {}
    for key, path in SPEC_FILES.items():
        if not path.exists():
            message = f"Missing spec file: {path.relative_to(ROOT)}"
            if strict:
                raise SystemExit(message)
            print(f"Warning: {message}")
            specs[key] = {}
            continue
        specs[key] = read_yaml_file(path)
    return specs


def expect_list(specs: dict[str, dict[str, Any]], key: str, top_level: str) -> list[dict[str, Any]]:
    data = specs.get(key, {})
    value = data.get(top_level, [])
    if value is None:
        return []
    if not isinstance(value, list):
        raise SystemExit(f"Spec section '{top_level}' in {SPEC_FILES[key].relative_to(ROOT)} must be a list")
    for item in value:
        if not isinstance(item, dict):
            raise SystemExit(f"Each entry in '{top_level}' must be an object")
    return value


def validate_unique_ids(items: list[dict[str, Any]], label: str) -> None:
    seen: set[str] = set()
    duplicates: list[str] = []
    for item in items:
        item_id = item.get("id")
        if not isinstance(item_id, str) or not item_id:
            raise SystemExit(f"Every {label} entry must have a non-empty string id")
        if item_id in seen:
            duplicates.append(item_id)
        seen.add(item_id)
    if duplicates:
        joined = ", ".join(sorted(set(duplicates)))
        raise SystemExit(f"Duplicate ids in {label}: {joined}")


def validate_specs(specs: dict[str, dict[str, Any]]) -> dict[str, list[dict[str, Any]]]:
    characters = expect_list(specs, "characters", "characters")
    ui_effects = expect_list(specs, "ui_effects", "ui_effects")
    effects = expect_list(specs, "effects", "effects")
    rigs = expect_list(specs, "rigs", "rigs")
    palettes = expect_list(specs, "palettes", "palettes")

    validate_unique_ids(characters, "characters")
    validate_unique_ids(ui_effects, "ui_effects")
    validate_unique_ids(effects, "effects")
    validate_unique_ids(rigs, "rigs")
    validate_unique_ids(palettes, "palettes")

    rig_ids = {rig["id"] for rig in rigs}
    palette_ids = {palette["id"] for palette in palettes}

    for character in characters:
        for field_name in ("visual_spec", "animation_spec"):
            target = character.get(field_name)
            if not isinstance(target, str) or not target:
                raise SystemExit(f"Character '{character['id']}' is missing '{field_name}'")
            if not repo_path(*target.split("/")).exists():
                raise SystemExit(
                    f"Character '{character['id']}' references missing file: {target}"
                )

        outputs = character.get("outputs")
        if not isinstance(outputs, dict):
            raise SystemExit(f"Character '{character['id']}' is missing 'outputs'")
        for field_name in ("svg_parts_dir", "composite_svg", "rive_runtime", "rive_blueprint"):
            target = outputs.get(field_name)
            if not isinstance(target, str) or not target:
                raise SystemExit(
                    f"Character '{character['id']}' is missing 'outputs.{field_name}'"
                )

        if character.get("rig") not in rig_ids:
            raise SystemExit(
                f"Character '{character['id']}' references unknown rig '{character.get('rig')}'"
            )

        if character.get("palette") not in palette_ids:
            raise SystemExit(
                f"Character '{character['id']}' references unknown palette '{character.get('palette')}'"
            )

    for ui_effect in ui_effects:
        effect_file = ui_effect.get("file")
        if not isinstance(effect_file, str) or not effect_file:
            raise SystemExit(f"UI effect '{ui_effect['id']}' is missing 'file'")

    return {
        "characters": characters,
        "ui_effects": ui_effects,
        "effects": effects,
        "rigs": rigs,
        "palettes": palettes,
    }


def run_step(step: Step, dry_run: bool) -> None:
    command_text = " ".join(step.command)
    print(f"[run] {step.name}: {command_text}")
    if dry_run:
        return

    result = subprocess.run(step.command, cwd=ROOT, check=False)
    if result.returncode != 0:
        raise SystemExit(f"Step failed: {step.name}")

    missing_outputs = [path for path in step.expected_outputs if not path.exists()]
    if missing_outputs:
        joined = "\n".join(f"- {path.relative_to(ROOT)}" for path in missing_outputs)
        raise SystemExit(
            f"Step completed but expected outputs are missing for {step.name}:\n{joined}"
        )


def run_steps(step_keys: Iterable[str], dry_run: bool) -> None:
    for step_key in step_keys:
        run_step(STEPS[step_key], dry_run=dry_run)


def relative_files(root: Path, pattern: str) -> list[str]:
    return sorted(str(path.relative_to(ROOT)).replace("\\", "/") for path in root.glob(pattern))


def relative_file(path: Path) -> str:
    return str(path.relative_to(ROOT)).replace("\\", "/")


def optional_repo_path(value: Any) -> Path | None:
    if not isinstance(value, str) or not value:
        return None
    return repo_path(*value.split("/"))


def slug_to_enum_name(value: str) -> str:
    parts = re.split(r"[^a-zA-Z0-9]+", value)
    filtered = [part for part in parts if part]
    if not filtered:
        return "unknown"
    first = filtered[0].lower()
    rest = [part[:1].upper() + part[1:] for part in filtered[1:]]
    return first + "".join(rest)


def build_dart_codegen(validated_specs: dict[str, list[dict[str, Any]]], dry_run: bool) -> None:
    characters = validated_specs["characters"]
    ui_effects = validated_specs["ui_effects"]
    runtime_paths_by_id = {
        character["id"]: optional_repo_path(character["outputs"].get("rive_runtime"))
        for character in characters
    }

    character_cases = "\n".join(
        f"  {slug_to_enum_name(character['id'])}," for character in characters
    )
    ui_effect_cases = "\n".join(
        f"  {slug_to_enum_name(effect['id'])}," for effect in ui_effects
    )

    composite_switch = "\n".join(
        "    case CharacterId.{case_name}:\n      return '{path}';".format(
            case_name=slug_to_enum_name(character["id"]),
            path=character["outputs"]["composite_svg"],
        )
        for character in characters
    )

    rive_switch = "\n".join(
        "    case CharacterId.{case_name}:\n      return {path};".format(
            case_name=slug_to_enum_name(character["id"]),
            path=(
                f"'{relative_file(runtime_paths_by_id[character['id']])}'"
                if runtime_paths_by_id[character["id"]] is not None
                and runtime_paths_by_id[character["id"]].exists()
                else "null"
            ),
        )
        for character in characters
    )

    ui_effect_switch = "\n".join(
        "    case UiEffectId.{case_name}:\n      return '{path}';".format(
            case_name=slug_to_enum_name(effect["id"]),
            path=effect["file"],
        )
        for effect in ui_effects
    )

    dart_source = f"""// GENERATED CODE - DO NOT MODIFY BY HAND.
// Generated by tools/pipeline.py.

enum CharacterId {{
{character_cases}
}}

enum UiEffectId {{
{ui_effect_cases}
}}

final class AssetPaths {{
  const AssetPaths._();

  static String characterCompositeSvg(CharacterId id) {{
    switch (id) {{
{composite_switch}
    }}
  }}

  static String? characterRive(CharacterId id) {{
    switch (id) {{
{rive_switch}
    }}
  }}

  static bool characterHasRive(CharacterId id) {{
    return characterRive(id) != null;
  }}

  static String uiEffect(UiEffectId id) {{
    switch (id) {{
{ui_effect_switch}
    }}
  }}
}}
"""

    print(f"[write] {GENERATED_DART_PATH.relative_to(ROOT)}")
    if dry_run:
        return

    LIB_GEN_DIR.mkdir(parents=True, exist_ok=True)
    GENERATED_DART_PATH.write_text(dart_source, encoding="utf-8")


def build_manifest(validated_specs: dict[str, list[dict[str, Any]]], dry_run: bool) -> None:
    character_inputs = []
    character_outputs = []
    all_svg_parts: list[str] = []
    all_composite_svgs: list[str] = []
    all_rive_runtime: list[str] = []
    all_rive_blueprints: list[str] = []
    all_rive_guides: list[str] = []

    for character in validated_specs["characters"]:
        outputs = character["outputs"]
        svg_parts_dir = optional_repo_path(outputs.get("svg_parts_dir"))
        composite_svg = optional_repo_path(outputs.get("composite_svg"))
        rive_runtime = optional_repo_path(outputs.get("rive_runtime"))
        rive_blueprint = optional_repo_path(outputs.get("rive_blueprint"))
        rive_guide = optional_repo_path(outputs.get("rive_guide"))

        character_inputs.append(
            {
                "id": character["id"],
                "display_name": character.get("display_name"),
                "visual_spec": character["visual_spec"],
                "animation_spec": character["animation_spec"],
            }
        )

        svg_parts = relative_files(svg_parts_dir, "*.svg") if svg_parts_dir is not None else []
        all_svg_parts.extend(svg_parts)

        if composite_svg is not None and composite_svg.exists():
            all_composite_svgs.append(relative_file(composite_svg))
        if rive_runtime is not None and rive_runtime.exists():
            all_rive_runtime.append(relative_file(rive_runtime))
        if rive_blueprint is not None and rive_blueprint.exists():
            all_rive_blueprints.append(relative_file(rive_blueprint))
        if rive_guide is not None and rive_guide.exists():
            all_rive_guides.append(relative_file(rive_guide))

        character_outputs.append(
            {
                "id": character["id"],
                "svg_parts": svg_parts,
                "composite_svg": relative_file(composite_svg) if composite_svg is not None else None,
                "rive_runtime": relative_file(rive_runtime) if rive_runtime is not None else None,
                "rive_runtime_exists": bool(rive_runtime is not None and rive_runtime.exists()),
                "rive_blueprint": relative_file(rive_blueprint) if rive_blueprint is not None else None,
                "rive_blueprint_exists": bool(rive_blueprint is not None and rive_blueprint.exists()),
                "rive_guide": relative_file(rive_guide) if rive_guide is not None else None,
                "rive_guide_exists": bool(rive_guide is not None and rive_guide.exists()),
            }
        )

    artifact_files = sorted(set(all_rive_blueprints + all_rive_guides))

    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "pipeline_version": 1,
        "notes": {
            "rive": "Only blueprint outputs are generated automatically right now. Final .riv files still require manual work in Rive.",
            "specs": "specs/ is now the stable ID and validation layer above the existing Dart generators.",
        },
        "inputs": {
            "character_specs": character_inputs,
            "specs_dir_exists": SPECS_DIR.exists(),
        },
        "specs": {
            "characters": [item["id"] for item in validated_specs["characters"]],
            "ui_effects": [item["id"] for item in validated_specs["ui_effects"]],
            "effects": [item["id"] for item in validated_specs["effects"]],
            "rigs": [item["id"] for item in validated_specs["rigs"]],
            "palettes": [item["id"] for item in validated_specs["palettes"]],
        },
        "outputs": {
            "characters": character_outputs,
            "character_svg_parts": sorted(set(all_svg_parts)),
            "character_composite_svg": sorted(set(all_composite_svgs)),
            "character_rive_runtime": sorted(set(all_rive_runtime)),
            "character_rive_blueprints": sorted(set(all_rive_blueprints)),
            "character_rive_guides": sorted(set(all_rive_guides)),
            "ui_lottie": relative_files(repo_path("assets", "ui", "lottie"), "*.json"),
            "artifacts": artifact_files,
            "dart_codegen": [str(GENERATED_DART_PATH.relative_to(ROOT)).replace("\\", "/")],
        },
    }

    print(f"[write] {MANIFEST_PATH.relative_to(ROOT)}")
    if dry_run:
        return

    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2), encoding="utf-8")


def main() -> None:
    args = parse_args()
    ensure_repo_layout(strict=args.strict)
    specs = load_specs(strict=args.strict)
    validated_specs = validate_specs(specs)

    command_to_steps = {
        "build-all": ("svg", "lottie", "rive", "composite"),
        "build-svg": ("svg",),
        "build-lottie": ("lottie",),
        "build-rive": ("rive",),
        "build-composite": ("composite",),
    }

    if args.command == "validate":
        print(
            "Validation completed: "
            f"{len(validated_specs['characters'])} character(s), "
            f"{len(validated_specs['ui_effects'])} UI effect(s), "
            f"{len(validated_specs['rigs'])} rig(s)."
        )
        return

    if args.command == "manifest":
        build_manifest(validated_specs, dry_run=args.dry_run)
        build_dart_codegen(validated_specs, dry_run=args.dry_run)
        print("Manifest completed.")
        return

    if args.command == "codegen":
        build_dart_codegen(validated_specs, dry_run=args.dry_run)
        print("Codegen completed.")
        return

    run_steps(command_to_steps[args.command], dry_run=args.dry_run)
    build_manifest(validated_specs, dry_run=args.dry_run)
    build_dart_codegen(validated_specs, dry_run=args.dry_run)
    print("Pipeline completed.")


if __name__ == "__main__":
    main()
