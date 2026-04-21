# Rive Rigs – Reference Files

**Downloaded:** 2026-03-10  
**Location:** `artifacts/*.riv`

## Current Runtime Status

⚠️ **mascot_character.riv** (placeholder/demo export)  
- **Source:** simple_character_rig.riv  
- **Size:** 7 KB  
- **Status:** Connected in app, but not production-ready  
- **Path:** `assets/characters/mascot/rive/mascot_character.riv`

Current verified runtime state:
- artboard reported by app: `Template-NoRig`
- state machines reported by app: none
- current app behavior: temporary legacy-animation compatibility path, not final `MascotStateMachine` runtime

## Alternative Rigs

### 1. creature_rig.riv
- **Size:** 22 KB  
- **Description:** More complex creature-style rig  
- **Use case:** If you want more detailed animations  
- **Location:** `artifacts/creature_rig.riv`

### 2. puppet_rig.riv
- **Size:** 6 KB  
- **Description:** Puppet-style character rig  
- **Use case:** Alternative character style  
- **Location:** `artifacts/puppet_rig.riv`

### 3. state_machine_character_demo.riv
- **Size:** 0.4 KB  
- **Description:** Minimal state machine demo  
- **Use case:** Learning/testing state machines  
- **Location:** `artifacts/state_machine_character_demo.riv`

## Do Not Switch Rigs By Copying Files

Do not treat the community `.riv` files in `artifacts/` as drop-in runtime replacements.
They are reference files only and are not part of the approved mascot pipeline unless they are manually rebuilt in Rive Editor to match the repo contract.

Approved path:
1. Start from the generated mascot SVG parts and blueprint.
2. Build the rig in Rive Editor.
3. Export to `assets/characters/mascot/rive/mascot_character.riv`.
4. Verify on emulator/device.

## Important Notes

⚠️ **Reference `.riv` files likely have different:**
- Artboard names (may not be "Mascot")
- State machine names (may not be "MascotStateMachine")
- Input trigger names (may not match our answer_correct, answer_wrong, etc.)

### To Fix Compatibility

1. **Open in Rive Editor:**
   ```
   https://rive.app
   File → Open → assets/characters/mascot/rive/mascot_character.riv
   ```

2. **Check artboard name:**
   - Should be: "Mascot"
   - If different: Rename artboard to "Mascot"

3. **Check state machine:**
   - Should be: "MascotStateMachine"
   - If different: Rename state machine to "MascotStateMachine"

4. **Check trigger inputs:**
   - Required: `answer_correct`, `answer_wrong`, `user_tap`, `screen_change`
   - If different: Add or rename triggers to match

5. **Export:**
   ```
   File → Export → Save as mascot_character.riv
   ```

## Current Integration Contract

The app expects:
- **Artboard:** "Mascot"
- **State Machine:** "MascotStateMachine"
- **Triggers:**
  - `answer_correct` → fired on correct quiz answer
  - `answer_wrong` → fired on wrong quiz answer
  - `user_tap` → fired when user taps character
  - `screen_change` → fired on navigation

See `lib/presentation/widgets/game_character.dart` for implementation.

## Runtime Behavior

If the exported file is production-ready:
- App should log `using state machine MascotStateMachine`

If the exported file is still a placeholder/demo export with a single animation:
- App may log `using legacy animation ...`

If the file fails to load or has no usable runtime controller:
- App falls back to SVG composite (`assets/characters/mascot/svg/mascot_composite.svg`)

## Testing

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_mascot_rive_runtime.ps1 -SyncFirst -RunScreenshotsFlow
```
