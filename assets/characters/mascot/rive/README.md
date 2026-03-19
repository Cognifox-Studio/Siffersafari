# Mascot Rive Asset

Expected runtime file:
- mascot_character.riv

This folder is reserved for optional rigged real-time character animation material.

Current status:
- The checked-in `mascot_character.riv` is still a placeholder/demo export.
- Runtime verification on emulator showed `artboard=Template-NoRig` and no state machines.
- The current product runtime does not load this file; mascot surfaces use the approved composite SVG path instead.

Production-ready export requirements:
- Artboard name: `Mascot`
- State machine name: `MascotStateMachine`
- Trigger inputs:
	- `answer_correct`
	- `answer_wrong`
	- `user_tap`
	- `screen_change`

Manual export workflow:
1. Open Rive Editor and follow [artifacts/MASCOT_RIVE_GUIDE.md](d:/Projects/Personal/Multiplikation/artifacts/MASCOT_RIVE_GUIDE.md).
2. Export the file as `assets/characters/mascot/rive/mascot_character.riv`.
3. If runtime Rive work is reintroduced later, validate the file explicitly before wiring product code to it.

Validation result meaning:
- Pass: manual inspection shows artboard `Mascot`, state machine `MascotStateMachine` and the expected trigger inputs.
- Not ready: the file is still placeholder/demo material or does not contain the required runtime contract.

Current automated checkpoint:
- `flutter test test/widget/mascot_character_test.dart`
- `flutter test test/widget/theme_mascot_test.dart`
- `flutter test test/unit/assets/generated_asset_paths_test.dart`
