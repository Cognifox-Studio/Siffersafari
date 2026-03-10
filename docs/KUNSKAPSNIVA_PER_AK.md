# Kunskapsnivå per årskurs (Åk 1–9)

En intern **spec** och **implementationsplan** för vilken kunskapsnivå som är rimlig per årskurs och hur den mappas till appens logik (talområden, räknesätt, feature-gates och frågegeneration).

## Syfte & Målbild

Använd årskurs-informationen (Åk 1–9) för att:
- Generera frågor med rätt **talområde**
- Gradvis introducera rätt **strategier** (t.ex. tiokompisar, tiotalsövergång)
- Senare kunna lägga till nya **frågetyper** (textuppgifter, pengar, tid, geometri) utan att bygga om appen i ett steg

**Målbild:**
- När en förälder sätter barnets Åk ska quizet automatiskt välja rimliga tal och "typiska" strategier för den Åk
- Föräldern kan alltid överstyra räknesätt och svårighet; Åk är en **guide**, inte ett tak
- Målet är "rimliga" frågor som tränar rätt strategi, inte en exakt läroplanssimulation

## Grundprinciper

- **Förståelse före hastighet** (särskilt Åk 1–2)
- **Stabil progression**: små steg, tydliga nivåer
- **Föräldern har sista ordet**: förälderns val av räknesätt begränsar alltid
- **Fallback**: om Åk saknas eller data saknas → använd nuvarande logik

## Taggar
- `NU (stöds i appen)`: kan uttryckas i nuvarande quiz-format (text + heltalssvar och/eller befintliga Mix-typer).
- `SEN (kräver UI/representation)`: kräver nya widgets/visualisering (klocka, pengar, figurer, grafer/diagram, bråkbitar, koordinatsystem osv.).

## Adaptiv svårighetsgrad (hybrid-modell)

**System:** Appen använder ett hybrid-adaptivt system som kombinerar **mikro-signaler** (snabba streaks) med **makro-bekräftelse** (rullande 5-fråge-fönster) för att justera `difficultyStep` per räknesätt under quiz.

**Regler:**
- **Mikro-signal uppåt:** 3 rätt i rad → föreslår +1 step
- **Mikro-signal nedåt:** 2 fel i rad → föreslår −1 step
- **Makro-bekräftelse:** Rullande 5-fråge-fönster med trösklar:
  - ≥ 85% rätt → föreslår +1 step
  - ≤ 60% rätt → föreslår −1 step
- **Konfliktlösning:** Steg ändras endast när mikro och makro är överens, **eller** när mikro är neutral (0) och makro har ett förslag
- **Cooldown:** 2 frågor måste passera efter varje step-ändring innan nästa justering tillåts (förhindrar thrashing)

**Resultat:** Barn som svarar snabbt och korrekt får snabbare progression utan att vänta på 5-fråge-fönstret (mikro), men långsamma fel eller jämn blandad prestanda regleras fortfarande av makro-fönstret. Steg persisteras per räknesätt i `UserProgress.operationDifficultySteps` och fortsätter mellan quiz-sessioner.

**Implementation:**
- Service-lager: `AdaptiveDifficultyService.suggestDifficultyStep`
- Runtime: `QuizNotifier.submitAnswer` räknar streaks och updaterar steg
- Persistence: `UserNotifier.applyQuizResult` sparar steg till profildata

## Snabböversikt (exakt app-mappning)

Tabellen visar **caps vid step 10** (maxnivå) för respektive räknesätt enligt `DifficultyConfig.curriculumNumberRangeForStep`.

