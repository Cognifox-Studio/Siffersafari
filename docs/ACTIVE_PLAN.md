<!--
typ: explanation
syfte: Now / Next / Later — aktiv prioritering utan falska datumlöften
uppdaterad: 2026-08-31
-->

# Aktiv plan — Now / Next / Later

> Facit för **riktning**. Det som byggs just nu står i [SESSION_BRIEF.md](SESSION_BRIEF.md).  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md)

---

## Now

**Se `SESSION_BRIEF.md`.**  
Cursor-first rutin-slim (QA-grön / landad).

*Senaste produkt-Now (klar):* Story / biome — nästa värld i slutskedet.  
*Parkerat:* Play promote av `1.4.3+21` (väntar Console).

---

## Next (kandidater — max tre)

1. **Play promote** — closed/alpha för `1.4.3+21`, sedan ev. staged production (människa i Console)
2. **Ny Play-build med camp/story** — bump `1.4.3+22` (eller högre) om HEAD ska ut via Play

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

---

## Facitordning vid konflikt

1. `ARCHITECTURE.md` / kod  
2. `SESSION_BRIEF.md` (Now)  
3. Denna fil (Next/Later)  
4. `DECISIONS_LOG.md`
