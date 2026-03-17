# Asset Generation (How-To)

This guide describes how to generate, review and promote assets in Siffersafari.

Core rule:
- only approved production assets belong in `assets/`
- previews, experiments and review material belong in `artifacts/`

## Quick Start

```bash
flutter pub get

python tools/create_character.py --name "Mira" --brief "space explorer with teal jacket and gold backpack"
python tools/refresh_character.py --slug loke
dart run scripts/generate_sfx_wav.dart --prompt "bell chime" --output artifacts/bell.wav
dart run scripts/generate_android_launcher_icons.dart --input assets/images/app_logo.png --output android/app/src/main/res/
```

## AI-Driven Asset Pipeline

### Automated generators

```bash
# Create a fully registered SVG-first character from a short brief
python tools/create_character.py --name "Mira" --brief "space explorer with teal jacket and gold backpack"
# -> assets/characters/mira/config/*.json
# -> assets/characters/mira/svg/*.svg
# -> artifacts/mira_rive_blueprint.json
# -> artifacts/MIRA_RIVE_GUIDE.md
# -> specs/*.yaml
# -> artifacts/asset_pipeline_manifest.json
# -> lib/gen/assets.g.dart

# Refresh an existing generator-backed character from its current config
python tools/refresh_character.py --slug loke
# -> updates assets/characters/loke/config/loke_visual_spec.json
# -> updates assets/characters/loke/svg/*.svg
# -> updates artifacts/loke_rive_blueprint.json
# -> updates artifacts/LOKE_RIVE_GUIDE.md
# -> updates artifacts/asset_pipeline_manifest.json
# -> updates lib/gen/assets.g.dart

# Generate mascot SVG parts
dart run scripts/generate_mascot_svg_parts.dart
# -> assets/characters/mascot/svg/*.svg

# Generate approved UI effects
dart run scripts/generate_lottie_effects.dart
# -> assets/ui/lottie/*.json

# Generate Rive rigging blueprint
dart run scripts/generate_rive_blueprint.dart
# -> artifacts/mascot_rive_blueprint.json
# -> artifacts/MASCOT_RIVE_GUIDE.md

# Orchestrate current asset pipeline + manifest + typed asset access
python tools/pipeline.py build-all
# -> artifacts/asset_pipeline_manifest.json
# -> lib/gen/assets.g.dart
```

### Output classification

| Asset type | Generator | Output | Status |
| --- | --- | --- | --- |
| New SVG-first character | `tools/create_character.py` | character folder + specs + blueprint + codegen | Fully automated |
| Refresh existing SVG-first character | `tools/refresh_character.py` | regenerated visual spec + SVG assets + blueprint + codegen | Safe refresh, preserves animation spec |
| SVG parts | `generate_mascot_svg_parts.dart` | `assets/characters/mascot/svg/*.svg` | Approved generated runtime/source assets |
| Lottie UI effects | `generate_lottie_effects.dart` | confetti, stars, success_pulse, error_shake | Approved runtime UI effects |
| Rive blueprint | `generate_rive_blueprint.dart` | JSON + guide for optional rigging | Optional blueprint only |

Important limitation:
- no script in this repo produces a production-ready `.riv` automatically
- this is acceptable because the default app runtime now uses generated SVG/composite assets and does not require a `.riv`

## Recommended Workflow

1. Create a new character from a short brief, or generate/update candidate assets
2. Review them in `artifacts/` or in dedicated preview surfaces
3. Run `python tools/pipeline.py validate --strict` and `python tools/pipeline.py manifest`
4. Promote only approved runtime files into `assets/`
5. Verify in app
6. Commit only the approved runtime artifacts and their source specs/scripts

## Runtime Policy For The Mascot

- Use the generated composite SVG as the default runtime character path
- Use `assets/ui/lottie/` for approved UI effects only
- Treat `.riv` files as optional enhancement assets only when explicitly approved and enabled
- Do not use preview files as hidden runtime fallback in product UI
- Simple mascot feedback motion should stay automatable in Flutter/SVG rather than depend on manual editor exports

## Organize Approved Assets

```bash
cp artifacts/jungle/background_v3.png assets/images/themes/jungle/background.png
cp artifacts/mascot/mascot_character.riv assets/characters/mascot/rive/mascot_character.riv
cp artifacts/ui/confetti.json assets/ui/lottie/confetti.json
```

Note:
- copying a `.riv` into `assets/characters/mascot/rive/` is only valid after it has been manually verified to contain artboard `Mascot` and state machine `MascotStateMachine`

## Pre-flight Checks

```bash
rg "assets/images|assets/characters|assets/ui/lottie|assets/sounds" pubspec.yaml
Get-ChildItem assets -Recurse | Measure-Object -Property Length -Sum
flutter analyze
flutter test
```
