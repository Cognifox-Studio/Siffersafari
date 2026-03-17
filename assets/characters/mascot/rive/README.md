# Mascot Rive Asset

Expected runtime file:
- mascot_character.riv

This folder is used for rigged real-time character animation.

Current status:
- The checked-in `mascot_character.riv` is still a placeholder/demo export.
- Runtime verification on emulator showed `artboard=Template-NoRig` and no state machines.
- The app currently uses a temporary compatibility path that plays the first legacy animation when no state machine exists.

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
3. Run `powershell -ExecutionPolicy Bypass -File scripts/verify_mascot_rive_runtime.ps1 -SyncFirst -RunScreenshotsFlow` from the repo root.

Validation result meaning:
- Pass: runtime logs show `using state machine MascotStateMachine`.
- Temporary compatibility only: runtime logs show `using legacy animation ...`.
- Fail: runtime logs show `using static SVG fallback` or no mascot runtime logs at all.
