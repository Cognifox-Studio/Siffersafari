<!--
typ: reference
syfte: Definition of Done — gemensam checklista för slice och release
uppdaterad: 2026-07-24
-->

# Definition of Done

Inget räknas som “klart” förrän rätt sektion nedan är uppfylld.  
Arbetssätt: [DEV_SYSTEM.md](DEV_SYSTEM.md).

---

## A. Slice DoD (varje kod-/docs-ändring)

Bocka innan commit:

- [ ] **En avsikt** — ingen blandad refaktor+feature+matte+`.github` i samma commit-grupp utan att det är nödvändigt
- [ ] **Plan godkänd** för icke-triviala slices (agenten utmanade scope/risk; människa sa go)
- [ ] **`flutter analyze`** grön för berörd yta (global analyze vid bredare diff)
- [ ] **Rätt tester** gröna:
  - matte/generator/bank/curriculum → relevanta unit/audits (+ difficulty-skill vid behov)
  - quiz/resultat/persistens → relevanta unit/widget
  - UI/navigation/assets → widget och/eller Pixel_6 enligt risk
- [ ] **`scripts/verify_git_changes.ps1`** OK om diffen inte är trivial docs-only
- [ ] **Docs i samma andetag** om Now, API, ägarskap eller användarvägar ändrats (`SESSION_BRIEF` / START_HERE / TRACE_MAP / beslut)
- [ ] **COPPA** oförändrad eller medvetet granskad (inga trackers/onlinekrav i kärnflödet)
- [ ] **Commit** med tydligt *varför* (människa begär commit)

**Inte DoD:** “agenten sa att det funkar”, “det kompilerar lokalt”, “vi fixar tester senare”.

---

## B. Release DoD (GitHub tagg / Play)

Allt i A, plus:

- [ ] Kärnflöde manuellt: **hem → quiz → resultat → story** (TTS om berört)
- [ ] `pubspec.yaml` **version = git-tagg** `v*`
- [ ] Play **internal testing** med samma AAB som ska promote:as (föredra framför enbart sideload)
- [ ] GitHub Release / Play-spår dokumenterat så “vilken build installerar jag?” är entydigt
- [ ] Go/No-go körd (`.github/prompts/release-go-no-go.prompt.md` eller canvas `ar-appen-redo`)
- [ ] `SESSION_BRIEF` uppdaterad med levererad version och nästa Now

Staged rollout på production: börja lågt, övervaka crash/feedback, höj medvetet.

---

## C. Now-byte DoD

När ett Now avslutas eller byts:

- [ ] Slice/Release DoD för det som landade
- [ ] `SESSION_BRIEF` Now-rad uppdaterad
- [ ] `ACTIVE_PLAN` Next/Later speglar verkligheten
- [ ] Canvas `hur-mycket-jobb-kvar` bockad/omfokuserad

---

## Snabbkommando före commit

```bash
flutter analyze
# + minsta relevanta:
flutter test <path>
powershell -ExecutionPolicy Bypass -File scripts/verify_git_changes.ps1
```

Skill: `.github/skills/testa-innan-vi-sparar/SKILL.md`  
QA-slice: `.github/prompts/repo-qa-slice.prompt.md`
