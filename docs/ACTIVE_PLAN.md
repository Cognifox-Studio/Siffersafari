# Siffersafari – Aktiv plan

> **Status:** Aktiv plan (2026-05-18)  
> **Horisont:** Nästa releasepolish till v2.0+  
> **Syfte:** Visa vad som fortfarande är planerat. Levererad historik och stabila beslut hålls i andra facitdokument.

Den här planen ska vara kort och bara bära det som fortfarande styr prioritering.

För övrigt facit:

- `docs/SESSION_BRIEF.md` för levererat nuläge och senaste steg
- `docs/DECISIONS_LOG.md` för stabila produkt- och teknikbeslut
- `docs/ARCHITECTURE.md` och `docs/PROJECT_STRUCTURE.md` för faktisk implementation

---

## Aktiv fas – releasepolish och nästa produktmål

**När:** Nu, efter att de committed roadmap-slices som redan varit i gång är landade.  
**Tidsfönster:** En liten slice i taget.

**Produktmål:** Säkerställa att storykarta, hemflöde och TTS känns bra på riktig enhet, och först därefter välja nästa verkliga produktmål.

**Det som återstår innan en ny större fas öppnas:**

1. Kör automatisk guardrail för releasepolish-slicen: `flutter analyze`, berörda widget-/unit-tester och `git diff --check`.
2. Gör en manuell känslokoll på enhet för TTS-röst/tempo, storykarta, garderob och barnets huvudsakliga väg genom hem -> quiz -> resultat -> story.
3. Landa bara små polish-slices som tydligt förbättrar begriplighet, CTA-hierarki eller device-känsla.
4. Välj nästa committed produktmål uttryckligen i stället för att låta flera halvaktiva spår leva samtidigt.

**Vad som kan bli nästa större steg, men ännu inte är låst:**

- fortsatt story-/biome-polish om den ger tydlig produktnytta
- mer camp-polish eller samlarvärde ovanpå nuvarande rewardmodell
- ytterligare pedagogiska hjälpmedel om data visar fastkörningar

## Guardrails

- Öppna inte ny biome, ny persistens och ny UX-polish i samma slice.
- Blanda inte releasepolish med stora datamigreringar.
- Definiera QA-slice innan implementation.
- Låt inte leaderboard eller andra experimentspår bli committed plan utan tydlig retention- eller begriplighetsnytta.

**Regel för experiment:**

- Allt som inte direkt stärker retention, pedagogik eller begriplighet ska behandlas som experiment.
- Ett experiment måste kunna tas bort utan att påverka kärnloopen.

**COPPA-notering:** Om ett lokalt leaderboard-experiment byggs får botar inte presenteras som verkliga barn eller sociala motspelare.

---

## v2.0+ – Forskningsspår och möjliga framtida leveranser

Första offline-TTS-slicen är levererad och följs nu upp i polish- och releasearbete, inte som ett eget framtidsblock här. Den här sektionen ska därför bara innehålla sådant som faktiskt fortfarande är research eller framtida kandidatspår.

### Forskningsspår: Handskrift och sifferigenkänning

**När:** Först efter en separat spike. Inte som planerad huvudleverans nu.

**Nuvarande bedömning:**

- Google ML Kit Digital Ink är mer lovande än att direkt bygga egen modell, eftersom den är gjord för streckdata, kör on-device och stöder många språk.
- Samtidigt hålls språkmodellerna små genom dynamisk nedladdning av språkpaket, vilket gör spåret svagare som offline-first-kärnflöde dag ett.
- LiteRT/TensorFlow Lite är kraftfullt, men kräver egen modellkedja: modellval, konvertering, optimering/kvantisering, benchmark och size-budget.

**Beslut:**

- Handskrift går inte in i committed roadmap förrän vi har bevis för rimlig modellstorlek, stabil latens på målenheter och ett första läge som inte bryter offline-first-principen.

---

## Inte nu

Detta ska uttryckligen inte prioriteras i den här planen:

- molnsync och kontoberoenden
- riktiga sociala funktioner
- leaderboard som kärnfeature
- ny mascot-runtime utanför nuvarande PNG-first-spåret
- stora ML-funktioner i kärnflödet innan offline- och size-frågor är lösta

---

## Aktiv tidslinje

För ett litet team är detta den rekommenderade ordningen nu:

1. Manuell device-koll för TTS, storykarta och huvudflöde.
2. En liten polish- eller release-slice utifrån det som faktiskt faller ut av den kollen.
3. Ett uttryckligt val av nästa committed produktmål.
4. Först därefter: eventuell större v1.8-v1.9-slice eller separat v2.0-spike.
