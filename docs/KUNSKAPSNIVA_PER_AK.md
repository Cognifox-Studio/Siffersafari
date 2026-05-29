<!--
typ: reference
syfte: Kunskapsdatabas for arskursmappning, fragetyper och quizprogression
uppdaterad: 2026-05-26
-->

# Kunskapsnivå per årskurs (Åk 1–9)

Detta dokument är det mänskliga navet för kunskapsfacit. Den kanoniska, maskinläsbara källan är [curriculum_facit.json](curriculum_facit.json). Audit-tester ska hålla JSON, kod och detta dokument i synk.

## Kanonisk struktur

- Maskinläsbar källa: [curriculum_facit.json](curriculum_facit.json)
- Mänskligt nav: [KUNSKAPSNIVA_PER_AK.md](KUNSKAPSNIVA_PER_AK.md)
- Runtime-ankare: `DifficultyConfig`, `QuestionGeneratorService`, `QuestionMixPolicy`
- Audit-ankare: `curriculum_facit_consistency_audit_test.dart`, `curriculum_logic_coverage_test.dart`, `difficulty_mix_audit_test.dart`, `mix_distribution_audit_test.dart`, `question_step_profile_audit_test.dart`

Konsekvens: detaljerad per-årskursmappning, step-tabeller, frågetypspolicys och källhierarki ska i första hand uppdateras i `curriculum_facit.json`. Den här filen ska förklara hur facit ska läsas och användas.

## Källhierarki

1. **Skolverket Lgr22, Matematik (`GRGRMAT01`)**: högsta facit. Officiellt centralt innehåll är grupperat per stadie, inte per enskild årskurs.
2. **Skolverkets kommentarmaterial för matematik**: stöd för progression, urval och bedömning.
3. **Skolverkets kriterier, nationella prov, bedömningsstöd och `Hitta matematiken`**: svenska kontrollkällor för bredd, tidiga färdigheter och stadieavstämning.
4. **Appens runtime-facit**: `DifficultyConfig`, `QuestionGeneratorService` och `QuestionMixPolicy` bestämmer exakt vad Siffersafari genererar i dag.
5. **Audit-tester**: skyddar att JSON-facit, dokumentation och faktisk frågemix inte driver isär.

## Så ska facit läsas

- **Skolverket är stadiebaserat**: officiellt innehåll anges för `1–3`, `4–6` och `7–9`.
- **Appen är årskursbaserad**: Åk 1–9 i facit är en konservativ produktmappning ovanpå Skolverkets stadier.
- **`NU` betyder generatorstöd i nuvarande quizformat**: text + heltalssvar och befintliga Mix-typer.
- **`SEN` betyder att representation saknas**: t.ex. bråk, figurer, diagram, koordinatsystem eller andra uttrycksformer som kräver egen UI-modul.
- **Svårare ska inte bara betyda större tal**: progression ska helst addera strategi, samband, problemlösning eller representation.

## Officiell modell vi följer

### Fem förmågor

Lgr22 beskriver fem förmågor som facit måste stödja över tid:

- begrepp och samband mellan begrepp
- metoder och rutinuppgifter
- problemlösning och värdering av strategier
- resonemang
- matematikens uttrycksformer

### Sex kunskapsområden

Skolverket återkommer till samma sex huvudområden i alla stadier. Varje ny frågetyp ska mappas till ett av dem i `curriculum_facit.json`.

| Område | Nuvarande stöd i appen | Största lucka |
|---|---|---|
| Taluppfattning och tals användning | Heltalsaritmetik, procent med heltalssvar, negativa tal, potenser | Bråk- och decimalrepresentation |
| Algebra | Saknat tal, vissa textbaserade funktionsfrågor | Ekvationer och symboliskt svarsstöd |
| Geometri | Begränsat textstöd | Figurer, mätverktyg, area/omkrets/volym som riktig visualisering |
| Sannolikhet och statistik | Lågstadie-statistik/chans, M4-statistik/sannolikhet, M5 avancerad statistik i text | Diagram, datavisualisering och rikare tolkning |
| Samband och förändring | Dubbelt/hälften som policyspår, procent, vissa textfunktioner | Koordinatsystem, grafer, modeller |
| Problemlösning | Korta textuppgifter | Rimlighetsbedömning, strategi-val och modellering |

### Svenska kontrollkällor

Utöver kursplanen använder vi svenska kontrollkällor för att undvika att frågelogiken reduceras till operandstorlek.

| Källa | Hur den används |
|---|---|
| Skolverkets kriterier för Åk 3/6/9 | Stadieavstämning av luckor, inte som exakt generatorregel |
| Skolverkets nationella prov | Kontroll att facitet täcker bredd vid stadieslut |
| Skolverkets bedömningsstöd | Kontroll av om en frågetyp tränar begrepp, metod, problemlösning eller representation |
| `Hitta matematiken` och garantin för tidiga stödinsatser | Kontroll av lågstadiets grundläggande taluppfattning, jämförelser, mönster och tidigt matematiskt tänkande |
| NCM | Didaktisk sanity check, aldrig högre facit än Skolverket |

