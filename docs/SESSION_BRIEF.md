# Session Status Brief

> Syfte: **Now** + kort leveransläge.  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md) · Next/Later: [ACTIVE_PLAN.md](ACTIVE_PLAN.md)  
> Beslut: [DECISIONS_LOG.md](DECISIONS_LOG.md) · AI-yta: [TOOLING_SURFACE.md](TOOLING_SURFACE.md)

---

## Now (2026-08-31)

**Mål:** Slimma utvecklarrutiner för Cursor (process + archive).  
**Status:** Slice landad — DoD-light + archive + Cursor-rule.

**Föregående produkt-Now (klart):** Story/biome — `nextBiome` i slutskedet (`fc236a7`).  
**Parkerat:** Play promote av `1.4.3+21` (Console).

---

## Nuläge (snapshot)

**Version:** 1.4.3+21 (`pubspec` = tagg `v1.4.3+21`)  
**Play:** Internt test **Go** för `1.4.3+21` ✅ · Closed/production: ej klar  
**GitHub Release:** https://github.com/Cognifox-Studio/Siffersafari/releases/tag/v1.4.3%2B21  
**Obs:** `main` har camp/story-commits efter taggen — kräver bump innan ny Play-upload.

---

## Senaste leveranser (kort)

**2026-08-31 – Cursor-first rutin-slim**  
DEV_SYSTEM/DoD-light, kort SESSION_BRIEF, `.cursor/rules`, TOOLING_SURFACE; arkiverade meta-prompts/skills under `.github/archive/`.

**2026-08-31 – Story/biome: nästa värld i slutskedet**  
`nextBiome` syns på sista noden och i resultatpanelens “Sedan”-kort. Ingen ny persistens. (`fc236a7`)

**2026-08-31 – START_HERE-audit**  
Feature-START_HERE synkade (settings/home/parent/quiz m.fl.). (`51fc85d`)

**2026-08-31 – Camp: piedestaler + souveniralbum**  
Souvenirer först på piedestaler; album från collection-badge. (`ef0e19a`, `1eaeb1c`)

**2026-07-24 – Daily Challenge pension + Play internal Go `1.4.3+21`**  
Feature borta; legacy Hive-nycklar endast för profil-wipe. Promote till closed/prod ej klar.

Äldre leveransnotiser: git-logg / tidigare brief-versioner.

---

## Nästa steg

Arbeta mot **Now** ovan. Next/Later: `ACTIVE_PLAN.md`.

När Now saknas: välj uttryckligen (release *eller* produktspår). Plan/slice-start bara vid risk.

**Guardrails:** inga trackers; inga stora experiment utan bet i Next.

---

## Stabila beslut (sammanfattning)

Se [DECISIONS_LOG.md](DECISIONS_LOG.md). Nyckelpunkter:

- COPPA först — inga trackers / OTA / `REQUEST_INSTALL_PACKAGES`
- PNG-first maskot (Loke); SVG/Rive utfasade som runtime
- Riverpod + GetIt + Hive; feature-first UI
- Hybrid adaptiv svårighet
- **Dagens runda:** fullt pensionerad; legacy settings-nycklar endast för wipe
