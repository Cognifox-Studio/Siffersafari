# Agentförteckning

Kort index. **Cursor Plan/Agent är default.** Copilot-agenter under `.github/agents/` är legacy-kompat.

Facit: [`docs/DEV_SYSTEM.md`](../docs/DEV_SYSTEM.md) · Yta: [`docs/TOOLING_SURFACE.md`](../docs/TOOLING_SURFACE.md) · Arkiv: [`.github/archive/README.md`](archive/README.md)

---

## Cursor-default (5 rader)

1. Läs `docs/SESSION_BRIEF.md` (Now).
2. Öppna berörd `lib/features/<feature>/START_HERE.md`.
3. Bygg; Plan/`slice-start` bara vid risk (persistens, mattebank, release, bred refaktor).
4. DoD-light: `docs/DEFINITION_OF_DONE.md` sektion A0.
5. Commit när människa ber om det; uppdatera Now-raden om status ändrats.

Project rule: `.cursor/rules/siffersafari.mdc`

---

## Aktiva prompts

| Behov | Fil |
| --- | --- |
| Risk-slice | `prompts/slice-start.prompt.md` |
| QA före commit | `prompts/repo-qa-slice.prompt.md` |
| Felsök | `prompts/felsok.prompt.md` |
| Play triage | `prompts/play-release-router.prompt.md` |
| Listing copy | `prompts/play-listing-copy-pass.prompt.md` |
| Go/No-go | `prompts/release-go-no-go.prompt.md` |
| Assets | `prompts/asset-flow-router.prompt.md` |
| Story/tema-bilder | `prompts/story-theme-asset-pass.prompt.md` |
| Garderob-rendering | `prompts/inventory-rendering-pass.prompt.md` |

---

## Aktiva skills (on-demand)

| Behov | Skill |
| --- | --- |
| Matte/bank/mix | `skills/testa-fragornas-svarighetsgrad` |
| Quiz persistens | `skills/testa-att-quiz-sparas-ratt` |
| COPPA | `skills/verifiera-coppa-regler` |
| Pixel_6 / adb | `skills/felsok-android-emulatorn` |
| Release readiness | `skills/kolla-om-appen-ar-redo-att-slappas` |
| Docs-synk | `skills/uppdatera-dokumentationen` |
| Play assets | `skills/synka-play-assets` |
| Nya assets | `skills/integrera-nya-assets`, `skills/skapa-bildbestallning` |
| Allmän QA | `skills/testa-att-appen-fungerar` |
| Trasiga tester | `skills/laga-kraschande-tester` |
| Hive/legacy | `skills/felsok-sparad-data`, `skills/granska-legacy-hive-format` |
| Analytics | `skills/faststall-spelar-statistik` |
| Barn-UX copy | `skills/granska-ux-och-copy-for-barn` |
| Testanimationer | `skills/hantera-flutter-test-animationer` |
| Formulär | `skills/validera-formular-och-input` |

Garderob: `.github/instructions/regler-for-z-index-inventory.instructions.md`

---

## Arkiverat

Se [`.github/archive/README.md`](archive/README.md). Kör **inte** som varje-pass-rutin (night-audit, customization-audit, repo-start-routing, duplicerade QA-skills, m.fl.).

---

## Copilot-agenter (legacy)

| Agent | Fil | När |
| --- | --- | --- |
| Plan | `agents/plan.agent.md` | Scope/risk utan kod |
| Beast Mode | `agents/beastmode.agent.md` | End-to-end implementering (Copilot) |
| Customization Maintainer | `agents/customization-maintainer.agent.md` | `.github`-underhåll |
| UI Reviewer | `agents/ui-reviewer.agent.md` | Ren UI-granskning |
| release-manager | `agents/release-manager.agent.md` | Release / Play |

I Cursor: använd inbyggt Plan/Agent i stället för Beast/Plan-agenter om inget annat sagts.

---

## Underhåll

- Håll denna fil kort.
- Nya skills: **nej** som default (DEV_SYSTEM).
- Repo-regler: `.github/copilot-instructions.md` + `.cursor/rules/siffersafari.mdc`.
