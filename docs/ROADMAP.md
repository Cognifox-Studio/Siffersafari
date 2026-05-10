# Siffersafari – Roadmap för genomförande

> **Status:** Revised Draft (2026-05-01)  
> **Horisont:** v1.4.x till v2.0+  
> **Syfte:** Visa vad vi bygger, i vilken ordning vi bygger det, när vi bör göra det, och hur vi undviker kända problem innan vi står mitt i dem.

Den här roadmapen är medvetet skriven som ett styrdokument för ett litet team. Den ska vara tillräckligt konkret för release-planering och QA, men inte så tekniskt låg nivå att den blir en ticketlista.

---

## Principer som gäller för hela planen

1. **Offline-first först.** Inga steg i kärnloopen får kräva nätverk, inloggning eller molnsync.
2. **Feature-first i UI-lagret.** Feature-specifik UI ligger under `lib/features/<feature>/presentation/`. `lib/presentation/widgets/` används bara för delad UI.
3. **Små releaser slår stora satsningar.** Vi levererar hellre tre små releaser som fungerar än en stor release som blandar retention, data-migration och nya spelsystem samtidigt.
4. **Återanvänd befintliga services först.** `AudioService`, `AppAnalyticsService`, `AchievementService`, `AdaptiveDifficultyService`, `SpacedRepetitionService` och befintliga notifier-flöden är första val innan nya domäner introduceras.
5. **Dataändringar går före UI när persistens påverkas.** För profiler, resume och inventory börjar arbetet i datamodell och migration, inte i skärmbygge.
6. **Varje release måste klara repoets QA-gate.** Minimikrav: `flutter analyze`, relevanta tester, samt Pixel_6-verifiering när navigation, rendering, animation eller assets påverkas.

---

## Styrande mätetal

Vi ska inte bara mäta om funktioner byggs, utan om de förbättrar produkten.

- `quiz_completed / quiz_start`
- `daily_completed / daily_start`
- `quiz_abandoned`
- återkomst nästa dag för aktiv profil
- andel sessioner där en upplåsning faktiskt triggas

Vi har redan lokal `AppAnalyticsService`. Den ska användas först, innan nya analytics-spår övervägs.

---

## Beslutsgrind före varje release

Ett steg får gå vidare till implementation när detta är sant:

1. Scope är begränsat till en releasebar slice.
2. Persistens- och migrationspåverkan är känd.
3. QA-slice är definierad.
4. Vi vet vad som uttryckligen **inte** ingår.

---

## Nu: Fas 0 – Baslinje och skyddsnät

**När:** Direkt efter alpha-feedback eller innan första v1.4-PR:n.  
**Tidsfönster:** 3–5 arbetsdagar.

**Varför nu:** Nästa fas rör ljud, animation och belöningar. Det är låg risk var för sig, men de blir dyra att felsöka senare om vi inte först låser baseline för QA, analytics och dataägarskap.

**Vad som ingår:**

- Säkerställ att befintliga lokala funnel-events räcker för att mäta effekt av v1.4.
- Lås vilka delar av quiz-sessionen som redan persisteras och vilka som fortfarande bara lever i runtime-state.
- Identifiera exakt vilka knappar och feedbackytor som ska få haptik, ljud och animation.
- Skapa en enkel releasechecklista för Pixel 6: starta quiz, svara rätt/fel, avsluta quiz, återvänd till hem, byt profil om relevant.

**Så går vi tillväga:**

1. Inventera existerande events i `AppAnalyticsService` och mappa dem mot mätetalen ovan.
2. Verifiera nuvarande quizpersistens i `QuizNotifier` och `UserNotifier` innan vi lägger till mer â€œjuiceâ€.
3. Bestäm vilka UI-ytor som ska få mikrofeedback i v1.4.0 och lämna resten utanför.

**Förebygg problem:**

- Lägg inte till ny provider-initiering i widgets. Riverpod rekommenderar att providers initierar sig själva och att man undviker init-logik i `initState()` när state egentligen hör till provider eller användarflöde.
- Lägg inte animationsstate i providers. Riverpod varnar uttryckligen för att använda providers för ephemeral state som animationer och controllers.

**Klart när:**

- Baslinjen för mätetal är känd.
- QA-checklistan finns.
- Vi vet exakt vad v1.4.0 ska ändra och inte ändra.

---

## v1.4.0 – Juice och responsiv feedback

**När:** Direkt efter Fas 0.  
**Tidsfönster:** 1–2 veckor.

