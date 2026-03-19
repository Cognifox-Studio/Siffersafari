# Character Animations

Goal: keep one clear animation architecture for runtime, and keep previews isolated from the app.

## Direction
Current direction is:
- SVG-first mascot runtime in product UI
- Lottie for approved UI effects
- Preview labs in `artifacts/animation_preview/`
- optional Rive outputs kept outside the active runtime path until a future explicit integration

Current hard rule for the mascot:
- the current product runtime uses the approved composite SVG
- simple mascot motion is handled in Flutter by `MascotCharacter`
- generated JSON blueprints and `.riv` files are optional preparation or enhancement material, not a required runtime dependency
- the checked-in `assets/characters/mascot/rive/mascot_character.riv` is still placeholder/demo material and is not used by the active runtime path

This means:
- no preview widgets embedded in product screens
- no hidden fallback from runtime character rendering to preview motion files
- no mixing of approved runtime assets and lab material

## Runtime Roles
- `MascotCharacter` is the triggered runtime widget for home, quiz and results
- `ThemeMascot.withState` is the passive mascot surface for simple state-based rendering
- current mascot runtime does not branch on theme-level Rive configuration

## Preview Roles
For Loke, Skogshjalte and future humanoids, animation work should move through this chain:
1. `reference_preview`
2. `still_preview`
3. `motion_lab`
4. `clean_preview`
5. `scene_preview`

Preview outputs are reference material only until they are explicitly approved and integrated.

## Canonical Preview Paths
- `artifacts/animation_preview/skogshjalte_walk_preview/`
- `artifacts/animation_preview/loke_walk_preview/`
- `artifacts/animation_preview/skogshjalte_pivot_clean_preview/`

## Runtime Asset Structure
Use this separation:

```text
assets/characters/
  mascot/
    config/   source of truth for specs
    svg/      generated runtime asset plus source material for further animation work
    rive/     optional future enhancement asset, not required by current runtime

assets/ui/lottie/
  confetti.json
  stars.json
  success_pulse.json
  error_shake.json

artifacts/animation_preview/
  ... preview and lab material only
```

## Integration Rules
1. Keep character specs in `assets/characters/<slug>/config/`
2. Put approved runtime `.riv` files in `assets/characters/<slug>/rive/`
3. Put approved UI effects in `assets/ui/lottie/`
4. Register runtime assets in `pubspec.yaml`
5. Do not treat preview material as runtime fallback
6. Do not treat blueprint generation as equivalent to a finished character export
7. Reintroduce runtime Rive only through an explicit product change, not through dormant config flags

## Widget Usage
```dart
ThemeMascot.withState(
  state: CharacterAnimationState.idle,
  height: 120,
)

MascotCharacter(
  reaction: MascotReaction.answerCorrect,
  reactionNonce: nonce,
  height: 120,
)
```

## AppThemeConfig Notes
- mascot-runtime no longer depends on dormant Rive flags in `AppThemeConfig`
- the safe runtime path for the mascot is the approved composite SVG, not theme-specific Lottie state files
- future Rive support should be added back only when a production-ready asset and a real runtime need both exist

## Current Cleanup Status
- product UI no longer embeds `LokeWalkCharacter` as a demo on home
- preview motion is no longer used as runtime fallback
- preview material remains available for iteration under `artifacts/animation_preview/`
- mascot surfaces now follow one shared SVG-first runtime path
