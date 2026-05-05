---
name: "Google Play publicering"
description: "Use when editing Play release docs, Android release workflows, pubspec versioning or child-app policy relevant files. Covers version bumps, AAB, permissions and COPPA constraints."
applyTo: "pubspec.yaml, docs/DEPLOY_ANDROID.md, .github/workflows/release.yml, android/app/build.gradle.kts"
---

# Google Play publishing och policy

- Uppdatera alltid både versionsnamn och versionskod när en ny release tas fram.
- Google Play kräver `.aab` för uppladdning. Behandla `.apk` som lokal verifieringsartefakt, inte som Play-format.
- Lägg inte till `REQUEST_INSTALL_PACKAGES`, OTA-flöden eller annan sideloadinglogik. Det bryter direkt mot barnappspolicyn.
- Appen ska förbli fri från annonser, Advertising ID och spårnings-SDK:er.
- Om publiceringsflödet ändras ska också relevanta docs och workflow-filer hållas i sync.
