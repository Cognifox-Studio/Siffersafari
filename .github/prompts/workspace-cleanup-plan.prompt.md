---
name: "workspace-cleanup-plan"
description: "Analysera Siffersafaris workspace och returnera en säker cleanup- och refaktorplan som utgår från faktisk kod, docs och aktiva audit-guards"
argument-hint: "Valfritt: begränsa planen till ett scope som docs, .github, feature-struktur, legacy paths eller assets"
agent: "Plan"
---

Analysera detta Siffersafari-repo och ta fram en säker cleanup- och refaktorplan utan att göra några ändringar.

Utgå från dessa källor först:

- `docs/SESSION_BRIEF.md`
- `docs/ARCHITECTURE.md`
- `docs/PROJECT_STRUCTURE.md`
- `.github/copilot-instructions.md`
- `test/unit/audits/naming_structure_audit_test.dart`

Använd historiska planer bara som sekundär bakgrund om de levande facit-filerna uttryckligen pekar dit.

Identify:
- outdated or unused Dart files
- unused widgets, classes, functions, and constants
- duplicate logic across lib/, test/, and scripts/
- assets in assets/ that are unused in the codebase
- files in android/ or artifacts/ that are safe to remove
- dead code or unreachable branches
- inconsistent naming (files, classes, variables)
- unclear folder structure or misplaced files
- code that should be consolidated into shared utilities
- files that should be renamed for clarity

Then propose:
- a complete refactor plan with exact file paths
- which files can be safely deleted
- which files should be renamed (with new names)
- which functions/classes should be merged or moved
- a recommended folder structure for a clean Flutter project
- a list of risky areas that should NOT be touched automatically

Important:
- DO NOT make any changes yet.
- Prefer the smallest safe plan over a broad rewrite.
- Treat `docs/ARCHITECTURE.md` and `docs/PROJECT_STRUCTURE.md` as facit over older historical plans.
- Separate active files from historical or retired files before proposing deletions.
- First show me the full plan for review.
- The plan must be safe, reversible, Flutter-compatible and repo-specific.