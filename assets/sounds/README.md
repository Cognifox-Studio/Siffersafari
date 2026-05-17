# Assets - Sounds

Denna mapp innehåller ljudfiler för appen.

## Nödvändiga ljudfiler:

Appen använder idag följande filer i `AudioService`:

- `click`: försöker `click.mp3` först, faller tillbaka till `click.wav`
- `correct`: försöker `correct.mp3` först, faller tillbaka till `correct.wav`
- `wrong`: försöker `wrong.mp3` först, faller tillbaka till `wrong.wav`
- `celebration`: försöker `celebration.mp3` först, faller tillbaka till `celebration.wav`
- `map_open`: försöker `map_open.mp3` först, faller tillbaka till `map_open.wav`
- `quiz_start`: försöker `quiz_start.mp3` först, faller tillbaka till `quiz_start.wav`
- `home_music`: använder `home_music.mp3`
- `story_music`: använder `story_music.mp3`
- `quiz_music`: använder `quiz_music.mp3`

`background_music.wav` finns kvar som äldre asset men används inte längre som primärt standardspår.

I repot finns för närvarande fungerande ljud för:

1. **click** - Knapptryckningar
2. **correct** - Rätt svar
3. **wrong** - Fel svar
4. **celebration** - Framgång/upplåsning
5. **map_open** - Öppna storykartan
6. **quiz_start** - Starta eller fortsätta quiz
7. **home_music** - Kuraterad lugn camp/home-loop (MP3)
8. **story_music** - Kuraterad äventyrlig story-loop (MP3)
9. **quiz_music** - Kuraterad lekfull quiz-loop (MP3)

## Generera lekiga standardljud (lokalt)

Det finns ett litet script som kan (om)generera enkla, barnvänliga standardljud som WAV:

`dart run scripts/generate_sfx_wav.dart --out assets/sounds`

Om du bara vill regenerera vissa filer (för att inte skriva över andra som du redan gillar), använd `--only`:

`dart run scripts/generate_sfx_wav.dart --out assets/sounds --only celebration`

Exempel för effekter:

`dart run scripts/generate_sfx_wav.dart --out assets/sounds --only celebration,map_open,quiz_start`

## Hämta kuraterad bakgrundsmusik automatiskt

För musikspåren använder repot kuraterade royalty-free MP3-filer från Pixabay.

Kör:

`powershell -ExecutionPolicy Bypass -File scripts/download_pixabay_music.ps1`

Spår som hämtas idag:

1. **home_music.mp3** - `Stylish Chill Loop [Promo Vlog Fashion]` av `Sonican`
   Källa: `https://pixabay.com/music/upbeat-stylish-chill-loop-promo-vlog-fashion-305717/`
2. **story_music.mp3** - `Adventure` av `AtlasAudio`
   Källa: `https://pixabay.com/music/adventure-adventure-522409/`
3. **quiz_music.mp3** - `Upbeat` av `prettyjohn1`
   Källa: `https://pixabay.com/music/electro-upbeat-513865/`

Pixabay anger fri användning utan krav på attribution i normal användning, men undvik att omdistribuera spåren fristående utanför appen.

Scriptet skapar alltid en timestampad backup av befintliga `.wav`-filer innan det skriver över.

Backups sparas i `assets/sounds/_backups/` för att undvika att de blandas med appens riktiga ljudassets.

## Rekommendationer:

- Format: MP3, WAV eller OGG
- Kort varaktighet (0.5-2 sekunder för effekter)
- Lagom volym
- Barnvänliga, positiva ljud

## Resurser för gratis ljud:

- https://freesound.org
- https://mixkit.co/free-sound-effects/
- https://pixabay.com/music/
- https://pixabay.com/sound-effects/
- https://www.zapsplat.com

## Licens:

Säkerställ att alla ljudfiler har lämpliga licenser för kommersiellt eller privat bruk.
