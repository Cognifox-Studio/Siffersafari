# Curriculum data migration (DifficultyConfig → facit)

Goal: one source of truth in [curriculum_facit.json](curriculum_facit.json); Dart keeps algorithms (adaptive hybrid, mix gates).

Steps (incremental):

1. Parse facit with [CurriculumFacitLoader](../lib/core/config/curriculum_facit_loader.dart) — gate with [curriculum_facit_consistency_audit_test.dart](../test/unit/audits/curriculum_facit_consistency_audit_test.dart).
2. Move **step band metadata** (grade ranges, stage labels) into JSON first; leave numeric ranges in `DifficultyConfig` until audits cover each slice.
3. After each slice: `flutter test test/unit/audits/` + targeted generator tests.

Do not big-bang replace `difficulty_config.dart` in one PR.