**Produktmål:** Göra quizflödet mer levande utan att röra progression, profiler eller datamodell.

**Vad som ingår:**

- Haptisk feedback för rätt/fel och utvalda klick.
- Enkla mikroanimationer på knappar och feedbackytor.
- Tydligare ljudseparering mellan klick/SFX och längre celebration-ljud.
- Visuell belöning i liten skala, till exempel konfetti eller pop-overlay.

**Så går vi tillväga:**

1. Återanvänd befintlig `AudioService` och lägg till tydlig uppdelning mellan korta SFX och längre uppspelningsfall.
2. Börja med implicita animationer (`AnimatedScale`, `AnimatedSlide`, `AnimatedSwitcher`, `TweenAnimationBuilder`) för knappfeedback och återkoppling.
3. Använd explicit animation först om vi efter prototyp ser att enkel implicit animation inte räcker.
4. Lägg haptik endast på de viktigaste ögonblicken: korrekt svar, fel svar, viktig bekräftelse.
5. Gör konfetti/overlay lokalt i widgetträdet, inte som global app-state.

**Best way enligt extern vägledning:**

- Flutters animationsguide rekommenderar att man väljer enklaste animationsnivå som löser problemet. För den här releasen betyder det implicita animationer först och explicit kontroll först när en sekvens verkligen kräver det.
- Flutters `HapticFeedback`-API är avsiktligt kortfattat och använder plattformens standardbeteende. Det är bra för snabb UI-feedback men inte för exakt fysisk kontroll. Därför ska haptik användas sparsamt och konsekvent.
- `audioplayers` rekommenderar separata spelare per ansvar. För korta SFX är `PlayerMode.lowLatency` lämpligt, men det saknar vissa funktioner som completion/position. För längre ljud eller uppspelningar där tillstånd behöver följas bör standardläget användas.

**Förebygg problem:**

- Använd inte overshoot-kurvor för hela `TweenSequence`-kedjor där värden måste hålla sig inom säkert område.
- Låt inte samma spelare hantera både musik och korta SFX.
- Om vi använder `lowLatency` för SFX ska vi inte bygga logik som kräver completion-event från samma spelare.
- Preladda bara de mest använda SFX:erna. Gå inte direkt till tung global preloading av alla ljud.

**Klart när:**

- Barnet märker tydligt skillnad i respons på rätt/fel svar.
- Inga visuella eller ljudmässiga regressioner i huvudflödet.
- Pixel 6-körning känns stabil utan märkbar jank.

---

## v1.4.1 - Belönings-MVP (KLAR)

**När:** Efter 5–7 dagar stabilitet på v1.4.0 eller när v1.4.0 inte längre ger nya regressionsfel.  
**Tidsfönster:** 1 vecka.

**Produktmål:** Göra progression synlig direkt för barnet med en första liten, konkret upplåsning.

**Vad som ingår:**

- En första unlockbar hattkategori.
- [x] Ett enkelt inventory-flöde för avatar-items (Z-index-stacking)
- [x] Ett belöningsdialogsteg efter tydlig progression

**Så går vi tillväga:**

1. Behåll `LevelUpEvent` som signal om progression, inte som bärare av allt reward-data.
2. Inför ett separat reward-steg som avgör vad som låses upp.
3. Bygg bara ett slot-baserat system först, till exempel `hat_layer` för vår Loke-PNG maskot.
4. Låt första inventory-versionen bara stödja få, tydliga item-typer.
5. Bygg UI för att byta hatt på en enda plats, helst där spelaren redan förväntar sig belöningar eller profiluttryck.

**Best way enligt extern vägledning:**

- Hive rekommenderar typed data, måttligt antal boxar och transaktioner när flera relaterade skrivningar måste lyckas tillsammans. Inventory + reward + analytics bör därför skrivas atomiskt när möjligt.
- Hive rekommenderar också att man inte lagrar binära assets direkt i databasen. Vi lagrar bara item-ID:n, metadata och eventuellt fil-/assetreferenser.

**Förebygg problem:**

- Överlasta inte `LevelUpEvent` med `itemId`. Nivåuppgång och belöningsupplösning är två olika ansvar.
- Introducera inte pets, stickers och full garderob i samma slice. En hatt räcker för att verifiera modellen.
- Stäng inte Hive-boxar i onödan. Inventory kommer att läsas ofta om det används i hemflödet.

**Klart när:**

