<!--
typ: reference
syfte: Aktiv vs parked vs arkiverad AI-/tooling-yta (Cursor-first)
uppdaterad: 2026-08-31
-->

# Tooling surface

Facit för vad agenten **ska** använda vs vad som är parkering/arkiv.  
Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md). Index: [`.github/AGENTS.md`](../.github/AGENTS.md).

---

## Aktivt (default)

| Yta | Var |
| --- | --- |
| Now / Next | `SESSION_BRIEF.md`, `ACTIVE_PLAN.md` |
| DoD | `DEFINITION_OF_DONE.md` (A0 DoD-light) |
| Kodkartor | `lib/features/**/START_HERE.md`, `TRACE_MAP.md` |
| Cursor-rule | `.cursor/rules/siffersafari.mdc` |
| CI / Play workflows | `.github/workflows/` |
| Pixel_6 | `scripts/flutter_pixel6.ps1`, `.vscode/tasks.json` |
| applyTo-instructions | `.github/instructions/` (träffar riktig kod) |

### Aktiva prompts (on-demand)

- `slice-start.prompt.md` — valfri vid risk
- `release-go-no-go.prompt.md`
- `play-release-router.prompt.md`
- `play-listing-copy-pass.prompt.md`
- `repo-qa-slice.prompt.md`
- `felsok.prompt.md`
- `asset-flow-router.prompt.md`
- `story-theme-asset-pass.prompt.md`
- `inventory-rendering-pass.prompt.md`

### Aktiva skills (on-demand)

- `testa-fragornas-svarighetsgrad`
- `testa-att-quiz-sparas-ratt`
- `verifiera-coppa-regler`
- `felsok-android-emulatorn`
- `kolla-om-appen-ar-redo-att-slappas`
- `uppdatera-dokumentationen`
- `synka-play-assets`
- `integrera-nya-assets` / `skapa-bildbestallning`
- `testa-att-appen-fungerar`
- `laga-kraschande-tester`
- `felsok-sparad-data`
- `granska-legacy-hive-format`
- `faststall-spelar-statistik`
- `granska-ux-och-copy-for-barn`
- `hantera-flutter-test-animationer`
- `validera-formular-och-input`

---

## Parked on-demand

Kör **bara** om användaren uttryckligen ber (t.ex. “full audit”). Inte veckorytm.

Efter Fas E ligger flera här i `.github/archive/` — se archive-README.

---

## Arkiverat

[`.github/archive/`](../.github/archive/) — one-shot routers, meta-audits, duplicerade QA-skills.

Återställ med `git mv` tillbaka om behov uppstår. Hårdradera tidigast efter 1–2 månader oanvänt.

---

## Rör ej utan beslut

- `.github/hooks/` — customization-hygien (kan stängas om Copilot överges helt)
- `.github/agents/` — legacy Copilot-agenter; Cursor Plan/Agent är default
- Legacy Hive Daily Challenge-nycklar i `SettingsKeys` — wipe-yta

---

## Policy

**Bygg inte nya skills** utan återkommande smärta (2+ gånger). Föredra 5–10 rader i DEV_SYSTEM eller feature START_HERE.
