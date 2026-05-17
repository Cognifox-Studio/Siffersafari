param(
    [string[]]$Track = @('all'),

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$soundsDir = Join-Path $repoRoot 'assets\sounds'

if (-not (Test-Path $soundsDir)) {
    New-Item -ItemType Directory -Path $soundsDir | Out-Null
}

$catalog = @{
    home = @{
        FileName = 'home_music.mp3'
        Url = 'https://cdn.pixabay.com/download/audio/2025/02/25/audio_bda661f40a.mp3?filename=sonican-stylish-chill-loop-promo-vlog-fashion-305717.mp3'
        SourcePage = 'https://pixabay.com/music/upbeat-stylish-chill-loop-promo-vlog-fashion-305717/'
        Title = 'Stylish Chill Loop [Promo Vlog Fashion]'
        Author = 'Sonican'
    }
    story = @{
        FileName = 'story_music.mp3'
        Url = 'https://cdn.pixabay.com/download/audio/2026/04/20/audio_5d43e65cb4.mp3?filename=atlasaudio-adventure-522409.mp3'
        SourcePage = 'https://pixabay.com/music/adventure-adventure-522409/'
        Title = 'Adventure'
        Author = 'AtlasAudio'
    }
    quiz = @{
        FileName = 'quiz_music.mp3'
        Url = 'https://cdn.pixabay.com/download/audio/2026/04/10/audio_1109a41117.mp3?filename=prettyjohn1-upbeat-513865.mp3'
        SourcePage = 'https://pixabay.com/music/electro-upbeat-513865/'
        Title = 'Upbeat'
        Author = 'prettyjohn1'
    }
}

$validTracks = @('all', 'home', 'story', 'quiz')
foreach ($trackName in $Track) {
    if ($trackName -notin $validTracks) {
        throw "Ogiltigt spårval '$trackName'. Giltiga värden: $($validTracks -join ', ')"
    }
}

$selectedTracks = if ($Track -contains 'all') {
    @('home', 'story', 'quiz')
} else {
    $Track
}

foreach ($trackName in $selectedTracks) {
    $entry = $catalog[$trackName]
    if ($null -eq $entry) {
        throw "Okänt spår: $trackName"
    }

    $destination = Join-Path $soundsDir $entry.FileName
    if ((Test-Path $destination) -and -not $Force) {
        Write-Host "[Music] Skippar befintlig fil: $($entry.FileName)"
        continue
    }

    $tempFile = Join-Path $soundsDir ("$($entry.FileName).download")
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }

    Write-Host "[Music] Hämtar $($entry.Title) av $($entry.Author)"
    Write-Host "[Music] Källa: $($entry.SourcePage)"
    Invoke-WebRequest -Uri $entry.Url -OutFile $tempFile -UseBasicParsing

    if (Test-Path $destination) {
        Remove-Item $destination -Force
    }

    Move-Item -Path $tempFile -Destination $destination

    $file = Get-Item $destination
    Write-Host "[Music] Sparad: $($file.Name) ($($file.Length) bytes)"
}

Write-Host '[Music] Klar.'