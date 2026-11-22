# Assets - Images

Denna mapp innehåller bildresurser för appen.

## Struktur:

```
images/
├── app_icon/           # Källbilder för app-ikon och Play Console-varianter
├── brand/              # Branding (t.ex. Cognifox-logga)
├── themes/             # Temabakgrunder och temakaraktärer
│   ├── jungle/
│   └── space/
├── story/              # Story map-ikoner och miljöbilder
├── ui/                 # UI-ikoner, avatarer och produktbilder
├── items/              # Inventory- och belöningsföremål
├── characters/         # Reserverad för rena karaktärsbilder vid behov
└── generated/          # Tillfälliga genererade bilder
```

## Filer som används direkt i appen

- `themes/` innehåller aktiva temaassets som `background.webp`, `character.webp` och `quest_hero.webp`.
- `story/` innehåller story map-bilder som `cabin.webp` och `campfire.webp`.
- `ui/` innehåller produkt-UI som avatarer, logga, matteikoner och belöningsbilder.
- `items/` innehåller inventory- och outfitföremål som används i garderob och belöningar.
- `brand/` och `app_icon/` innehåller branding- och releasebilder.

## Bildformat:

- **WebP** är standardformatet i denna mapp. Konverteringen gjordes 2026-11-22:
  40,6 MB PNG blev 6,6 MB WebP (84 % mindre) utan synlig kvalitetsförlust.
- Undantag: `app_icon/` behåller PNG, eftersom
  `scripts/generate_android_launcher_icons.dart` läser `icon_source.png`.
- Behåll produktionsassets som rasterbilder om inte en dokumenterad pipeline säger något annat.
- Lägg inte ny aktiv runtime på SVG-, Lottie- eller Rive-spår här utan att först uppdatera repo-dokumentationen.

## Bildstorlekar:

- Ikoner: 48x48, 72x72, 96x96 (olika DPI)
- Bakgrunder: minst 1080x1920 (portrait)
- Karaktärer: 256x256 eller 512x512

## Karaktärer och animation

Denna mapp innehåller statiska bildassets. I produkt-UI används WebP för karaktärer och Flutter-styrda procedurrörelser i kod, inte en separat animationsmapp med runtimefiler.

## Optimering:

- Kör `python3 scripts/convert_images_to_webp.py` (kräver Pillow) när nya PNG:er
  läggs till. Scriptet mäter PSNR per bild: q90 räcker oftast, annars q95, annars
  lossless, och PNG behålls om WebP inte blir minst 20 % mindre.
- Kör inte PNG-optimerare på nytt i onödan — PNG:erna var redan optimerade
  (0,35–0,39 byte/pixel), det var formatet som vägde.
- Använd lämplig upplösning (inte större än nödvändigt)
- Använd @2x, @3x suffixes för olika DPI-varianter

## Resurser för gratis bilder:

- https://unsplash.com
- https://www.flaticon.com (för ikoner)
- https://www.freepik.com
- https://pixabay.com

## Designriktlinjer:

### Rymdtema:
- Färger: Mörkblå, lila, gul (stjärnor)
- Stil: Friendly space, inte för sci-fi
- Element: Planeter, stjärnor, raketer, astronauter

### Djungeltema:
- Färger: Grönt, brunt, gult
- Stil: Lekfull djungel, inte för mörk eller skrämmande
- Element: Träd, blad, djur, lianer

## Licens:

Säkerställ att alla bilder har lämpliga licenser.
