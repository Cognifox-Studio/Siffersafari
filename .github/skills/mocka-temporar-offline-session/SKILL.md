---
name: mocka-temporar-offline-session
description: 'Use when creating or updating test setups for offline-first quiz persistence, resume flows (Fortsätt spela), and interrupted app states.'
argument-hint: 'Beskriv vilket offline- eller resume-flöde som ska mockas och om det gäller unit-, widget- eller integrationstest.'
---

# Mocka temporär offline-session

## Context
Siffersafari tillämpar offline-first-persistens via Hive (enligt `docs/ARCHITECTURE.md`). Ett påbörjat quiz (in-progress) autosparas i bakgrunden. Om appen avbryts skall detta quiz återupptas nästa gång appen startas, för att undvika data- eller framstegsförlust för barnet.

## Spelregler för test & mockning

1. **InMemory Repository:**
   Testerna ska alltid injicera `InMemoryLocalStorageRepository` för att undvika riktig disk I/O, rensa state mellan test och undvika Hive-kraschar.

2. **Injicera Start-state:**
   För att sätta upp (mocka) en avbruten session:
   - Skapa och populera en `QuizSession` med svar, tider och `currentQuestionIndex`.
   - Anropa `repository.saveInProgressSession(...)` **innan** widgeten pumpas in och appen eller _QuizNotifier_ initieras.

3. **Data-serialisering:**
   Vid utökning av sessionens datamodell (exempelvis nya svårighetsgrader eller operationer):
   - Säkerställ att `toJson()` och `fromJson()` konverterar enum-värden (som `Difficulty`, `OperationType`) och andra anpassade klasser as-is eller genom explicita maps, istället för att förlita sig på `.index` (som är skört om enums byter ordning).
