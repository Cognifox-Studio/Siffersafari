---
description: "Regler för Android versionshantering, keystore, gradle och CI-byggen"
applyTo: "android/app/build.gradle.kts, android/**/*.properties, .github/workflows/**"
---

# Android Build & Release

- **Signering och Keystore:** Signeringsnyckeln för realease heter `upload-keystore.jks` och förväntas infinna sig under `android/app/` vid ett release-bygge.
- **GitHub Actions (CI):** Helautomatiska byggen förlitar sig på att repo-secrets `KEYSTORE_BASE64` och `KEYSTORE_PASSWORD` dekodas on-the-fly och placeras i `android/app/upload-keystore.jks` innan bygget körs. Ändra **inte** dessa sökvägar i Gradle-filen.
- **Gradle Release Config:** I `build.gradle.kts` skall `buildTypes.release` uttryckligen peka på `signingConfigs.release`.
- **Validering av Native Ändringar:** Efter minsta ändring av Manifest, Kotlin/Java-kod eller Gradle-inställningar, uppmana användaren att köra tasken `Pixel_6: Sync + QA` i VS Code innan eventuell commit för att eliminera plattforms/enhets-relaterade buggar.