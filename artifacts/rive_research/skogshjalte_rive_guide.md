# Skogshjalte Rive Guide

Generated from brief: Original child forest hero with green tunic silhouette, blond hair and blue cape-inspired accessory

## Default Runtime
The default runtime asset for this character is the generated SVG composite:

`assets/characters/skogshjalte/svg/skogshjalte_composite.svg`

A `.riv` export is optional and not required for app integration.

## Source Files
- `assets/characters/skogshjalte/config/skogshjalte_visual_spec.json`
- `assets/characters/skogshjalte/config/skogshjalte_animation_spec.json`
- `assets/characters/skogshjalte/svg/skogshjalte_*.svg`
- `artifacts/skogshjalte_rive_blueprint.json`

## Optional Rive Import Order
1. `assets/characters/skogshjalte/svg/skogshjalte_shadow.svg`
2. `assets/characters/skogshjalte/svg/skogshjalte_backpack.svg`
3. `assets/characters/skogshjalte/svg/skogshjalte_leg_upper_left.svg`
4. `assets/characters/skogshjalte/svg/skogshjalte_leg_lower_left.svg`
5. `assets/characters/skogshjalte/svg/skogshjalte_shoe_left.svg`
6. `assets/characters/skogshjalte/svg/skogshjalte_arm_upper_left.svg`
7. `assets/characters/skogshjalte/svg/skogshjalte_arm_lower_left.svg`
8. `assets/characters/skogshjalte/svg/skogshjalte_torso.svg`
9. `assets/characters/skogshjalte/svg/skogshjalte_head.svg`
10. `assets/characters/skogshjalte/svg/skogshjalte_eyes_open.svg`
11. `assets/characters/skogshjalte/svg/skogshjalte_eyes_blink.svg`
12. `assets/characters/skogshjalte/svg/skogshjalte_mouth_neutral.svg`
13. `assets/characters/skogshjalte/svg/skogshjalte_mouth_happy.svg`
14. `assets/characters/skogshjalte/svg/skogshjalte_mouth_sad.svg`
15. `assets/characters/skogshjalte/svg/skogshjalte_hat.svg`
16. `assets/characters/skogshjalte/svg/skogshjalte_arm_upper_right.svg`
17. `assets/characters/skogshjalte/svg/skogshjalte_arm_lower_right.svg`
18. `assets/characters/skogshjalte/svg/skogshjalte_leg_upper_right.svg`
19. `assets/characters/skogshjalte/svg/skogshjalte_leg_lower_right.svg`
20. `assets/characters/skogshjalte/svg/skogshjalte_shoe_right.svg`

## Suggested State Machine
Name: `SkogshjalteStateMachine`

Inputs:
- `answer_correct`
- `answer_wrong`
- `user_tap`
- `screen_change`
