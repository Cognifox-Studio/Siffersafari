# Character Animations

Goal: keep one clear animation architecture for runtime, and keep previews isolated from the app.

## Direction
Current direction is hybrid:
- Rive for interactive characters in product UI
- Lottie for approved UI effects
- Preview labs in `artifacts/animation_preview/`

This means:
- no preview widgets embedded in product screens
- no hidden fallback from runtime character rendering to preview motion files
- no mixing of approved runtime assets and lab material

## Runtime Roles
- `VilleCharacter` is the triggered runtime widget for home, quiz and results
- `ThemeMascot.withState` is the passive mascot surface for simple state-based rendering
- `AppThemeConfig` decides whether runtime should prefer approved Rive or approved Lottie fallback states

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
  ville/
    config/   source of truth for specs
    svg/      rig/export input plus static fallback
    rive/     approved runtime character asset

assets/animations/
  ville_jungle_idle.json
  ville_jungle_happy.json
  ville_jungle_celebrate.json
  ville_jungle_error.json

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

## Widget Usage
```dart
ThemeMascot.withState(
  appThemeConfig: themeCfg,
  state: CharacterAnimationState.idle,
  height: 120,
)

VilleCharacter(
  reaction: VilleReaction.answerCorrect,
  reactionNonce: nonce,
  height: 120,
)
```

## AppThemeConfig Notes
- `getCharacterAnimation(state)` should return approved state assets only
- `shouldUseRiveCharacter` should enable only approved runtime Rive assets
- if approved runtime animation is unavailable, fallback should be explicit and safe

## Current Cleanup Status
- product UI no longer embeds `LokeWalkCharacter` as a demo on home
- preview motion is no longer used as runtime fallback
- preview material remains available for iteration under `artifacts/animation_preview/`
