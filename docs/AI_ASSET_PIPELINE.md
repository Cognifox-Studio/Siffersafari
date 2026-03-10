# AI Asset Generator Pipeline – Quick Reference

**Skapad:** 2026-03-10  
**Syfte:** Generera alla visuella assets via kod – ingen handritning.

---

## 🚀 Quick Commands

```bash
# Generera alla assets på en gång
# Metod 1: Via VS Code Task (rekommenderat)
Tasks → Run Task → "Assets: Generate All (SVG + Lottie + Rive Blueprint)"

# Metod 2: Via terminal
dart run scripts/generate_ville_svg_parts.dart
dart run scripts/generate_lottie_effects.dart
dart run scripts/generate_rive_blueprint.dart
```

---

## 📦 Vad genereras?

### 1. Ville SVG Parts (12 filer)
**Generator:** `scripts/generate_ville_svg_parts.dart`  
**Input:** `assets/characters/ville/config/ville_visual_spec.json`  
**Output:** `assets/characters/ville/svg/*.svg`

Genererade filer:
- `ville_head.svg` – huvudform med blush
- `ville_eyes_open.svg` – öppna ögon med glans
- `ville_eyes_closed.svg` – blinkande ögon
- `ville_mouth_smile.svg` – leende
- `ville_mouth_sad.svg` – ledsen mun
- `ville_mouth_neutral.svg` – neutral mun
- `ville_body.svg` – kropp med mage-detalj
- `ville_arm_left.svg` – vänster arm + hand
- `ville_arm_right.svg` – höger arm + hand
- `ville_leg_left.svg` – vänster ben + fot
- `ville_leg_right.svg` – höger ben + fot
- `ville_antennas.svg` – båda antennerna

**Stil:** Cartoon, mjuka former, stroke width 4, rundade hörn

---

### 2. Lottie UI Effects (4 filer)
**Generator:** `scripts/generate_lottie_effects.dart`  
**Output:** `assets/ui/lottie/*.json`

Genererade effekter:
- `confetti.json` – 20 färgglada partiklar som faller (90 frames, 3s)
- `stars.json` – 8 blinkande guldstjärnor (120 frames, 4s)
- `success_pulse.json` – grön puls-ring + inner circle (45 frames, 1.5s)
- `error_shake.json` – rött X som skakar (30 frames, 1s)

**Format:** Lottie JSON v5.7.4, redo för direktanvändning i Flutter

---

### 3. Rive Rigging Blueprint
**Generator:** `scripts/generate_rive_blueprint.dart`  
**Input:** `assets/characters/ville/config/ville_animation_spec.json`  
**Output:** 
- `artifacts/ville_rive_blueprint.json` – teknisk spec
- `artifacts/VILLE_RIVE_GUIDE.md` – steg-för-steg guide

**Innehåll:**
- 9 bones (root, spine, head, arms, legs, antennas)
- 15+ animations (idle, blink, celebrate, sad, tap_react, etc.)
- State machine "VilleStateMachine" med 4 triggers
- Detaljerade instruktioner för manuell riggning i Rive Editor

**Status:** Blueprint är klar, faktisk .riv-fil kräver manuellt arbete i Rive Editor

---

## 🔄 Typiskt Workflow

### Scenario 1: Uppdatera Villes färg

```bash
# 1. Ändra färg i spec
code assets/characters/ville/config/ville_visual_spec.json
# Ändra t.ex. "bodyPrimary": "#4CAF50" → "#FF5722"

# 2. Regenerera SVG-delar
dart run scripts/generate_ville_svg_parts.dart

# 3. Verifiera visuellt
flutter run
# → Kolla att Ville ser rätt ut

# 4. Commit
git add assets/characters/ville/config/ville_visual_spec.json
git add assets/characters/ville/svg/*.svg
git commit -m "assets: change Ville body color to orange"
```

### Scenario 2: Lägg till ny Lottie-effekt

```bash
# 1. Öppna generator
code scripts/generate_lottie_effects.dart

# 2. Lägg till metod generateNewEffect() i LottieEffectGenerator-klassen

# 3. Registrera i main():
#    'new_effect': generator.generateNewEffect(),

# 4. Kör generator
dart run scripts/generate_lottie_effects.dart

# 5. Registrera i pubspec.yaml
code pubspec.yaml
# Lägg till under flutter → assets:
#   - assets/ui/lottie/new_effect.json

# 6. Använd i kod
code lib/presentation/widgets/my_widget.dart
# Lottie.asset('assets/ui/lottie/new_effect.json')
```

### Scenario 3: Rigga Ville i Rive Editor