| Åk | Synliga räknesätt (default) | Förv. step +/− | Förv. step ×/÷ | +/− cap | × cap | ÷ cap | Mix cap |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | +, − | 2 | 1 | 20 | 5 | 5 | 5 |
| 2 | +, − | 2 | 1 | 100 | 10 | 10 | 10 |
| 3 | +, −, ×, ÷ | 3 | 2 | 1000* | 12 | 12 | 12 |
| 4 | +, −, ×, ÷ | 4 | 3 | 10000* | 99 | 20 | 20 |
| 5 | +, −, ×, ÷ | 5 | 4 | 100000* | 199 | 50 | 30 |
| 6 | +, −, ×, ÷ | 6 | 5 | 100000* | 299 | 100 | 60 |
| 7 | +, −, ×, ÷ | 6 | 5 | 1000000 | 299 | 100 | 60 |
| 8 | +, −, ×, ÷ | 7 | 6 | 1000000 | 299 | 100 | 60 |
| 9 | +, −, ×, ÷ | 7 | 6 | 1000000 | 299 | 100 | 60 |

\* Åk 3–6 (+/−) använder en **step-tabell** (inte linjär interpolation) för att undvika stora “hopp”.

Notiser:
- `Synliga räknesätt (default)` kommer från `visibleOperationsForGrade` och kan fortfarande begränsas av förälderns val.
- `÷ cap` används för *kvot + divisor*; dividend byggs som `kvot * divisor` (heltal utan rest i standardläget).
- Talområdena i `DifficultyConfig` är 0..cap. Negativa heltal (M5a) hanteras i generatorn och är ett separat lager.

---

## Åk 1

### Kunna
- `NU`: Taluppfattning 0–20, jämföra tal.
- `NU`: +/− inom 10 som “lägga till/ta bort”, samt tiokompisar.
- `SEN`: Former/lägesord (behöver visuell representation).

### Introducera
- `NU`: +/− upp till 20.
- `NU`: Enkla textuppgifter för +/− (kort, 1 steg).

### App-logik (exakt)
- Räknesätt (default): `+`, `−`.
- Benchmark-step: `+`/`−`=2, `×`/`÷`=1.
- Caps vid step 10: +/− 20, Mix 5.
- Feature-gates:
  - Textuppgift +/−: Åk 1–3 (om påslaget).
  - Saknat tal: ej i Åk 1.

### Vanliga fel
- Tolkning av text (“fler” vs “kvar”) och blandar +/−.

## Åk 2

### Kunna
- `NU`: Tal 0–100, tiotal/ental, räkna i tiosteg.
- `NU`: +/− inom 100 med enkla strategier.
- `SEN`: Klockan/pengar (kräver UI).

### Introducera
- `NU`: Tiotalsövergång i lugn progression.
- `NU`: “Saknat tal” som begrepp.

### App-logik (exakt)
- Räknesätt (default): `+`, `−`.
- Benchmark-step: `+`/`−`=2, `×`/`÷`=1.
- Caps vid step 10: +/− 100, Mix 10.
- Feature-gates:
  - Saknat tal: Åk 2–3, endast +/−.
  - Textuppgift +/−: Åk 1–3.

### Vanliga fel
- Likhetstecknet blir “nu kommer svaret” istället för “lika på båda sidor”.

## Åk 3

### Kunna
- `NU`: Tal 0–1000 (positionssystem).
- `NU`: +/− upp till 1000.
- `NU`: ×/÷ som kopplade operationer (tabeller 2–10 gradvis).

### Introducera
- `NU`: Enkla textuppgifter även för ×/÷ (konservativ rollout i appen).
- `SEN`: Bråk som del av helhet (behöver representation).

### App-logik (exakt)
- Räknesätt (default): `+`, `−`, `×`, `÷`.
- Benchmark-step: +/−=3, ×/÷=2.
- +/− step-tabell (Åk 3, min=0):
  - step 1..10 max = `[10, 20, 50, 100, 200, 350, 500, 700, 850, 1000]`
- Caps vid step 10: +/− 1000, × 12, ÷ 12, Mix 12.
- Feature-gates:
  - Textuppgift +/−: Åk 1–3.
  - Textuppgift ×/÷: endast Åk 3.
  - Saknat tal: Åk 2–3.

### Vanliga fel
- Division blir svår om tabellerna inte sitter; håll ÷ kopplad till tabellträning.

## Åk 4

