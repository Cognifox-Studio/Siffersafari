---
name: "Android build och paketering"
description: "Use when editing Android Gradle config, keystore paths, release packaging or CI workflows for Android builds."
applyTo: "android/app/build.gradle.kts, android/**/*.properties, .github/workflows/**"
---

# Android build och releasepaketering

- Release-signering utgår från `android/app/upload-keystore.jks`.
- GitHub Actions förlitar sig på `KEYSTORE_BASE64` och `KEYSTORE_PASSWORD` och dekodar keystoren till samma path under bygget. Ändra inte den kedjan utan att uppdatera hela flödet.
- `buildTypes.release` ska uttryckligen använda `signingConfigs.release`.
- Efter native ändringar i Gradle, manifest eller Android-kod ska verifiering inkludera relevant Pixel_6-flöde och inte bara Dart-QA.