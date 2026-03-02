$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$soundsDir = Join-Path $repoRoot 'assets\sounds'

if (-not (Test-Path $soundsDir)) {
  throw "Hittar inte assets/sounds: $soundsDir"
}

$requiredMp3 = @(
  'background_music.mp3',
  'celebration.mp3',
  'click.mp3',
  'correct.mp3',
  'wrong.mp3'
)

$missing = @()
foreach ($name in $requiredMp3) {
  $path = Join-Path $soundsDir $name
  if (-not (Test-Path $path)) {
    $missing += $name
  }
}

if ($missing.Count -eq 0) {
  Write-Host 'OK: Alla MP3-ljud finns.'
  exit 0
}

Write-Host 'SAKNAS: Följande MP3-filer finns inte ännu:'
$missing | ForEach-Object { Write-Host "  - $_" }
Write-Host ''
Write-Host 'Gor sa har:'
Write-Host '  1) Konvertera WAV till MP3 (t.ex. cloudconvert)'
Write-Host '  2) Lag MP3 i assets/sounds/ med exakt namnen ovan'
Write-Host '  3) Kor detta script igen'
Write-Host '  4) Nar OK: sag till sa uppdaterar vi pubspec.yaml till endast MP3'
exit 1
