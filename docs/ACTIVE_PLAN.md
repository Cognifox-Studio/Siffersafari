<!--
typ: explanation
syfte: Now / Next / Later — aktiv prioritering utan falska datumlöften
uppdaterad: 2026-10-24
-->

# Aktiv plan — Now / Next / Later

> Facit för **riktning**. Det som byggs just nu står i [SESSION_BRIEF.md](SESSION_BRIEF.md).  
> Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md) · Klart när: [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md)  
> ROI-ordning (Top 100): [ROI_BACKLOG.md](ROI_BACKLOG.md) — ship redan byggt → föräldrartillit → discoverability → matte-broar → cadence.

---

## Now

**Se `SESSION_BRIEF.md`.**  
**Produktspår:** Desert theme parity ([ROI_BACKLOG](ROI_BACKLOG.md) #45). #11–44 + #20 levererade.

---

## Next (kandidater — max tre)

1. **Feedback glanceability** — #46
2. **Hard-quest vs hard-badge fairness** — #47
3. **Curriculum polish leftovers** — #51–62

Lyft **en** till Now i taget.

---

## Later (riktning, inga löften)

Full rangordning: [ROI_BACKLOG.md](ROI_BACKLOG.md) (#14–100 + near-miss). Hög nivå:

- Ytterligare matte-broar (Åk 6 `%`/multi-step, Åk 8–9 integer-subset, Mix-feedback) — backlog #26–40, #51–62
- Store/trust-hygien efter release (listing, privacy-copy, screenshots) — #4–10, #89–95
- Cadence-multiplikatorer (release-guard, preflight-script, a11y-pass) — #41–50, #96–100
- Curriculum/parent/quiz polish efter Next — #51–88
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