- Minst en hatt kan låsas upp, sparas, väljas och återläsas korrekt.
- Reward-dialogen känns som en tydlig, positiv förstärkning.
- Ingen datakorruption eller tappad state vid appstängning.

---

## v1.5.0 – Lokala profiler, återupptagning och Spaced Repetition v2

**När:** När v1.4.x är stabil och reward-MVP inte längre skapar datamässiga regressionsfel.  
**Tidsfönster:** 2–3 veckor.

**Produktmål:** Göra appen bättre för familjer och säkrare för längre användning genom robust lokal profilscoping och bättre träningsåterkoppling.

**Vad som ingår:**

- Flera barnprofiler offline.
- Tydligt scoped state per profil.
- Resume av quiz där det är rimligt och tryggt.
- Spaced Repetition v2 och ett första â€œDagens träningslägerâ€.

**Så går vi tillväga:**

1. Börja i data- och providerlagret, inte i UI.
2. Definiera stabila användaridentifierare och vilken state som ska vara profilscopad.
3. Flytta profilberoende providers till family-baserade providers där det passar.
4. Lägg migrationsplan för `settings`, `user_progress` och `quiz_history` innan ny UI byggs.
5. Inför deterministic saving för in-progress quiz på säkra checkpoints: start, svar, fråga-växling, resultat, och vid app-paus när det är relevant.
6. Koppla in SRS v2 i generatorflödet gradvis och verifiera först med smal testmatris.

**Best way enligt extern vägledning:**

- Riverpod rekommenderar `family` för flera oberoende tillstånd baserat på parameter, och rekommenderar också `autoDispose` när gamla parametrar inte längre behövs.
- Riverpod varnar för parametrar utan stabil `==`/`hashCode`. Profilscoping ska därför alltid ske med stabila värden som `userId`, inte lösa listor eller ad hoc-objekt.
- Hive rekommenderar transaktioner för relaterade uppdateringar och att man inte skapar för många boxar. För detta steg är det bättre med tydligt ägda boxar och versionsmigrering än att skapa nya småboxar för varje feature.

**Förebygg problem:**

- Lägg inte vald flik, knappstate, controllers eller annan route-ephemeral state i providers bara för att â€œallt ska vara i Riverpodâ€.
- Förlita dig inte bara på app lifecycle-callbacks för resume. Spara även vid domänhändelser i quizflödet.
- Gör migrationstester innan UI-test. Resume och profiler är dataproblem först, UX-problem sen.

**Klart när:**

- Minst två profiler kan användas lokalt utan att deras state blandas ihop.
- Ett påbörjat quiz kan återupptas utan dubbelräkning eller fel merge mot persistent user state.
- SRS-v2 kan presentera due-frågor utan att bryta huvudgeneratorn.

---

## v1.6.0 – Camp-grund och hemflödets första metaspel

**När:** Efter att v1.5.0 har stabiliserats.  
**Tidsfönster:** 2–3 veckor.

**Produktmål:** Göra hemskärmen mer levande och ge barnet ett tydligare visuellt â€œhemâ€ som kan växa över tid.

**Vad som ingår:**

- En ny camp-bakgrund eller camp-scen som ersätter dagens platta startsida.
- Ett första datadrivet lager för placerbara eller synliga upplåsningar.
- En mycket liten mängd möbler/dekorationer.

**Så går vi tillväga:**

1. Börja med statisk camp-scen utan drag-and-drop.
2. När scenen känns rätt, lägg till datadrivna objekt ovanpå scenen.
3. Först därefter avgör vi om barnet faktiskt behöver repositionering.
4. Om repositionering tillför tydligt värde: bygg ett begränsat drag-system för några få objekt, inte ett generellt redigeringsläge från dag ett.

**Best way enligt extern vägledning:**

- Flutters `DragTarget` och `Draggable` fungerar, men moderna callbacks använder `onWillAcceptWithDetails` och `onAcceptWithDetails`. Om vi bygger drag/drop ska vi använda de nya callbacks, inte äldre deprecated varianter.
- För animation och rörelse i campet gäller samma princip som i v1.4.0: börja med enkel visuell respons, inte ett fullskaligt fysik- eller editor-system.

**Förebygg problem:**

- Börja inte med fri möblering. Det skapar direkt krav på layout, snap-logik, lagring och återställning.
- Låt inte campet bli ett separat progressionsträd. Det ska bygga ovanpå samma reward- och inventorymodell som redan finns.

