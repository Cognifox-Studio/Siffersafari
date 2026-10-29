# Cloud backup (Firebase)

Ansvar: valfri säkerhetskopia av barnprofilers framsteg — **inte** kärnflöde.

## Börja här

- `docs/FIREBASE_CLOUD_BACKUP.md` — faser och datamodell
- `docs/FIREBASE_SETUP.md` — FlutterFire + Console
- `lib/core/firebase/firebase_bootstrap.dart`
- `lib/core/services/cloud_backup_service.dart`
- `lib/core/providers/cloud_backup_service_provider.dart`
- `firebase/firestore.rules`

## Status

- **Phase 1:** SDK, bootstrap, DI-port, policy — ingen inloggning i UI än
- **Phase 2:** förälder-PIN → toggle → Auth → Firestore sync (TODO)

## Guardrails

- Quiz/story ska fungera utan nät och utan Firebase init
- Ingen Firebase Analytics / Ads
- Barn skapar inte Firebase-konton
