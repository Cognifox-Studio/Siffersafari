# Snabbstart

Kort guide for att komma igang med aktuell kodbas.

## TL;DR

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --fatal-infos lib test integration_test
flutter test test
flutter run
```

## Miljo

Krav:
- Flutter SDK (Dart 3)
- Android SDK + emulator/enhet
- Git

Notera:
- Projektet ar Android-fokuserat.
- CI och releasefloden ar Android.

## Rekommenderat deviceflode (Pixel_6)

```powershell
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action run
```

## VS Code-flode
Repo:t innehaller delade VS Code-filer under `.vscode/`.
Viktigt: enligt `.gitignore` ar endast `.vscode/tasks.json` spårad i git (övriga `.vscode/*` ar personliga).

- `tasks.json` med QA-, Pixel_6- och asset-kommandon

Efter att du oppnat repot i VS Code:

1. Kor `Developer: Reload Window`.
2. Anvand `Run and Debug` for `Flutter: Debug`.
3. Anvand `Tasks: Run Task` for `QA: Analyze` och testfloden.
4. Anvand `Tasks: Run Task` for Pixel_6-kommandon vid behov.

## Vanliga kommandon

```bash
# Statisk analys
flutter analyze --fatal-infos lib test integration_test

# Tester
flutter test test
flutter test integration_test/app_smoke_test.dart --plain-name "Smoke: app startar och hittar huvudskärm"

# Release APK
flutter build apk --release
```

## Kodgenerering

Kor efter andringar i Hive-adapters eller generators:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Vanliga problem

### "Hive type adapter not found"
Kor codegen:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### "Asset not found"
Verifiera att asset finns under `assets/` och att path ar listad i `pubspec.yaml`.

### Android buildfel
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## Las vidare

- `docs/ARCHITECTURE.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/SERVICES_API.md`
- `docs/CONTRIBUTING.md`
- `docs/DEPLOY_ANDROID.md`
