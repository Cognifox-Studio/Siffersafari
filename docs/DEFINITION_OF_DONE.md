<!--
typ: reference
syfte: Definition of Done — DoD-light (Cursor default) och full DoD
uppdaterad: 2026-08-31
-->

# Definition of Done

Inget räknas som “klart” förrän rätt sektion nedan är uppfylld.  
Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md).

---

## A0. DoD-light (Cursor default)

Använd för vanliga UI-/docs-/små logik-slices:

- [ ] **En avsikt** per commit-grupp
- [ ] **`flutter analyze`** grön för berörd yta
- [ ] **Berörda tester** gröna (unit och/eller widget)
- [ ] **Docs** om Now, ägarskap eller användarväg ändrats (`SESSION_BRIEF` / START_HERE / TRACE_MAP)
- [ ] **COPPA** oförändrad eller medvetet granskad
- [ ] **Commit** när människa ber om det

Pixel_6 / `verify_git_changes.ps1` / Plan-godkännande: **bara vid risk** (se A).

---

## A. Slice DoD (full — riskytor)

Använd vid persistens, matte/bank, release-nära diff, bred refaktor, eller blandad `.github`+feature:

Allt i A0, plus:

- [ ] **Plan godkänd** (Cursor Plan eller slice-start) när scopet var icke-trivialt
- [ ] Rätt tester per yta:
  - matte/generator/bank → unit/audits (+ difficulty-skill)
  - quiz/resultat/persistens → unit/widget
  - UI/device → widget och/eller Pixel_6
- [ ] **`scripts/verify_git_changes.ps1`** OK om diffen inte är trivial docs-only

**Inte DoD:** “agenten sa att det funkar”, “det kompilerar”, “tester senare”.

---

## B. Release DoD (GitHub tagg / Play)

Allt i A, plus:

- [ ] Kärnflöde manuellt: **hem → quiz → resultat → story** (TTS om berört)
- [ ] `pubspec.yaml` **version = git-tagg** `v*`
- [ ] Play **internal testing** med samma AAB som ska promote:as
- [ ] GitHub Release / Play-spår entydigt
- [ ] Go/No-go (`.github/prompts/release-go-no-go.prompt.md`)
- [ ] `SESSION_BRIEF` uppdaterad med levererad version och nästa Now

Staged production: börja lågt, övervaka, höj medvetet.

---

## C. Now-byte DoD

- [ ] Rätt DoD för det som landade (A0 eller A/B)
- [ ] `SESSION_BRIEF` Now-rad uppdaterad
- [ ] `ACTIVE_PLAN` Next/Later speglar verkligheten

---

## Snabbkommando före commit

```bash
flutter analyze
flutter test <path>
# vid risk:
powershell -ExecutionPolicy Bypass -File scripts/verify_git_changes.ps1
```

Valfritt: `.github/prompts/repo-qa-slice.prompt.md`