```bash
# 1. Generera SVG + blueprint
dart run scripts/generate_ville_svg_parts.dart
dart run scripts/generate_rive_blueprint.dart

# 2. Öppna Rive Editor
# https://rive.app

# 3. Följ guide
artifacts/VILLE_RIVE_GUIDE.md

# 4. Importera alla SVG från assets/characters/ville/svg/

# 5. Följ 7-stegs guide:
#    - Create artboard "Ville"
#    - Add 9 bones
#    - Weight paint meshes
#    - Create animations
#    - Build state machine "VilleStateMachine"
#    - Test triggers
#    - Export .riv

# 6. Spara exporterad fil
# File → Export → Save as: assets/characters/ville/rive/ville_character.riv

# 7. Verifiera att artboard = "Ville" och state machine = "VilleStateMachine"

# 8. Testa i app
flutter run
# → Trigga animations: quiz svar, user tap, navigation
```

---

## 🧪 Testing

### Testa SVG-delar
```bash
# Öppna SVG i webbläsare eller SVG-viewer
open assets/characters/ville/svg/ville_head.svg
```

### Testa Lottie-effekter
```bash
# Öppna i Lottie-previewer
# https://lottiefiles.com/preview

# Eller testa i Flutter direkt
flutter run
# Navigate till screen som använder Lottie-effekten
```

### Testa Rive-animation
```bash
# Öppna i Rive Editor
# File → Open → assets/characters/ville/rive/ville_character.riv

# Eller testa i Flutter
flutter run
# Trigga triggers via quiz/tap/navigation
```

---

## 📁 File Structure

```
assets/
  characters/
    ville/
      config/
        ville_visual_spec.json       ← Colors, proportions, style
        ville_animation_spec.json    ← Bones, animations, states
      svg/
        ville_head.svg               ← Generated (12 total)
        ville_eyes_open.svg
        ...
      rive/
        ville_character.riv          ← Manual export from Rive Editor

  ui/
    lottie/
      confetti.json                  ← Generated (4 total)
      stars.json
      success_pulse.json
      error_shake.json

scripts/
  generate_ville_svg_parts.dart      ← SVG generator
  generate_lottie_effects.dart       ← Lottie generator
  generate_rive_blueprint.dart       ← Rive blueprint generator

artifacts/
  ville_rive_blueprint.json          ← Technical spec
  VILLE_RIVE_GUIDE.md                ← Human-readable guide
```

---

## ⚙️ VS Code Tasks

Alla generatorer finns som VS Code tasks:

```
Tasks → Run Task → välj:

Assets: Generate Ville SVG Parts
Assets: Generate Lottie Effects
Assets: Generate Rive Blueprint
Assets: Generate All (SVG + Lottie + Rive Blueprint)  ← Rekommenderad
```

**Keyboard shortcut:** `Ctrl+Shift+B` → välj task

---

## 🎨 Customize

### Ändra Villes utseende
Editera: `assets/characters/ville/config/ville_visual_spec.json`

```json
{
  "colors": {
    "skin": "#F2D3A0",        ← Hudfärg
    "bodyPrimary": "#4CAF50", ← Huvudfärg kropp
    "antenna": "#FF6F61"      ← Antennkulor
  },
  "proportions": {
    "headToBodyRatio": 0.55,  ← Huvud vs kropp
    "eyeSizeRelativeToHead": 0.18
  },
  "style": {
    "strokeWidth": 4,         ← Kantbredd
    "cornerRadius": 12        ← Rundade hörn
  }
}
```

Efter ändring: `dart run scripts/generate_ville_svg_parts.dart`

### Ändra animationer
Editera: `assets/characters/ville/config/ville_animation_spec.json`

Lägg till nya states/triggers/transitions, kör sedan:
```bash
dart run scripts/generate_rive_blueprint.dart
# → Uppdaterad blueprint → Rigga om i Rive Editor
```

---

## 📚 Related Docs

- [ASSET_GENERATION.md](ASSET_GENERATION.md) – Fullständig asset-guide
- [CHARACTER_ANIMATIONS.md](CHARACTER_ANIMATIONS.md) – Animation integration
- [ANIMATION_PIPELINE_TODO.md](../docs/ANIMATION_PIPELINE_TODO.md) – Rive + Lottie checklist
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) – Repo structure

---

## 🐛 Troubleshooting

### "Error: ville_visual_spec.json not found"
→ Kör från repo root: `cd d:\Projects\Personal\Multiplikation`

### SVG ser konstig ut
→ Öppna i Inkscape/webbläsare → inspektera XML → justera generator-kod

### Lottie spelar inte
→ Verifiera JSON-format via https://lottiefiles.com/preview  
→ Kontrollera `"v": "5.7.4"` header finns

### Rive-fil laddar inte i Flutter
→ Kontrollera att artboard = "Ville" exakt (case-sensitive)  
→ Kontrollera att state machine = "VilleStateMachine" exakt  
→ Verifiera att alla 4 trigger inputs finns: answer_correct, answer_wrong, user_tap, screen_change

---

**Sammanfattning:** Ändra JSON-spec → Kör Dart-script → Få nya assets.  
Ingen handritning. Full kontroll via kod. 🚀
