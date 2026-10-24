<!--
typ: reference
syfte: Rangordnad Top 100 ROI — facit utanför chatten
uppdaterad: 2026-10-24
-->

# ROI backlog — Top 100

> Facit för **prioritering**. Det som byggs just nu står i [SESSION_BRIEF.md](SESSION_BRIEF.md).  
> Aktiv Next (max tre): [ACTIVE_PLAN.md](ACTIVE_PLAN.md).  
> Metod: (1) ship redan byggt → (2) föräldrartillit/Store → (3) discoverability → (4) lärande utan ny svarsmodell → (5) cadence/offline.

**Effort:** S = hours–1 dag · M = 1–3 dagar · L = multi-day / ny representation.

**Exkluderat (Inte nu):** cloud sync, social, leaderboard-as-core, ny mascot-runtime, ML, Daily Challenge-revival, SEN bråk/diagram-UI som product track, Nattskogen som riktig biome.

---

## 1–50 (låsta tiers)

### A — Ship & trust (1–10)

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 1 | Fix 4 `prefer_const` infos så `--fatal-infos` CI passerar | Unblocks Play/CI | S | `curriculum_facit_loader.dart`, `question_generation_context_test.dart` |
| 2 | Release `v1.4.3+22` (tag + samma AAB internal) | Camp/badges/nextBiome når inte barn förrän detta | S–M | DoD B, `play-closed-beta.yml` |
| 3 | What’s-new notes för +22 | Testers/parents ser verklig delta | S | `play/release-notes/*` |
| 4 | Wire Play screenshots into fastlane + sync | Installs; assets finns, metadata tom | S | `artifacts/play_console_phone_9x16/`, `play-store-listing.yml` |
| 5 | Listing copy: offline, no ads/trackers, PIN parent | Parent Store conversion | S | `fastlane/metadata/android/` |
| 6 | Fix privacy “encrypted Hive” claim (ärlig copy först) | Trust / Data safety | S | `PRIVACY_POLICY.md`, `privacy_policy_screen.dart` |
| 7 | Sync in-app privacy deps (Just Audio → audioplayers) | Trust drift | S | `privacy_policy_screen.dart`, `pubspec.yaml` |
| 8 | Audit INTERNET permission vs offline-first story | Parent/Data-safety narrative | S–M | `AndroidManifest.xml` |
| 9 | COPPA check named in Release DoD B / go-no-go | Cheap Store-risk insurance | S | `DEFINITION_OF_DONE.md` |
| 10 | Feature graphic + 512 icon into fastlane images | Store shelf presence | S–M | `assets/images/app_icon/` |

### B — Close loops already built (11–25)

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 11 | Badge unlock-hints på låsta brickor | Collectibles utan mål | S | `home_badge_album.dart`, `achievement_catalog.dart` |
| 12 | Namngivna unlocks på resultat | Stänger camp/badge-investering | S–M | `results_screen__content_part.dart` |
| 13 | Wardrobe CTA från tom camp | Dress-up missas första sessioner | S | `camp_scene_view.dart`, `wardrobe_screen.dart` |
| 14 | Camp collection-teaser när count = 0 | Early “vad du ska samla” | S | `camp_scene_view.dart` |
| 15 | TTS discoverability för föräldrar (default-off) | A11y begravd bakom PIN | S | parent dashboard |
| 16 | In-quiz TTS replay/stop clarity | Friktion för TTS-kohorten | S | `quiz_screen.dart` |
| 17 | Resume CTA visar op + progress | Playtest-förvirring på “Fortsätt” | S | `home_read_model.dart` |
| 18 | Results focused-practice CTA prominence | Wrong → retry loop parents vill ha | S | `_ResultsPracticePlanner` |
| 19 | Nattskogen soft landing (ingen fake biome) | Endgame-vägg efter nextBiome | S–M | `story_progression_service.dart` |
| 20 | Align “Sedan/Senare” copy home↔map↔results | Next-step läses automatiskt | S | story + results parts |
| 21 | Onboarding grade helper (“osäker?”) | Fel Åk förgiftar profilen | S | `onboarding_screen.dart` |
| 22 | Parent first-run checklist (grade → TTS → ops) | Snabbare familjesetup | S | parent dashboard |
| 23 | Gate wipe/delete bakom PIN i settings | Trust när settings är öppet | M | `settings_screen.dart` |
| 24 | Parent “tonight’s practice” från weakest areas | Befintlig read model → retention | M | parent read model |
| 25 | Home first-viewport: play primär, camp sekundär | Korta telefoner efter camp/badges | M | `home_screen__content_part.dart` |

