# Copy‑paste: vår pipeline för Ville‑animationer (ComfyUI → assets → preview)

Du kan kopiera allt i den här filen och posta till andra för att be om råd.

## Mål
- Ville ska se **likadan ut** i varje frame (ingen morph/flimmer i ansikte/hatt/outfit).
- Ville ska ändå röra sig naturligt (idle: andning/vikt/blink; wave/jump/run: tydliga poser).
- Rå-genereringar läggs under `artifacts/` och **curated** frames kopieras in till `assets/`.

## Repo‑struktur (relevant)
- Init/referensbild: `assets/images/themes/jungle/character_v2.png`
- Curated frames (används av appen):
  - `assets/images/characters/character_v2/idle/idle_000.png .. idle_007.png`
  - `assets/images/characters/character_v2/wave/wave_000.png .. wave_007.png`
  - `assets/images/characters/character_v2/jump/jump_000.png .. jump_007.png`
  - `assets/images/characters/character_v2/run/run_000.png .. run_007.png`
- ComfyUI workflow (API): `scripts/comfyui/workflows/character_v2_pose_pack_api.json`

## Steg 1: Generera en animation (1 PNG per frame)
Vi kör en PowerShell‑driver som:
- bygger en prompt per frame (modifier)
- kör ComfyUI img2img workflow
- sparar stabila filnamn (`idle_000.png` osv)
- kan skapa alpha‑PNG (transparent bakgrund)
- kan låsa identiteten med:
  - **StableSeed**: välj random seed en gång och återanvänd för alla frames
  - **ChainInit**: frame→frame init (nästa frame tar förra frame som init)

Exempel (idle, stabil identitet):
```powershell
powershell -ExecutionPolicy Bypass -File scripts/generate_character_v2_animation_frames.ps1 `
  -Anim idle -Frames 8 `
  -Denoise 0.28 -Steps 28 -Cfg 6.5 `
  -Seed -1 -StableSeed -ChainInit `
  -AlphaAll
```

Output hamnar i:
- `artifacts/comfyui/<run>/raw/*.png`
- `artifacts/comfyui/<run>/alpha/*.png` (om `-AlphaAll`)

## Steg 2: Förhandsvisa utan emulator
### 2a) Skapa GIF från frames
```powershell
# Ex: skapa en gif från alpha-frames
$dir = "artifacts/comfyui/<run>/alpha"

dart run scripts/preview_animation_gif.dart --dir $dir --prefix idle_ --fps 8 --out artifacts/comfyui/previews/idle.gif
```

### 2b) Inspektera GIF + skapa strip (kontaktkarta)
```powershell
dart run scripts/inspect_animation_gif.dart --gif artifacts/comfyui/previews/idle.gif --outStrip artifacts/comfyui/previews/idle_strip.png --cols 8
```

## Steg 3: Audit (mät om frames är “för lika” eller bara flyttade)
```powershell
dart run scripts/audit_animation_frames.dart --dir assets/images/characters/character_v2/idle --prefix idle_
```

Audit gör bl.a.:
- aHash + Hamming‑delta
- mean abs diff (RGB)
- alpha‑aware diff (premultiplied RGBA)
- bästa translation‑shift (±4px) för att flagga “bara flyttat runt”

## Steg 4: Curate → assets
När du är nöjd, kopiera in `raw` eller `alpha` till rätt assets‑mapp:
```powershell
Copy-Item "artifacts/comfyui/<run>/alpha/idle_*.png" "assets/images/characters/character_v2/idle/" -Force
```

---

# Scripts (inkluderade för copy‑paste)

