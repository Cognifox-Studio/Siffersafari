# Loke Rive Rigging Guide

Generated: 2026-03-10

## Overview
Loke is a simplified child safari explorer based on the supplied reference image. The design preserves the hat, hair shape, yellow shirt, mint overalls, backpack and yellow shoes, but removes texture and tiny details so the character is easier to rig.

## Files
- `assets/characters/loke/config/loke_visual_spec.json`
- `assets/characters/loke/config/loke_animation_spec.json`
- `assets/characters/loke/svg/loke_*.svg`
- `artifacts/loke_rive_blueprint.json`

## Import Order
1. `loke_shadow.svg`
2. `loke_backpack.svg`
3. `loke_leg_upper_left.svg`
4. `loke_leg_lower_left.svg`
5. `loke_leg_upper_right.svg`
6. `loke_leg_lower_right.svg`
7. `loke_shoe_left.svg`
8. `loke_shoe_right.svg`
9. `loke_torso.svg`
10. `loke_arm_upper_left.svg`
11. `loke_arm_lower_left.svg`
12. `loke_arm_upper_right.svg`
13. `loke_arm_lower_right.svg`
14. `loke_head.svg`
15. `loke_eyes_open.svg`
16. `loke_eyes_blink.svg`
17. `loke_mouth_neutral.svg`
18. `loke_mouth_happy.svg`
19. `loke_mouth_sad.svg`
20. `loke_hat.svg`

## Recommended Hierarchy
```text
root
 └─ spine
     └─ chest
         ├─ head
         │  ├─ eyes
         │  ├─ mouth
         │  └─ hat
         ├─ backpack
         ├─ upper_arm_left
         │  └─ lower_arm_left
         ├─ upper_arm_right
         │  └─ lower_arm_right
         ├─ upper_leg_left
         │  └─ lower_leg_left
         ├─ upper_leg_right
         │  └─ lower_leg_right
         ├─ shoe_left
         └─ shoe_right
```

## Rig Notes
- Keep the hat on its own mesh or grouped layer so it can lag behind the head slightly.
- Keep the backpack behind the torso and attach it to chest movement only.
- Keep upper and lower limbs as separate meshes so elbow and knee bends stay clean.
- Keep shoes as separate pieces so foot pivots stay clean.
- Use mouth swaps instead of deforming the mouth mesh heavily.
- Use eyes_open and eyes_blink as visibility swaps.

## Recommended Animation Set
- `idle`: breathing, tiny head bob, occasional blink
- `happy`: quick bounce, arms lift, happy mouth
- `sad`: head drop, shoulders down, sad mouth
- `tap_react`: squash, blink, release
- `enter_screen`: fade in and step in
- `exit_screen`: fade out and lean back

## State Machine
Name: `LokeStateMachine`

Inputs:
- `answer_correct`
- `answer_wrong`
- `user_tap`
- `screen_change`

States:
- `idle`
- `happy`
- `sad`
- `tap_react`
- `enter`
- `exit`

## Export
Export the runtime file as:

`assets/characters/loke/rive/loke_character.riv`

## Important Limitation
This repo now contains the full asset kit and rigging blueprint for Loke, but not a finished exported `.riv`. That final file still needs to be assembled and exported in Rive Editor.