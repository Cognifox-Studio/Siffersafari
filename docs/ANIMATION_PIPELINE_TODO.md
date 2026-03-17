# Animation Pipeline TODO (Rive + Lottie)

## Goal
Use Rive for characters and Lottie for UI effects, while keeping preview work outside the product UI.

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
- [x] Add `rive` dependency
- [x] Add `MascotCharacter` widget
- [x] Wire triggers in home, quiz and results flows
- [x] Set `characterRiveAsset` in theme config
- [x] Remove preview walk fallback from runtime character rendering
- [x] Move passive mascot surfaces to `Rive -> SVG fallback`
- [ ] Replace placeholder/demo `.riv` with a production-approved export

## Current Runtime Notes
- `MascotCharacter` is the triggered runtime widget for `home_screen.dart`, `quiz_screen.dart` and `results_screen.dart`
- `ThemeMascot.withState` uses approved Rive when available, otherwise approved composite SVG fallback
- Preview/test motion belongs in `artifacts/animation_preview/`, not in product UI

## Lottie Policy
- Keep Lottie under `assets/ui/lottie/` for approved UI effects such as confetti, stars and feedback pulses
- Do not use theme-specific mascot Lottie state files as passive mascot runtime fallback
- Do not use preview walk cycles as runtime fallback for `MascotCharacter`

## Execution Todo To Reach Testable State

The goal of this checklist is not "more docs". The goal is to reach a state where the pipeline can be exercised end-to-end and the runtime can be verified on real screens.

### Milestone 1: Make the mascot testable in runtime
- [ ] Replace the current demo or placeholder `.riv` with a production-approved `mascot_character.riv`
- [ ] Verify that the exported file contains artboard `Mascot`
- [ ] Verify that the exported file contains state machine `MascotStateMachine`
- [ ] Verify that the triggers `answer_correct`, `answer_wrong`, `user_tap` and `screen_change` exist and are wired
- [ ] Run the mascot through home, quiz and results flows and confirm `Rive -> SVG fallback` behaves correctly
- [x] Decide whether the legacy explicit Lottie constructor in `ThemeMascot` is still needed or can be removed

Verified 2026-03-13 on emulator-5554:
- Current runtime log reports `MascotCharacter: artboard=Template-NoRig, animations=[Animation 1], stateMachines=[]`
- Current runtime log reports `MascotCharacter: no matching state machine, using legacy animation Animation 1`
- Conclusion: device verification confirms the temporary legacy-animation compatibility path works, but the current `.riv` is still a placeholder/demo export and not a production `MascotStateMachine` file

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
- [x] Add a focused widget test for `MascotCharacter` fallback behavior when Rive loading fails
- [x] Add a focused widget test for `ThemeMascot.withState` covering approved Rive and SVG fallback paths
- [x] Add a focused test that fails if a generated asset enum points to a missing file
- [x] Run `QA: Analyze`
- [x] Run focused Flutter tests for asset and mascot behavior

### Milestone 5: Validate on device or emulator
- [x] Run the app on Pixel_6 or equivalent Android target
- [ ] Verify that the mascot reacts correctly in home, quiz and results flows
- [ ] Verify that approved UI Lottie effects still play correctly
- [ ] Verify that no preview-only assets are used in product runtime
- [ ] Record any runtime mismatch between specs, manifest and actual assets before adding more characters

## Definition Of Done
- [ ] `python tools/pipeline.py build-all` succeeds without manual cleanup
- [ ] At least two characters are represented in specs and generated asset helpers
- [ ] Flutter runtime uses generated asset access for the tested mascot surfaces
- [x] Widget tests cover mascot fallback behavior
- [x] Analyze is green
- [x] The app has been checked on a real device or emulator