### C — Learning depth without new UI models (26–40)

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 26 | Åk 6 `%`-change med fixed answer policy | Bank redo; policy-only unlock | S | `grade_6_question_bank.json` |
| 27 | Åk 6 multi-step word → single integer | Problem-solving gap, 1 svar | S–M | bank + audit |
| 28 | Åk 8 compound % integer subset | Återanvänder befintlig % Mix | S | mix policy + audit |
| 29 | Widen Åk 8 proportionality (integer-only) | Mer variation, proven pattern | S | proportionality generators |
| 30 | Widen Åk 9 geometry integer formulas | Completeness utan π/skala | S | geometry bank tests |
| 31 | Dubbelt/hälften som Mix specialty (Åk 1–3) | Cheap taluppfattning Store-claim | S | `question_mix_policy.dart` |
| 32 | Feedback tips for Mix (% / ekv / prop) | Fel svar ofta bara bare | M | `feedback_service.dart` |
| 33 | Struggle → focused practice från parent weak areas | Offline mastery → session | M | parent + quiz planner |
| 34 | SRS/due keys för Mix prompt families | Retention-läcka på bridges | M | `quiz_due_question_planner.dart` |
| 35 | Åk 1–2 “Sortera” as MC order (inte sort-UI) | Number sense i nuvarande modell | S–M | grade 1–2 banks |
| 36 | Integer “½ of n” text-bridge (pre-SEN visual) | Curriculum credibility Åk 3–6 | M | facit SEN fractions |
| 37 | Åk 6 diagram via befintlig ASCII bar-style | Mid-grade stats utan chart-UI | M | M4 diagram generators |
| 38 | Rimlighets-/estimate integer checks | Skolverket-förmåga vs drill | M | `curriculum_facit.json` |
| 39 | Åk 8–9 linear/functions integer text subset | Older-kid bridge, inga grafer | M | grade 8–9 banks |
| 40 | Åk 9 probability bag/table text | Completes 7–9 matrix | S–M | chance generators |

### D — Cadence & polish multipliers (41–50)

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 41 | Fix `release-guard` missing test paths | False confidence / red dispatch | S | `release-guard.yml` |
| 42 | One-command release preflight script | Färre fel-version uploads | S | `scripts/` |
| 43 | Align `DEPLOY_ANDROID` examples to +22 | Shipping hygiene | S | `docs/DEPLOY_ANDROID.md` |
| 44 | A11y pass: home ops, wardrobe, story, badges | Beyond quiz Semantics | M | `accessibility_widgets_test.dart` |
| 45 | Space theme parity vs jungle | Andra temat måste kännas äkta | M | `app_theme_config.dart` |
| 46 | Feedback glanceability (timing/density) | Help läsbar före Nästa | S–M | `feedback_dialog__content_part.dart` |
| 47 | Hard-quest vs hard-badge fairness | Badge kan kännas ouppnåelig | M | `quest_progression_service.dart` |
| 48 | Surface local analytics in parent (no cloud) | Offline insight-loop | M | `app_analytics_service.dart` |
| 49 | Incremental facit→runtime step-band migration | Shipping speed för varje bank | M | `CURRICULUM_DATA_MIGRATION.md` |
| 50 | Difficulty steps that add strategy, not only bigger numbers | Färre rage-quits | M | `difficulty_config.dart` |

---

