# Animation Pipeline TODO (Rive + Lottie)

## Goal
Use Rive for characters (Ville) and Lottie for UI effects.

## Build Exact This
1. Create and maintain this structure:
  - assets/characters/ville/svg/
  - assets/characters/ville/rive/
  - assets/characters/ville/config/
  - assets/ui/lottie/
2. Keep visual + animation specs as single source of truth under config/
3. Build Ville in Rive with artboard `Ville` and state machine `VilleStateMachine`
4. Wire Flutter triggers from quiz flow: correct/wrong/tap/screen change
5. Keep Lottie only for UI effects (confetti/stars/pulses/shakes)

## Asset Structure
- assets/characters/ville/svg/
- assets/characters/ville/rive/
- assets/characters/ville/config/
- assets/ui/lottie/

## Specs
- [x] assets/characters/ville/config/ville_visual_spec.json
- [x] assets/characters/ville/config/ville_animation_spec.json

## Rive Build Requirements
In assets/characters/ville/rive/ville_character.riv:
- Artboard: Ville
- State machine: VilleStateMachine
- Triggers:
  - answer_correct
  - answer_wrong
  - user_tap
  - screen_change

Nodes / Components:
- root
- spine
- head
- eyes
- mouth
- arm_left
- arm_right
- leg_left
- leg_right
- antenna_left
- antenna_right

Animations:
- idle
- idle_blink
- happy
- very_happy
- sad
- confused
- react_tap
- enter
- exit

## Flutter Integration
- [x] Add rive dependency
- [x] Add VilleCharacter widget
- [x] Wire first quiz trigger to character reaction
- [ ] Add real .riv file and set characterRiveAsset in theme config
- [ ] Connect additional triggers in result/home transitions

## Current Integration Notes
- `VilleCharacter` exists in `lib/presentation/widgets/ville_character.dart`
- Quiz reactions are connected in `lib/presentation/screens/quiz_screen.dart`
- `ThemeMascot` + `CharacterAnimationPlayer` are Rive-ready with Lottie fallback

## Lottie Policy
- Keep Lottie under assets/ui/lottie for confetti/stars/pulses
- Keep character Lottie files only as fallback during migration
