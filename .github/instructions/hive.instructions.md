---
description: "Regler för Hive lokal databas, offline-first, och data-validering"
applyTo: "lib/data/**, lib/core/services/storage/**, lib/domain/**, lib/features/**/data/**, **/*_repository.dart"
---

# Hive Data & Offline-first

- **Inkapsling i Repository:** All data till och från Hive **MÅSTE** gå via en inkapslad repository-klass (t.ex. `LocalStorageRepository`). Inga `Hive.box()`-anrop i UI, domän-tjänster (services) eller providers.
- **Defensiv Data-validering:** All data från Hive (`get()` eller iterering över `.values`) kommer som `dynamic` och **MÅSTE** typ-valideras manuellt innan användning (inbyggda Hive-typeadapters kan krångla och versionsproblem uppstå). Skapa defensiva funktioner som `_validateXYZSession(value)` som kontrollerar null-hittande, lists (`is List`), objekt eller `Map`. Lita *aldrig blint* på ostrukturerad data från disk.
- **Offline-first (COPPA-compliance):** Blanda aldrig in Firebase Data, kontosynk eller cloud-verktyg för användardata förrän strikt granskat i `docs/PRIVACY_POLICY.md` (det ska helt undvikas i detta repo). All data stannar lokalt.
- **Deterministiska nycklar:** Använd meningsfulla ID:n för state-hantering ("inprogress_${userId}_$operationType") framför slumpmässiga UUID när logistik behöver hållas unik men förnybar, så att ofärdiga krash-sessioner skrivs över.
- **Session State vs Profil:** Avslutade sessioner (t.ex., uppdaterad streak, difficulty-data, `QuizSession`) måste explicit sparas och *mergas* med den persistenta profilen (t.ex. `UserProgress`) i ditt repository. Data syncas inte automatiskt.
- **Versionshantering (SRS v2 mönster):** Vid format som innehåller okonstanta strängar (t.ex. Spaced Repetition SRS-nycklar), packa grunddatan separat med en formatversion (t.ex. `v2|`) istället för att regex-parsa varierande display-text i efterhand. Detta håller state stabil mot framtida text-/struktur-ändringar och garanterar bakåtkompatibilitet.