## 51–70 — Curriculum hygiene + pedagogik + profile/parent

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 51 | Åk7 `simplify_expressions` → evaluate-at-x integer | Unlocks deferred bank utan symbolic UI | M | `grade_7_question_bank.json` |
| 52 | Publish Åk4 `statistics` exception matrix | Makes with_exceptions actionable | S | `question_bank_runtime_status_audit_test.dart` |
| 53 | Publish Åk8 prop remaining-deferred matrix | Guards #29 from decimal/graph creep | S | `grade_8_question_bank.json` |
| 54 | Publish Åk9 geo π/skala/cylinder matrix | Complements #30 | S | `grade_9_question_bank.json` |
| 55 | Feedback tips: prioriteringsregler | Bank misconception → bare wrongs | S | `feedback_service.dart` |
| 56 | Feedback + tallinje: negative_numbers | Supported Mix, thin help | M | audit + feedback |
| 57 | Widen Åk8 `powers` integer variety | Supported; more Mix depth | S | `grade_8_question_bank.json` |
| 58 | Normalize equation answers to bare int | Cuts `x=` false wrongs | S | grade 7/9 banks |
| 59 | Audit: tiokompisar actually in Mix | Facit claim vs starvation | S | `grade_1_question_bank.json` |
| 60 | Mark `requiresCompletedPrompt` non-runtime | Stops multi-blank force-in | S | grade 6 bank + audit |
| 61 | Fill empty `undercoveredConcepts` | Audits hide Skolverket gaps | M | grade banks / facit |
| 62 | Tip: Åk2 tens-transition addition | Supported section, generic tips | S | `grade_2_question_bank.json` |
| 63 | Profile rename after create | Multi-kid name stuck forever | S | `create_user_dialog.dart` |
| 64 | Force security Q before PIN unlock done | Recovery dead-end if null | S | `pin_recovery_screen.dart` |
| 65 | Parent SRS toggle: what “due” means | Tautology copy → SRS stays off | S | parent dashboard content |
| 66 | Confirm Åk change when path 10↔30 | Silent map rewrite | S | `quest_progression_service.dart` |
| 67 | Single Åk editor owner (parent XOR settings) | Dual dropdowns confuse | M | settings + parent |
| 68 | Default word/saknat-tal by Åk | Åk1 can get hard text early | S | parent dashboard |
| 69 | Profile empty-state + soft max-kids | Store multi-profile claim | S | `profile_selection_screen.dart` |
| 70 | Onboarding abandon copy (`PopScope`) | Force-kill orphans profile | S | `onboarding_screen.dart` |

---

## 71–85 — Parent trust + quiz/camp polish

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 71 | CTA when Skolverket panel `gradeLevel == null` | Benchmark useless until Åk | S | parent dashboard |
| 72 | Kid-safe SFX labels vs parent-only toggles | Settings mixes audiences | S | `settings_screen.dart` |
| 73 | Confirm before quiz abandon/close | Accidental X feels destructive | S | `quiz_screen.dart` |
| 74 | Duck music while TTS speaks | TTS vs `quiz_music.mp3` | S | `audio_service.dart` |
| 75 | Distinct haptic wrong vs correct | Same lightImpact today | S | `quiz_screen.dart` |
| 76 | Confetti only above score threshold | 0/10 celebration hurts trust | S | `results_screen.dart` |
| 77 | Live-region “fråga X av Y” TalkBack | Progress Semantics weak mid-quiz | S | `progress_indicator_bar.dart` |
| 78 | Hold-to-confirm answers Åk1–2 | Fat-finger before tips | M | `answer_button.dart` |
| 79 | Abandon → seed due keys if SRS on | Partial practice discarded | M | `quiz_due_question_planner.dart` |
| 80 | TTS SV digit/operator pass for Mix | Robotic Mix prompts | M | `text_to_speech_service.dart` |
| 81 | Hard quests on older-grade story paths | Hard badge without map stops | M | `quest_progression_service.dart` |
| 82 | Pedestal arrival anim on souvenir unlock | Results teaser ≠ camp update | S | `camp_scene_view.dart` |
| 83 | Badge album emoji → PNG tiles | PNG-first product, emoji catalog | M | `achievement_catalog.dart` |
| 84 | Auto-scroll story map to current stop | 30-stop paths hide “you are here” | S | story map canvas |
| 85 | Wardrobe pose labels (idle vs wrong) | Pose equip invisible to kids | S | `wardrobe_screen.dart` |

