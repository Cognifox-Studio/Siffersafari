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

- `themes/` innehåller aktiva temaassets som `background.png`, `character.png` och `quest_hero.png`.
- `story/` innehåller story map-bilder som `cabin.png` och `campfire.png`.
- `ui/` innehåller produkt-UI som avatarer, logga, matteikoner och belöningsbilder.
- `items/` innehåller inventory- och outfitföremål som används i garderob och belöningar.
- `brand/` och `app_icon/` innehåller branding- och releasebilder.

## Bildformat:

- **PNG** är standardformatet i denna mapp.
- Behåll produktionsassets som rasterbilder om inte en dokumenterad pipeline säger något annat.
- Lägg inte ny aktiv runtime på SVG-, Lottie- eller Rive-spår här utan att först uppdatera repo-dokumentationen.

## Bildstorlekar:

- Ikoner: 48x48, 72x72, 96x96 (olika DPI)
- Bakgrunder: minst 1080x1920 (portrait)
- Karaktärer: 256x256 eller 512x512

## Karaktärer och animation

Denna mapp innehåller statiska bildassets. I produkt-UI används PNG-first för karaktärer och Flutter-styrda procedurrörelser i kod, inte en separat animationsmapp med runtimefiler.

## Optimering:

- Komprimera bilder med TinyPNG eller ImageOptim
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
