# Asset Generation (How-To)

Denna guide visar hur du genererar grafik, ljud och animationer för Siffersafari.

**Assets** genereras ofta offline (tex i ComfyUI) och läggs sedan in i `assets/`. Under development ligger de i `artifacts/`.

---

## Quick Start

```bash
# 1. Starta ComfyUI (om du använder det)
powershell -ExecutionPolicy Bypass -File scripts/comfyui/start_comfyui.ps1

# 2. Generera bilder via API
dart run scripts/generate_images_comfyui.dart --prompt "cute mascot" --output mascot.png

# 3. Generera ljud
dart run scripts/generate_sfx_wav.dart --prompt "bell chime" --output bell.wav

# 4. Generera animationsframes
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 -Anim idle -Frames 8
```

---

## 1. Graphics (ComfyUI)

### Overview

Vi använder **ComfyUI** (Stable Diffusion UI) för att generera barnvänliga bilder:
- Tema-bakgrunder (jungle, space)
- Quest-hero (större illustrationer)
- Karaktär-sprites (Ville the mascot)

**Varför ComfyUI?**
- ✅ Reproducible workflows (sparade JSON-filer)
- ✅ Möjlighet att loopa/batch-generera
- ✅ Exakt kontroll (seed, sampler, prompts)

### Setup ComfyUI (First Time)

```bash
# 1. Installera ComfyUI (separate installation, inte i repo)
# https://github.com/comfyanonymous/ComfyUI

# 2. Starta servern
cd C:\Users\Ropbe\Comfyui
.\start.bat
# Eller via script:
powershell -ExecutionPolicy Bypass -File scripts/comfyui/start_comfyui.ps1

# 3. Webb-UI öppnas på http://127.0.0.1:8000
# 4. Verifiera att den är uppe innan du kör generation-scripts
```

**Configuration:**
- Vi använder **port 8000** (se `scripts/generate_images_comfyui.dart`)
- Workflows sparas i `C:\Users\Ropbe\Comfyui\user\default\workflows\`

### Generate Images (API)

Använd `scripts/generate_images_comfyui.dart` för att generera via API:

```bash
# Enkel txt2img (text to image)
dart run scripts/generate_images_comfyui.dart \
  --workflow txt2img \
  --positive-prompt "cute mascot character, anime, cheerful, transparent background" \
  --negative-prompt "blurry, deformed, ugly" \
  --output artifacts/mascot_v1.png

# Med init-bild (img2img = transformation)
dart run scripts/generate_images_comfyui.dart \
  --workflow img2img \
  --init-image assets/images/mascot_v1.png \
  --positive-prompt "same character, jumping pose, happy expression" \
  --denoise 0.35 \
  --output artifacts/mascot_jumping.png
```

**Tips:**
- **`--seed`:** Samma seed = samma bild (debugging)
- **`--denoise`:** 0.0–1.0, låga värden = mindre förändring
- **`--steps`:** Högre = bättre kvalitet men långsammare (standard: 20)

### Theme Backgrounds

Generation av tema-bakgrunder:

```bash
# Jungle tema
dart run scripts/generate_images_comfyui.dart \
  --workflow txt2img \
  --positive-prompt "jungle background, nature, trees, plants, bright colors, cartoon style, suitable for kids game, clean" \
  --output artifacts/jungle_bg_v1.png

# Space tema
dart run scripts/generate_images_comfyui.dart \
  --workflow txt2img \
  --positive-prompt "space background, planets, stars, colorful, cartoon style, kids game, clean" \
  --output artifacts/space_bg_v1.png
```

Väl godkända bilder kopieras till `assets/images/themes/<theme>/background.png`.

### Character Animations

Generera animationsframes för Ville (mascot):

```powershell
# Idle animation (8 frames)
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 `
  -Anim idle `
  -Frames 8 `
  -AlphaAll  # Gör bakgrunden transparent

# Jump animation
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 `
  -Anim jump `
  -Frames 6 `
  -StableSeed 42  # Samma seed = samma karaktär

# Preview som GIF
dart run scripts/preview_animation_gif.dart --animation idle --output artifacts/idle_preview.gif
```

**Parametrar:**
- **`-Anim`:** idle, jump, run, wave, dance
- **`-Frames`:** Antal frames (vanligt 6–12)
- **`-StableSeed`:** Håller karaktären likadan över alla frames
- **`-Denoise`:** 0.25–0.45 rekommenderat (låg = mindre drift)
- **`-AlphaAll`:** Gör alla frames transparenta

**Output:** Frames sparas i `artifacts/comfyui/`. Välj bästa och flytta till `assets/images/characters/character_v2/<anim>/`.

### Organize Generated Assets

Efter generation:

```bash
# 1. Review i artifacts/comfyui/
ls artifacts/comfyui/

# 2. Välj bästa bilden
# - Rätt stil (barnvänlig, tydlig)
# - Rätt transparens (rena kanter)
# - Rätt storlek

# 3. Kopiera till assets/
# För bakgrunder:
cp artifacts/mascot_v1.png assets/images/themes/jungle/background.png

# För karaktärer:
cp artifacts/idle_000.png assets/images/characters/character_v2/idle/idle_000.png
cp artifacts/idle_001.png assets/images/characters/character_v2/idle/idle_001.png
# (återhål för alla frames)

# 4. Verifiera att pubspec.yaml listar dem
cat pubspec.yaml | grep -A 5 "assets:"

# 5. Rebuild appen
flutter pub get
flutter run
```

---

## 2. Sound Effects (gen_sfx_wav.dart)

Generera eller bearbeta ljudeffekter:

```bash
# Generera ett ljud (ex: bell chime)
dart run scripts/generate_sfx_wav.dart \
  --prompt "bell chime, bright, cheerful" \
  --duration 1 \
  --output artifacts/bell.wav

