<!--
typ: explanation
syfte: Kanoniskt arbetssätt för produkt och utveckling (Now/Next/Later, DoD, AI-loop, release)
uppdaterad: 2026-08-31
-->

# Utvecklingssystem (Siffersafari)

Detta är **hur vi jobbar**. Facit för rutin — Cursor-first, solo.

Relaterat:

- [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md) — DoD-light (default) och full DoD
- [SESSION_BRIEF.md](SESSION_BRIEF.md) — **Now** + senaste leveranser
- [ACTIVE_PLAN.md](ACTIVE_PLAN.md) — **Next / Later** + guardrails
- [DECISIONS_LOG.md](DECISIONS_LOG.md) — stabila beslut
- [TOOLING_SURFACE.md](TOOLING_SURFACE.md) — aktiv vs parked vs arkiverad AI-yta
- `.github/AGENTS.md` — kort index (inte obligatorisk startlista)

---

## Principer (låsta)

1. **Ett Now i taget.**
2. **`main` ska alltid vara mergebart.** Små slices; CI grön före merge.
3. **Repo är sanningen.** SESSION_BRIEF, DoD och tester slår chattminne.
4. **Constraints i CI/tester**, inte bara i prompts.
5. **Plan bara vid risk.** Persistens, mattebank, release, bred refaktor → Plan. Små UI/docs-slices → bygg direkt.
6. **Kod ≠ Play-release.** Mergar ofta; Play internal/promote medvetet.
7. **Inga nya `.github/skills` som default.** Saknas rutin → 5–10 rader här eller i feature START_HERE.

---

## Produkt: Now / Next / Later

| Horisont | Fil | Betydelse |
| --- | --- | --- |
| **Now** | `SESSION_BRIEF.md` | Det enda vi bygger just nu |
| **Next** | `ACTIVE_PLAN.md` | Max 2–3 kandidater |
| **Later** | `ACTIVE_PLAN.md` | Riktning utan löfte |

När Now är DoD-klart: promote Next → Now, eller välj nytt Now uttryckligen.  
`ACTIVE_PLAN` räcker — ingen separat canvas för Next/Later.

---

## Arbetsloop (Cursor default)

```text
1. Läs SESSION_BRIEF-toppen (Now)
2. Säg målet / "nästa" / "fortsätt"
3. Bygg i små steg
4. DoD-light (analyze + berörda tester)
5. Commit när människa ber om det
6. Uppdatera Now-raden om status ändrats
```

**One-liners som får räcka:** fortsätt, nästa, committa, play promote, full audit.

**Valfritt vid risk:** `.github/prompts/slice-start.prompt.md` eller Cursor Plan-läge.

**Grenar:** `feat/…`, `fix/…`, `docs/…`, `chore/…` från `main`. Inget GitFlow.

---

## AI i Cursor (inte Copilot-rutin)

| Behov | Gör |
| --- | --- |
| Vardag | Cursor Agent + project rule `.cursor/rules/siffersafari.mdc` |
| Osäker scope / risk | Cursor Plan-läge |
| Releasebeslut | `.github/prompts/release-go-no-go.prompt.md` |
| Matte/bank | `.github/skills/testa-fragornas-svarighetsgrad/SKILL.md` |
| Quiz-persistens | `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md` |

Copilot-agenter under `.github/agents/` är **legacy-kompat**, inte obligatorisk varje-pass-routing.  
Router-promptar och meta-skills som flyttats till `.github/archive/` körs **bara på begäran**.

---

## Testpyramid

| Lager | När |
| --- | --- |
| Unit / audits | Nästan varje Dart-slice |
| Widget | UI-ändringar |
| Integration / Pixel_6 | Pre-release eller UI/device-risk — **inte** varje commit |

Matteändringar: difficulty/bank-skill enligt AGENTS aktiv-lista.

---

## Releasekedja (Android / Play)

```text
main grön  →  tag v* = pubspec  →  Internal testing (samma AAB)
                                 →  Closed / production (promote + staged)
```

Go/No-go: `.github/prompts/release-go-no-go.prompt.md` + DoD sektion B.

---

## Dokumentation (Diátaxis-light)

| Behov | Fil |
| --- | --- |
| Now / levererat | `SESSION_BRIEF.md` |
| Next / Later | `ACTIVE_PLAN.md` |
| Hur vi jobbar | **denna fil** |
| Klart när | `DEFINITION_OF_DONE.md` |
| Kodkarta | `lib/features/START_HERE.md`, `TRACE_MAP.md` |
| AI-yta | `TOOLING_SURFACE.md` |
| Varför | `DECISIONS_LOG.md` |

Uppdatera docs i samma slice när verkligheten ändras.

---

## Veckorytm (lätt)

| Cadence | Ritual |
| --- | --- |
| Varje pass | Now → bygg → DoD-light → commit |
| Vid behov | Pixel_6 / Play internal |
| På begäran | Full audit (inte automatisk natt-rutin) |
| Per release | Release-DoD + tag = version |

---

## Medvetet utanför systemet

- Flera Now samtidigt
- Obligatorisk skill-/prompt-routing varje slice
- “Klart” utan DoD-light
- Agent som pushar/releasar utan uttrycklig begäran
- Nya skills utan återkommande smärta (2+ gånger)
