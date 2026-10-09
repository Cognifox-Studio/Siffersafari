# Hive migration playbook

Checklist before changing `@HiveType(typeId: 0)` on `UserProgress` or adding required fields:

1. Add field with `@HiveField(n)` and safe default in constructor + `copyWith`.
2. Run / extend `test/unit/logic/user_progress_adapter_test.dart`.
3. Run `test/unit/audits/settings_keys_audit_test.dart` if settings keys change.
4. Manual smoke: profil → quiz → resultat → merge → hem (progress synlig).
5. Prefer backward-compatible reads; use profile wipe only as documented escape hatch.

Quiz session maps: validate via [QuizSessionRecord](../lib/domain/entities/quiz_session_record.dart) before trusting `quiz_history` entries.
