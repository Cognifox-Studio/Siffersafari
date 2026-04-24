# Loke Rive Guide

Generated from brief: Loke is a brave mischievous kind energetic 10 year old jungle boy with blue shorts, blue shirt, cap, glasses, bright colors and no dark colors. He is a friendly helpful ordinary boy who loves adventure and makes everyone feel safe.

## Default Runtime
The default runtime asset for this character is the generated SVG composite:

`assets/characters/loke/svg/loke_composite.svg`

A `.riv` export is optional and not required for app integration.

## Source Files
- `assets/characters/loke/config/loke_visual_spec.json`
- `assets/characters/loke/config/loke_animation_spec.json`
- `assets/characters/loke/svg/loke_*.svg`
- `artifacts/loke_rive_blueprint.json`

## Optional Rive Import Order
1. `assets/characters/loke/svg/loke_shadow.svg`
2. `assets/characters/loke/svg/loke_backpack.svg`
3. `assets/characters/loke/svg/loke_leg_upper_left.svg`
4. `assets/characters/loke/svg/loke_leg_lower_left.svg`
5. `assets/characters/loke/svg/loke_shoe_left.svg`
6. `assets/characters/loke/svg/loke_arm_upper_left.svg`
7. `assets/characters/loke/svg/loke_arm_lower_left.svg`
8. `assets/characters/loke/svg/loke_torso.svg`
9. `assets/characters/loke/svg/loke_head.svg`
10. `assets/characters/loke/svg/loke_eyes_open.svg`
11. `assets/characters/loke/svg/loke_eyes_blink.svg`
12. `assets/characters/loke/svg/loke_mouth_neutral.svg`
13. `assets/characters/loke/svg/loke_mouth_happy.svg`
14. `assets/characters/loke/svg/loke_mouth_sad.svg`
15. `assets/characters/loke/svg/loke_hat.svg`
16. `assets/characters/loke/svg/loke_arm_upper_right.svg`
17. `assets/characters/loke/svg/loke_arm_lower_right.svg`
18. `assets/characters/loke/svg/loke_leg_upper_right.svg`
19. `assets/characters/loke/svg/loke_leg_lower_right.svg`
20. `assets/characters/loke/svg/loke_shoe_right.svg`

## Suggested State Machine
Name: `LokeStateMachine`

Inputs:
- `answer_correct`
- `answer_wrong`
- `user_tap`
- `screen_change`
