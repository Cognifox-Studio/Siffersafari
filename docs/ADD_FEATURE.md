# Adding a Feature (How-To Guide)

Denna guide visar **steg-för-steg** hur du lägger till en ny feature i Siffersafari.

Exempel: Vi lägger till en ny quiz-svårighetsgrad kallad "Expert Mode".

---

## Overview: Feature Development Pipeline

```
1. Plan             (Vad gör den? Hur integreras den?)
2. Implement        (Ändra kod, skapa tester)
3. QA               (flutter analyze, flutter test)
4. Commit & Push    (Git-historia ren)
5. Deploy           (Manual test på emulator, ev. Play Store)
```

---

## 1. Planning Phase

### 1.1 Define the Feature

Beskriv i ett par meningar:
- **What:** "Expert Mode - 3rd difficulty level för Åk 7-9"
- **Why:** "Högpresterande barn behöver högre svårighet"
- **Scope:** "Config only - ingen ny UI ännu"

### 1.2 Identify Touch Points

Research: Vilka filer behöver ändringar?

**För Expert Mode:**
```
lib/domain/enums/difficulty_level.dart          → Ny svårighetsgrad i enum
lib/core/config/difficulty_config.dart          → Regler: ranges/steps/poäng
lib/core/services/question_generator_service.dart → Generering av frågor per svårighet
lib/domain/services/adaptive_difficulty_service.dart → Progression/logik
lib/presentation/…                              → UI (om svårighet visas)
test/unit/logic/…                               → Uppdatera/lägg till unit tests
```

### 1.3 Create a Branch (optional men recommended)

```bash
git checkout -b feature/expert-mode
```

---

## 2. Implementation Phase

### Step 1: Update Models

Öppna `lib/domain/enums/difficulty_level.dart`:

```dart
enum DifficultyLevel {
  easy,
  medium,
  hard,
  expert, // ← Ny (exempel)
}
```

Obs: I projektet är `DifficultyLevel` även annoterad för Hive. Kom ihåg att uppdatera `@HiveField(...)`-index på ett kompatibelt sätt.

### Step 2: Add Data

I detta projekt genereras frågor primärt via `lib/core/services/question_generator_service.dart`.

Typiskt arbetssätt:
- Lägg till/justera logik för nya svårighetsgraden i generatorn.
- Uppdatera regler i `lib/core/config/difficulty_config.dart` (t.ex. ranges/step-buckets).

### Step 3: Update Business Logic

Öppna `lib/domain/services/adaptive_difficulty_service.dart`:

```dart
Difficulty _calculateNextDifficulty(...) {
  // Befintlig logik...
  
  if (currentScore > 95 && points >= 500) {
    return Difficulty.expert;  // ← Ny
  }
  
  // resten...
}
```

Obs: Anropa/brukar denna logik ofta från Riverpod-notifiers i `lib/core/providers/`.

### Step 4: Update UI (if needed)

Om du behöver visa "Expert Mode" i UI, sök efter `DifficultyLevel` i `lib/presentation/` och uppdatera de ställen där svårighetens label/rendering sker.

---

## 3. Testing Phase

### Write/Update Unit Tests

I detta repo ligger tester under `test/unit/...` och `test/widget/...`.

För en ändring i svårighetslogik är det vanligast att uppdatera/bryta ut tester i:
- `test/unit/logic/difficulty_config_*_test.dart`
- `test/unit/logic/adaptive_difficulty_test.dart`

### Run Tests

```bash
# Exempel: kör en relevant, liten testfil
flutter test test/unit/logic/adaptive_difficulty_test.dart

# Eller kolla alla tester
flutter test
```

**Förväntat:** Alla tester passa.

---

## 4. QA Phase

### 4.1 Static Analysis

```bash
flutter analyze
```

**Förväntat:** "No issues found!"

Om linters-fel dyker upp:
```bash
# Automatisk fix
dart fix --apply
```

### 4.2 Full Test Suite

```bash
flutter test
```

**Förväntat:** Alla tester passerar.

### 4.3 Manual Smoke Test

