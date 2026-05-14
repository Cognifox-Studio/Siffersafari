# Test Suite Documentation

This document describes the organization, structure, and conventions for the Siffersafari test suite.

## Overview

All tests run with: `flutter test`.

Note: Håll inte hårdkodade test-antal i dokumentation (de blir snabbt stale). Kör `flutter test` för aktuell totalsiffra.

## Directory Structure

```
test/
├── support/                       # Shared non-runtime test support widgets/files
│   └── widgets/
├── test_utils.dart                # Shared helpers/mocks for widget tests
├── unit/                          # Unit tests
│   ├── audits/                    # Verification and audit tests
│   ├── core/                      # Core app and provider-focused unit tests
│   ├── logic/                     # Business logic and progression rules
│   ├── services/                  # Service layer and repository-adjacent tests
│   └── assets/                    # Asset- och fixture-relaterade enhetstester
└── widget/                        # Widget- och flödestester
   ├── app_*.dart
   ├── daily_challenge_card_test.dart
   ├── game_character_test.dart
   └── mascot_reaction_view_test.dart
```

### Directory Purposes

- **`test/unit/logic/`** – Tests for core game mechanics, difficulty progression, and quiz flow logic
- **`test/unit/core/`** – Tests for central providers, config, bootstrap-near logic, and shared app state
- **`test/unit/services/`** – Tests for business services, persistence-adjacent logic, achievements, parent features, and offline flows
- **`test/unit/audits/`** – Verification tests that validate system invariants, question distribution, offline behavior, and repo-specific guards
- **`test/widget/`** – Widget- och användarflödestester; end-to-end smoke ligger i `integration_test/`

## Test Naming Convention

All tests follow this standardized naming format:

```
[Category] Feature – description
```

### Examples

**Unit Tests:**
- `[Unit] DifficultyConfig – Grade benchmarks`
- `[Unit] AdaptiveDifficultyService – beräknar träffsäkerhet` (calculates hit rate)
- `[Unit] ParentPinService – Change PIN`

**Widget Tests:**
- `[Widget] Quiz – complete full session and replay`
- `[Widget] Parent mode – PIN setup and unlock`
- `[Widget] Onboarding – appears once and is skippable`

### Naming Guidelines

- **Category**: `[Unit]` or `[Widget]` to indicate test type
- **Feature**: Name of the main class/feature being tested
- **Description**: What is being tested (in Swedish or English)
- **Separator**: Use ` – ` (em-dash) between feature and description

## Running Tests

### Run all tests
```bash
flutter test
```

### Run only unit tests
```bash
flutter test test/unit/
```

### Run only widget tests
```bash
flutter test test/widget/
```

### Run only logic tests
```bash
flutter test test/unit/logic/
```

### Run only service tests
```bash
flutter test test/unit/services/
```

### Run only audit tests
```bash
flutter test test/unit/audits/
```

### Run a specific test file
```bash
flutter test test/unit/services/achievement_service_test.dart
```

### Run with specific pattern
```bash
flutter test --name "DifficultyConfig"
```

### Run with coverage
```bash
flutter test --coverage
```

## Test Organization Rationale

### Why split by unit/widget?
- **Unit tests** verify isolated logic without UI framework overhead
- **Widget tests** verify full app integration and user interactions
- Clear separation helps developers find relevant tests quickly

### Why split unit tests into logic/services/audits?
- **Logic**: Core game mechanics that should never break
- **Services**: Testable business logic (storage, sync, achievements)
- **Audits**: System-wide verification (no broken questions, offline-safe code, a11y compliant widgets)

## Writing New Tests

When adding new tests:

1. **Choose the right category:**
   - Single class/function logic → `test/unit/logic/` or `test/unit/services/`
   - UI widget behavior → `test/widget/`
   - System invariants → `test/unit/audits/`

2. **Follow naming convention:**
   ```dart
   group('[Unit] YourFeature – what is tested', () {
     test('specific behavior', () {
       // arrange, act, assert
     });
   });
   ```

3. **Keep tests focused:**
   - One test group per file (or split if file grows beyond ~150 lines)
   - Test one behavior per test
   - Use descriptive test names

4. **Use mocks and fixtures:**
   - Prefer shared helpers and mocks via `test/test_utils.dart` när samma setup återkommer
   - Keep setup code at top of file

## Test Quality Standards

- All tests must pass before committing: `flutter test`
- All tests must be deterministic (no flakiness)
- Tests should document expected behavior (act as executable specs)

## Troubleshooting

### Tests fail randomly
- Check for Navigator state issues (don't recreate widgets unnecessarily)
- Ensure mocks are properly reset between tests
- Look for race conditions in async code

### Tests take too long
- Profile with `flutter test --concurrency=1` to find slow tests
- Consider moving slow integration tests to `integration_test/` instead

### Coverage gaps
- Run `flutter test --coverage` and check `coverage/lcov.info`
- Focus on high-risk game logic first

---
