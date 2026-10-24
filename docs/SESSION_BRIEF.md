# Session Status Brief

> Syfte: **Now** + kort leveransläge.  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md) · Next/Later: [ACTIVE_PLAN.md](ACTIVE_PLAN.md) · ROI: [ROI_BACKLOG.md](ROI_BACKLOG.md)  
> Beslut: [DECISIONS_LOG.md](DECISIONS_LOG.md) · AI-yta: [TOOLING_SURFACE.md](TOOLING_SURFACE.md)

---

## Now (2026-10-24)

**Mål:** Curriculum hygiene ([ROI_BACKLOG](ROI_BACKLOG.md) #58–62).  
**Status:** #57 Åk8 powers widen klar. #11–48 + #51–57 + #20 klara. `v1.4.3+22` på Play internal draft. `main` ahead ~37 lokalt (ej pushad).

**Klart sedan förra briefen:** Powers widen; feedback tips; exception matrices; Förenkla@x.

---

## Nuläge (snapshot)

**Version i repo:** `1.4.3+22` (`pubspec.yaml`)  
**Senaste tagg:** `v1.4.3+22`  
**GitHub Release:** https://github.com/Cognifox-Studio/Siffersafari/releases/tag/v1.4.3%2B22  
**Play internal:** https://github.com/Cognifox-Studio/Siffersafari/actions/runs/40100575151 (draft)

---

## Senaste leveranser (kort)

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
