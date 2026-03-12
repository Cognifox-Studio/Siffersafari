# AI Asset Pipeline Quick Reference

Purpose: generate visual assets through code, while keeping production assets separate from previews.

## Quick Commands

```bash
dart run scripts/generate_ville_svg_parts.dart
dart run scripts/generate_lottie_effects.dart
dart run scripts/generate_rive_blueprint.dart
```

## What Gets Generated

### 1. Ville SVG Parts
- Generator: `scripts/generate_ville_svg_parts.dart`
- Input: `assets/characters/ville/config/ville_visual_spec.json`
- Output: `assets/characters/ville/svg/*.svg`

These SVGs are source/input for rigging and also provide the static fallback composite.

### 2. Lottie UI Effects
- Generator: `scripts/generate_lottie_effects.dart`
- Output: `assets/ui/lottie/*.json`

Generated runtime UI effects:
- `confetti.json`
- `stars.json`
- `success_pulse.json`
- `error_shake.json`

### 3. Rive Blueprint
- Generator: `scripts/generate_rive_blueprint.dart`
- Input: `assets/characters/ville/config/ville_animation_spec.json`
- Output:
  - `artifacts/ville_rive_blueprint.json`
  - `artifacts/VILLE_RIVE_GUIDE.md`

This is a blueprint for manual Rive work, not a finished runtime character.

## File Policy

Use this separation:

```text
assets/characters/<slug>/config/   source of truth
assets/characters/<slug>/svg/      rigging input and static fallback
assets/characters/<slug>/rive/     approved runtime character assets
assets/ui/lottie/                  approved runtime UI effects
artifacts/                         previews, references, blueprints, review material
```

## Recommended Workflow

1. Update the spec
2. Regenerate outputs
3. Review preview/reference material outside the product UI
4. Promote only approved runtime assets into `assets/`
5. Verify in app
6. Commit source spec, script changes and approved runtime outputs

## Important Rule

Do not treat preview motion or experimental outputs as runtime fallback in product code.
