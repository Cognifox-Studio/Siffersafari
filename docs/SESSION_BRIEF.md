# Session Status Brief

> Syfte: **Now** + kort leveransläge.  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md) · Next/Later: [ACTIVE_PLAN.md](ACTIVE_PLAN.md) · ROI: [ROI_BACKLOG.md](ROI_BACKLOG.md)  
> Beslut: [DECISIONS_LOG.md](DECISIONS_LOG.md) · AI-yta: [TOOLING_SURFACE.md](TOOLING_SURFACE.md)

---

## Now (2026-10-29)

**Mål:** Firebase **Phase 2** — förälder-UI + Firestore-sync efter +25 smoke. **Phase 1** (SDK, bootstrap, policy) på `main`.  
**Status:** Play +25 success; GitHub APK `v1.4.3+25`. Konfigurera projekt: `docs/FIREBASE_SETUP.md`.

**Klart sedan förra briefen:** hem-CTA efter avslutat quiz; ROI **#11–14**; Play +24 [40674563631](https://github.com/Cognifox-Studio/Siffersafari/actions/runs/40674563631) (discoverability, utan resume-fix).

---

## Nuläge (snapshot)

**Version i repo:** `1.4.3+25` (`pubspec.yaml`)  
**Senaste tagg:** `v1.4.3+25`  
**GitHub Release:** https://github.com/Cognifox-Studio/Siffersafari/releases/tag/v1.4.3%2B25 (APK när build är klar)  
**Play internal (draft):** https://github.com/Cognifox-Studio/Siffersafari/actions/runs/40860107568 (`1.4.3+25`)  
**Go/no-go:** Soft go — device-smoke internal/APK build 25; tagg skapad.

---

## Senaste leveranser (kort)

**2026-10-29 – Firebase Phase 1 (foundation)**  
SDK + bootstrap + `CloudBackupService` + policy/spec; ingen inloggning/sync i UI än. Setup: `docs/FIREBASE_SETUP.md`.

**2026-10-29 – Tagg `v1.4.3+25` + GitHub APK**  
Signerad `app-release.apk` via `build.yml` (resume-fix + discoverability).

**2026-10-29 – Bump `1.4.3+25` + Play internal**  
What's-new sv/en (resume på hem + discoverability); [40860107568](https://github.com/Cognifox-Studio/Siffersafari/actions/runs/40860107568).

**2026-10-28 – Hem-CTA efter avslutat quiz**  
Avslutad runda tas bort som pågående och räknas inte som “Fortsätt”. Story-CTA (“Spela nästa stopp”) visas i stället.

**2026-10-28 – Discoverability #11–14 (audit + gap)**  
Camp-album: tap-hints på låsta souvenirer; hem: `home_collect_section_hint` + camp-knapp på alla mobilbredder.

**2026-10-28 – Bump `1.4.3+23` + Play internal (sync `main`)**  
What's-new sv/en; ersätter stale internal @ `6e70548`.

**2026-10-28 – Release +22 smoke (Soft go)**  
Verifierat: `flutter analyze`, full `flutter test`, `integration_test/app_smoke_test` (emulator), camp/badge/nextBiome-tester. Play-upload oförändrad tills +23.

**2026-10-24 – Release `v1.4.3+22` (tag + Play internal draft)**  
Camp/souvenirer, badges, nextBiome, quiz polish, CI fatal-infos-fix. AAB via `play-closed-beta` track=`internal`.

**2026-10-24 – Top 100 ROI backlog**  
`ROI_BACKLOG.md` med #1–100; Next = named unlocks + camp/wardrobe.

**2026-10-24 – Top 50 ROI → Now/Next/Later**  
Release +22 som Now; collect-loop discoverability i Next; SEN biome/cloud parkerade.

**2026-08-31 – Cursor-first rutin-slim**  
DEV_SYSTEM/DoD-light, kort SESSION_BRIEF, `.cursor/rules`, TOOLING_SURFACE; arkiverade meta-prompts/skills under `.github/archive/`.

**2026-08-31 – Story/biome: nästa värld i slutskedet**  
`nextBiome` syns på sista noden och i resultatpanelens “Sedan”-kort. Ingen ny persistens. (`fc236a7`)

**2026-08-31 – START_HERE-audit**  
Feature-START_HERE synkade (settings/home/parent/quiz m.fl.). (`51fc85d`)

**2026-08-31 – Camp: piedestaler + souveniralbum**  
Souvenirer först på piedestaler; album från collection-badge. (`ef0e19a`, `1eaeb1c`)

**2026-09-25 – Samlar-badges**  
Fler samlar-achievements på `main` (`7090fd3`), i samma build som `1.4.3+22`.

**2026-07-24 – Daily Challenge pension**  
Feature borta; legacy Hive-nycklar endast för profil-wipe.

Äldre leveransnotiser: git-logg / tidigare brief-versioner.

---

## Nästa steg

Arbeta mot **Now** ovan. Next/Later: `ACTIVE_PLAN.md`.

Plan/slice-start bara vid risk.

**Guardrails:** inga trackers; inga stora experiment utan bet i Next.

---

## Stabila beslut (sammanfattning)

Se [DECISIONS_LOG.md](DECISIONS_LOG.md). Nyckelpunkter:

- COPPA först — inga trackers / OTA / `REQUEST_INSTALL_PACKAGES`
- PNG-first maskot (Loke); SVG/Rive utfasade som runtime
- Riverpod + GetIt + Hive; feature-first UI
- Hybrid adaptiv svårighet
- **Dagens runda:** fullt pensionerad; legacy settings-nycklar endast för wipe
