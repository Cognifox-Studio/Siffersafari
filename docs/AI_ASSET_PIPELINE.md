# AI Asset Pipeline Quick Reference

Purpose: generate visual assets through code, while keeping production assets separate from previews.

## Quick Commands

```bash
python tools/create_character.py --name "Mira" --brief "space explorer with teal jacket and gold backpack"
python tools/refresh_character.py --slug loke
dart run scripts/generate_mascot_svg_parts.dart
dart run scripts/generate_lottie_effects.dart
dart run scripts/generate_rive_blueprint.dart
python tools/pipeline.py build-all
```

## What Gets Generated

### 1. New Character From Brief
- Generator: `tools/create_character.py`
- Input: character name + plain-language brief
- Output:
  - `assets/characters/<slug>/config/*.json`
  - `assets/characters/<slug>/svg/*.svg`
  - `artifacts/<slug>_rive_blueprint.json`
  - `artifacts/<SLUG>_RIVE_GUIDE.md`
  - updated `specs/*.yaml`
  - updated `artifacts/asset_pipeline_manifest.json`
  - updated `lib/gen/assets.g.dart`

This is the main zero-manual-step flow for new SVG-first characters.

### 2. Refresh Existing Character
- Generator: `tools/refresh_character.py`
- Input: existing character slug, plus optional replacement brief/theme override
- Output:
  - updated `assets/characters/<slug>/config/<slug>_visual_spec.json`
  - updated `assets/characters/<slug>/svg/*.svg`
  - updated `artifacts/<slug>_rive_blueprint.json`
  - updated `artifacts/<SLUG>_RIVE_GUIDE.md`
  - updated `artifacts/asset_pipeline_manifest.json`
  - updated `lib/gen/assets.g.dart`

This is the safe refresh path for generator-backed characters when we want new proportions or layout logic without overwriting the current animation spec.

### 3. Mascot SVG Parts
- Generator: `scripts/generate_mascot_svg_parts.dart`
- Input: `assets/characters/mascot/config/mascot_visual_spec.json`
- Output: `assets/characters/mascot/svg/*.svg`

These SVGs are generated production assets. The composite SVG is the default runtime character in app, and the segmented parts can also be reused for optional Rive work later.

### 4. Lottie UI Effects
- Generator: `scripts/generate_lottie_effects.dart`
- Output: `assets/ui/lottie/*.json`

Generated runtime UI effects:
- `confetti.json`
- `stars.json`
- `success_pulse.json`
- `error_shake.json`

### 5. Rive Blueprint
- Generator: `scripts/generate_rive_blueprint.dart`
- Input: `assets/characters/mascot/config/mascot_animation_spec.json`
- Output:
  - `artifacts/mascot_rive_blueprint.json`
  - `artifacts/MASCOT_RIVE_GUIDE.md`

This is optional blueprint material for later Rive work, not a required runtime step.

Current rule:
- the repo fully generates the default runtime character path via SVG/composite assets
- the repo can also generate the inputs for optional Rive work, but not the final `.riv`

## File Policy

Use this separation:

```text
assets/characters/<slug>/config/   source of truth
assets/characters/<slug>/svg/      generated runtime character assets + rigging input
assets/characters/<slug>/rive/     optional runtime enhancement assets
assets/ui/lottie/                  approved runtime UI effects
artifacts/                         previews, references, blueprints, review material
```

## Recommended Workflow

1. Describe a new character with `tools/create_character.py`, or refresh an existing generator-backed character with `tools/refresh_character.py`
2. Regenerate outputs when needed
3. Run the pipeline manifest/codegen step
4. Review preview/reference material outside the product UI
5. Promote only approved runtime assets into `assets/`
6. Verify in app
7. Commit source spec, script changes and approved runtime outputs

## Important Rule

Do not treat preview motion or experimental outputs as runtime fallback in product code.

Current mascot runtime policy:
- mascot surfaces use the approved composite SVG path by default
- optional `.riv` files are an enhancement layer, not a release blocker
- Lottie remains for approved UI effects, not for theme-level mascot state fallbacks
- if a future `.riv` is added and explicitly enabled, the app can still use it
