# Asset Generation (How-To)

This guide describes how to generate, review and promote assets in Siffersafari.

Core rule:
- only approved production assets belong in `assets/`
- previews, experiments and review material belong in `artifacts/`

## Quick Start

```bash
flutter pub get

dart run scripts/generate_sfx_wav.dart --prompt "bell chime" --output artifacts/bell.wav
dart run scripts/generate_android_launcher_icons.dart --input assets/images/app_logo.png --output android/app/src/main/res/
```

## AI-Driven Asset Pipeline

### Automated generators

```bash
# Generate Ville SVG parts
dart run scripts/generate_ville_svg_parts.dart
# -> assets/characters/ville/svg/*.svg

# Generate approved UI effects
dart run scripts/generate_lottie_effects.dart
# -> assets/ui/lottie/*.json

# Generate Rive rigging blueprint
dart run scripts/generate_rive_blueprint.dart
# -> artifacts/ville_rive_blueprint.json
# -> artifacts/VILLE_RIVE_GUIDE.md
```

### Output classification

| Asset type | Generator | Output | Status |
| --- | --- | --- | --- |
| SVG parts | `generate_ville_svg_parts.dart` | `assets/characters/ville/svg/*.svg` | Approved source/input |
| Lottie UI effects | `generate_lottie_effects.dart` | confetti, stars, success_pulse, error_shake | Approved runtime UI effects |
| Rive blueprint | `generate_rive_blueprint.dart` | JSON + guide for manual rigging | Blueprint only |

## Recommended Workflow

1. Generate or create candidate assets
2. Review them in `artifacts/` or in dedicated preview surfaces
3. Promote only approved runtime files into `assets/`
4. Verify in app
5. Commit only the approved runtime artifacts and their source specs/scripts

## Runtime Policy For Ville

- Use `assets/characters/ville/rive/ville_character.riv` for runtime character animation when it is approved
- Use `assets/ui/lottie/` for approved UI effects only
- If runtime animation is not approved or the required state machine is missing, use a safe static fallback
- Do not use preview files as hidden runtime fallback in product UI

## Organize Approved Assets

```bash
cp artifacts/jungle/background_v3.png assets/images/themes/jungle/background.png
cp artifacts/ville/ville_character.riv assets/characters/ville/rive/ville_character.riv
cp artifacts/ui/confetti.json assets/ui/lottie/confetti.json
```

## Pre-flight Checks

```bash
rg "assets/images|assets/characters|assets/ui/lottie|assets/sounds" pubspec.yaml
Get-ChildItem assets -Recurse | Measure-Object -Property Length -Sum
flutter analyze
flutter test
```