Starta appen på emulator och testa manuellt:

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync
```

**Test checklist:**
- [ ] Appen startar
- [ ] Gamla difficultyes fungerar fortfarande
- [ ] Expert Mode är tillgänglig efter vissa poäng
- [ ] Expert Mode frågor är svårare
- [ ] Achievements sparas offline

---

## 5. Commit & Push Phase

### Clean Git History

Se till att du bara har relevanta files:

```bash
git status

# Förväntat output (ungefär):
# modified:   lib/domain/enums/difficulty_level.dart
# modified:   lib/core/config/difficulty_config.dart
# modified:   lib/core/services/question_generator_service.dart
# modified:   lib/domain/services/adaptive_difficulty_service.dart
# modified:   test/unit/logic/...
```

### Commit

```bash
git add .
git commit -m "feat: add Expert Mode difficulty level

- Added Difficulty.expert enum value
- Added 50+ Expert-level questions to quiz database
- Updated adaptive_difficulty_service to unlock Expert at 95%+ score
- Added unit tests for Expert Mode questions

Closes #42 (if applicable)"
```

**Format:** Använd [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` för nya features
- `fix:` för bugfixes
- `refactor:` för code reorganization
- `test:` för test-ändringar
- `docs:` för dokumentation
- `chore:` för inte-funktionell ändringar

### Push

```bash
git push origin feature/expert-mode
```

Eller direkt till main (om no-branch-workflow):

```bash
git push origin main
```

---

## 6. Deploy Phase

### Prepare for Release

Se [DEPLOY_ANDROID.md](DEPLOY_ANDROID.md) för full process.

Kort:
```bash
# Uppdatera version i pubspec.yaml
version: 1.0.3+6  # Var 1.0.2+5 innan

# Commit
git commit -m "chore: bump version to 1.0.3"

# Build release APK
flutter build apk --release

# Upload to Play Store
# (google play console UI)
```

---

## Example Checklist for Expert Mode

```markdown
- [x] Models updated (Difficulty enum)
- [x] Questions added to database
- [x] Business logic updated (progression)
- [x] UI updated (if needed)
- [x] Unit tests written and passing
- [x] flutter analyze passing
- [x] Manual smoke test on Pixel_6
- [x] Committed with clear message
- [x] Pushed to GitHub
- [ ] Release notes prepared (for Play Store)
- [ ] Version bumped (if releasing)
- [ ] Built APK and tested on real device
```

---

## Common Patterns

### Pattern 1: Add a New Service

Se [SERVICES_API.md](SERVICES_API.md) för hur services struktureras.

**Steps:**
1. Skapa service (domain eller core beroende på beroenden):
  - Pure domain: `lib/domain/services/my_service.dart`
  - Flutter-aware: `lib/core/services/my_service.dart`
2. Exponera via provider i `lib/core/providers/` om den behövs i UI/state.
3. Om GetIt används: registrera i `lib/core/di/injection.dart`.

### Pattern 2: Add Persistent Data

För data som behöver sparas offline:

1. Create entity: `lib/domain/entities/my_entity.dart`
2. Use Hive: `@HiveType(typeId: N)` och `@HiveField(0)`
3. Create/uppdatera repository i `lib/data/repositories/`.
4. Kör codegen: `dart run build_runner build --delete-conflicting-outputs`

---

## Troubleshooting

### "Test fails with 'class not found'"
- **Orsak:** Import-sökväg fel
- **Lösning:** Kontrollera import i test-fil
  ```dart
  import 'package:siffersafari/domain/enums/difficulty_level.dart';
  ```

### "flutter analyze fails with lint error"
- **Lösning:**
  ```bash
  dart fix --apply  # Automatisk fix
  ```

### "git commit blocked by pre-push checks"
- **Orsak:** GitHub Actions kanske testar innan du pushar
- **Lösning:** Kör `flutter test` lokalt innan push

---

## More Help

- **Architecture questions?** Se [ARCHITECTURE.md](ARCHITECTURE.md)
- **Service API?** Se [SERVICES_API.md](SERVICES_API.md)
- **Code standards?** Se [CONTRIBUTING.md](CONTRIBUTING.md)
- **Folder structure?** Se [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
