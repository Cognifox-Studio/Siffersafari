---
name: felsok-android-emulatorn
description: 'Troubleshoot Pixel_6 emulator issues such as adb offline, stale APK installs, sync/install failures or launch problems. Use when the repo Pixel_6 workflow does not match the latest build on device.'
argument-hint: 'Beskriv felklassen: adb offline, emulator saknas, stale APK, sync/install-fel eller launch/logcat-problem.'
---

# Felsök Android-emulatorn

## När den ska användas
- När `scripts/flutter_pixel6.ps1` inte hittar eller kan prata med `Pixel_6`.
- När emulatorn är `offline` eller `unauthorized` i `adb devices`.
- När appen på device ser ut som en gammal build trots ny kod.
- När `sync`, `install` eller `run` på Pixel_6 faller.

## Källor
- `docs/GETTING_STARTED.md`
- `docs/SETUP_ENVIRONMENT.md`
- `docs/DEPLOY_ANDROID.md`
- `scripts/flutter_pixel6.ps1`

## Arbetsordning
1. Klassificera felet: emulator, `adb`, stale APK, install eller runtime/logcat.
2. Verifiera billigaste sanningskälla för just den klassen.
3. Kör minsta åtgärd som angriper rotorsaken.
4. Kör om relevant Pixel_6-task eller script och rapportera vad som återstår.

## Felsök per felklass

### 1. Emulatorn hittas inte
- Bekräfta att `Pixel_6` finns och att emulatorn faktiskt kör.
- Använd repoets Pixel_6-task eller `scripts/flutter_pixel6.ps1` i stället för generell `flutter run`.
- Om emulatorn inte kommer upp eller `adb` tappar den: prioritera cold boot utan snapshot innan bredare felsökning.

### 2. `adb device offline` eller `unauthorized`
- Bekräfta först att emulatorn är fullt bootad.
- Följ miljödokumentationen för `adb kill-server`, `adb start-server`, `adb wait-for-device` och ny kontroll med `adb devices`.
- Om Pixel_6 fortsätter fastna offline i detta repo: prioritera cold boot utan snapshot.

### 3. Stale APK eller fel build på device
- Anta inte att `run` alltid installerar exakt senaste APK på enheten.
- Prioritera `scripts/flutter_pixel6.ps1 -Action install` eller `-Action sync` för deterministisk install.
- Om problemet visade sig vara kod och inte install: gå tillbaka till vanlig QA via `.github/skills/testa-att-appen-fungerar/SKILL.md`.

### 4. `sync` eller `install` faller
- Läs felet från `scripts/flutter_pixel6.ps1` och avgör om det är emulator-, adb-, build- eller installfel.
- Om builden är boven: isolera Dart-/Flutter-felet med normal QA innan du fortsätter på device-spåret.
- Om installen är boven: fokusera på adb-anslutning, paketstatus och explicit reinstall i stället för bredare omstartscykler.

### 5. Behov av logcat eller launch-felsök
- Använd Pixel_6-scriptets logcat-flöde i första hand när det redan ingår i workflowet.
- Ta logcat efter install/run bara när problemet verkligen är device- eller runtime-specifikt.

## Kvalitetsgränser
- Eskalera inte direkt till full Flutter-QA om felet tydligt är emulator eller adb.
- Fastna inte i generella Android-råd om repoets Pixel_6-script redan ger ett mer deterministiskt svar.
- Rapportera exakt vilken felklass som återstår om problemet inte är löst.