## scripts/generate_character_v2_animation_frames.ps1
```powershell
param(
  [ValidateSet('idle', 'wave', 'jump', 'run')]
  [string]$Anim = 'idle',
  [int]$Frames = 8,

  [string]$Init = "assets/images/themes/jungle/character_v2.png",
  [string]$OutDir = "",
  [string]$Workflow = "scripts/comfyui/workflows/character_v2_pose_pack_api.json",
  [string]$Server = "",

  [double]$Denoise = 0.35,
  [int]$Steps = 28,
  [double]$Cfg = 6.5,
  [int]$Width = 1024,
  [int]$Height = 1024,
  [int]$Seed = -1,

  # If Seed < 0 (random), StableSeed will pick one random seed once and reuse it
  # across all frames. This significantly improves character consistency.
  [switch]$StableSeed,

  # If enabled, each frame (after the first) uses the previous generated frame
  # as init. This further reduces identity drift, but can accumulate small
  # artifacts over time.
  [switch]$ChainInit,

  [switch]$AlphaAll,
  [int]$Tolerance = 18
)

$ErrorActionPreference = 'Stop'

if ($Frames -lt 2) {
  throw "Frames must be >= 2"
}

if ([string]::IsNullOrWhiteSpace($OutDir)) {
  $OutDir = Join-Path "artifacts/comfyui" ("anim_${Anim}_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
}

if ([string]::IsNullOrWhiteSpace($Server)) {
  if (-not [string]::IsNullOrWhiteSpace($env:COMFYUI_SERVER)) {
    $Server = $env:COMFYUI_SERVER
  } elseif (-not [string]::IsNullOrWhiteSpace($env:COMFYUI_URL)) {
    $Server = $env:COMFYUI_URL
  } else {
    $Server = "http://127.0.0.1:8000"
  }
}

if (-not (Test-Path -LiteralPath $Init)) {
  throw "Init image not found: $Init"
}
if (-not (Test-Path -LiteralPath $Workflow)) {
  throw "Workflow not found: $Workflow"
}

$rawDir = Join-Path $OutDir 'raw'
$alphaDir = Join-Path $OutDir 'alpha'

New-Item -ItemType Directory -Force -Path $rawDir | Out-Null
if ($AlphaAll) {
  New-Item -ItemType Directory -Force -Path $alphaDir | Out-Null
}

$basePrompt = "cute friendly jungle explorer kid, full body, centered, bold outline, simple shapes, high contrast, clean silhouette, cartoon style, same character, same face, same proportions, consistent outfit, consistent hat, consistent backpack"
$negative = "scary, creepy, gore, realistic, blurry, noisy, text, watermark, logo, multiple characters, character sheet, cropped, out of frame, cut off, extra fingers, extra limbs, bad hands, different character, different face, different hat"

function Get-FrameModifier([int]$i, [int]$n, [string]$anim) {
  $t = if ($n -le 1) { 0.0 } else { $i / [double]$n }

  switch ($anim) {
    'idle' {
      $phase = [Math]::Sin(2.0 * [Math]::PI * $t)  # -1..1
      $blinkFrame = [int]([Math]::Floor($n * 0.62))

      $breath = if ($phase -gt 0.35) {
        'breathing in, chest slightly expanded, shoulders slightly raised'
      } elseif ($phase -lt -0.35) {
        'breathing out, shoulders relaxing down'
      } else {
        'gentle breathing, relaxed'
      }

      $weight = if ($phase -lt 0) {
        'subtle weight shift onto left foot, hips slightly left'
      } else {
        'subtle weight shift onto right foot, hips slightly right'
      }

      $face = 'soft friendly smile'
      if ($i -eq $blinkFrame) { $face = 'blink, eyes closed, soft friendly smile' }
      elseif ($i -eq ($blinkFrame + 1)) { $face = 'eyes half-open, soft friendly smile' }

      return "idle standing pose, $breath, $weight, $face, head micro-tilt"
    }

    'wave' {
      $k = $i % 8
      switch ($k) {
        0 { return 'waving, arm down, hand near hip, start raising, friendly smile' }
        1 { return 'waving, arm halfway up, elbow bent, hand near waist, friendly smile' }
        2 { return 'waving, hand at shoulder height, elbow bent, palm facing out, friendly smile' }
        3 { return 'waving, hand high above shoulder, palm facing out, fingers spread, friendly smile' }
        4 { return 'waving, hand high above shoulder, palm facing out, wrist bent, big friendly wave' }
        5 { return 'waving, hand at shoulder height, palm facing out, wrist bent opposite, friendly smile' }
        6 { return 'waving, arm halfway down, elbow bent, hand near waist, friendly smile' }
        7 { return 'waving, arm down, hand near hip, end wave, friendly smile' }
      }
    }

    'jump' {
      $k = $i % 8
      switch ($k) {
        0 { return 'preparing to jump, deep crouch, arms back, excited' }
        1 { return 'takeoff, pushing off ground, arms swinging up, happy' }
        2 { return 'rising, feet leaving ground, legs extending, arms up, happy' }
        3 { return 'apex of jump, in the air, legs tucked slightly, arms up, happy' }
        4 { return 'falling, in the air, legs extending down, arms slightly down, happy' }
        5 { return 'landing impact, knees bent, arms forward for balance, happy' }
        6 { return 'recovering from landing, standing up, relaxed, happy' }
        7 { return 'back to idle after jump, relaxed, happy' }
      }
    }

    'run' {
      $k = $i % 8
      switch ($k) {
        0 { return 'running, left foot contact forward, right leg back, arms pumping, dynamic pose' }
        1 { return 'running, left leg down (weight), body slightly lowered, arms pumping' }
        2 { return 'running, passing pose, legs close together, arms pumping' }
        3 { return 'running, left leg up (lift), body slightly raised, arms pumping' }
        4 { return 'running, right foot contact forward, left leg back, arms pumping, dynamic pose' }
        5 { return 'running, right leg down (weight), body slightly lowered, arms pumping' }
        6 { return 'running, passing pose, legs close together, arms pumping' }
        7 { return 'running, right leg up (lift), body slightly raised, arms pumping' }
      }
    }
  }

  return 'neutral pose'
}

Write-Host "---"
Write-Host "Character_v2 animation frame generation (ComfyUI)"
Write-Host "Anim:     $Anim"
Write-Host "Frames:   $Frames"
Write-Host "Server:   $Server"
Write-Host "Workflow: $Workflow"
Write-Host "Init:     $Init"
Write-Host "OutDir:   $OutDir"
Write-Host "AlphaAll: $AlphaAll"
Write-Host "Seed:     $Seed"
Write-Host "StableSeed: $StableSeed"
Write-Host "ChainInit:  $ChainInit"
Write-Host "Params:   steps=$Steps cfg=$Cfg denoise=$Denoise size=${Width}x${Height}"

if ($StableSeed -and $Seed -lt 0) {
  $Seed = Get-Random -Minimum 0 -Maximum 2147483647
  Write-Host "Stable seed chosen: $Seed"
}

$currentInit = $Init
$prevOutPath = $null

for ($i = 0; $i -lt $Frames; $i++) {
  if ($ChainInit -and $i -gt 0 -and $prevOutPath -and (Test-Path -LiteralPath $prevOutPath)) {
    $currentInit = $prevOutPath
  } else {
    $currentInit = $Init
  }

  $modifier = Get-FrameModifier -i $i -n $Frames -anim $Anim
  $prompt = "$basePrompt, $modifier"
  $fileName = "${Anim}_$($i.ToString().PadLeft(3,'0')).png"
  $outPath = Join-Path $rawDir $fileName

  Write-Host "---"
  Write-Host "Frame $($i+1)/${Frames}: $fileName"

  dart run scripts/generate_images_comfyui.dart `
    --server $Server `
    --workflow $Workflow `
    --init $currentInit `
    --prompt $prompt `
    --negative $negative `
    --width $Width `
    --height $Height `
    --denoise $Denoise `
    --steps $Steps `
    --cfg $Cfg `
    --seed $Seed `
    --count 1 `
    --fixedName $fileName `
    --out $rawDir

  if ($LASTEXITCODE -ne 0) {
    throw "generate_images_comfyui failed for frame $fileName (exit code: $LASTEXITCODE)"
  }

  if ($AlphaAll) {
    $alphaOut = Join-Path $alphaDir $fileName
    dart run scripts/make_background_transparent.dart --in $outPath --out $alphaOut --tolerance $Tolerance --protect-radius 2

    if ($LASTEXITCODE -ne 0) {
      throw "make_background_transparent failed for frame $fileName (exit code: $LASTEXITCODE)"
    }
  }

  $prevOutPath = $outPath
}

Write-Host "---"
Write-Host "KLAR: Frames genererade i: $OutDir"
Write-Host "Nästa steg (manuellt): välj raw/alpha och kopiera till assets när du är nöjd."
Write-Host "Exempel:"
Write-Host "  Copy-Item \"$rawDir\\${Anim}_*.png\" \"assets/images/characters/character_v2/$Anim/\" -Force"
if ($AlphaAll) {
  Write-Host "  Copy-Item \"$alphaDir\\${Anim}_*.png\" \"assets/images/characters/character_v2/$Anim/\" -Force"
}
```

