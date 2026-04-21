param(
  [switch]$SyncFirst,
  [switch]$RunScreenshotsFlow,
  [switch]$AllowLegacyAnimation,
  [string]$ExpectedStateMachine = 'MascotStateMachine',
  [int]$StartupDelaySeconds = 12
)

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$AppId = 'se.cognifox.Siffersafari'
$PixelScript = Join-Path $PSScriptRoot 'flutter_pixel6.ps1'

function Invoke-RepoCommand {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command,
    [string]$FailureMessage = 'Command failed.'
  )

  Push-Location $RepoRoot
  try {
    Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
      throw "$FailureMessage ExitCode=$LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
}

function Get-MascotLogLines {
  $appPid = $null
  $timeoutAt = (Get-Date).AddSeconds(20)

  do {
    try {
      $appPid = (adb shell pidof $AppId).Trim()
    } catch {
      $appPid = $null
    }

    if (-not [string]::IsNullOrWhiteSpace($appPid)) {
      break
    }

    Start-Sleep -Milliseconds 500
  } while ((Get-Date) -lt $timeoutAt)

  if (-not [string]::IsNullOrWhiteSpace($appPid)) {
    $raw = adb logcat -d --pid=$appPid | Select-String -Pattern 'MascotCharacter' | ForEach-Object { $_.Line }
    return @($raw)
  }

  $raw = adb logcat -d | Select-String -Pattern 'MascotCharacter' | ForEach-Object { $_.Line }
  return @($raw)
}

function Start-AppAndCollectLogs {
  adb logcat -c | Out-Null
  $commandOutputLines = @()

  if ($RunScreenshotsFlow) {
    Push-Location $RepoRoot
    try {
      $commandOutputLines = @(& cmd /c flutter test integration_test\screenshots_test.dart -d emulator-5554 2>&1)
      $commandOutputLines | Out-Host
      if ($LASTEXITCODE -ne 0) {
        throw "Screenshot integration flow failed. ExitCode=$LASTEXITCODE"
      }
    } finally {
      Pop-Location
    }
  }

  adb shell am force-stop $AppId | Out-Null
  Start-Sleep -Seconds 2
  adb shell monkey -p $AppId -c android.intent.category.LAUNCHER 1 | Out-Null
  Start-Sleep -Seconds $StartupDelaySeconds

  return @($commandOutputLines + (Get-MascotLogLines))
}

if ($SyncFirst) {
  & powershell -ExecutionPolicy Bypass -File $PixelScript -Action sync
  if ($LASTEXITCODE -ne 0) {
    throw "Pixel sync failed. ExitCode=$LASTEXITCODE"
  }
}

$lines = Start-AppAndCollectLogs

if (-not $lines -or $lines.Count -eq 0) {
  throw 'No MascotCharacter runtime logs were captured.'
}

$joined = ($lines -join "`n")
$usedExpectedStateMachine = $joined.Contains("using state machine $ExpectedStateMachine")
$usedLegacyAnimation = $joined.Contains('using legacy animation')
$usedStaticFallback = $joined.Contains('using static SVG fallback')
$sawReactionLog = $joined.Contains('fire reaction MascotReaction.')

Write-Host 'Mascot runtime log summary:'
$lines | ForEach-Object { Write-Host $_ }

if ($usedExpectedStateMachine) {
  Write-Host "PASS: Mascot uses state machine $ExpectedStateMachine." -ForegroundColor Green
  exit 0
}

if ($usedLegacyAnimation) {
  if ($AllowLegacyAnimation) {
    Write-Host 'WARN: Mascot uses legacy animation compatibility path.' -ForegroundColor Yellow
    exit 0
  }

  throw 'Mascot still uses legacy animation compatibility path instead of the expected state machine export.'
}

if ($usedStaticFallback) {
  throw 'Mascot fell back to static SVG. The exported .riv is not usable at runtime.'
}

if ($sawReactionLog) {
  throw 'Mascot reactions were observed, but export status could not be determined from the captured logs. Re-run after a fresh manual .riv export and inspect whether a state-machine status line appears.'
}

throw 'Mascot runtime logs were captured, but no expected state machine, legacy animation, static fallback, or reaction line was found.'