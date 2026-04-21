# Animation Pipeline TODO (SVG + Lottie, optional Rive)

## Goal
Keep mascot-runtime automatable in SVG/Flutter, keep Lottie for approved UI effects, and isolate preview or optional Rive work from product runtime until there is a concrete need.

## Runtime Structure
- `assets/characters/mascot/config/`
- `assets/characters/mascot/svg/`
- `assets/characters/mascot/rive/`
- `assets/ui/lottie/`
- `artifacts/animation_preview/` for preview and motion labs only

## Specs
- [x] `assets/characters/mascot/config/mascot_visual_spec.json`
- [x] `assets/characters/mascot/config/mascot_animation_spec.json`

## Rive Build Requirements
In `assets/characters/mascot/rive/mascot_character.riv`:
- Artboard: `Mascot`
- State machine: `MascotStateMachine`
- Triggers:
  - `answer_correct`
  - `answer_wrong`
  - `user_tap`
  - `screen_change`

## Flutter Integration
- [x] Add `MascotCharacter` widget
- [x] Wire reactions in home, quiz and results flows
- [x] Remove preview walk fallback from runtime character rendering
- [x] Move passive mascot surfaces to one shared SVG-first path
- [x] Remove dormant theme/runtime Rive toggles from the active mascot API

## Current Runtime Notes
- `GameCharacter` is the triggered runtime widget for `home_screen.dart`, `quiz_screen.dart` and `results_screen.dart`
- `MascotReactionView.withState` now uses the same composite-SVG runtime path as the rest of the product UI
- Preview/test motion belongs in `artifacts/animation_preview/`, not in product UI
- Optional `.riv` files remain repo artifacts, but are not part of the current runtime contract

## Lottie Policy
- Keep Lottie under `assets/ui/lottie/` for approved UI effects such as confetti, stars and feedback pulses
- Do not use theme-specific mascot Lottie state files as passive mascot runtime fallback
- Do not use preview walk cycles as runtime fallback for `GameCharacter`

## Execution Todo To Reach Testable State

The goal of this checklist is not "more docs". The goal is to reach a state where the pipeline can be exercised end-to-end and the runtime can be verified on real screens.

### Milestone 1: Make the current mascot path rock-solid
- [x] Standardize mascot-runtime on composite SVG + Flutter reactions
- [x] Remove dormant Rive-first runtime assumptions from widget/theme APIs
- [ ] Run the mascot through home, quiz and results flows and confirm reactions feel right on device
- [ ] Verify that no preview-only assets are used in product runtime

### Milestone 2: Remove remaining single-character assumptions
- [ ] Refactor `tools/pipeline.py` so it builds characters from spec entries instead of mascot-specific output assumptions
- [ ] Ensure manifest generation is driven from spec data, not hardcoded file names
- [ ] Expand `lib/gen/assets.g.dart` generation so new characters appear automatically from `specs/characters.yaml`
- [ ] Audit Flutter code for remaining hardcoded asset paths and move them to generated asset helpers

### Milestone 3: Prove the pipeline with character number two
- [ ] Add a second character entry to `specs/characters.yaml`
- [ ] Create the required config inputs for that character under `assets/characters/<id>/config/`
- [ ] Define expected SVG, composite and Rive outputs for that character
- [ ] Run `python tools/pipeline.py validate --strict`
- [ ] Run `python tools/pipeline.py build-all`
- [ ] Regenerate and verify `artifacts/asset_pipeline_manifest.json` and `lib/gen/assets.g.dart`

### Milestone 4: Add focused QA so testing is repeatable
- [x] Add a focused widget test for `MascotCharacter` composite-SVG runtime behavior
- [x] Add a focused widget test for `MascotReactionView.withState` on the shared SVG path
- [x] Add a focused test that fails if a generated asset enum points to a missing file
- [x] Run `QA: Analyze`
- [x] Run focused Flutter tests for asset and mascot behavior

### Milestone 5: Validate on device or emulator
- [x] Run the app on Pixel_6 or equivalent Android target
- [ ] Verify that the mascot reacts correctly in home, quiz and results flows
- [ ] Verify that approved UI Lottie effects still play correctly
- [ ] Record any runtime mismatch between specs, manifest and actual assets before adding more characters
- [ ] If a future `.riv` is proposed for runtime again: validate it as a separate enhancement track, not as release-critical work

## Definition Of Done
- [ ] `python tools/pipeline.py build-all` succeeds without manual cleanup
- [ ] At least two characters are represented in specs and generated asset helpers
- [ ] Flutter runtime uses generated asset access for the tested mascot surfaces
- [x] Widget tests cover mascot runtime behavior
- [x] Analyze is green
- [x] The app has been checked on a real device or emulator