## scripts/preview_animation_gif.dart
```dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.containsKey('help') || parsed.containsKey('h') || args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final dirPath = parsed['dir'] ?? parsed['d'];
  if (dirPath == null) {
    stderr.writeln('Missing required arg: --dir');
    _printHelp();
    exit(2);
  }

  final prefix = parsed['prefix'];

  final fps = int.tryParse(parsed['fps'] ?? '') ?? 8;
  if (fps <= 0 || fps > 60) {
    stderr.writeln('Invalid --fps: $fps (expected 1..60)');
    exit(2);
  }
  final frameDurationMs = (1000 / fps).round().clamp(1, 60000);

  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: $dirPath');
    exit(2);
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.png'))
      .where((f) {
        if (prefix == null || prefix.trim().isEmpty) return true;
        return f.uri.pathSegments.last.startsWith(prefix);
      })
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('No PNG files found in: $dirPath');
    exit(2);
  }

  final outPath = parsed['out'] ??
      parsed['o'] ??
      _defaultOutPath(dirPath: dirPath, prefix: prefix);

  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);

  // GIF uses 1/100 sec units. Keep >= 1 to avoid zero-delay frames.
  final frameDurationHundredths = _clampInt((frameDurationMs / 10).round(), 1, 60000);

  final encoder = img.GifEncoder(repeat: 0);

  int? targetWidth;
  int? targetHeight;
  var decodedFrames = 0;

  for (final f in files) {
    final bytes = f.readAsBytesSync();
    final decoded = img.decodePng(bytes);
    if (decoded == null) {
      stderr.writeln('Failed to decode: ${f.path}');
      continue;
    }

    var frame = decoded.convert(format: img.Format.uint8);
    targetWidth ??= frame.width;
    targetHeight ??= frame.height;

    if (frame.width != targetWidth || frame.height != targetHeight) {
      frame = img.copyResize(
        frame,
        width: targetWidth!,
        height: targetHeight!,
        interpolation: img.Interpolation.nearest,
      );
    }

    encoder.addFrame(frame, duration: frameDurationHundredths);
    decodedFrames++;
  }

  if (decodedFrames < 2) {
    stderr.writeln('Only $decodedFrames decodable frame(s). Need >= 2 for preview.');
    exit(2);
  }

  final gifBytes = encoder.finish();
  if (gifBytes == null || gifBytes.isEmpty) {
    stderr.writeln('Failed to encode GIF.');
    exit(2);
  }

  outFile.writeAsBytesSync(gifBytes);

  stdout.writeln('Wrote: ${outFile.path}');
  stdout.writeln('Frames: $decodedFrames @ ${fps}fps (~${frameDurationMs}ms/frame)');
}

int _clampInt(int value, int minValue, int maxValue) {
  if (value < minValue) return minValue;
  if (value > maxValue) return maxValue;
  return value;
}

String _defaultOutPath({required String dirPath, required String? prefix}) {
  final baseName = (prefix == null || prefix.trim().isEmpty)
      ? 'preview'
      : prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]+'), '');
  final safeBase = baseName.isEmpty ? 'preview' : baseName;
  return '${dirPath.replaceAll('\\', '/')}/$safeBase.gif';
}

void _printHelp() {
  stdout.writeln('''
Build a GIF preview from PNG animation frames (no emulator needed).

Required:
  --dir <path>        Directory with PNG frames

Optional:
  --prefix <text>     Only include files whose name starts with prefix (e.g. idle_)
  --fps <int>         Frames per second (default 8)
  --out <path>        Output GIF path (default: <dir>/<prefix>.gif)

Examples:
  dart run scripts/preview_animation_gif.dart --dir assets/images/characters/character_v2/idle --prefix idle_ --fps 10 --out artifacts/comfyui/previews/idle.gif
  dart run scripts/preview_animation_gif.dart --dir assets/images/characters/character_v2/run  --prefix run_  --fps 12 --out artifacts/comfyui/previews/run.gif
''');
}

Map<String, String?> _parseArgs(List<String> args) {
  final out = <String, String?>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('-')) continue;

    final key = a.replaceFirst(RegExp(r'^-+'), '');
    String? value;
    final eqIndex = key.indexOf('=');
    if (eqIndex != -1) {
      final k = key.substring(0, eqIndex);
      value = key.substring(eqIndex + 1);
      out[k] = value;
      continue;
    }

    if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
      value = args[i + 1];
      i++;
    } else {
      value = 'true';
    }

    out[key] = value;
  }
  return out;
}
```