# Konvertera WAV till MP3 (sparar ~90% storlek)
powershell -ExecutionPolicy Bypass -File scripts/convert_wav_to_mp3.ps1 `
  -InputFile artifacts/bell.wav `
  -OutputFile assets/sounds/bell.mp3 `
  -Bitrate 192
```

**Sound-format:**
- **WAV:** RAW audio, stor fil (~100 KB för 1 sek)
- **MP3:** Komprimerad, liten fil (~10 KB för 1 sek, 128-192 kbps)
- **Target:** MP3 för alla produktionsfiler

**Befintliga ljud:**
- `assets/sounds/background_music.wav` — Loop music
- `assets/sounds/celebration.wav` — Achievement unlocked
- `assets/sounds/correct.wav` — Rätt svar
- `assets/sounds/wrong.wav` — Fel svar
- `assets/sounds/click.wav` — Button tap

Se [CONVERT_TO_MP3.md](../assets/sounds/CONVERT_TO_MP3.md) för konvertering av alla WAV.

---

## 3. Icons (Android Launcher)

Generera launcher-ikoner för Android:

```bash
# Generera ikoner från en base-image (1024x1024 PNG)
dart run scripts/generate_android_launcher_icons.dart \
  --input assets/images/app_logo.png \
  --output android/app/src/main/res/

# Verifiera att alla storlekar genererades
ls android/app/src/main/res/mipmap-*/
```

**Output:**
```
android/app/src/main/res/
  mipmap-ldpi/
    ic_launcher.png (36x36)
  mipmap-mdpi/
    ic_launcher.png (48x48)
  mipmap-hdpi/
    ic_launcher.png (72x72)
  mipmap-xhdpi/
    ic_launcher.png (96x96)
  ... (och fler)
```

---

## 4. Pre-flight Checks

Innan du committar nya assets:

```bash
# 1. Verifiera pubspec.yaml listar alla assets
grep -r "assets/images" pubspec.yaml
grep -r "assets/sounds" pubspec.yaml

# 2. Checkra filstorlek (goal: < 50 MB APK)
du -sh assets/

# 3. Verifiera inga WAV-filer ligger i assets/sounds/
ls -la assets/sounds/*.wav  # Ska vara tomt!

# 4. Analyser ljud-kvalitet
# Lyssna på ett audio-sample:
# - Klart ljud? Inget klipp/distortion?
# - Rätt längd?

# 5. Analys bild-kvalitet
# Öppna PNG i bild-viewer:
# - Rätt transparens?
# - Rätt dimensioner?
# - Ingen artifakter?

# 6. Kör tester
flutter test
```

---

## 5. Workflow Tips

### Iteration Workflow (Draft → Final)

```
1. DRAFT
   └─ Generera många bilder i ComfyUI
   └─ Spara till artifacts/comfyui/
   └─ Välj 2–3 bästa

2. REVIEW
   └─ Öppna bilder i bild-viewer
   └─ Döm på stil, transparens, detaljer
   └─ Markera "godkänd" eller "behöver revision"

3. FINAL
   └─ Kopiera godkänd bild till assets/
   └─ Uppdatera pubspec.yaml om ny kategori
   └─ Testa i appen (flutter run)

4. COMMIT
   └─ Bara slutlig bild commitas till Git (artifacts/ är .gitignored)
   └─ Commit message: "assets: add new jungle background"
```

### Reproducibility (Save Workflow & Seed)

ComfyUI workflows sparas som JSON:

```json
{
  "1": {
    "class_type": "CheckpointLoader",
    "inputs": {
      "ckpt_name": "sd_xl_base_1.0.safetensors"
    }
  },
  "2": {
    "class_type": "CLIPTextEncode",
    "inputs": {
      "text": "cute mascot character, transparent background",
      "clip": ["1", 0]
    }
  },
  ...
}
```

**Spara den!** Nästa gång du behöver varianter kan du:
- Ändra **seed** (#olika bilder, same style)
- Ändra **prompt** (#different style, same seed-base)
- Skapa versionshistorik av bra workflows

Workflows sparas i `C:\Users\Ropbe\Comfyui\user\default\workflows\` och committas INTE till Git (för stort).

---

## 6. ComfyUI Troubleshooting

### "ComfyUI won't start"
```bash
# Kontrollera port 8000 är inte occupied
netstat -an | findstr :8000

# Om occupied, starta på annan port
python main.py --listen 127.0.0.1 --port 8001
```

### "API call fails: 'Can't find service'"
```bash
# Verifiera ComfyUI server är uppe
curl http://127.0.0.1:8000/system_stats

# Om fail, starta ComfyUI igen
powershell -ExecutionPolicy Bypass -File scripts/comfyui/start_comfyui.ps1
```

### "Generated image is blurry/deformed"
- Öka **steps** (20 → 30 eller 40)
- Använd bättre **sampler** (euler_a, ddim)
- Clarifiera **prompt** (ta bort vaga ord)

---

## Resources

- **Detaljerad setup:** [scripts/comfyui/README.md](../scripts/comfyui/README.md)
- **Karaktärsanimation:** [CHARACTER_ANIMATIONS.md](CHARACTER_ANIMATIONS.md)
- **ComfyUI-strategi:** [COMFYUI_STRATEGI.md](COMFYUI_STRATEGI.md)
- **Sound conversion:** [assets/sounds/CONVERT_TO_MP3.md](../assets/sounds/CONVERT_TO_MP3.md)
