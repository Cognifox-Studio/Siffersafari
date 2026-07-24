<!--
typ: explanation
syfte: Now / Next / Later — aktiv prioritering utan falska datumlöften
uppdaterad: 2026-07-24
-->

# Aktiv plan — Now / Next / Later

> Facit för **riktning**. Det som byggs just nu står i [SESSION_BRIEF.md](SESSION_BRIEF.md).  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md)

---

## Now

**Se `SESSION_BRIEF.md`.**  
Här ska det bara finnas **ett** committed mål. Om Now är tomt: välj uttryckligen innan kod.

*Nuläge 2026-07-24:* polish/device-koll klar — **Now behöver väljas** (release/distribution *eller* ett produktspår).

---

## Next (kandidater — max tre)

Högst förtroende, inte påbörjade:

1. **Play / distribution** — synka tagg med `1.4.3+20`, internal testing, go/no-go, closed beta
2. **Story / biome (presentation-first)** — gör nästa-värld-löftet tydligare utan ny persistens
3. **Camp / samlarvärde** — mer “min värld” ovanpå nuvarande rewards

Välj **en** till Now. Parkera de andra kvar i Next eller flytta till Later.

---

## Later (riktning, inga löften)

- Ytterligare matte-broar (delvisa banksektioner i Åk 6–9)
- Bråk / decimaler / diagram-UI (ny representation)
- Mer pedagogisk hjälp *om* data visar fastkörningar
- Handskrift / sifferigenkänning (research först)
- Molnsync, konton, sociala funktioner, leaderboard som kärna

---

## Guardrails (gäller alltid)

- Öppna inte ny biome + ny persistens + stor UX-polish i samma slice.
- Blanda inte release med stora datamigreringar.
- Definiera QA-slice / DoD innan implementation.
- Experiment måste kunna tas bort utan att knäcka kärnloopen (hem → quiz → resultat → story).
- COPPA: inga trackers; leaderboard-botar får inte låtsas vara riktiga barn.

---

## Inte nu (explicit)

- Molnsync / kontoberoenden  
- Riktiga sociala funktioner  
- Leaderboard som kärnfeature  
- Ny mascot-runtime utanför PNG-first  
- Stora ML-funktioner i kärnflödet innan offline- och size-frågor är lösta  

---

## Facitordning vid konflikt

1. `ARCHITECTURE.md` / kod  
2. `SESSION_BRIEF.md` (Now)  
3. Denna fil (Next/Later)  
4. `DECISIONS_LOG.md`
