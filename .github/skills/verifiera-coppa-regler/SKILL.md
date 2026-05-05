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
   - Letar efter förbjudna tredjepartsverktyg för analys eller reklam (t.ex. `firebase_analytics`, `appsflyer`, reklamnätverk).
   - Tillser att auto-update paket (som `ota_update`) **inte** existerar, då det förbjuds av policy för barnappar.

2. **Kolla Manifest (`android/app/src/main/AndroidManifest.xml`):**
   - Måste absolut sakna permissions för `REQUEST_INSTALL_PACKAGES`.
   - Ska undvika onödiga permissions utöver nätverk för eventuellt framtida in-app godkända upplägg. Inga plats-, kamera- eller telefonboksbehörigheter får smugglas in.

3. **Granska Datatrafik och Exfiltrering (`lib/data/**`):**
   - Skanna efter gömda http-anrop eller telemetri som skickar iväg användardata/profiler till nätet. Allt ska lagras stängt i Hive lokalt.

4. **Sammanställ Rapport:**
   - Om allt ser snyggt ut, returnera en grön "Pass"-rapport.
   - Hittas varningsflaggor, lista filen, raden och exakt varför det bryter mot Barn-policyn, med förslag på borttagning.
