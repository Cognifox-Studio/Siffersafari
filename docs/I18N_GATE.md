# i18n gate

**Status:** Swedish copy is inline in widgets and services. No ARB / `flutter_localizations` yet.

**Gate:** Do not introduce l10n until a second locale is an explicit product goal.

When enabled:

- Vertical slice first (quiz + feedback), not whole-app migration.
- Keep [curriculum_facit.json](curriculum_facit.json) and grade banks Swedish until facit is translated.
- Bank/runtime audits must stay green after each slice.
