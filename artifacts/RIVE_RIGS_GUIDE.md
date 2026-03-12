# Rive Rigs – Available Characters

**Downloaded:** 2026-03-10  
**Location:** `artifacts/*.riv`

## Active Character

✅ **ville_character.riv** (Simple Character Rig)  
- **Source:** Simple Character Rig.riv  
- **Size:** 7 KB  
- **Status:** Active in app  
- **Path:** `assets/characters/ville/rive/ville_character.riv`

## Alternative Rigs

### 1. Creature Rig.riv
- **Size:** 22 KB  
- **Description:** More complex creature-style rig  
- **Use case:** If you want more detailed animations  
- **Location:** `artifacts/Creature Rig.riv`

### 2. Puppet Rig.riv
- **Size:** 6 KB  
- **Description:** Puppet-style character rig  
- **Use case:** Alternative character style  
- **Location:** `artifacts/Puppet Rig.riv`

### 3. State Machine Character Demo.riv
- **Size:** 0.4 KB  
- **Description:** Minimal state machine demo  
- **Use case:** Learning/testing state machines  
- **Location:** `artifacts/State Machine Character Demo.riv`

## Switch to Different Rig

To test another rig:

```bash
# Example: Switch to Creature Rig
Copy-Item "artifacts\Creature Rig.riv" `
  -Destination "assets\characters\ville\rive\ville_character.riv" `
  -Force

# Then run app
flutter run
```

## Important Notes

⚠️ **Rive files from Rive Community likely have different:**
- Artboard names (may not be "Ville")
- State machine names (may not be "VilleStateMachine")
- Input trigger names (may not match our answer_correct, answer_wrong, etc.)

### To Fix Compatibility

1. **Open in Rive Editor:**
   ```
   https://rive.app
   File → Open → assets/characters/ville/rive/ville_character.riv
   ```

2. **Check artboard name:**
   - Should be: "Ville"
   - If different: Rename artboard to "Ville"

3. **Check state machine:**
   - Should be: "VilleStateMachine"
   - If different: Rename state machine to "VilleStateMachine"

4. **Check trigger inputs:**
   - Required: `answer_correct`, `answer_wrong`, `user_tap`, `screen_change`
   - If different: Add or rename triggers to match

5. **Export:**
   ```
   File → Export → Save as ville_character.riv
   ```

## Current Integration

The app expects:
- **Artboard:** "Ville"
- **State Machine:** "VilleStateMachine"
- **Triggers:**
  - `answer_correct` → fired on correct quiz answer
  - `answer_wrong` → fired on wrong quiz answer
  - `user_tap` → fired when user taps character
  - `screen_change` → fired on navigation

See `lib/presentation/widgets/ville_character.dart` for implementation.

## Fallback Behavior

If Rive file fails to load or triggers don't exist:
- App shows SVG composite (`assets/characters/ville/svg/ville_composite.svg`)
- No errors or crashes
- Graceful degradation

## Testing

```bash
# Run app to test current rig
flutter run

# Watch for console messages about Rive loading
# Tap Ville in home screen to test user_tap trigger
# Start quiz to test answer_correct/answer_wrong triggers
```
