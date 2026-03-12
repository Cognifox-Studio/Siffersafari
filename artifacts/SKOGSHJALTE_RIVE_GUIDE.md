# Skogshjalte Rive Rigging Guide

Updated: 2026-03-12

## Overview
Skogshjalte is an original child forest-hero humanoid with a green tunic, blond hair, hat, backpack and blue cape accent. The useful output from this repo is now the segmented SVG kit, pivot guidance and manual Rive handoff, not the HTML preview animation itself.

1. `assets/characters/skogshjalte/svg/skogshjalte_*.svg`
2. `assets/characters/skogshjalte/config/skogshjalte_visual_spec.json`
3. `artifacts/skogshjalte_rive_blueprint.json`
4. `assets/characters/skogshjalte/config/skogshjalte_animation_spec.json`

Use that order when preparing the character for rigging in Rive.

## Canonical Source Files
- `assets/characters/skogshjalte/config/skogshjalte_visual_spec.json`
- `assets/characters/skogshjalte/config/skogshjalte_animation_spec.json`
- `assets/characters/skogshjalte/svg/skogshjalte_*.svg`
- `artifacts/skogshjalte_rive_blueprint.json`
- `artifacts/animation_preview/skogshjalte_walk_preview/index.html` (layout and pivot reference only)

## Import Order
Import these actual files in this order:

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

This order preserves the current 3/4 read:

- left side = far side, behind torso
- right side = near side, in front of torso

## Recommended Rig Hierarchy
```text
root
 ├─ pelvis
 │  ├─ hip_left
 │  │  └─ upper_leg_left
 │  │     └─ lower_leg_left
 │  │        └─ ankle_left
 │  │           └─ foot_left
 │  │              └─ toe_left
 │  └─ hip_right
 │     └─ upper_leg_right
 │        └─ lower_leg_right
 │           └─ ankle_right
 │              └─ foot_right
 │                 └─ toe_right
 └─ spine
    └─ chest
       ├─ neck
       │  └─ head
       │     ├─ eyes_open / eyes_blink
       │     ├─ mouth_* swap
       │     └─ hat
       ├─ shoulder_left
       │  └─ upper_arm_left
       │     └─ lower_arm_left
       │        └─ wrist_left
       ├─ shoulder_right
       │  └─ upper_arm_right
       │     └─ lower_arm_right
       │        └─ wrist_right
       ├─ backpack
       └─ cape
```

## Walk Rig Requirements
These pivots are approved as rig anchors and should be matched as closely as practical in Rive. They are useful even if the final walk is authored manually:

- `pelvis_group`: `50% 66%`
- `chest_group`: `50% 35%`
- `neck_group`: `50% 88%`
- `head_group`: `50% 78%`
- `shoulder_left`: `86% 8%`
- `shoulder_right`: `14% 8%`
- `upper_arm_left`: `84% 8%`
- `upper_arm_right`: `16% 8%`
- `lower_arm_left`: `52% 8%`
- `lower_arm_right`: `48% 8%`
- `hip_left`: `66% 10%`
- `hip_right`: `34% 10%`
- `upper_leg_left`: `56% 7%`
- `upper_leg_right`: `44% 7%`
- `lower_leg_left`: `48% 7%`
- `lower_leg_right`: `52% 7%`
- `ankle_left`: `50% 12%`
- `ankle_right`: `50% 12%`
- `foot_left`: `24% 32%`
- `foot_right`: `24% 32%`
- `toe_left`: `8% 56%`
- `toe_right`: `8% 56%`

## Walk Timing Summary
Current walk values in the animation spec are a blocking pass only. Use them only if they help you rough in poses quickly; do not treat them as final motion direction.

- Duration: `1.16s`
- FPS: `60`
- Frames: `70`
- Loop frames: `0 -> 70`
- Contact frames: `0`, `35`
- Passing frames: `18`, `53`
- Easing: `cubic-bezier(0.42, 0, 0.28, 1)`

## Key Walk Intent
Use these motion goals while rigging, not just the raw numbers:

- Final locomotion should be authored directly in Rive after the rig reads well in still poses.
- Keep the left-side limbs visually farther back and the right-side limbs visually nearer to camera.
- Preserve readable heel/toe articulation, but do not chase the browser-preview curves 1:1.
- Hat and cape should lag slightly as secondary motion.
- Blink remains independent and should not be baked into walk timing.

## Recommended Animation Set
- `idle`: breathing, tiny head bob, occasional blink
- `walk`: grounded locomotion with readable toe and ankle roll
- `happy`: quick bounce, arms lift, happy mouth
- `sad`: head drop, shoulders down, sad mouth
- `tap_react`: squash, blink, release
- `enter_screen`: fade in and step in
- `exit_screen`: fade out and lean back

## State Machine
Name: `SkogshjalteStateMachine`

Inputs:
- `start_walking`
- `stop_walking`
- `answer_correct`
- `answer_wrong`
- `user_tap`
- `screen_change`

States:
- `idle`
- `walk`
- `happy`
- `sad`
- `tap_react`
- `enter`
- `exit`

Recommended transitions:
- `idle -> walk` on `start_walking`
- `walk -> idle` on `stop_walking`
- `idle|walk -> happy` on `answer_correct`
- `idle|walk -> sad` on `answer_wrong`
- `idle|walk -> tap_react` on `user_tap`

## Manual Rive Checklist
1. Import the SVG files in the order above.
2. Build the bone hierarchy with explicit pelvis, chest, neck, ankle and toe controls.
3. Match pivots to the approved walk anchors before tuning animation curves.
4. Block the four key poses first: contact right, passing right, contact left, passing left.
5. Add hat, backpack and cape lag after the body motion reads correctly.
6. Create the state machine with walk inputs before exporting.

## Automation Status
There is currently no safe repo generator for Skogshjalte equivalent to the Ville-only `scripts/generate_rive_blueprint.dart`. The current Skogshjalte blueprint and guide are maintained manually from the segmented SVG kit, visual spec and rig-prep decisions.

## Export
Export the runtime file as:

`assets/characters/skogshjalte/rive/skogshjalte_character.riv`

## Important Limitation
This repo contains the spec, segmented SVG kit, manual blueprint and rigging guide for Skogshjalte, but not a finished exported `.riv`. The actual animation work still needs to be assembled and authored in Rive Editor.