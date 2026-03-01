# Kunskapsnivå per årskurs (Åk 1–9)

Syfte: En intern **spec** för vilken kunskapsnivå som är rimlig per årskurs och hur den mappas till appens nuvarande logik (talområden, räknesätt och feature-gates). Målet är att förbättra frågegenerationen utan att vi behöver “gissa” vad appen faktiskt gör.

## Taggar
- `NU (stöds i appen)`: kan uttryckas i nuvarande quiz-format (text + heltalssvar och/eller befintliga Mix-typer).
- `SEN (kräver UI/representation)`: kräver nya widgets/visualisering (klocka, pengar, figurer, grafer/diagram, bråkbitar, koordinatsystem osv.).

## Snabböversikt (exakt app-mappning)

Tabellen visar **caps vid step 10** (maxnivå) för respektive räknesätt enligt `DifficultyConfig.curriculumNumberRangeForStep`.

| Åk | Synliga räknesätt (default) | Förv. step +/− | Förv. step ×/÷ | +/− cap | × cap | ÷ cap | Mix cap |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | +, − | 2 | 1 | 20 | 5 | 5 | 5 |
| 2 | +, − | 2 | 1 | 100 | 10 | 10 | 10 |
| 3 | +, −, ×, ÷ | 3 | 2 | 1000 | 12 | 12 | 12 |
| 4 | +, −, ×, ÷ | 5 | 4 | 10000* | 99 | 20 | 20 |
| 5 | +, −, ×, ÷ | 5 | 4 | 100000* | 199 | 50 | 30 |
| 6 | +, −, ×, ÷ | 5 | 4 | 100000* | 299 | 100 | 60 |
| 7 | +, −, ×, ÷ | 7 | 6 | 1000000 | 299 | 100 | 60 |
| 8 | +, −, ×, ÷ | 7 | 6 | 1000000 | 299 | 100 | 60 |
| 9 | +, −, ×, ÷ | 7 | 6 | 1000000 | 299 | 100 | 60 |

\* Åk 4–6 (+/−) använder en **step-tabell** (inte linjär interpolation) för att undvika stora “hopp”.

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
- Benchmark-step: +/−=5, ×/÷=4.
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
- Benchmark-step: +/−=5, ×/÷=4.
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
- Benchmark-step: +/−=7, ×/÷=6.
- Caps vid step 10: +/− 1 000 000, × 299, ÷ 100, Mix 60.
- Mix feature-gates (Åk 7–9):
  - M5a procent: roll < 0.18.
  - M5a potenser: bara Åk 8–9 (se nästa).
  - M5a prioriteringsregler: roll i `[0.30, 0.42)`.
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
- Samma benchmark/caps som Åk 7.
- M5a potenser: roll i `[0.18, 0.30)` (endast Åk≥8).
- M5b: samma rollfönster som Åk 7 när step≥8.

## Åk 9

### Kunna
- `NU`: Stabil aritmetik + M5a/M5b i Mix enligt gates.
- `SEN`: Resonemang, modeller, algebra, funktioner, geometri med figurer.

### App-logik (exakt)
- Samma benchmark/caps som Åk 7.

---

## Källor & avgränsningar

Pedagogiska “progressionssignaler” (kompletterande, ej maskin-exakt):
- Rik Matematik: https://www.rikmatematik.se/prova
- Matematik ABG (film-översikt): https://www.matematikabg.se/elever/filmer.html
- Skolmagi.nu: blockerade automatiserad hämtning (HTTP 403) vid insamling.

Exakta app-regler i repo (detta dokument speglar dessa):
- Talspann + benchmark + synliga räknesätt: `lib/core/config/difficulty_config.dart`
- Feature-gates + Mix-fördelning: `lib/core/services/question_generator_service.dart`
