# Deploying to Android

Denna guide visar hur du **bygger, testar och releaser** APK:er för Android.

---

## Quick Start

**För utveckling (Pixel_6 emulator):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync
```

## 0. Automatisk Release via GitHub Actions (Rekommenderas)
Vi har nu en fullt konfigurerad CI/CD pipeline för Siffersafari. Du behöver oftast **inte bygga releaser lokalt**. 
Gör så här för att släppa en ny version:

1. Sätt ny version i `pubspec.yaml` (t.ex. `version: 1.3.4+12`).
2. Spara, committa och pusha ändringarna till main.
3. Kör kommandot för att skapa och pusha en ny tagg:
   ```bash
   git tag v1.3.4
   git push origin v1.3.4
   ```
4. Pipelinen (`.github/workflows/release.yml`) sätter automatiskt upp Keystore (via GitHub Secrets), analyserar koden, kör alla tester, bygger Android release apk (`app-release.apk`) och laddar upp detta till *GitHub Releases*.

---

## 1. Development Build (Debug)

### Via Pixel_6-script (rekommenderat)

Denna PowerShell-script bygger, installerar och startar appen deterministiskt på Pixel_6:

```powershell
# SYNC: Bygg + installera + starta om appen (säkrast när emulatorn måste matcha kod)
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync

# RUN: Dev-läge med hot reload (snabbare om APK redan installerad)
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action run

# INSTALL: Bara bygg + installera (startar inte appen)
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action install
```

**Varför det här scriptet?**
- ✅ Deterministisk targetting av **Pixel_6** (ingen gissning om vilken enhet)
- ✅ Väntar på att Android är fullt startad (`sys.boot_completed = 1`)
- ✅ Verifierar APK-SHA256 innan installation
- ✅ Minskar risken för "gammal APK som fick inte uppdatera"

### Manual Flutter run

```bash
# Lista enheter
flutter devices

# Kör på specifik enhet
flutter run -d emulator-<id>

# Med debug-info
flutter run -v
```

---

## 2. Test Build (Debug APK)

### Bygga test APK

```bash
flutter build apk --debug

# Output:
# ✓ Built build/app/outputs/flutter-apk/app-debug.apk (XX MB)
```

**Installera manuellt:**
```powershell
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## 3. Release Build (Signed APK)

För att distribuera på **Google Play**, behöver du en **signerad APK**.

### Step 1: Skapa key store (första gången)

```bash
# Generera keystore (sparas hemligt!)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload-key

# Fyllande frågor:
# - Keystore password: (välj starkt lösenord, sparas!)
# - Key password: (samma eller annat)
# - CN (ditt namn): Ropbe  
# - O (organisation): Siffersafari
# - L (stad): (din stad)
# - ST (stat): (din region)
# - C (land): SE

# Resultatet sparas som: upload-keystore.jks (GIT-IGNORERA DENNA!)
```

**VIKTIGT:** `upload-keystore.jks` är hemlig! **ALDRIG commita till Git!** Se `.gitignore`.
## GitHub Actions – Automated Builds & Releases


### Step 2: Konfigurera Android keystore path

Skapa `android/key.properties` (eller uppdatera om den finns):

```properties
storePassword=<ditt_keystore_lösenord>
keyPassword=<ditt_key_lösenord>
keyAlias=upload-key
storeFile=upload-keystore.jks
```

**VIKTIGT:** `key.properties` är även hemlig! Se `.gitignore`.

### Step 3: Bygga release APK

```bash
flutter build apk --release

# Output:
# ✓ Built build/app/outputs/flutter-apk/app-release.apk (XX MB)
```

---

## 4. Google Play Console Setup

