---
name: synka-play-assets
description: 'Sync Play Store listing assets for Siffersafari into fastlane metadata. Use when screenshots, icon eller feature graphic ska forberedas for play-store-listing.yml, fastlane/metadata/android eller Play Console listing sync.'
argument-hint: 'Valfritt: begransa till screenshots, ikon eller full listing-assets.'
---

# Synka Play-assets

Denna skill används när listing-bilder ska föras in i repo:ts Fastlane-metadata utan att blanda ihop dem med appens runtime-assets eller råa emulator-dumpar.

## Mål

- kopiera rätt screenshots till `fastlane/metadata/android/<locale>/images/phoneScreenshots/`
- kopiera rätt ikon till `fastlane/metadata/android/<locale>/images/icon.png`
- bara lägga till `featureGraphic.png` när en faktisk, avsedd källa finns i repo:t

## Källor att verifiera först

- `assets/images/app_icon/appikon siffersafari_play_console_512.png`
- `artifacts/play_console_phone_9x16/*.png`
- `fastlane/metadata/android/README.md`
- `docs/DEPLOY_ANDROID.md`

Använd inte `artifacts/play_console_raw/` som defaultkälla för listing-bilder när färdiga 9x16-captures redan finns.

## Arbetsflöde

1. Inventera faktiska källfiler på disk innan något kopieras.
2. Klargör scope: bara screenshots, bara ikon eller full listing-yta.
3. Kopiera, flytta aldrig, från källmapp till `fastlane/metadata/android/<locale>/images/...`.
4. Bevara screenshot-ordningen deterministiskt med filnamn som redan sorterar rätt.
5. Om samma screenshots ska användas för `sv-SE` och `en-US`, kopiera samma uppsättning till båda locale-mapparna i stället för att referera tillbaka till en gemensam mapp.
6. Om `featureGraphic` saknas: stoppa där och säg det uttryckligen i stället för att använda en godtycklig screenshot som ersättning.

## Regler

- Håll listing-sync defensiv: slå inte på `sync_images` eller `sync_screenshots` i workflowen förrän filer faktiskt finns och är granskade.
- Rör inte produktionsassets under `assets/` mer än nödvändigt; listing-kopian ska ligga under `fastlane/metadata/android/`.
- Behåll repo:s offline-first och child-safe ton även i bildvalen: inga nätverksclaims, inga vuxna adminskärmar och inga råa debugbilder i listing.

## Validering

- Kontrollera att varje fil som ska syncas faktiskt finns på rätt metadata-path efter kopieringen.
- Kontrollera att `play-store-listing.yml` fortfarande kör med rätt scope för den tänkta syncen.
- För rena `.github`- eller metadataändringar räcker diffgranskning och filkontroll; ingen Flutter-QA behövs om inga appfiler ändrats.