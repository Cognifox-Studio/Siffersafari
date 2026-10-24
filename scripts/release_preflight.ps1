# One-command release preflight (ROI #42).
# Usage: pwsh scripts/release_preflight.ps1
# Exit non-zero on first failure.

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host '== pubspec version ==' -ForegroundColor Cyan
$pubspec = Get-Content -Raw pubspec.yaml
if ($pubspec -notmatch '(?m)^version:\s*([^\r\n]+)') {
  throw 'Could not read version from pubspec.yaml'
}
$version = $Matches[1].Trim()
Write-Host "version: $version"

Write-Host '== flutter pub get ==' -ForegroundColor Cyan
flutter pub get

Write-Host '== flutter analyze lib test ==' -ForegroundColor Cyan
flutter analyze lib test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== fast release unit tests ==' -ForegroundColor Cyan
flutter test `
  test/unit/logic/spaced_repetition_test.dart `
  test/unit/logic/quiz_provider_srs_test.dart `
  test/unit/audits/question_bank_runtime_status_audit_test.dart
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== debug APK size budget (80 MiB) ==' -ForegroundColor Cyan
flutter build apk --debug
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$apk = 'build/app/outputs/flutter-apk/app-debug.apk'
if (-not (Test-Path $apk)) { throw "Missing APK at $apk" }
$size = (Get-Item $apk).Length
$max = 80 * 1024 * 1024
Write-Host "APK size: $size bytes (max $max)"
if ($size -gt $max) {
  throw "APK exceeds budget ($max bytes)"
}

Write-Host "Preflight OK for $version" -ForegroundColor Green
