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
      # Goal: "illusion of life" via a simple base loop + layered micro-motions.
      # - Base loop: breathing in/out (chest/shoulders)
      # - Layer: subtle weight shift (hips/feet)
      # - Layer: occasional blink

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
      # 8-step wave (distinct silhouettes): raise -> wave -> lower.
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
      # 8-step jump (clear arcs): crouch -> takeoff -> rise -> apex -> fall -> land -> recover.
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
      # 8-step run cycle (more readable): contact/down/passing/up per leg.
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
  # Pick once; reuse across all frames.
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