**Klart när:**

- Hemskärmen känns tydligt mer världslik utan att bli tyngre att förstå.
- Minst ett upplåst objekt kan visas konsekvent i campet.

---

## v1.6.1 – Följeslagare och samlarobjekt

**När:** Direkt efter v1.6.0 om inventory-modellen håller.  
**Tidsfönster:** 1–2 veckor.

**Produktmål:** Bredda belöningar utan att uppfinna ännu ett parallellt system.

**Vad som ingår:**

- Ett första pet-slot.
- Ett enkelt klistermärkesalbum eller badge-flöde.

**Så går vi tillväga:**

1. Återanvänd inventory-strukturen från v1.4.1.
2. Begränsa första pet-slicen till en visuell plats och ett fåtal items.
3. Låt achievement-/badge-flödet bygga vidare på `AchievementService` i stället för att skapa en separat progressionstjänst direkt.

**Förebygg problem:**

- Skapa inte ett helt nytt pets-system med egen lagring om samma inventorymodell räcker.
- Låt inte albumet bli ett vuxet checklistesystem. Det ska vara begripligt för barn.

**Klart när:**

- En pet och ett enkelt badge-/albumflöde fungerar utan att komplicera kärnloopen.

---

## v1.7.0 – Första minspelet

**När:** Efter att metaspel och inventory inte längre skapar regressionsarbete.  
**Tidsfönster:** 2–4 veckor.

**Produktmål:** Bryta upp quizformatet med exakt ett minispel som stärker retention eller repetition.

**Vad som ingår:**

- Ett minispel, inte flera.
- Egen results-loop.
- Merge tillbaka till samma profil- och progressionssystem som quiz använder.

**Så går vi tillväga:**

1. Välj minispel utifrån verkligt behov i mätetalen, inte bara idéstyrka.
2. Bygg det som en egen feature med minsta möjliga koppling till resten.
3. Återanvänd existerande difficulty- och feedbacklogik när det är rimligt.
4. Lägg till lokala analytics för start, completion och abandon även här.

**Förebygg problem:**

- Bygg inte fyra minispel samtidigt.
- Undvik specialfall i `QuizNotifier` om minspelet egentligen förtjänar ett eget notifier-flöde.

**Klart när:**

- Ett minispel kan spelas, slutföras och spara tillbaka relevant progression utan specialtrassel i resten av appen.

---

## v1.7.1 – Pedagogiska hjälpmedel

**När:** Efter första minspelet eller tidigare om data visar tydliga fastkörningar i quiz.  
**Tidsfönster:** 1–2 veckor.

**Produktmål:** Ge barnet hjälp när det behövs, utan att förstöra tempo eller självförtroende.

**Vad som ingår:**

- Tipp-kort eller korta förklaringar.
- Tallinje eller annan visuell stödmodell för de operationer där barnet ofta fastnar.

**Så går vi tillväga:**

1. Visa stödet först vid tydliga struggle-signaler: flera fel, lång svarstid eller låg säkerhet i samma mönster.
2. Börja med en operation där nyttan är högst.
3. Mät om hjälpen faktiskt leder till slutförda sessioner.

**Förebygg problem:**

- Visa inte hjälpen konstant. Då blir den bakgrundsbrus.
- Gör inte hjälpen till vuxenförklaring. Den måste vara kort, visuell och handlingsbar.

**Klart när:**

- Stödet hjälper utan att störa.
- Barn med återkommande svårigheter kommer lättare vidare i quizflödet.

---

## v1.8–v1.9 – Fördjupning, polish och ny biome

**När:** Först när v1.4–v1.7 faktiskt har förbättrat kärnmätetalen.  
**Tidsfönster:** 4–8 veckor totalt, uppdelat i mindre releaser.

**Vad som kan ingå:**

- Ny biome i Story Map.
- Fler camp-objekt och polish.
- Ytterligare ett minispel om det första verkligen fungerar.
- Ett strikt valfritt experimentspår som lokal, generisk leaderboard.

**Regel för experiment i denna fas:**

- Allt som inte direkt stärker retention, pedagogik eller begriplighet ska behandlas som experiment.
- Ett experiment måste kunna tas bort utan att påverka kärnloopen.

**COPPA-notering:** Om ett lokalt leaderboard-experiment byggs får botar inte presenteras som verkliga barn eller sociala motspelare.

---

## v2.0+ – Planerade leveranser vs forskningsspår

