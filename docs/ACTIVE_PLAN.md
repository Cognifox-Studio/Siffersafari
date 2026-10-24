<!--
typ: explanation
syfte: Now / Next / Later — aktiv prioritering utan falska datumlöften
uppdaterad: 2026-10-24
-->

# Aktiv plan — Now / Next / Later

> Facit för **riktning**. Det som byggs just nu står i [SESSION_BRIEF.md](SESSION_BRIEF.md).  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md)  
> ROI-ordning (Top 50): ship redan byggt → föräldrartillit → discoverability → matte-broar → cadence.

---

## Now

**Se `SESSION_BRIEF.md`.**  
**Release-spår:** stäng `v1.4.3+22` (Top-50 #1–3) — analyze infos → tag + internal AAB → what’s-new. Inget nytt produktspår förrän taggen finns.

---

## Next (kandidater — max tre)

Efter +22, i denna ordning (collect-loop discoverability, Tier B):

1. **Badge unlock-hints** på låsta brickor (`home_badge_album`, `achievement_catalog`)
2. **Namngivna unlocks** på resultatskärmen (inte generisk teaser)
3. **Camp/wardrobe tom-tillstånd** — collection-teaser vid 0 + tydlig garderobs-CTA

Lyft **en** till Now i taget. Alternativt matte-spår (Åk 6 `%`-policy m.m.) får vänta tills dessa tre är klara eller uttryckligen byts ut här.

---

## Later (riktning, inga löften)

- Ytterligare matte-broar (Åk 6 `%`/multi-step, Åk 8–9 integer-subset, Mix-feedback) — Top-50 Tier C
- Store/trust-hygien efter release (listing, privacy-copy, screenshots) — Tier A #4–10
- Cadence-multiplikatorer (release-guard, preflight-script, a11y-pass) — Tier D
- Full bråk / decimaler / diagram-UI (**SEN**-representation)
- Nattskogen som **riktig** biome (inte bara soft landing-copy)
- Mer pedagogisk hjälp *om* lokal data visar fastkörningar
- Handskrift / sifferigenkänning (research först)
- Underwater **eller** fantasy som ett komplett tema (inte båda samtidigt)
- Molnsync, konton, sociala funktioner, leaderboard som kärna

---

## Guardrails (gäller alltid)

- Öppna inte ny biome + ny persistens + stor UX-polish i samma slice.
- Blanda inte release med stora datamigreringar.
- Definiera QA-slice / DoD innan implementation vid riskytor.
- Experiment måste kunna tas bort utan att knäcka kärnloopen (hem → quiz → resultat → story).
- COPPA: inga trackers; leaderboard-botar får inte låtsas vara riktiga barn.
- Bygg inte nya `.github/skills` utan återkommande smärta (se DEV_SYSTEM).

---

## Inte nu (explicit)

- Molnsync / kontoberoenden  
- Riktiga sociala funktioner  
- Leaderboard som kärnfeature  
- Ny mascot-runtime utanför PNG-first  
- Stora ML-funktioner i kärnflödet innan offline- och size-frågor är lösta  
- Hive-kryptering som retrofit (ärlig privacy-copy först)  
- Session time-limits innan PIN-gate wipe + parent practice-CTA finns  
- Underwater **och** fantasy samtidigt  

---

## Facitordning vid konflikt

1. `ARCHITECTURE.md` / kod  
2. `SESSION_BRIEF.md` (Now)  
3. Denna fil (Next/Later)  
4. `DECISIONS_LOG.md`
