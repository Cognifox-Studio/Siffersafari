# Deploying to Android

Denna guide beskriver repo:ts faktiska Android-floden: Pixel_6 for utveckling, signerad `.aab` for Google Play och GitHub Actions for automatisk closed-test-upload.

---

## Snabbval

**Utveckling pa Pixel_6:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync
```

**Automatisk upload till Google Play closed test:**
- Workflow: `.github/workflows/play-closed-beta.yml`
- Format: `build/app/outputs/bundle/release/app-release.aab`

**Signerad APK till GitHub Release:**
- Workflow: `.github/workflows/build.yml`
- Format: `build/app/outputs/flutter-apk/app-release.apk`

Google Play accepterar `.aab`, inte `.apk`.

---

## 1. Utveckling pa Pixel_6

Anvand repo-scriptet for deterministisk build/install mot emulatorn:

```powershell
# Bygg + installera + starta om appen
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync

# Dev-lage med hot reload
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action run

# Bara bygg + installera
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action install
```

Nar native Android, navigation eller UI har andrats ar `sync` den sakraste verifieringen.

---

## 2. Versionshantering

Versionen styrs i `pubspec.yaml`:

```yaml
version: 1.4.3+20
```

- `1.4.3` = versionsnamn
- `20` = versionskod

Innan varje Play-upload ska bada uppdateras. Play nekar nya builds om versionskoden inte okar.

---

## 3. Hemligheter for release och Play API

Foljande GitHub Secrets maste finnas for automatisk Play-upload:

1. `KEYSTORE_BASE64`
2. `KEYSTORE_PASSWORD`
3. `PLAY_SERVICE_ACCOUNT_JSON`

`KEYSTORE_BASE64` ska vara base64 av `android/app/upload-keystore.jks`.

Exempel i PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/upload-keystore.jks"))
```

`PLAY_SERVICE_ACCOUNT_JSON` ska vara hela JSON-innehallet fran ett Google Play service account som har access till appen `se.cognifox.Siffersafari` i Play Console API Access.

Skriv aldrig ut eller klistra in service account-JSON i chatten eller i repo:t.

---

## 4. Automatisk upload till Google Play closed test

Workflowen `.github/workflows/play-closed-beta.yml` bygger signerad AAB och laddar upp den till valt Play-spar.

Release notes for samma workflow ligger i `play/release-notes/` som `whatsnew-sv-SE` och `whatsnew-en-US`.

### Via GitHub UI

1. Oppna `Actions`.
2. Valj `Play Closed Beta`.
3. Klicka `Run workflow`.
4. Ange:
   - `track`: normalt `alpha`
   - `release_status`: `draft` eller `completed`
   - `run_tests`: normalt `true`

### Via GH CLI

```powershell
gh workflow run play-closed-beta.yml -f track=alpha -f release_status=draft -f run_tests=true
```

Hamta senaste korningen:

```powershell
gh run list --workflow play-closed-beta.yml --limit 1
```

### Val av `release_status`

- `draft`: sakrast. Uploadar builden utan att forutsatta att Play accepterar en klar release direkt.
- `completed`: anvand nar du vill att releasen ska behandlas som klar for sparet utan manuell draft-hantering i Console.

Google Play kan fortfarande krava review. Automatisk upload tar bort det manuella upload-steget, inte Googles granskning.

Om Play svarar med `Only releases with status draft may be created on draft app`, kor om workflowen med `release_status=draft`.

---

## 5. Automatisk butikssides-sync

Full listing-sync kor separat via `.github/workflows/play-store-listing.yml` och metadata i `fastlane/metadata/android/`.

Det ar medvetet ett eget flode sa att butikstext, screenshots och grafik inte blandas ihop med binar-uploaden.

### Defaultbeteende

- `validate_only=true`: validerar mot Play utan att skriva nya utkast
- `sync_texts=true`: syncar titel + kort/full beskrivning
- `sync_images=false`: uploadar inte icon eller feature graphic utan uttryckligt val
- `sync_screenshots=false`: uploadar inte screenshots utan uttryckligt val
- `send_for_review=false`: metadata sparas som draft i stallet for att skickas vidare direkt

### Via GH CLI

```powershell
gh workflow run play-store-listing.yml -f validate_only=true -f sync_texts=true -f sync_images=false -f sync_screenshots=false -f send_for_review=false
```

Nar du ar nojd med textmetadata kan du kora om workflowen med `validate_only=false`.

### Metadatafiler

- `fastlane/metadata/android/sv-SE/*.txt`
- `fastlane/metadata/android/en-US/*.txt`
- valfria bilder och screenshots enligt `fastlane/metadata/android/README.md`

---

## 6. Lokal manuell fallback

Om du vill bygga samma Play-artefakt lokalt:

```powershell
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Den filen kan laddas upp manuellt i Play Console till closed test.

---

## 7. GitHub Release APK

Workflowen `.github/workflows/build.yml` bygger fortfarande en signerad `app-release.apk` och publicerar den till GitHub Releases.

Det flodet ar bra for intern QA och artefakthantering, men det ersatter inte Google Play-uploaden. For Play ska du anvanda `.aab`.

---

## 8. Rekommenderad verifiering fore Play-upload

Kor minsta rimliga QA-slice fore release:

```powershell
flutter analyze
flutter test
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync
```

Lagg till fokuserade integrationstester eller smoke-test nar andringen beror quizflode, navigation, assets eller Android-beteende.

Produktappen ska forbli fri fran OTA/sideload-logik, `REQUEST_INSTALL_PACKAGES`, annonser och tracking-SDK:er.

---

## 9. Play Console-forberedelser

Verifiera att dessa Play-ytor redan ar korrekta innan du automatiserar fler uploads:

1. Integritetspolicyn ar publik och oppen utan inloggning.
2. Appen anvander ratt package name: `se.cognifox.Siffersafari`.
3. Servicekontot ar kopplat via Play Console API Access.
4. Closed-test-sparet du valjer finns faktiskt i Play Console, normalt `alpha`.
5. Metadata-workflowen anvander `fastlane/metadata/android/` som kallsanning for listing-copy.

Repo-facit for privacy policy:

- Kalltext: `docs/PRIVACY_POLICY.md`
- Publik sida: `https://cognifox-studio.github.io/Siffersafari/privacy-policy/`

---

## 10. Troubleshooting

### Missing required secrets

Workflowen stoppar tidigt om `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD` eller `PLAY_SERVICE_ACCOUNT_JSON` saknas.

Listing-workflowen kraver bara `PLAY_SERVICE_ACCOUNT_JSON`.

### `Only releases with status draft may be created on draft app`

Play accepterar inte `completed` an. Kor samma workflow igen med `release_status=draft`.

### Package mismatch

Play-uploaden maste anvanda samma package name som appen i Console: `se.cognifox.Siffersafari`.

### AAB/APK for stor

Analysera storleken med:

```powershell
flutter build appbundle --release --analyze-size
```

### Version code is lower than previously released code

Oka buildnumret i `pubspec.yaml`, till exempel `1.4.3+20` -> `1.4.4+21`.

---

Nasta steg for ny releaseyta eller releasebeslut finns i `docs/SESSION_BRIEF.md` och `docs/DECISIONS_LOG.md`.