Vi ska skilja på sådant som är rimligt att planera och sådant som ännu är research.

### Planerad leverans: Offline-TTS för tillgänglighet

**När:** Tidigast efter att v1.7.x är stabil och vi vet att kärnloopen håller.  
**Tidsfönster:** 1 vecka spike + 1–2 veckor produktifiering.

**Varför:** TTS är ett tydligt tillgänglighetslyft och passar offline-first bättre än många andra â€œAIâ€-spår.

**Så går vi tillväga:**

1. Bygg först en spike på Android.
2. Verifiera vilka språk och röster som faktiskt finns installerade på våra målenheter.
3. Börja med uppläsning av fråga och kort feedback, inte hela appen.
4. Lägg funktionen bakom tydlig inställning i föräldraläge eller tillgänglighetsläge.

**Best way enligt extern vägledning:**

- `flutter_tts` kräver minst Android SDK 21.
- För Android 11+ anger pluginets dokumentation att TTS-service ska deklareras i manifestets `queries` om appen använder text-till-tal.
- Pluginets pausstöd på Android bygger på workaround och fungerar först från API 26+. Planera därför inte beroende logik kring â€œpause/resume narrationâ€ på lägre Android-versioner.

**Förebygg problem:**

- Blockera inte UI på speak-completion.
- Blanda inte TTS, celebration-ljud och musik utan att bestämma prioritet i ljudflödet.
- Gör språkdetektion och fallback tydlig. Appen får inte bli tyst utan begriplig återkoppling.

### Forskningsspår: Handskrift och sifferigenkänning

**När:** Först efter en separat spike. Inte som planerad huvudleverans nu.

**Nuvarande bedömning:**

- Google ML Kit Digital Ink är mer lovande än att direkt bygga egen modell, eftersom den är gjord för streckdata, kör on-device och stöder många språk.
- Samtidigt säger ML Kit-dokumentationen att språkmodeller hålls små genom dynamisk nedladdning av språkpaket. Det gör att spåret inte är ett rent offline-first-core-flöde dag ett.
- LiteRT/TensorFlow Lite är kraftfullt, men kräver egen modellkedja: modellval, konvertering, optimering/kvantisering, benchmark och size-budget. Det är ett större program än en vanlig feature.

**Beslut:**

- Handskrift går inte in i committed roadmap förrän vi har bevis för: rimlig modellstorlek, stabil latens på målenheter och ett första-läge som inte bryter offline-first-principen.

---

## Inte nu

Detta ska uttryckligen inte prioriteras i den här planen:

- molnsync och kontoberoenden
- riktiga sociala funktioner
- leaderboard som kärnfeature
- ny mascot-runtime utanför SVG-first-spåret
- stora ML-funktioner i kärnflödet innan vi har löst offline- och size-frågor
- flera minispel samtidigt

---

## Samlad tidslinje

För ett litet team är detta den rekommenderade ordningen:

1. **Fas 0**: 3–5 arbetsdagar
2. **v1.4.0**: 1–2 veckor
3. **v1.4.1**: 1 vecka
4. **v1.5.0**: 2–3 veckor
5. **v1.6.0**: 2–3 veckor
6. **v1.6.1**: 1–2 veckor
7. **v1.7.0**: 2–4 veckor
8. **v1.7.1**: 1–2 veckor
9. **v1.8–v1.9**: delas upp i små releaser efter mätetal
10. **v2.0+**: TTS som planerat spår, handskrift som separat research-spår

Det här betyder i praktiken att det viktigaste under de närmaste 6–10 veckorna är: `juice -> reward-MVP -> profiler/resume/SRS`.

---

## Externa källor som styr rekommendationerna

Följande vägledning användes när denna roadmap skrevs om:

- Flutter animations docs: välj enklaste fungerande animationsapproach först
- Flutter `HapticFeedback`: använd plattformens standardfeedback sparsamt
- `audioplayers` getting started: separera spelare efter ansvar, använd low latency bara för korta SFX
- Riverpod `family` och DO/DON'T: använd stabila parametrar, undvik widget-init och ephemeral state i providers
- Flutter `DragTarget`: använd moderna callbacks med details
- `flutter_tts` README: Android-krav, queries-deklaration och begränsningar för pause
- ML Kit Digital Ink: offline recognition på streckdata men små språkmodeller via dynamisk nedladdning
- LiteRT guide: ML-spår kräver modellanskaffning, optimering och benchmark innan produktplanering