*Denna del antas du redan gjort. Om inte, se [Google Play Console docs](https://support.google.com/googleplay/android-developer/answer/9859348).*

**Kort checklist:**
- [ ] Google Play Developer-konto skapat ($25 one-time)
- [ ] Applikation skapad i Play Console
- [ ] Publik integritetspolicy-URL finns och kan öppnas utan inloggning
- [ ] Release-noteringar på svenska/engelska
- [ ] Screenshots för Play Store (finns i `integration_test/screenshots_test.dart`)
- [ ] Icon och feature-graphics uppladdade

**Privacy policy URL för detta repo:**
- Källtext: `docs/PRIVACY_POLICY.md`
- Publik GitHub Pages-sida: `https://cognifox-studio.github.io/Siffersafari/privacy-policy/`
- Deploy-workflow: `.github/workflows/privacy-policy-pages.yml`

---

## 5. Release to Play Store

### Upload APK
4. **Upload APK:** Välj `build/app/outputs/flutter-apk/app-release.apk`
   ```
   Version 1.3.1 - March 21, 2026
   
   - Uppdaterade dependencies (Riverpod, audioplayers, etc.)
   - Förbättrad offline-stabilitet
   - Bugfixar för quiz-progression
   ```
6. **Review & confirm**
7. **Send for review** (eller **Deploy to production**)

**Observera:** First time? Google Play granskar appen (typically 2-4 timmar, ibland upp till 24h). Senare updates går ofta snabbare.

---

## 6. Version Management

Version är definierad i `pubspec.yaml`:

```yaml
version: 1.3.1+9
```

**Namnkonvention:**
- `1.0.0` = Version (3 siffror: major.minor.patch)
- `+1` = Build number (iterativ, incrementeras varje build)

**Innan release:**
```yaml
# Uppdatera:
version: 1.3.1+9

# Commit message:
"chore: bump version to 1.3.1 (Google Play release)"

# Git tag:
git tag v1.3.1
git push origin v1.3.1
```

---

## 7. Pre-Release Checklist

Innan du pushar till Play Store, kör denna checklist:

```bash
# 1. Lint & tests
flutter analyze
flutter test

# 2. Build (debug + release)
flutter build apk --debug
flutter build apk --release

# 3. Manual smoke test på emulator
flutter run -d emulator-<id>
# Testa: profiler skapas, quiz fungerar, achievements sparas

# 4. Signature-verify
# (Flutter gör detta automatiskt för release builds)

# 5. APK size check
ls -lh build/app/outputs/flutter-apk/app-release.apk
# Target: < 50 MB (helst < 30 MB)
```

### OTA-verifiering pa fysisk enhet (release-gate nar OTA andrats)

Krav: Denna checklista ska vara gron innan release bedoms som full go nar OTA-flodet andrats.

1. Enhet: fysisk Android (inte emulator), med tidigare appversion installerad.
2. Data-seed: skapa minst en profil och verifiera att statistik, PIN och quizhistorik finns.
3. Oppna Foraldralage > Appuppdatering och tryck pa `Sok uppdatering`.
4. Bekrafta att ny version hittas och att informationsdialog visas.
5. Starta nedladdning och verifiera att installationsprompt visas efter nedladdning.
6. Installera ovanpa befintlig app (ingen avinstallation fore uppdatering).
7. Efter uppdatering: verifiera dataretention:
   - profil(er) kvar
   - foraldra-PIN kvar
   - statistik/poang kvar
   - quizhistorik kvar
8. Verifiera OTA-kortets statusmeddelanden:
   - ny version tillganglig
   - senaste version installerad
   - felmeddelande vid misslyckad release-kontroll
   - checksum-status visas (aktiv eller saknas metadata)

No-go: om installationsprompt inte visas, eller om dataretention misslyckas.

---

## 8. Troubleshooting

### "APK not aligned to 4 bytes"
```bash
zipalign -v 4 app-release-unaligned.apk app-release.apk
```

### "Keystore not found"
```bash
# Verifiera key.properties finns i android/
# och att storeFile sökvägen är korrekt relativ till android/
```

### "APK is too large"
Kolla size breakdown:
```bash
flutter build apk --release --analyze-size
```

Vanliga culprits:
- ❌ Unused assets (skulle redan vara rensade nu)
- ❌ Stora dependencies (review pubspec.yaml)
- ✅ WAV vs MP3 (vi är i process att konvertera till MP3)

### "Version code X is lower than previously released code Y"
- **Orsak:** Build number i `pubspec.yaml` går inte upp
- **Lösning:** Incrementera `+1` → `+2` etc. innan nästa release

---

## 9. Release Notes Template

Använd denne mall för release notes på Play Store och GitHub:

```markdown
# Version X.Y.Z (Release Date)

## Features
- Feature 1 description
- Feature 2 description

## Improvements
- Improvement 1
- Improvement 2

## Bugfixes
- Fixed bug 1
- Fixed bug 2

## Known Issues
- (om något)

## Technical Changes
- Updated dependency X from v1 to v2
- Refactored Y service
```

---

**Nästa steg:** Läs [ADD_FEATURE.md](ADD_FEATURE.md) för hur man lägger till nya features inom denna pipeline.

---

## 10. GitHub Actions: Closed Beta (Google Play)

For automatisk uppladdning till closed testing finns workflow:

- `.github/workflows/play-closed-beta.yml`

### Secrets som maste finnas i GitHub repo settings

1. `KEYSTORE_BASE64` - base64 av `android/app/upload-keystore.jks`
2. `KEYSTORE_PASSWORD` - losenord till keystore/key
3. `PLAY_SERVICE_ACCOUNT_JSON` - hela JSON-innehallet for Play API service account

### Korning

1. Gå till `Actions` i GitHub.
2. Välj `Play Closed Beta`.
3. Klicka `Run workflow`.
4. Ange `track`:
   - `beta` (vanlig closed beta)
   - `internal` (snabb intern test)
   - eller custom closed track-namn
5. Valfritt: avmarkera `run_tests` om du bara vill verifiera uploadflodet.

### Resultat

Workflow bygger signerad `app-release.aab` och laddar upp till valt Play-track.
Release blir tillganglig enligt Play Consoles granskning/regler for sparet.