## scripts/inspect_animation_gif.dart
```dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.containsKey('help') || parsed.containsKey('h') || args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final gifPath = parsed['gif'] ?? parsed['g'];
  if (gifPath == null || gifPath.trim().isEmpty) {
    stderr.writeln('Missing required arg: --gif');
    _printHelp();
    exit(2);
  }

  final outStripPath = parsed['outStrip'] ?? parsed['strip'];
  final cols = int.tryParse(parsed['cols'] ?? '') ?? 8;
  final safeCols = cols <= 0 ? 8 : cols;

  final file = File(gifPath);
  if (!file.existsSync()) {
    stderr.writeln('GIF not found: $gifPath');
    exit(2);
  }

  final bytes = file.readAsBytesSync();
  final decoded = img.decodeGif(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode GIF: $gifPath');
    exit(2);
  }

  final frames = decoded.frames;
  final frameCount = decoded.numFrames;

  stdout.writeln('GIF: ${file.path}');
  stdout.writeln('Size: ${decoded.width}x${decoded.height}');
  stdout.writeln('Frames: $frameCount');
  stdout.writeln('LoopCount: ${decoded.loopCount} (0 = forever)');

  final durationsMs = <int>[];
  for (final f in frames) {
    durationsMs.add(f.frameDuration);
  }

  final nonZero = durationsMs.where((d) => d > 0).toList();
  final avgMs = nonZero.isEmpty
      ? 0
      : (nonZero.reduce((a, b) => a + b) / nonZero.length).round();
  final approxFps = avgMs > 0 ? (1000 / avgMs).toStringAsFixed(2) : 'n/a';

  stdout.writeln('Frame durations (ms): ${durationsMs.join(', ')}');
  stdout.writeln('Avg non-zero frame duration: ${avgMs == 0 ? 'n/a' : '${avgMs}ms'}');
  stdout.writeln('Approx fps: $approxFps');

  if (outStripPath != null && outStripPath.trim().isNotEmpty) {
    final stripFile = File(outStripPath);
    stripFile.parent.createSync(recursive: true);

    final w = decoded.width;
    final h = decoded.height;
    final cols = safeCols;
    final rows = ((frameCount + cols - 1) / cols).floor();

    final strip = img.Image(width: w * cols, height: h * rows, numChannels: 4);

    for (var i = 0; i < frameCount; i++) {
      final f = frames[i].convert(format: img.Format.uint8);
      final x = (i % cols) * w;
      final y = (i ~/ cols) * h;
      img.compositeImage(strip, f, dstX: x, dstY: y);
    }

    final pngBytes = img.encodePng(strip);
    stripFile.writeAsBytesSync(pngBytes);

    stdout.writeln('Wrote strip: ${stripFile.path}');
  }
}

void _printHelp() {
  stdout.writeln('''
Inspect an animated GIF (frame count, timing) and optionally create a PNG strip.

Required:
  --gif <path>          Path to a .gif file

Optional:
  --outStrip <path>     Write a contact sheet (PNG) with all frames
  --cols <int>          Columns in the strip (default 8)

Examples:
  dart run scripts/inspect_animation_gif.dart --gif artifacts/comfyui/previews/idle.gif --outStrip artifacts/comfyui/previews/idle_strip.png --cols 8
''');
}

Map<String, String?> _parseArgs(List<String> args) {
  final out = <String, String?>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('-')) continue;

    final key = a.replaceFirst(RegExp(r'^-+'), '');
    String? value;

    final eqIndex = key.indexOf('=');
    if (eqIndex != -1) {
      final k = key.substring(0, eqIndex);
      value = key.substring(eqIndex + 1);
      out[k] = value;
      continue;
    }

    if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
      value = args[i + 1];
      i++;
    } else {
      value = 'true';
    }

    out[key] = value;
  }
  return out;
}
```

