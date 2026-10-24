# Session Status Brief

> Syfte: **Now** + kort leveransläge.  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md) · Next/Later: [ACTIVE_PLAN.md](ACTIVE_PLAN.md) · ROI: [ROI_BACKLOG.md](ROI_BACKLOG.md)  
> Beslut: [DECISIONS_LOG.md](DECISIONS_LOG.md) · AI-yta: [TOOLING_SURFACE.md](TOOLING_SURFACE.md)

---

## Now (2026-10-24)

**Mål:** Stäng release `v1.4.3+22` innan nytt produktspår.  
**Status:** #1 analyze infos fixade; #3 what’s-new uppdaterad. Kvar: tag `v1.4.3+22` + samma AAB till Play internal (DoD B). Senaste tagg `v1.4.3+21`.

**Now-steg (i ordning):**
1. ~~Fix 4 `prefer_const` infos så `--fatal-infos` CI passerar~~
2. Tag `v1.4.3+22` + samma AAB till Play internal (DoD B)
3. ~~What’s-new notes för +22 (camp, badges, nextBiome, polish)~~

**Klart sedan förra briefen:** prefer_const CI-fix + what’s-new +22; ROI Top 100; playtest-polish lokalt; camp/nextBiome/badges.

---

## Nuläge (snapshot)

**Version i repo:** `1.4.3+22` (`pubspec.yaml`)  
**Senaste tagg:** `v1.4.3+21`  
**GitHub Release:** https://github.com/Cognifox-Studio/Siffersafari/releases/tag/v1.4.3%2B21

---

## Senaste leveranser (kort)

**2026-10-24 – Top 100 ROI backlog**  
`ROI_BACKLOG.md` med #1–100; Now fortfarande +22 release; Next = badge/unlocks/camp.

**2026-10-24 – Top 50 ROI → Now/Next/Later**  
Release +22 som Now; Next = collect-loop discoverability; SEN biome/cloud parkerade.

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

Efter +22: lyft en Next-kandidat till Now (max en i taget). Plan/slice-start bara vid risk.

**Guardrails:** inga trackers; inga stora experiment utan bet i Next.

---

## Stabila beslut (sammanfattning)

Se [DECISIONS_LOG.md](DECISIONS_LOG.md). Nyckelpunkter:

- COPPA först — inga trackers / OTA / `REQUEST_INSTALL_PACKAGES`
- PNG-first maskot (Loke); SVG/Rive utfasade som runtime
- Riverpod + GetIt + Hive; feature-first UI
- Hybrid adaptiv svårighet
- **Dagens runda:** fullt pensionerad; legacy settings-nycklar endast för wipe
