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

$basePrompt = "cute friendly jungle explorer kid, full body, centered, bold outline, simple shapes, high contrast, clean silhouette, cartoon style, same character, consistent outfit, consistent hat, consistent backpack"
$negative = "scary, creepy, gore, realistic, blurry, noisy, text, watermark, logo, multiple characters, character sheet, cropped, out of frame, cut off, extra fingers, extra limbs, bad hands"

function Get-FrameModifier([int]$i, [int]$n, [string]$anim) {
  $t = if ($n -le 1) { 0.0 } else { $i / [double]$n }

  switch ($anim) {
    'idle' {
      # Gentle sway loop (prompts only; the workflow should keep identity consistent).
      $phase = [Math]::Sin(2.0 * [Math]::PI * $t)
      if ([Math]::Abs($phase) -lt 0.25) { return 'neutral idle pose, relaxed smile' }
      if ($phase -lt 0) { return 'neutral idle pose, relaxed smile, leaning slightly left' }
      return 'neutral idle pose, relaxed smile, leaning slightly right'
    }

    'wave' {
      # Raise -> peak -> lower loop.
      $phase = [Math]::Sin(2.0 * [Math]::PI * $t)
      if ($phase -lt -0.33) { return 'waving with one hand, hand low, starting wave' }
      if ($phase -lt 0.33) { return 'waving with one hand, hand at shoulder height' }
      return 'waving with one hand, hand high, big friendly wave'
    }

    'jump' {
      # Crouch -> takeoff -> air -> land.
      if ($t -lt 0.20) { return 'preparing to jump, crouching slightly, excited' }
      if ($t -lt 0.45) { return 'jumping up, takeoff pose, happy' }
      if ($t -lt 0.75) { return 'in the air, jumping, happy, legs tucked slightly' }
      return 'landing from a jump, knees slightly bent, happy' }

    'run' {
      # Simple 4-phase run cycle repeated.
      $phaseIndex = [int]([Math]::Floor(($t * 4.0))) % 4
      switch ($phaseIndex) {
        0 { return 'running, left leg forward, right leg back, arms pumping' }
        1 { return 'running, passing pose, legs close together, arms pumping' }
        2 { return 'running, right leg forward, left leg back, arms pumping' }
        3 { return 'running, passing pose, legs close together, arms pumping' }
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
Write-Host "Params:   steps=$Steps cfg=$Cfg denoise=$Denoise size=${Width}x${Height}"

for ($i = 0; $i -lt $Frames; $i++) {
  $modifier = Get-FrameModifier -i $i -n $Frames -anim $Anim
  $prompt = "$basePrompt, $modifier"
  $fileName = "${Anim}_$($i.ToString().PadLeft(3,'0')).png"
  $outPath = Join-Path $rawDir $fileName

  Write-Host "---"
  Write-Host "Frame $($i+1)/$Frames: $fileName"

  dart run scripts/generate_images_comfyui.dart `
    --server $Server `
    --workflow $Workflow `
    --init $Init `
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
}

Write-Host "---"
Write-Host "KLAR: Frames genererade i: $OutDir"
Write-Host "Nästa steg (manuellt): välj raw/alpha och kopiera till assets när du är nöjd."
Write-Host "Exempel:"
Write-Host "  Copy-Item \"$rawDir\\${Anim}_*.png\" \"assets/images/characters/character_v2/$Anim/\" -Force"
if ($AlphaAll) {
  Write-Host "  Copy-Item \"$alphaDir\\${Anim}_*.png\" \"assets/images/characters/character_v2/$Anim/\" -Force"
}
