---
description: "Regler för Google Play Console publicering, versionshantering, och app-policies (COPPA)"
applyTo: "pubspec.yaml, docs/DEPLOY_ANDROID.md, .github/workflows/release.yml, android/app/build.gradle.kts"
---

# Google Play Publishing & Policies (Siffersafari)

Dessa regler gäller för all kod som påverkar byggnad, paketering eller publicering av appen till Google Play.

## Versionshantering (`pubspec.yaml`)
- **Version Bumping:** Uppdatera alltid både versionsnamn och versionskod när en ny release skapas (t.ex. från `1.3.4+12` till `1.3.5+13`).

## App-format
- **AAB krävs:** Google Play Console kräver Android App Bundle (`.aab`). Ladda inte upp `.apk`-filer till Play Store.

## Behörigheter och Uppdateringar
- **Ingen Sideloading/OTA:** Appen får inte begära behörigheten `REQUEST_INSTALL_PACKAGES` eller innehålla mekanik för självuppdatering (t.ex. `ota_update`). Detta leder till omedelbar avvisning för appar som riktar sig till barn.

## COPPA och Reklam
- **Barnpolicy (COPPA):** Appen riktar sig primärt till barn (6-12 år). Den deklarerar uttryckligen i Play Console att den **inte** använder Advertising ID eller spårnings-SDK:er.
- **Inga annonser:** Det är förbjudet att injicera annons-SDK:er i kodbasen. Appen ska vara helt fri från spårning och marknadsföring riktad till tredje part.
