# Contributing (Siffersafari)

Tack för att du vill bidra.

## Snabb QA-rutin (före commit/push)

Kör detta som standard innan du committar eller pushar:

```bash
# 1) Statisk analys
flutter analyze

# 2) Tester: kor minsta relevanta subset for andringen
flutter test test/unit/logic/adaptive_difficulty_test.dart

# 3) Vid stora commits, merges eller bred paverkan:
flutter test
```

## VS Code-tasks (rekommenderat)

Det finns fardiga tasks i `.vscode/tasks.json` sa du kan kora QA med ett klick:

- "QA: Analyze + Test (valfri path)" (standard)
- "QA: Analyze + Full Test (stora andringar)"
- "Pixel_6: Sync + QA (valfri testpath)" (sakrast nar du vill vara 100% saker att emulatorn kor senaste APK)

## VS Code debug-flode

Repo:t innehaller normalt bara `.vscode/tasks.json` (andra `.vscode/*` ignoreras enligt `.gitignore`).
Anvand standard `Run and Debug` i VS Code for:

- "Flutter: Debug"

For Pixel_6: anvand tasks i `tasks.json` (t.ex. `Flutter: Run (Pixel_6 only)` eller `Pixel_6: Sync + QA (valfri testpath)`).

## Rekommenderade extensions

Som forslag (installera om VS Code fragar):

- Dart
- Flutter
- Error Lens
- Mermaid-stod for dokumentation

## Android (rekommenderat): Pixel_6-script for deterministisk install

Om emulatorn ibland verkar kora en gammal APK, anvand PowerShell-scriptet som alltid riktar in sig pa `Pixel_6` och gor ett deterministiskt build+install-flode:

```bash
# SYNC: bygg + installera exakt APK + starta om appen
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync

# RUN: dev-lage med hot reload
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action run

# INSTALL: bara bygg + installera
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action install
```

## Branch/PR (enkel rutin)

- Gor andringen liten och tydlig.
- Lagg till eller uppdatera test om beteendet andras.
- Skriv en commit message som beskriver vad och varfor.
