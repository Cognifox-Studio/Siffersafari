<!--
typ: explanation
syfte: Kanoniskt arbetssätt för produkt och utveckling (Now/Next/Later, DoD, AI-loop, release)
uppdaterad: 2026-07-24
-->

# Utvecklingssystem (Siffersafari)

Detta är **hur vi jobbar**. Det är facit för rutin — inte en önskelista.

Relaterat:

- [DEFINITION_OF_DONE.md](DEFINITION_OF_DONE.md) — när något räknas som klart
- [SESSION_BRIEF.md](SESSION_BRIEF.md) — **Now** (aktuellt committed mål + senaste leveranser)
- [ACTIVE_PLAN.md](ACTIVE_PLAN.md) — **Next / Later** + guardrails
- [DECISIONS_LOG.md](DECISIONS_LOG.md) — stabila beslut
- `.github/AGENTS.md` — routing till agent/skill/prompt

---

## Principer (låsta)

1. **Ett Now i taget.** Inget parallellt “halvfärdigt spår” utan att Now är DoD-klart eller medvetet pausat.
2. **`main` ska alltid vara mergebart.** Små slices, korta grenar (helst &lt; 1–2 dagar), CI grön före merge.
3. **Repo är sanningen.** Session_brief, DoD, skills och audits slår chattminne.
4. **Constraints i CI/tester, inte bara i prompts.** Agenten får misslyckas högt — analyze/tester stoppar dåligt arbete.
5. **Plan → Execute → Review.** Agenten utmanar planen; människa godkänner innan större kod; människa äger commit/push/release.
6. **Kod ≠ Play-release.** Mergar ofta; Play internal ofta; staged/prod medvetet.

---

## Produkt: Now / Next / Later

| Horisont | Fil | Betydelse |
| --- | --- | --- |
| **Now** | `SESSION_BRIEF.md` | Det enda vi bygger just nu. Hög commitment. |
| **Next** | `ACTIVE_PLAN.md` | Nästa bet — formad nog att starta snart, inte påbörjad. |
| **Later** | `ACTIVE_PLAN.md` | Riktning utan löfte (bråk-UI, handskrift, …). |

**Regler:**

- Bara **ett** Now.
- Next får max 2–3 kandidater; Later är parkering.
- När Now är DoD-klart: antingen promote Next → Now, eller välj nytt Now uttryckligen.
- Canvas **hur-mycket-jobb-kvar** (Cursor) speglar samma lager — uppdatera state när Now byts.

---

## Arbetsloop (varje slice)

```text
1. Läs SESSION_BRIEF (Now)
2. Plan-läge: scope, risk, DoD, minsta QA — agenten ska utmana
3. Människa godkänner planen
4. Bygg i små steg (en avsikt per commit-grupp)
5. Kör Definition of Done (slice)
6. Commit (människa ber om det)
7. Uppdatera SESSION_BRIEF om Now-status ändrats
```

**Startprompt:** `.github/prompts/slice-start.prompt.md`

**Grenar:** `feat/…`, `fix/…`, `docs/…`, `chore/…` från `main`. Inget GitFlow (`develop`/`release/*`).

**Diffstorlek:** sikta på reviewbara slices. Blandar du refaktor + feature + `.github` + mattebank → dela.

---

## AI-roller (byt medvetet)

| Fas | Roll | Beteende |
| --- | --- | --- |
| Discovery | Plan | Utmana antaganden, fråga, ingen kod |
| Bygg | Beast Mode / standard | Implementera godkänd plan, fail fast, kör tester |
| QA före commit | `testa-innan-vi-sparar` + DoD | Analyze + rätt tester |
| Release | `release-manager` / go-no-go | Tag = pubspec, Play-spår |

Agenten ska **inte** vara “alltid glad utförare”. Be den hitta luckor i planen innan implementation.

---

## Testpyramid

| Lager | När | Exempel |
| --- | --- | --- |
| Unit / audits | Nästan varje Dart-slice | bank-runtime, mix, curriculum, services |
| Widget | UI-ändringar | home, results, story, parent |
| Integration / Pixel_6 | Pre-release eller UI/device-risk | smoke, `app_quiz_flow`, Pixel_6 sync |

PR/CI: analyze + snabb testsvit. Emulator/integration: nightly eller release-DoD — inte varje commit.

Matteändringar: alltid difficulty/bank-skills enligt `.github/AGENTS.md`.

---

## Releasekedja (Android / Play)

```text
main grön  →  tag v* = pubspec  →  Internal testing (samma AAB)
                                 →  Closed / production (promote + staged rollout)
```

- GitHub Releases APK och Play-AAB ska inte divergera i “vilken version är sanning”.
- Efter release: uppdatera SESSION_BRIEF + README versionsrad om de skiljer sig från tagg.
- Go/No-go: `.github/prompts/release-go-no-go.prompt.md` + DoD release-sektion.

---

## Dokumentation (Diátaxis-light)

| Behov | Fil |
| --- | --- |
| Vad är Now / vad levererades? | `SESSION_BRIEF.md` |
| Next / Later / guardrails | `ACTIVE_PLAN.md` |
| Hur jobbar vi? | **denna fil** |
| När är klart? | `DEFINITION_OF_DONE.md` |
| Var ligger koden? | `lib/features/START_HERE.md`, `TRACE_MAP.md` |
| Varför? | `DECISIONS_LOG.md` |
| Install / setup | rot-`README.md`, `SETUP_ENVIRONMENT.md` |

Uppdatera docs **i samma slice** när verkligheten ändras — inte i stora “doc-helger” efteråt.

---

## Veckorytm

| Cadence | Ritual |
| --- | --- |
| Varje pass | SESSION_BRIEF → slice-start → DoD → commit |
| Efter merge | Ingen permanent dirty tree “över natten” utan avsikt |
| 1–2×/vecka | Play internal eller Pixel_6 om Now berör känsla/device |
| Veckovis ~20 min | Now/Next/Later-review; bocka canvas |
| Per release | Release-DoD + tag = version |

---

## Medvetet utanför systemet

- Flera Now samtidigt
- Långa feature branches (&gt; några dagar) utan merge
- “Klart” utan DoD
- Agent som pushar/releasar utan uttrycklig mänsklig begäran
- Stora experimentspår (leaderboard, moln, handskrift) utan bet i Next

---

## Införande

När detta dokument och DoD motsäger äldre vanor: **följ detta**.  
Äldre skills/promptar är verktyg inuti systemet — de ersätter inte Now/DoD-loopen.