## scripts/audit_animation_frames.dart
```dart
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

void main(List<String> args) {
  final parsed = _parseArgs(args);
  if (parsed.containsKey('help') || parsed.containsKey('h') || args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final dirPath = parsed['dir'] ?? parsed['d'];
  if (dirPath == null) {
    stderr.writeln('Missing required arg: --dir');
    _printHelp();
    exit(2);
  }

  final prefix = parsed['prefix'];

  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: $dirPath');
    exit(2);
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.png'))
      .where((f) {
        if (prefix == null || prefix.trim().isEmpty) return true;
        return f.uri.pathSegments.last.startsWith(prefix);
      })
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('No PNG files found in: $dirPath');
    exit(2);
  }

  final decoded = <_Frame>[];
  for (final f in files) {
    final bytes = f.readAsBytesSync();
    final sha = sha256.convert(bytes).toString().substring(0, 12);

    final image = img.decodePng(bytes);
    if (image == null) {
      stderr.writeln('Failed to decode: ${f.path}');
      continue;
    }

    final aHash = _averageHash(image, size: 8);
    final small = img.copyResize(
      image,
      width: 64,
      height: 64,
      interpolation: img.Interpolation.average,
    );

    decoded.add(
      _Frame(
        name: f.uri.pathSegments.last,
        sha12: sha,
        w: image.width,
        h: image.height,
        aHash: aHash,
        small: small,
      ),
    );
  }

  if (decoded.length < 2) {
    stdout.writeln('Only ${decoded.length} decodable frame(s). Nothing to compare.');
    exit(0);
  }

  stdout.writeln('Frames: ${decoded.length}');
  stdout.writeln('Dir: $dirPath');
  stdout.writeln('---');

  for (final fr in decoded) {
    stdout.writeln('${fr.name}  sha=${fr.sha12}  ${fr.w}x${fr.h}  aHash=${_hashToHex(fr.aHash)}');
  }

  stdout.writeln('---');
  stdout.writeln('Similarity (lower = more similar):');

  final first = decoded.first;
  final diffsToFirst = <double>[];
  for (final fr in decoded) {
    final d = _meanAbsDiff(first.small, fr.small);
    diffsToFirst.add(d);
  }

  final diffsConsecutive = <double>[];
  final diffsConsecutiveRgba = <double>[];
  final hammingConsecutive = <int>[];
  final bestShift = <({int dx, int dy, double diff})>[];
  for (var i = 1; i < decoded.length; i++) {
    diffsConsecutive.add(_meanAbsDiff(decoded[i - 1].small, decoded[i].small));
    diffsConsecutiveRgba.add(
      _meanAbsDiffRgbaPremultiplied(decoded[i - 1].small, decoded[i].small),
    );
    hammingConsecutive.add(_hamming64(decoded[i - 1].aHash, decoded[i].aHash));
    bestShift.add(_bestTranslationMatch(decoded[i - 1].small, decoded[i].small, maxShift: 4));
  }

  for (var i = 0; i < decoded.length; i++) {
    final fr = decoded[i];
    final dFirst = diffsToFirst[i];
    final dPrev = i == 0 ? double.nan : diffsConsecutive[i - 1];
    final hPrev = i == 0 ? null : hammingConsecutive[i - 1];

    final dPrevRgba = i == 0 ? double.nan : diffsConsecutiveRgba[i - 1];
    final shift = i == 0 ? null : bestShift[i - 1];

    final prevText = i == 0
        ? 'prev=  -'
        : 'prev=${dPrev.toStringAsFixed(4)} rgb  ${dPrevRgba.toStringAsFixed(4)} rgba (aHash Δ=${hPrev.toString().padLeft(2)})';

    final shiftText = i == 0
        ? ''
        : '  bestShift=(${shift!.dx.toString().padLeft(2)},${shift.dy.toString().padLeft(2)}) diff=${shift.diff.toStringAsFixed(4)}';

    stdout.writeln(
      '${fr.name.padRight(14)} first=${dFirst.toStringAsFixed(4)}  $prevText$shiftText',
    );
  }

  stdout.writeln('---');
  final maxToFirst = diffsToFirst.reduce(math.max);
  final minToFirst = diffsToFirst.reduce(math.min);
  final avgToFirst = diffsToFirst.reduce((a, b) => a + b) / diffsToFirst.length;

  final maxPrev = diffsConsecutive.isEmpty ? 0.0 : diffsConsecutive.reduce(math.max);
  final minPrev = diffsConsecutive.isEmpty ? 0.0 : diffsConsecutive.reduce(math.min);
  final avgPrev = diffsConsecutive.isEmpty
      ? 0.0
      : diffsConsecutive.reduce((a, b) => a + b) / diffsConsecutive.length;

  final maxPrevRgba =
      diffsConsecutiveRgba.isEmpty ? 0.0 : diffsConsecutiveRgba.reduce(math.max);
  final minPrevRgba =
      diffsConsecutiveRgba.isEmpty ? 0.0 : diffsConsecutiveRgba.reduce(math.min);
  final avgPrevRgba = diffsConsecutiveRgba.isEmpty
      ? 0.0
      : diffsConsecutiveRgba.reduce((a, b) => a + b) / diffsConsecutiveRgba.length;

  stdout.writeln('Summary (mean abs diff @64x64, 0..1-ish):');
  stdout.writeln(
    '  to first:  min=${minToFirst.toStringAsFixed(4)} avg=${avgToFirst.toStringAsFixed(4)} max=${maxToFirst.toStringAsFixed(4)}',
  );
  stdout.writeln(
    '  prev diff: min=${minPrev.toStringAsFixed(4)} avg=${avgPrev.toStringAsFixed(4)} max=${maxPrev.toStringAsFixed(4)}',
  );
  stdout.writeln(
    '  prev rgba: min=${minPrevRgba.toStringAsFixed(4)} avg=${avgPrevRgba.toStringAsFixed(4)} max=${maxPrevRgba.toStringAsFixed(4)}',
  );

  if (bestShift.isNotEmpty) {
    final shiftMag = bestShift
        .map((s) => math.sqrt((s.dx * s.dx + s.dy * s.dy).toDouble()))
        .toList(growable: false);
    final avgShift = shiftMag.reduce((a, b) => a + b) / shiftMag.length;
    final maxShiftMag = shiftMag.reduce(math.max);
    stdout.writeln(
      '  bestShift: avg=${avgShift.toStringAsFixed(2)}px max=${maxShiftMag.toStringAsFixed(2)}px (search ±4px)',
    );
  }

  final maxH = hammingConsecutive.isEmpty ? 0 : hammingConsecutive.reduce(math.max);
  final minH = hammingConsecutive.isEmpty ? 0 : hammingConsecutive.reduce(math.min);
  final avgH = hammingConsecutive.isEmpty
      ? 0.0
      : hammingConsecutive.reduce((a, b) => a + b) / hammingConsecutive.length;

  stdout.writeln('  aHash Δ:   min=$minH avg=${avgH.toStringAsFixed(1)} max=$maxH (0..64)');

  // Heuristic guidance (very rough):
  // - If aHash deltas are ~0 and premultiplied RGBA diffs are tiny, frames are likely "same pose + noise".
  // - If bestShift is non-trivial AND shifted diff becomes tiny, motion is likely mostly translation.
  if (decoded.length >= 2) {
    final likelyStatic = avgH < 1.0 && avgPrevRgba < 0.030;

    var likelyMostlyTranslation = false;
    if (bestShift.isNotEmpty) {
      final avgShifted =
          bestShift.map((s) => s.diff).reduce((a, b) => a + b) / bestShift.length;
      final shiftMag = bestShift
          .map((s) => math.sqrt((s.dx * s.dx + s.dy * s.dy).toDouble()))
          .toList(growable: false);
      final avgShift = shiftMag.reduce((a, b) => a + b) / shiftMag.length;

      // If we can explain most changes by a small shift, shifted diff should be much lower.
      if (avgShift >= 0.75 && avgShifted <= (avgPrevRgba * 0.55)) {
        likelyMostlyTranslation = true;
      }
    }

    stdout.writeln('Assessment (heuristic):');
    if (likelyMostlyTranslation) {
      stdout.writeln('  - Motion risk: looks like mostly translation between frames.');
    } else if (likelyStatic) {
      stdout.writeln('  - Motion risk: frames likely too similar (pose change not visible).');
    } else {
      stdout.writeln('  - Looks more alive: variation is likely visible frame-to-frame.');
    }
  }
}

void _printHelp() {
  stdout.writeln('''
Audit animation frames for similarity.

Required:
  --dir <path>        Directory with PNG frames

Optional:
  --prefix <text>     Only include files whose name starts with prefix (e.g. idle_)

Example:
  dart run scripts/audit_animation_frames.dart --dir assets/images/characters/character_v2/idle --prefix idle_
''');
}

Map<String, String?> _parseArgs(List<String> args) {
  final out = <String, String?>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('-')) continue;

    final key = a.replaceFirst(RegExp(r'^-+'), '');
    String? value;
    final eqIndex = key.indexOf('=');
    if (eqIndex != -1) {
      final k = key.substring(0, eqIndex);
      value = key.substring(eqIndex + 1);
      out[k] = value;
      continue;
    }

    if (i + 1 < args.length && !args[i + 1].startsWith('-')) {
      value = args[i + 1];
      i++;
    } else {
      value = 'true';
    }

    out[key] = value;
  }
  return out;
}

class _Frame {
  _Frame({
    required this.name,
    required this.sha12,
    required this.w,
    required this.h,
    required this.aHash,
    required this.small,
  });

  final String name;
  final String sha12;
  final int w;
  final int h;
  final int aHash; // 64-bit packed
  final img.Image small;
}

int _averageHash(img.Image input, {required int size}) {
  final resized = img.copyResize(
    input,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );

  final values = <int>[];
  var sum = 0.0;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final p = resized.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final v = ((r + g + b) / 3).round();
      values.add(v);
      sum += v;
    }
  }

  final avg = sum / values.length;

  var bits = 0;
  for (var i = 0; i < values.length; i++) {
    if (values[i] >= avg) {
      bits |= (1 << i);
    }
  }

  return bits;
}

int _hamming64(int a, int b) {
  var x = a ^ b;
  var count = 0;
  while (x != 0) {
    x &= (x - 1);
    count++;
  }
  return count;
}

String _hashToHex(int v) {
  // 64 bits => 16 hex chars.
  final u = v.toUnsigned(64);
  return u.toRadixString(16).padLeft(16, '0');
}

double _meanAbsDiff(img.Image a, img.Image b) {
  if (a.width != b.width || a.height != b.height) {
    throw StateError('Image sizes differ: ${a.width}x${a.height} vs ${b.width}x${b.height}');
  }

  var sum = 0.0;
  final n = a.width * a.height * 3;

  for (var y = 0; y < a.height; y++) {
    for (var x = 0; x < a.width; x++) {
      final pa = a.getPixel(x, y);
      final pb = b.getPixel(x, y);

      sum += (pa.r.toInt() - pb.r.toInt()).abs();
      sum += (pa.g.toInt() - pb.g.toInt()).abs();
      sum += (pa.b.toInt() - pb.b.toInt()).abs();
    }
  }

  // Normalize to roughly 0..1.
  return sum / (n * 255.0);
}

double _meanAbsDiffRgbaPremultiplied(img.Image a, img.Image b) {
  if (a.width != b.width || a.height != b.height) {
    throw StateError('Image sizes differ: ${a.width}x${a.height} vs ${b.width}x${b.height}');
  }

  var sum = 0.0;
  final n = a.width * a.height * 4;

  for (var y = 0; y < a.height; y++) {
    for (var x = 0; x < a.width; x++) {
      final pa = a.getPixel(x, y);
      final pb = b.getPixel(x, y);

      final aa = pa.a.toInt();
      final ab = pb.a.toInt();

      // Premultiply so transparent areas don't dominate.
      final ar = (pa.r.toInt() * aa) ~/ 255;
      final ag = (pa.g.toInt() * aa) ~/ 255;
      final ablu = (pa.b.toInt() * aa) ~/ 255;

      final br = (pb.r.toInt() * ab) ~/ 255;
      final bg = (pb.g.toInt() * ab) ~/ 255;
      final bblu = (pb.b.toInt() * ab) ~/ 255;

      sum += (ar - br).abs();
      sum += (ag - bg).abs();
      sum += (ablu - bblu).abs();
      sum += (aa - ab).abs();
    }
  }

  return sum / (n * 255.0);
}

({int dx, int dy, double diff}) _bestTranslationMatch(
  img.Image a,
  img.Image b, {
  required int maxShift,
}) {
  if (a.width != b.width || a.height != b.height) {
    throw StateError('Image sizes differ: ${a.width}x${a.height} vs ${b.width}x${b.height}');
  }

  var bestDx = 0;
  var bestDy = 0;
  var best = double.infinity;

  for (var dy = -maxShift; dy <= maxShift; dy++) {
    for (var dx = -maxShift; dx <= maxShift; dx++) {
      final d = _meanAbsDiffRgbaPremultipliedShifted(a, b, dx: dx, dy: dy);
      if (d < best) {
        best = d;
        bestDx = dx;
        bestDy = dy;
      }
    }
  }

  return (dx: bestDx, dy: bestDy, diff: best);
}

double _meanAbsDiffRgbaPremultipliedShifted(
  img.Image a,
  img.Image b, {
  required int dx,
  required int dy,
}) {
  // Compare a(x,y) with b(x+dx, y+dy). Out-of-bounds in b => transparent.
  var sum = 0.0;
  final n = a.width * a.height * 4;

  for (var y = 0; y < a.height; y++) {
    final by = y + dy;
    for (var x = 0; x < a.width; x++) {
      final bx = x + dx;

      final pa = a.getPixel(x, y);
      final aa = pa.a.toInt();
      final ar = (pa.r.toInt() * aa) ~/ 255;
      final ag = (pa.g.toInt() * aa) ~/ 255;
      final ablu = (pa.b.toInt() * aa) ~/ 255;

      int br;
      int bg;
      int bblu;
      int ab;

      if (bx < 0 || by < 0 || bx >= b.width || by >= b.height) {
        br = 0;
        bg = 0;
        bblu = 0;
        ab = 0;
      } else {
        final pb = b.getPixel(bx, by);
        ab = pb.a.toInt();
        br = (pb.r.toInt() * ab) ~/ 255;
        bg = (pb.g.toInt() * ab) ~/ 255;
        bblu = (pb.b.toInt() * ab) ~/ 255;
      }

      sum += (ar - br).abs();
      sum += (ag - bg).abs();
      sum += (ablu - bblu).abs();
      sum += (aa - ab).abs();
    }
  }

  return sum / (n * 255.0);
}
```