### Kunna
- `NU`: Stabil +/− med större tal.
- `NU`: ×/÷ skalar upp, men fortfarande “hanterbart”.
- `NU`: Mix kan inkludera M4 (statistik/sannolikhet) med låg andel.
- `SEN`: Bråk/decimaler/geometri i visuellt format.

### Introducera
- `NU`: Problemlösning 1–2 steg (kort text).

### App-logik (exakt)
- Benchmark-step: +/−=4, ×/÷=3.
- +/− step-tabell (Åk 4, min=0):
  - step 1..10 max = `[20, 50, 100, 200, 500, 1000, 2000, 4000, 7000, 10000]`
- Caps vid step 10: × 99, ÷ 20, Mix 20.
- Mix feature-gates (Åk 4–6):
  - M4 statistik: roll < `statsChance` (0.10 vid step≤3, annars 0.12).
  - M4 sannolikhet: roll i `[statsChance, statsChance+probabilityChance)` (samma 0.10/0.12).

### Vanliga fel
- Svårighets-hopp om vi inte använder step-tabellen för +/−.

## Åk 5

### Kunna
- `NU`: +/− med stora tal (växling/lån ska kännas begripligt).
- `NU`: ×/÷ med större tal i gradvis progression.
- `SEN`: Procent/bråk/decimaler som representation.

### App-logik (exakt)
- Benchmark-step: +/−=5, ×/÷=4.
- +/− step-tabell (Åk 5, min=0):
  - step 1..10 max = `[50, 100, 200, 500, 1000, 2000, 5000, 10000, 30000, 100000]`
- Caps vid step 10: × 199, ÷ 50, Mix 30.
- Mix M4: samma regler som Åk 4.

## Åk 6

### Kunna
- `NU`: Robust aritmetik (större tal).
- `NU`: Kunna tolka enklare statistik/sannolikhet när M4 dyker upp i Mix.
- `SEN`: Bråk/decimal/procent som vardagsmat, geometri/koordinater.

### App-logik (exakt)
- Benchmark-step: +/−=6, ×/÷=5.
- +/− step-tabell (Åk 6, min=0):
  - step 1..10 max = `[100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000]`
- Caps vid step 10: × 299, ÷ 100, Mix 60.
- Mix M4: samma regler som Åk 4.

## Åk 7

### Kunna
- `NU`: Fortsatt aritmetik + börja möta svårare Mix.
- `NU`: Procent/prioriteringsregler kan dyka upp i Mix (M5a).
- `SEN`: Algebra/funktioner med tydlig representation.

### App-logik (exakt)
- Benchmark-step: +/−=6, ×/÷=5.
- Caps vid step 10: +/− 1 000 000, × 299, ÷ 100, Mix 60.
- Mix feature-gates (Åk 7–9):
  - Signed +/− i kärnflödet: introduceras från step 4.
  - M5a procent: från step 4, roll < 0.18.
  - M5a potenser: bara Åk 8–9 (se nästa).
  - M5a prioriteringsregler: från step 6, roll i `[0.30, 0.42)`.
  - M5b (extra typer): endast om `mixBaselineStep` (clamped) ≥ 8:
    - Linjär funktion (textformat): roll i `[0.42, 0.52)`.
    - Geometrisk transformation (textformat): roll i `[0.52, 0.62)`.
    - Avancerad statistik (textformat): roll i `[0.62, 0.72)`.

## Åk 8

### Kunna
- `NU`: M5a procent + potenser + prioritering i Mix.
- `NU`: M5b-typer kan dyka upp i Mix vid step≥8.
- `SEN`: Fullt algebraspår (kräver mer än heltalssvar i många uppgifter).

### App-logik (exakt)
- Benchmark-step: +/−=7, ×/÷=6.
- Samma caps som Åk 7.
- Signed +/− i kärnflödet: från step 4.
- M5a procent: från step 4.
- M5a potenser: från step 7, roll i `[0.18, 0.30)` (endast Åk≥8).
- M5a prioriteringsregler: från step 6.
- M5b: samma rollfönster som Åk 7 när step≥8.

