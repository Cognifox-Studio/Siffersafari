# Copilot-instruktioner (Siffersafari)

## Projektet

Siffersafari är ett Flutter-baserat mattespel för barn. Appen är Android-first, offline-first och byggd för: profilval → quiz → resultat → story map / camp.

## Start här (minimalt)

1. `docs/SESSION_BRIEF.md` — **Now**
2. `docs/DEFINITION_OF_DONE.md` — DoD-light (A0) default; full A vid risk
3. Berörd `lib/features/<feature>/START_HERE.md`
4. `docs/DEV_SYSTEM.md` — arbetssätt (Cursor-first)
5. `docs/TOOLING_SURFACE.md` — aktiv vs arkiverad AI-yta

`.github/AGENTS.md` är **referensindex**, inte obligatorisk startlista.  
Ladda skills/prompts bara när problemtypen redan är känd och aktiv (se AGENTS / TOOLING_SURFACE).

Vid djupare behov: `docs/ARCHITECTURE.md`, `docs/DECISIONS_LOG.md`, matchande `.github/instructions/` för filytan.

## Alltid på

- **Nulägesfacit:** `SESSION_BRIEF`, `ARCHITECTURE`, `DECISIONS_LOG` slår äldre artefakter.
- **COPPA:** inga trackers, annonser eller onlinekrav i kärnflödet. Se `docs/PRIVACY_POLICY.md`.
- **Feature-first UI:** `lib/features/<feature>/presentation/`. `lib/presentation/widgets/` bara delad UI.
- **PNG-first maskot:** Loke PNG + proceduranimationer. Rive/SVG är inte aktiv runtime.
- **Offline-first:** Hive via repository; quiz-session mergas till `UserProgress` vid slut.
- **Link, don't embed:** peka till docs i stället för att duplicera.
- **Inga nya skills som default** — skriv rutin i DEV_SYSTEM/START_HERE vid behov.

## Arbetsflöde

1. Läs Now. Plan / `slice-start` **bara vid risk** (persistens, mattebank, release, bred refaktor).
2. Hitta ägande kodväg; DoD-light som default.
3. Följ matchande `.github/instructions/` när filytan är känd.
4. En avsikt per commit-grupp.
5. Före commit: DoD-light (eller full A). Commit när människa ber om det.
6. Uppdatera `SESSION_BRIEF` när Now ändrats.

## QA

```sh
flutter analyze
flutter test <path>
# vid risk:
powershell -ExecutionPolicy Bypass -File scripts/verify_git_changes.ps1
```

Pixel_6 (`scripts/flutter_pixel6.ps1`) vid UI/asset/navigation/Android-risk — inte varje commit.

## Repo-fallgropar

- Pixel_6 offline: `emulator.exe -avd Pixel_6 -no-snapshot-load`
- Stale APK: `flutter_pixel6.ps1 -Action sync`
- Garderob: Z-index-mix, inte hårda slots — `regler-for-z-index-inventory.instructions.md`
- SRS-nycklar: versionsprefix (`v2|`), inte displaytext-gissningar
