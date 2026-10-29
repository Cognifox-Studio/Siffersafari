# Firebase cloud backup — product & tech spec

**Status:** Phase 1 (foundation) on `main`. Phase 2 = parent UI + sync.

## Objective

Let families **optionally** restore child progress after a new device, without making login or network mandatory for play.

## Principles

| Rule | Detail |
|------|--------|
| Offline-first core | Hem → quiz → resultat → story works with zero Firebase |
| Opt-in | Parent PIN area; default **off** |
| Parent account | Firebase Auth for **guardian**, not child credentials in UI |
| Data minimization | Sync `UserProgress` + quiz summary fields needed for restore; no ads/analytics SDKs |
| Hive remains source of truth | Firestore is backup/replica; merge on restore with idempotent rules |

## Phases

### Phase 1 — Foundation (done / in progress)

- Dependencies: `firebase_core`, `firebase_auth`, `cloud_firestore`
- `FirebaseBootstrap.initialize()` in app startup (no-op until configured)
- `CloudBackupService` port + `SettingsKeys.cloudBackupOptInAt`
- Docs, Firestore rules template, privacy policy alignment
- **No** sign-in UI yet

### Phase 2 — Parent backup UX

- Settings (behind PIN): “Säkerhetskopiera framsteg” toggle + explain COPPA copy
- Email magic link or Google sign-in for parent
- Firestore path: `accounts/{uid}/households/{householdId}/profiles/{profileId}`
- Push on quiz merge + periodic debounce; pull on new device after sign-in

### Phase 3 — Store & compliance

- Play Data safety: “Account optional”, “Data collected when backup enabled”
- Update `site/privacy-policy` and go/no-go checklist
- Security review of rules + deletion (delete account → wipe Firestore subtree)

## Out of scope

- Firebase Analytics, Performance Monitoring with user ids, FCM marketing
- Child-facing social, leaderboard, real-time multiplayer
- Replacing Hive with Firestore as only store

## Verification

- Unit: bootstrap skipped when not configured; opt-in false blocks `ensureSignedIn`
- Manual: configure Firebase → bootstrap ready → core flow still offline-capable with opt-in off
- Regression: full `flutter test` green without `google-services.json`
