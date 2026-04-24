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
import xml.etree.ElementTree as ET
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
    "style_contract": SPECS_DIR / "style_contract.yaml",
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
    # mascot-specific — generate SVG body parts for the mascot character
    "mascot_parts": Step(
        name="Mascot SVG parts",
        command=(DART_EXECUTABLE or "dart", "run", "scripts/generate_mascot_svg_parts.dart"),
        expected_outputs=SVG_OUTPUTS,
    ),
    # mascot-specific — assemble final composite SVG for the mascot character
    "mascot_composite": Step(
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
            "lint-assets",
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
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Report lint violations as warnings without failing.",
    )
    parser.add_argument(
        "--report-path",
        type=str,
        default="",
        help="Optional JSON report path for lint results, relative to repo root.",
    )
    return parser.parse_args()


def ensure_repo_layout(strict: bool) -> None:
    required = [
        repo_path("pubspec.yaml"),
        repo_path("scripts", "generate_mascot_svg_parts.dart"),
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


def parse_positive_int(value: Any, fallback: int) -> int:
    if isinstance(value, int) and value > 0:
        return value
    if isinstance(value, str) and value.isdigit() and int(value) > 0:
        return int(value)
    return fallback


def parse_number(value: str) -> float | None:
    match = re.search(r"-?\d+(?:\.\d+)?", value)
    if not match:
        return None
    return float(match.group(0))


def parse_stroke_width_range(
    svg_contract: dict[str, Any],
    fallback: tuple[float, float] = (4.0, 14.0),
) -> tuple[float, float]:
    range_value = svg_contract.get("stroke_width_range")
    if not isinstance(range_value, list) or len(range_value) != 2:
        return fallback

    min_value = range_value[0]
    max_value = range_value[1]
    if not isinstance(min_value, (int, float)) or not isinstance(max_value, (int, float)):
        return fallback
    if min_value <= 0 or max_value <= 0 or min_value >= max_value:
        return fallback
    return (float(min_value), float(max_value))


def parse_string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [item for item in value if isinstance(item, str) and item]


def parse_bool(value: Any, fallback: bool) -> bool:
    if isinstance(value, bool):
        return value
    return fallback


def get_contract_file_override(contract: dict[str, Any], relative_path: str) -> dict[str, Any]:
    files = contract.get("files")
    if not isinstance(files, dict):
        return {}
    override = files.get(relative_path)
    if not isinstance(override, dict):
        return {}
    return override


def find_svg_files(
    validated_specs: dict[str, list[dict[str, Any]]],
    selected_character_ids: set[str] | None = None,
) -> list[Path]:
    files: set[Path] = set()
    for character in validated_specs["characters"]:
        character_id = character.get("id")
        if selected_character_ids is not None and character_id not in selected_character_ids:
            continue
        outputs = character["outputs"]
        svg_parts_dir = optional_repo_path(outputs.get("svg_parts_dir"))
        composite_svg = optional_repo_path(outputs.get("composite_svg"))

        if svg_parts_dir is not None and svg_parts_dir.exists():
            files.update(svg_parts_dir.glob("*.svg"))
        if composite_svg is not None and composite_svg.exists():
            files.add(composite_svg)

    return sorted(files)


def check_svg_valid_xml(path: Path, errors: list[str]) -> None:
    try:
        ET.fromstring(path.read_text(encoding="utf-8"))
    except ET.ParseError as exc:
        errors.append(f"{relative_file(path)} invalid XML: {exc}")


def lint_svg_files(
    svg_files: list[Path],
    svg_contract: dict[str, Any],
    errors: list[str],
) -> None:
    forbidden_tokens = svg_contract.get(
        "forbidden_tokens",
        ["<filter", "<mask", "<clippath", "<lineargradient", "<radialgradient", "<pattern"],
    )
    forbidden_tokens = [token.lower() for token in forbidden_tokens if isinstance(token, str)]
    max_paths_per_file = parse_positive_int(svg_contract.get("max_paths_per_file"), 140)
    max_hex_colors_per_file = parse_positive_int(svg_contract.get("max_hex_colors_per_file"), 14)
    stroke_min, stroke_max = parse_stroke_width_range(svg_contract)
    ignored_files = set(parse_string_list(svg_contract.get("ignore_files")))

    stroke_width_attribute = re.compile(r"stroke-width\s*=\s*['\"]([^'\"]+)['\"]", re.IGNORECASE)
    stroke_width_style = re.compile(r"stroke-width\s*:\s*([^;\"']+)", re.IGNORECASE)

    for svg_file in svg_files:
        relative_path = relative_file(svg_file)
        if relative_path in ignored_files:
            continue

        file_override = get_contract_file_override(svg_contract, relative_path)
        ignored_checks = set(parse_string_list(file_override.get("ignore_checks")))
        file_max_paths = parse_positive_int(
            file_override.get("max_paths_per_file"),
            max_paths_per_file,
        )
        file_max_hex_colors = parse_positive_int(
            file_override.get("max_hex_colors_per_file"),
            max_hex_colors_per_file,
        )
        file_stroke_min, file_stroke_max = parse_stroke_width_range(
            file_override,
            fallback=(stroke_min, stroke_max),
        )
        allowed_tokens_for_file = {
            token.lower()
            for token in parse_string_list(file_override.get("allow_forbidden_tokens"))
        }

        content = svg_file.read_text(encoding="utf-8")
        content_lower = content.lower()
        if "xml" not in ignored_checks:
            check_svg_valid_xml(svg_file, errors)

        if "forbidden_tokens" not in ignored_checks:
            for token in forbidden_tokens:
                if token in allowed_tokens_for_file:
                    continue
                if token and token in content_lower:
                    errors.append(
                        f"{relative_path} contains forbidden token '{token}'"
                    )

        path_count = len(re.findall(r"<path(?:\s|>)", content, flags=re.IGNORECASE))
        if "max_paths_per_file" not in ignored_checks and path_count > file_max_paths:
            errors.append(
                f"{relative_path} has {path_count} paths (max {file_max_paths})"
            )

        hex_colors = set(re.findall(r"#[0-9a-fA-F]{6}(?:[0-9a-fA-F]{2})?", content))
        if "max_hex_colors_per_file" not in ignored_checks and len(hex_colors) > file_max_hex_colors:
            errors.append(
                f"{relative_path} uses {len(hex_colors)} hex colors (max {file_max_hex_colors})"
            )

        stroke_values: list[float] = []
        for match in stroke_width_attribute.findall(content):
            parsed = parse_number(match)
            if parsed is not None:
                stroke_values.append(parsed)
        for match in stroke_width_style.findall(content):
            parsed = parse_number(match)
            if parsed is not None:
                stroke_values.append(parsed)

        if "stroke_width_range" not in ignored_checks:
            for value in stroke_values:
                if value < file_stroke_min or value > file_stroke_max:
                    errors.append(
                        f"{relative_path} has stroke-width {value} outside [{file_stroke_min}, {file_stroke_max}]"
                    )


def json_contains_expression(value: Any) -> bool:
    if isinstance(value, dict):
        expression = value.get("x")
        if isinstance(expression, str) and expression.strip():
            return True
        return any(json_contains_expression(child) for child in value.values())
    if isinstance(value, list):
        return any(json_contains_expression(child) for child in value)
    return False


def json_contains_key(value: Any, key: str) -> bool:
    if isinstance(value, dict):
        if key in value:
            return True
        return any(json_contains_key(child, key) for child in value.values())
    if isinstance(value, list):
        return any(json_contains_key(child, key) for child in value)
    return False


def lint_lottie_files(
    validated_specs: dict[str, list[dict[str, Any]]],
    lottie_contract: dict[str, Any],
    errors: list[str],
    selected_effect_ids: set[str] | None = None,
) -> None:
    max_layers = parse_positive_int(lottie_contract.get("max_layers_per_file"), 32)
    disallow_expressions = parse_bool(lottie_contract.get("disallow_expressions"), True)
    disallow_effects = parse_bool(lottie_contract.get("disallow_effects"), True)
    ignored_files = set(parse_string_list(lottie_contract.get("ignore_files")))

    for effect in validated_specs["ui_effects"]:
        effect_id = effect.get("id")
        if selected_effect_ids is not None and effect_id not in selected_effect_ids:
            continue
        file_path = effect.get("file")
        if not isinstance(file_path, str) or not file_path:
            continue
        if file_path in ignored_files:
            continue

        file_override = get_contract_file_override(lottie_contract, file_path)
        ignored_checks = set(parse_string_list(file_override.get("ignore_checks")))
        file_max_layers = parse_positive_int(file_override.get("max_layers_per_file"), max_layers)
        file_disallow_expressions = not parse_bool(
            file_override.get("allow_expressions"),
            not disallow_expressions,
        )
        file_disallow_effects = not parse_bool(
            file_override.get("allow_effects"),
            not disallow_effects,
        )

        path = optional_repo_path(file_path)
        if path is None or not path.exists():
            errors.append(f"Missing Lottie file: {file_path}")
            continue

        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append(f"{file_path} invalid JSON: {exc}")
            continue

        layers = data.get("layers")
        if "max_layers_per_file" not in ignored_checks and isinstance(layers, list) and len(layers) > file_max_layers:
            errors.append(f"{file_path} has {len(layers)} layers (max {file_max_layers})")

        if "expressions" not in ignored_checks and file_disallow_expressions and json_contains_expression(data):
            errors.append(f"{file_path} contains expressions (unsupported by contract)")

        if "effects" not in ignored_checks and file_disallow_effects and json_contains_key(data, "ef"):
            errors.append(f"{file_path} contains effects key 'ef' (unsupported by contract)")


def lint_assets(
    specs: dict[str, dict[str, Any]],
    validated_specs: dict[str, list[dict[str, Any]]],
    strict: bool,
    warn_only: bool,
    report_path: str,
) -> bool:
    contract = specs.get("style_contract", {})
    if not isinstance(contract, dict):
        raise SystemExit("specs/style_contract.yaml must contain a top-level object")

    svg_contract = contract.get("svg", {}) if isinstance(contract.get("svg"), dict) else {}
    lottie_contract = (
        contract.get("lottie", {}) if isinstance(contract.get("lottie"), dict) else {}
    )
    enforcement = contract.get("enforcement", {}) if isinstance(contract.get("enforcement"), dict) else {}
    pilot = contract.get("pilot", {}) if isinstance(contract.get("pilot"), dict) else {}

    default_warn_only = parse_bool(enforcement.get("default_warn_only"), False)
    effective_warn_only = warn_only or default_warn_only

    selected_character_ids: set[str] | None = None
    selected_effect_ids: set[str] | None = None
    if parse_bool(pilot.get("enabled"), False):
        character_ids = set(parse_string_list(pilot.get("character_ids")))
        effect_ids = set(parse_string_list(pilot.get("effect_ids")))
        selected_character_ids = character_ids if character_ids else None
        selected_effect_ids = effect_ids if effect_ids else None

    svg_files = find_svg_files(validated_specs, selected_character_ids=selected_character_ids)
    errors: list[str] = []

    if strict and not svg_files:
        errors.append("No SVG files were discovered from character outputs")

    lint_svg_files(svg_files, svg_contract, errors)
    lint_lottie_files(
        validated_specs,
        lottie_contract,
        errors,
        selected_effect_ids=selected_effect_ids,
    )

    report_data = {
        "mode": "warn" if effective_warn_only else "block",
        "strict": strict,
        "pilot_enabled": parse_bool(pilot.get("enabled"), False),
        "selected_character_ids": sorted(selected_character_ids) if selected_character_ids else [],
        "selected_effect_ids": sorted(selected_effect_ids) if selected_effect_ids else [],
        "svg_files_checked": len(svg_files),
        "ui_effects_configured": len(validated_specs["ui_effects"]),
        "violations": errors,
        "status": "failed" if errors and not effective_warn_only else ("warning" if errors else "passed"),
    }

    if report_path:
        report_file = optional_repo_path(report_path)
        if report_file is None:
            raise SystemExit(f"Invalid --report-path: {report_path}")
        report_file.parent.mkdir(parents=True, exist_ok=True)
        report_file.write_text(json.dumps(report_data, indent=2), encoding="utf-8")
        print(f"[write] {relative_file(report_file)}")

    if errors:
        joined = "\n".join(f"- {error}" for error in errors)
        if effective_warn_only:
            print(f"Asset style lint warning:\n{joined}")
            return False
        raise SystemExit(f"Asset style lint failed:\n{joined}")

    print(
        "Asset style lint passed: "
        f"{len(svg_files)} SVG file(s), {len(validated_specs['ui_effects'])} Lottie file(s)."
    )
    return True


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
        "build-all": ("mascot_parts", "mascot_composite"),
        "build-svg": ("mascot_parts",),
        "build-composite": ("mascot_composite"),
    }

    if args.command == "validate":
        print(
            "Validation completed: "
            f"{len(validated_specs['characters'])} character(s), "
            f"{len(validated_specs['ui_effects'])} UI effect(s), "
            f"{len(validated_specs['rigs'])} rig(s)."
        )
        return

    if args.command == "lint-assets":
        lint_assets(
            specs,
            validated_specs,
            strict=args.strict,
            warn_only=args.warn_only,
            report_path=args.report_path,
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