---

## 86–100 — Collect clarity, Store, CI, docs

| # | Item | Why | Effort | Anchor |
|---|------|-----|--------|--------|
| 86 | Locked souvenir vs pedestal filler visual | Fillers look like loot | S | `inventory_item.dart` / camp |
| 87 | Achievement for episode/`nextBiome` | Story climax has no collectible | S | `achievement_catalog.dart` |
| 88 | Locked wardrobe “kommer snart” by level | Dress-up goals opaque | S | `wardrobe_screen.dart` |
| 89 | Honest privacy export (how-to or remove claim) | Policy promises export; no UI | S | `PRIVACY_POLICY.md` |
| 90 | Align en-US listing with sv-SE beats | US Store conversion left | S | `en-US/full_description.txt` |
| 91 | Play Data safety answers checklist in DoD B | Console drift after copy fixes | S | `DEFINITION_OF_DONE.md` |
| 92 | Snapshot content-rating / target-age in docs | COPPA questionnaire drift | S | `DEPLOY_ANDROID.md` |
| 93 | Short desc formula: Åk 1–9 · offline · no ads | Short text underuses differentiators | S | `sv-SE/short_description.txt` |
| 94 | Dual-locale what’s-new template per tag | One locale misses delta | S | `play/release-notes` |
| 95 | Screenshot beat: parent PIN + no-ads | Parents decide installs | M | `artifacts/play_console_phone_9x16/` |
| 96 | Align `ci.yaml` analyze with `--fatal-infos` | Green+red same push | S–M | `.github/workflows/ci.yaml` |
| 97 | Size gate on AAB not only debug APK | Guard measures wrong artifact | S | `release-guard.yml` |
| 98 | Widget tests badge + camp albums | Collect loop unguarded | M | `home_badge_album.dart` |
| 99 | START_HERE UTF-8 (å/ä/ö) restore | Agent/docs accuracy | S | feature `START_HERE.md` |
| 100 | TRACE_MAP: badges + camp souvenirs | Post-v1.8 collectibles missing | S | `docs/TRACE_MAP.md` |

---

## Near-miss (just outside 100 — Later notes)

- ~~Bank-audit on PR CI~~ (done — `ci.yaml` analyze job)
- ~~Drop unused `background_music.wav` from pubspec~~
- ~~Precache camp/wardrobe thumbs on first home frame~~
- ~~Vibration toggle vs START_HERE~~ (haptic follows `soundEnabled`; START_HERE fixed)
- ~~Settings “Om appen” version/build~~ (`AppConstants.appVersionLabel`)
- ~~Hive `quiz_history` growth hygiene~~ (keep newest 40 completed / user)
- ~~Parent sibling picker in parent mode~~
- ~~Practice planner filler when no weak items~~ (tonight CTA always)
- ~~Music handoff reliability home ↔ quiz ↔ story~~ (serialized track switches)

*(Near-miss list cleared — Top 100 + near-miss shipped. Next: push/PR ask.)*

---

## Parked (Inte nu)

- Full bråk / decimaler / diagram-UI (**SEN**)
- Nattskogen som **riktig** biome
- Underwater **och** fantasy samtidigt
- Molnsync / konton / sociala / leaderboard-as-core
- Ny mascot-runtime / stora ML-funktioner
- Hive-kryptering som retrofit (ärlig copy först)
- Session time-limits innan #23–24
- Daily Challenge revival

---

## How to use

1. **Now** = en sak i taget via `SESSION_BRIEF.md` (release #1–3 först).
2. **Next** = max tre i `ACTIVE_PLAN.md` (nu: #11 → #12 → #13).
3. Dra från #51+ bara när Next är tomt eller en Next-slot byts uttryckligen.
4. Uppdatera denna fil när ranking eller status ändras — inte via chat-minne.