## Åk 9

### Kunna
- `NU`: Stabil aritmetik + M5a/M5b i Mix enligt gates.
- `SEN`: Resonemang, modeller, algebra, funktioner, geometri med figurer.

### App-logik (exakt)
- Benchmark-step: +/−=7, ×/÷=6.
- Samma caps som Åk 7.
- Signed +/− i kärnflödet: från step 4.
- M5a procent: från step 4.
- M5a prioriteringsregler: från step 6.
- M5a potenser: från step 7.

---

## Källor & avgränsningar

Pedagogiska “progressionssignaler” (kompletterande, ej maskin-exakt):
- Rik Matematik: https://www.rikmatematik.se/prova
- Matematik ABG (film-översikt): https://www.matematikabg.se/elever/filmer.html
- Skolmagi.nu: blockerade automatiserad hämtning (HTTP 403) vid insamling.

Exakta app-regler i repo (detta dokument speglar dessa):
- Talspann + benchmark + synliga räknesätt: `lib/core/config/difficulty_config.dart`
- Feature-gates + Mix-fördelning: `lib/core/services/question_generator_service.dart`

Skolverkets kursplan för matematik (Lgr22):
- https://www.skolverket.se/undervisning/grundskolan/laroplan-lgr22-for-grundskolan-samt-for-forskoleklassen-och-fritidshemmet
- Kursplan i matematik: https://www.skolverket.se/undervisning/grundskolan/laroplan-lgr22-for-grundskolan-samt-for-forskoleklassen-och-fritidshemmet#/curriculums/LGR22/GRGRMAT01

---

## Implementationsstatus (2026-03-05)

- ✅ UI-svårighet: 3 nivåer (lätt/medel/svår)
- ✅ Intern svårighet: step 1–10 per räknesätt (adaptiv), sparas per barnprofil
- ✅ Åk-styrning: används som talområde + constraints, med fallback om data saknas
- ✅ Textuppgifter v1: finns och är per barn (på/av)
- ✅ "Saknat tal" (t.ex. `? + 3 = 7`): finns och är per barn (på/av)
- ✅ M3 (Åk 4–6): +/− har jämnare talområde per step + gradvis växling; ×/÷ har "tabeller först"-formning
- ✅ M4 (påbörjad): enkla statistik- och sannolikhetsfrågor + enkel kombinatorik kan dyka upp i Mix för Åk 4–6
- ⚠️ Division med rest: **avstängt** i nuvarande quiz-format (heltal utan rest)

## Milstolpar (framtida utveckling)

### M2 — Textuppgifter v2 (Åk 1–3, utökade mallar)
- Utöka textuppgifts-generator med fler mallar
- 1–2 steg, kort text, låg kognitiv last
- Acceptance: Textuppgifter fungerar i quizflödet utan ny skärm

### M3 — Åk 4–6: fler strategier och större tal
- Utöka talområde + constraints (mer växling, division med rest som option)
- Acceptance: Talområde skalar upp utan stora "hopp", step 1–10 känns jämn

### M4 — Geometri/Mätning/Diagram (separata moduler)
- Implementera en modul i taget med visuell representation
- Varje modul behöver: datamodell, generator, rendering, test
- Acceptance: Varje modul kan slås av/på och har fallback

### M5a — Åk 7–9: utan ny UI
- Negativa tal: +/−/×/÷ med heltal
- Prioriteringsregler: enkla uttryck med parenteser
- Procent: "x % av y", procentuell förändring
- Potenser: kvadrattal/kubiktal
- Acceptance: Kan köras i quizflödet utan ny skärm

### M5b — Åk 7–9: kräver ny UI/representation
- Funktioner & grafer (koordinatsystem, lutning)
- Geometri med figur (Pythagoras, cirkel-omkrets/area)
- Statistik/sannolikhet med diagram
- Acceptance: Varje modul har egen minimal rendering + enhetstester
