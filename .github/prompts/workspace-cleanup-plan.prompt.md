---
name: "workspace-cleanup-plan"
description: "Analyze the current Flutter workspace and produce a safe, detailed cleanup and refactor plan"
agent: "agent"
---

Analyze my entire workspace (this Flutter project) and produce a detailed cleanup and refactor plan.

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
- First show me the full plan for review.
- The plan must be safe, reversible, and Flutter-compatible.