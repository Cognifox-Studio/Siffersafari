# Audio Conversion: WAV → MP3

## Problem
Alla ljudfiler är för närvarande `.wav`-format, vilket resulterar i stor APK-storlek:
- Background music: ~3-5 MB
- SFX files: ~100-500 KB vardera
- **Total påverkan på APK**: ~10-20 MB onödig storlek

## Lösning
Konvertera alla `.wav`-filer till `.mp3` med 128-192 kbps kvalitet för att minska storleken med ~90%.

OBS: Projektet listar ljudassets explicit i `pubspec.yaml` för att undvika att `*.backup_*` råkar packas in i APK. Det betyder att du först ska lägga in MP3-filerna, och därefter uppdatera `pubspec.yaml` till att peka på MP3.

---

## Metod 1: Online Converter (Enklast, ingen installation)

### Steg:
1. Gå till https://cloudconvert.com/wav-to-mp3
2. Ladda upp alla `.wav`-filer (kan göra bulk upload)
3. Välj inställningar:
   - **Bitrate**: 128 kbps (för SFX) eller 192 kbps (för music)
   - **Quality**: High
4. Konvertera och ladda ner `.mp3`-filerna
5. Placera dem i `assets/sounds/` (samma namn som .wav men .mp3 extension)
6. Ta INTE bort .wav-filerna ännu (AudioService har fallback, och `background_music` använder idag fortfarande WAV som primary)
7. När MP3-filerna ligger på plats: uppdatera `pubspec.yaml` så att endast MP3 packas in

### Filnamn som appen förväntar sig
- `background_music.mp3`
- `celebration.mp3`
- `click.mp3`
- `correct.mp3`
- `wrong.mp3`

---

## Metod 2: FFmpeg (Bäst kvalitet, kräver installation)

### Installation (Windows):
```powershell
# Med Chocolatey:
choco install ffmpeg

# Eller ladda ner från: https://ffmpeg.org/download.html
```

### Konvertering (PowerShell):
```powershell
cd assets/sounds

# Konvertera alla WAV till MP3 med 128 kbps
Get-ChildItem *.wav | ForEach-Object {
    $mp3 = $_.BaseName + ".mp3"
    ffmpeg -i $_.Name -codec:a libmp3lame -b:a 128k $mp3
}

# För background music: använd 192 kbps
ffmpeg -i background_music.wav -codec:a libmp3lame -b:a 192k background_music.mp3
```

---

## Metod 3: Audacity (Gratis, GUI-baserad)

### Steg:
1. Ladda ner Audacity: https://www.audacityteam.org/
2. Öppna `.wav`-fil
3. File → Export → Export as MP3
4. Välj kvalitet: 128 kbps (Voice) eller 192 kbps (Music)
5. Spara som samma namn men `.mp3` extension

---

## Filstorlek jämförelse (uppskattad)

| Fil | WAV-storlek | MP3-storlek (128 kbps) | Besparing |
|-----|-------------|------------------------|-----------|
| correct.wav | ~200 KB | ~20 KB | 90% |
| wrong.wav | ~150 KB | ~15 KB | 90% |
| celebration.wav | ~400 KB | ~40 KB | 90% |
| click.wav | ~50 KB | ~5 KB | 90% |
| background_music.wav | ~5 MB | ~500 KB | 90% |
| **TOTAL** | **~6 MB** | **~600 KB** | **~5.4 MB saved** |

---

## Efter konvertering

1. Verifiera att alla `.mp3`-filer fungerar i appen
2. Ta bort `.wav`-backup-filerna (`.wav.backup_*`)
3. (Valfritt) Ta bort `.wav`-originalfilerna när .mp3 är verifierade
4. Ta bort fallback-logiken från `AudioService._playAssetWithFallback()`

---

## AudioService-integration

För ljudeffekter försöker `AudioService` redan ladda `.mp3` först:
```dart
await _playAssetWithFallback(
  player: _audioPlayer,
  primary: 'sounds/correct.mp3',    // Försöker först
  fallback: 'sounds/correct.wav',    // Fallback om .mp3 saknas
);
```

För `background_music` är ordningen just nu omvänd (`.wav` primary, `.mp3` fallback), så där behövs en liten kodjustering om MP3 ska bli förstahandsval även i runtime.

---

## Testning efter konvertering

```powershell
# Bygg och kolla APK-storlek
flutter build apk --debug
Get-Item build\app\outputs\flutter-apk\app-debug.apk | Select-Object Length

# Jämför före/efter lokalt för att mäta faktisk minskning i detta repo
```

---

## Nästa steg (produktion)

För release build (Play Store):
```powershell
flutter build apk --release
# Mät faktisk release-storlek lokalt efter konverteringen
```

Kombinerat med release-optimeringar kan detta ge en tydlig minskning av APK-storleken.
