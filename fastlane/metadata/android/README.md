# Play Store listing metadata

Den har mappen ar kallsanningen for automatisk listing-sync via `.github/workflows/play-store-listing.yml`.

## Textmetadata

- `sv-SE/title.txt`
- `sv-SE/short_description.txt`
- `sv-SE/full_description.txt`
- `en-US/title.txt`
- `en-US/short_description.txt`
- `en-US/full_description.txt`

## Valfria bilder

Nar du ar redo att synca bilder eller screenshots, lagg dem har:

- `<locale>/images/icon.png`
- `<locale>/images/featureGraphic.png`
- `<locale>/images/phoneScreenshots/*.png`

Nuvarande kallsor i repo:t:

- Appikon: `assets/images/app_icon/appikon siffersafari_play_console_512.png`
- Play screenshots: `artifacts/play_console_phone_9x16/*.png`

Release notes ligger medvetet separat i `play/release-notes/` sa att binar-upload och listing-copy inte blandas ihop.