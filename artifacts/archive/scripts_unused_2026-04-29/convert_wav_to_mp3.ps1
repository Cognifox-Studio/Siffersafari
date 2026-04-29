param(
  [string]$SfxBitrate = '128k',
  [string]$MusicBitrate = '192k',
  [switch]$Force,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function BytesToMB([long]$bytes) {
  return [Math]::Round($bytes / 1MB, 2)
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$soundsDir = Join-Path $repoRoot 'assets\sounds'

if (-not (Test-Path $soundsDir)) {
  throw "Hittar inte assets/sounds: $soundsDir"
}

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
  Write-Host 'FFmpeg saknas. Installera t.ex. via:'
  Write-Host '  choco install ffmpeg'
  Write-Host '...eller ladda ner från https://ffmpeg.org/download.html'
  exit 2
}

Write-Host "Repo: $repoRoot"
Write-Host "Ljudmapp: $soundsDir"
Write-Host "ffmpeg: $($ffmpeg.Source)"
Write-Host "SFX bitrate: $SfxBitrate | Music bitrate: $MusicBitrate"

$wavFiles = Get-ChildItem -Path $soundsDir -File -Filter '*.wav' |
  Where-Object { $_.Name -notmatch '\.backup_' } |
  Sort-Object Name

if ($wavFiles.Count -eq 0) {
  Write-Host 'Inga .wav-filer hittades (utan backups).'
  exit 0
}

$converted = 0
$skipped = 0

foreach ($wav in $wavFiles) {
  $mp3Path = Join-Path $soundsDir ($wav.BaseName + '.mp3')
  $bitrate = if ($wav.BaseName -eq 'background_music') { $MusicBitrate } else { $SfxBitrate }

  if ((Test-Path $mp3Path) -and (-not $Force)) {
    $mp3 = Get-Item $mp3Path
    if ($mp3.LastWriteTimeUtc -ge $wav.LastWriteTimeUtc) {
      Write-Host "SKIP: $($wav.Name) -> $([IO.Path]::GetFileName($mp3Path)) (redan aktuell)"
      $skipped++
      continue
    }
  }

  Write-Host "CONVERT: $($wav.Name) -> $([IO.Path]::GetFileName($mp3Path)) (bitrate $bitrate)"

  if (-not $DryRun) {
    & $ffmpeg.Source -y -loglevel error -i $wav.FullName -codec:a libmp3lame -b:a $bitrate $mp3Path
  }

  $converted++
}

$wavTotal = ($wavFiles | Measure-Object -Property Length -Sum).Sum
$mp3Total = (Get-ChildItem -Path $soundsDir -File -Filter '*.mp3' | Measure-Object -Property Length -Sum).Sum

Write-Host ''
Write-Host "Klart. Konverterade: $converted | Skippade: $skipped"
Write-Host "WAV total (utan backups): $(BytesToMB $wavTotal) MB"
Write-Host "MP3 total: $(BytesToMB $mp3Total) MB"
if ($wavTotal -gt 0) {
  $pct = [Math]::Round((1 - ($mp3Total / [double]$wavTotal)) * 100, 1)
  Write-Host "Uppskattad besparing: $pct%"
}
