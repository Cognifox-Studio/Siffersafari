# Firebase setup (Siffersafari)

Firebase is **optional**. The app runs fully offline until you configure a project and (later) a parent opts in to cloud backup.

**Allowed:** `firebase_core`, `firebase_auth`, `cloud_firestore` for parent-gated progress backup.  
**Not allowed in product:** Firebase Analytics, Crashlytics with PII, Ads, Remote Config for tracking.

## 1. Create project

1. [Firebase Console](https://console.firebase.google.com/) → Add project (e.g. `siffersafari`).
2. Add Android app: package `se.cognifox.Siffersafari`.
3. Download `google-services.json` → `android/app/google-services.json` (do not commit secrets you do not intend to share; many teams commit this file — your choice).

## 2. FlutterFire CLI

```powershell
dart pub global activate flutterfire_cli
dart run flutterfire_cli:flutterfire configure
```

This overwrites `lib/firebase_options.dart` and sets `isConfigured = true`.

## 3. Enable Auth + Firestore

- Authentication: Email/link or Google — **parent account only** (no child login in quiz UI).
- Firestore: create database; deploy rules from `firebase/firestore.rules`.

```powershell
firebase deploy --only firestore:rules
```

## 4. Verify

```powershell
flutter analyze
flutter test test/unit/logic/firebase_bootstrap_test.dart
flutter run
```

Logcat should show `[FirebaseBootstrap] ready` when configured.

## CI / clones without Firebase

Without `google-services.json` and with `DefaultFirebaseOptions.isConfigured == false`, Gradle skips the Google Services plugin and the app skips `Firebase.initializeApp`.
