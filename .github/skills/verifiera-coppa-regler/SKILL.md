---
name: verifiera-coppa-regler
description: 'Audit the repo for COPPA risks such as tracking SDKs, cloud storage, risky permissions, ads or network exfiltration. Use when checking child-app compliance, Play policy risk, analytics, permissions or offline-first guarantees.'
argument-hint: 'Beskriv vilken yta som ska granskas, till exempel release, Android-manifest, analytics eller persistens.'
---

# Skill: Verifiera COPPA-regler

## Syfte
Siffersafari är en app riktad mot barn (6-12 år). Google Plays strikta COPPA-regler (samt policys för familjeprogram) innebär att molnspårning, reklam-SDK eller oförklarliga behörigheter leder till att appen tas bort direkt. Denna skill verifierar att appen förblir säker, offline-first och "clean".

## Arbetsflöde

1. **Skanna Beroenden (`pubspec.yaml`):**
   - Förbjudet: `firebase_analytics`, `firebase_crashlytics` med PII, reklam-SDK, `appsflyer`, m.m.
   - Tillåtet **endast** med föräldraopt-in-backup: `firebase_core`, `firebase_auth`, `cloud_firestore` (se `docs/FIREBASE_CLOUD_BACKUP.md`).
   - Tillser att auto-update paket (som `ota_update`) **inte** existerar.

2. **Kolla Manifest (`android/app/src/main/AndroidManifest.xml`):**
   - Måste absolut sakna permissions för `REQUEST_INSTALL_PACKAGES`.
   - Ska undvika onödiga permissions utöver nätverk för eventuellt framtida in-app godkända upplägg. Inga plats-, kamera- eller telefonboksbehörigheter får smugglas in.

3. **Granska Datatrafik (`lib/data/**`, `lib/core/firebase/**`):**
   - Kärnflöde ska fungera offline; Hive är source of truth.
   - Molnsync får bara ske via `CloudBackupService` när förälder optat in — ingen dold telemetri.

4. **Sammanställ Rapport:**
   - Om allt ser snyggt ut, returnera en grön "Pass"-rapport.
   - Hittas varningsflaggor, lista filen, raden och exakt varför det bryter mot Barn-policyn, med förslag på borttagning.