## Appens tolkning just nu

### Snabböversikt

Tabellen visar aktuella `step 10`-caps enligt `DifficultyConfig.curriculumNumberRangeForStep`. Detaljerade step-tabeller per årskurs ligger i `curriculum_facit.json`.

| Åk | Synliga räknesätt | Förv. step +/− | Förv. step ×/÷ | +/− cap | × cap | ÷ cap | Mix cap |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | +, − | 2 | 1 | 20 | 5 | 5 | 5 |
| 2 | +, −, ×, ÷ | 2 | 1 | 100 | 10 | 10 | 10 |
| 3 | +, −, ×, ÷ | 3 | 2 | 1000 | 10 | 10 | 10 |
| 4 | +, −, ×, ÷ | 4 | 3 | 10000 | 99 | 20 | 20 |
| 5 | +, −, ×, ÷ | 5 | 4 | 100000 | 199 | 50 | 30 |
| 6 | +, −, ×, ÷ | 6 | 5 | 100000 | 299 | 100 | 60 |
| 7 | +, −, ×, ÷ | 6 | 5 | 1000 | 299 | 100 | 60 |
| 8 | +, −, ×, ÷ | 7 | 6 | 1000 | 299 | 100 | 60 |
| 9 | +, −, ×, ÷ | 7 | 6 | 1000 | 299 | 100 | 60 |

### Fokus per block

| Block | Fokus i appen | Inte standard ännu |
|---|---|---|
| Åk 1–3 | Taluppfattning (före/efter, jämföra tal, enkla talföljder), +/−, mjuk ×/÷-introduktion, saknat tal inklusive vissa ×/÷-varianter, korta textproblem, sparsam statistik/chans/tid | Bråk, geometri, mätning, tabeller/diagram som riktig UI |
| Åk 4–6 | Större aritmetik, tabellnära ×/÷, M4-statistik/sannolikhet, sen procent och negativa tal | Bråk, decimaler, koordinater, grafer, geometri med figur |
| Åk 7–9 | Negativa tal, procent, potenser, prioriteringsregler, enkla numeriska ekvationer, heltalsbar proportionalitet, delar av geometri med heltalssvar och textbaserade M5-brofrågor | Symbolisk förenkling, funktioner med graf/formelinput, proportionalitet med decimal-/grafkrav, modeller, diagram, koordinatsystem, full geometri |

### Adaptiv svårighetsgrad

`difficultyStep` är appens interna progressionsmotor per räknesätt.

- **Mikro-signal**: 3 rätt i rad föreslår +1, 2 fel i rad föreslår −1.
- **Makro-signal**: rullande 5-fråge-fönster över/under trösklar bekräftar upp eller ner.
- **Cooldown**: 2 frågor mellan step-ändringar.
- **Persistens**: steg sparas per räknesätt i `UserProgress.operationDifficultySteps`.

## Regler för ny frågetyp

Varje ny frågetyp ska först läggas in i `curriculum_facit.json` med:

1. `skolverketAreaId`
2. `stage`
3. `appStatus` (`NU`, `SEN` eller `SAKNAS`)
4. tydlig `gate`
5. minst ett `minAuditTests`

Om frågetypen är `SEN` får den inte bli standard i Mix förrän representationen finns och ett audit-/testspår verifierar den.

## Kända luckor

- bråk och decimaler som riktig representation
- geometri och mätning med figurer och verktyg
- koordinatsystem, grafer och diagram
- resonemang, modellering och svar som kräver mer än heltal

## Repoankare

- Strukturerad källa: [curriculum_facit.json](curriculum_facit.json)
- Runtime-konfig: `lib/core/config/difficulty_config.dart`
- Generatorfacad: `lib/core/services/question_generator_service.dart`
- Mix-policy: `lib/core/services/question_mix_policy.dart`
- Synk-audit: `test/unit/audits/curriculum_facit_consistency_audit_test.dart`
- Coverage-audit: `test/unit/logic/curriculum_logic_coverage_test.dart`
- Grade-bank-statusaudit: `test/unit/audits/question_bank_runtime_status_audit_test.dart`

## Källor & avgränsningar

Officiella svenska källor:

- Skolverket Lgr22, matematik (`GRGRMAT01`)
- Skolverket Syllabus API v2 (`/v2/subjects/GRGRMAT01`)
- Skolverkets kommentarmaterial till kursplanen i matematik
- Skolverkets nationella prov
- Skolverkets digitala betygsstödjande bedömningsstöd
- Skolverkets kartläggningsmaterial `Hitta matematiken`

Kompletterande, ej överordnade kontrollkällor:

- NCM, Nationellt centrum för matematikutbildning
- Rik Matematik
- Matematik ABG
