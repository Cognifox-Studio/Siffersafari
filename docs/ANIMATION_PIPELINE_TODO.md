# Animation Pipeline TODO (Rive + Lottie)

## Goal
Use Rive for characters and Lottie for UI effects, while keeping preview work outside the product UI.

## Runtime Structure
- `assets/characters/ville/config/`
- `assets/characters/ville/svg/`
- `assets/characters/ville/rive/`
- `assets/ui/lottie/`
- `artifacts/animation_preview/` for preview and motion labs only

## Specs
- [x] `assets/characters/ville/config/ville_visual_spec.json`
- [x] `assets/characters/ville/config/ville_animation_spec.json`

## Rive Build Requirements
In `assets/characters/ville/rive/ville_character.riv`:
- Artboard: `Ville`
- State machine: `VilleStateMachine`
- Triggers:
  - `answer_correct`
  - `answer_wrong`
  - `user_tap`
  - `screen_change`

## Flutter Integration
- [x] Add `rive` dependency
- [x] Add `VilleCharacter` widget
- [x] Wire triggers in home, quiz and results flows
- [x] Set `characterRiveAsset` in theme config
- [x] Remove preview walk fallback from runtime character rendering
- [ ] Replace placeholder/demo `.riv` with a production-approved export
- [ ] Review whether passive mascot surfaces should keep Lottie state fallbacks or move fully to approved Rive assets

## Current Runtime Notes
- `VilleCharacter` is the triggered runtime widget for `home_screen.dart`, `quiz_screen.dart` and `results_screen.dart`
- `ThemeMascot.withState` is for passive mascot rendering
- Preview/test motion belongs in `artifacts/animation_preview/`, not in product UI

## Lottie Policy
- Keep Lottie under `assets/ui/lottie/` for approved UI effects such as confetti, stars and feedback pulses
- Keep character Lottie files only if they are approved runtime state fallbacks
- Do not use preview walk cycles as runtime fallback for `VilleCharacter`
