# Siffersafari â€“ Roadmap fÃ¶r genomfÃ¶rande

> **Status:** Revised Draft (2026-05-01)  
> **Horisont:** v1.4.x till v2.0+  
> **Syfte:** Visa vad vi bygger, i vilken ordning vi bygger det, nÃ¤r vi bÃ¶r gÃ¶ra det, och hur vi undviker kÃ¤nda problem innan vi stÃ¥r mitt i dem.

Den hÃ¤r roadmapen Ã¤r medvetet skriven som ett styrdokument fÃ¶r ett litet team. Den ska vara tillrÃ¤ckligt konkret fÃ¶r release-planering och QA, men inte sÃ¥ tekniskt lÃ¥g nivÃ¥ att den blir en ticketlista.

---

## Principer som gÃ¤ller fÃ¶r hela planen

1. **Offline-first fÃ¶rst.** Inga steg i kÃ¤rnloopen fÃ¥r krÃ¤va nÃ¤tverk, inloggning eller molnsync.
2. **Feature-first i UI-lagret.** Feature-specifik UI ligger under `lib/features/<feature>/presentation/`. `lib/presentation/widgets/` anvÃ¤nds bara fÃ¶r delad UI.
3. **SmÃ¥ releaser slÃ¥r stora satsningar.** Vi levererar hellre tre smÃ¥ releaser som fungerar Ã¤n en stor release som blandar retention, data-migration och nya spelsystem samtidigt.
4. **Ã…teranvÃ¤nd befintliga services fÃ¶rst.** `AudioService`, `AppAnalyticsService`, `AchievementService`, `AdaptiveDifficultyService`, `SpacedRepetitionService` och befintliga notifier-flÃ¶den Ã¤r fÃ¶rsta val innan nya domÃ¤ner introduceras.
5. **DataÃ¤ndringar gÃ¥r fÃ¶re UI nÃ¤r persistens pÃ¥verkas.** FÃ¶r profiler, resume och inventory bÃ¶rjar arbetet i datamodell och migration, inte i skÃ¤rmbygge.
6. **Varje release mÃ¥ste klara repoets QA-gate.** Minimikrav: `flutter analyze`, relevanta tester, samt Pixel_6-verifiering nÃ¤r navigation, rendering, animation eller assets pÃ¥verkas.

---

## Styrande mÃ¤tetal

Vi ska inte bara mÃ¤ta om funktioner byggs, utan om de fÃ¶rbÃ¤ttrar produkten.

- `quiz_completed / quiz_start`
- `daily_completed / daily_start`
- `quiz_abandoned`
- Ã¥terkomst nÃ¤sta dag fÃ¶r aktiv profil
- andel sessioner dÃ¤r en upplÃ¥sning faktiskt triggas

Vi har redan lokal `AppAnalyticsService`. Den ska anvÃ¤ndas fÃ¶rst, innan nya analytics-spÃ¥r Ã¶vervÃ¤gs.

---

## Beslutsgrind fÃ¶re varje release

Ett steg fÃ¥r gÃ¥ vidare till implementation nÃ¤r detta Ã¤r sant:

1. Scope Ã¤r begrÃ¤nsat till en releasebar slice.
2. Persistens- och migrationspÃ¥verkan Ã¤r kÃ¤nd.
3. QA-slice Ã¤r definierad.
4. Vi vet vad som uttryckligen **inte** ingÃ¥r.

---

## Nu: Fas 0 â€“ Baslinje och skyddsnÃ¤t

**NÃ¤r:** Direkt efter alpha-feedback eller innan fÃ¶rsta v1.4-PR:n.  
**TidsfÃ¶nster:** 3â€“5 arbetsdagar.

**VarfÃ¶r nu:** NÃ¤sta fas rÃ¶r ljud, animation och belÃ¶ningar. Det Ã¤r lÃ¥g risk var fÃ¶r sig, men de blir dyra att felsÃ¶ka senare om vi inte fÃ¶rst lÃ¥ser baseline fÃ¶r QA, analytics och dataÃ¤garskap.

**Vad som ingÃ¥r:**

- SÃ¤kerstÃ¤ll att befintliga lokala funnel-events rÃ¤cker fÃ¶r att mÃ¤ta effekt av v1.4.
- LÃ¥s vilka delar av quiz-sessionen som redan persisteras och vilka som fortfarande bara lever i runtime-state.
- Identifiera exakt vilka knappar och feedbackytor som ska fÃ¥ haptik, ljud och animation.
- Skapa en enkel releasechecklista fÃ¶r Pixel 6: starta quiz, svara rÃ¤tt/fel, avsluta quiz, Ã¥tervÃ¤nd till hem, byt profil om relevant.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. Inventera existerande events i `AppAnalyticsService` och mappa dem mot mÃ¤tetalen ovan.
2. Verifiera nuvarande quizpersistens i `QuizNotifier` och `UserNotifier` innan vi lÃ¤gger till mer â€œjuiceâ€.
3. BestÃ¤m vilka UI-ytor som ska fÃ¥ mikrofeedback i v1.4.0 och lÃ¤mna resten utanfÃ¶r.

**FÃ¶rebygg problem:**

- LÃ¤gg inte till ny provider-initiering i widgets. Riverpod rekommenderar att providers initierar sig sjÃ¤lva och att man undviker init-logik i `initState()` nÃ¤r state egentligen hÃ¶r till provider eller anvÃ¤ndarflÃ¶de.
- LÃ¤gg inte animationsstate i providers. Riverpod varnar uttryckligen fÃ¶r att anvÃ¤nda providers fÃ¶r ephemeral state som animationer och controllers.

**Klart nÃ¤r:**

- Baslinjen fÃ¶r mÃ¤tetal Ã¤r kÃ¤nd.
- QA-checklistan finns.
- Vi vet exakt vad v1.4.0 ska Ã¤ndra och inte Ã¤ndra.

---

## v1.4.0 â€“ Juice och responsiv feedback

**NÃ¤r:** Direkt efter Fas 0.  
**TidsfÃ¶nster:** 1â€“2 veckor.

**ProduktmÃ¥l:** GÃ¶ra quizflÃ¶det mer levande utan att rÃ¶ra progression, profiler eller datamodell.

**Vad som ingÃ¥r:**

- Haptisk feedback fÃ¶r rÃ¤tt/fel och utvalda klick.
- Enkla mikroanimationer pÃ¥ knappar och feedbackytor.
- Tydligare ljudseparering mellan klick/SFX och lÃ¤ngre celebration-ljud.
- Visuell belÃ¶ning i liten skala, till exempel konfetti eller pop-overlay.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. Ã…teranvÃ¤nd befintlig `AudioService` och lÃ¤gg till tydlig uppdelning mellan korta SFX och lÃ¤ngre uppspelningsfall.
2. BÃ¶rja med implicita animationer (`AnimatedScale`, `AnimatedSlide`, `AnimatedSwitcher`, `TweenAnimationBuilder`) fÃ¶r knappfeedback och Ã¥terkoppling.
3. AnvÃ¤nd explicit animation fÃ¶rst om vi efter prototyp ser att enkel implicit animation inte rÃ¤cker.
4. LÃ¤gg haptik endast pÃ¥ de viktigaste Ã¶gonblicken: korrekt svar, fel svar, viktig bekrÃ¤ftelse.
5. GÃ¶r konfetti/overlay lokalt i widgettrÃ¤det, inte som global app-state.

**Best way enligt extern vÃ¤gledning:**

- Flutters animationsguide rekommenderar att man vÃ¤ljer enklaste animationsnivÃ¥ som lÃ¶ser problemet. FÃ¶r den hÃ¤r releasen betyder det implicita animationer fÃ¶rst och explicit kontroll fÃ¶rst nÃ¤r en sekvens verkligen krÃ¤ver det.
- Flutters `HapticFeedback`-API Ã¤r avsiktligt kortfattat och anvÃ¤nder plattformens standardbeteende. Det Ã¤r bra fÃ¶r snabb UI-feedback men inte fÃ¶r exakt fysisk kontroll. DÃ¤rfÃ¶r ska haptik anvÃ¤ndas sparsamt och konsekvent.
- `audioplayers` rekommenderar separata spelare per ansvar. FÃ¶r korta SFX Ã¤r `PlayerMode.lowLatency` lÃ¤mpligt, men det saknar vissa funktioner som completion/position. FÃ¶r lÃ¤ngre ljud eller uppspelningar dÃ¤r tillstÃ¥nd behÃ¶ver fÃ¶ljas bÃ¶r standardlÃ¤get anvÃ¤ndas.

**FÃ¶rebygg problem:**

- AnvÃ¤nd inte overshoot-kurvor fÃ¶r hela `TweenSequence`-kedjor dÃ¤r vÃ¤rden mÃ¥ste hÃ¥lla sig inom sÃ¤kert omrÃ¥de.
- LÃ¥t inte samma spelare hantera bÃ¥de musik och korta SFX.
- Om vi anvÃ¤nder `lowLatency` fÃ¶r SFX ska vi inte bygga logik som krÃ¤ver completion-event frÃ¥n samma spelare.
- Preladda bara de mest anvÃ¤nda SFX:erna. GÃ¥ inte direkt till tung global preloading av alla ljud.

**Klart nÃ¤r:**

- Barnet mÃ¤rker tydligt skillnad i respons pÃ¥ rÃ¤tt/fel svar.
- Inga visuella eller ljudmÃ¤ssiga regressioner i huvudflÃ¶det.
- Pixel 6-kÃ¶rning kÃ¤nns stabil utan mÃ¤rkbar jank.

---

## v1.4.1 - Belönings-MVP (KLAR)

**NÃ¤r:** Efter 5â€“7 dagar stabilitet pÃ¥ v1.4.0 eller nÃ¤r v1.4.0 inte lÃ¤ngre ger nya regressionsfel.  
**TidsfÃ¶nster:** 1 vecka.

**ProduktmÃ¥l:** GÃ¶ra progression synlig direkt fÃ¶r barnet med en fÃ¶rsta liten, konkret upplÃ¥sning.

**Vad som ingÃ¥r:**

- En fÃ¶rsta unlockbar hattkategori.
- [x] Ett enkelt inventory-flöde för avatar-items (Z-index-stacking)
- [x] Ett belöningsdialogsteg efter tydlig progression

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. BehÃ¥ll `LevelUpEvent` som signal om progression, inte som bÃ¤rare av allt reward-data.
2. InfÃ¶r ett separat reward-steg som avgÃ¶r vad som lÃ¥ses upp.
3. Bygg bara ett slot-baserat system fÃ¶rst, till exempel `hat_layer` fÃ¶r vÃ¥r Loke-PNG maskot.
4. LÃ¥t fÃ¶rsta inventory-versionen bara stÃ¶dja fÃ¥, tydliga item-typer.
5. Bygg UI fÃ¶r att byta hatt pÃ¥ en enda plats, helst dÃ¤r spelaren redan fÃ¶rvÃ¤ntar sig belÃ¶ningar eller profiluttryck.

**Best way enligt extern vÃ¤gledning:**

- Hive rekommenderar typed data, mÃ¥ttligt antal boxar och transaktioner nÃ¤r flera relaterade skrivningar mÃ¥ste lyckas tillsammans. Inventory + reward + analytics bÃ¶r dÃ¤rfÃ¶r skrivas atomiskt nÃ¤r mÃ¶jligt.
- Hive rekommenderar ocksÃ¥ att man inte lagrar binÃ¤ra assets direkt i databasen. Vi lagrar bara item-ID:n, metadata och eventuellt fil-/assetreferenser.

**FÃ¶rebygg problem:**

- Ã–verlasta inte `LevelUpEvent` med `itemId`. NivÃ¥uppgÃ¥ng och belÃ¶ningsupplÃ¶sning Ã¤r tvÃ¥ olika ansvar.
- Introducera inte pets, stickers och full garderob i samma slice. En hatt rÃ¤cker fÃ¶r att verifiera modellen.
- StÃ¤ng inte Hive-boxar i onÃ¶dan. Inventory kommer att lÃ¤sas ofta om det anvÃ¤nds i hemflÃ¶det.

**Klart nÃ¤r:**

- Minst en hatt kan lÃ¥sas upp, sparas, vÃ¤ljas och Ã¥terlÃ¤sas korrekt.
- Reward-dialogen kÃ¤nns som en tydlig, positiv fÃ¶rstÃ¤rkning.
- Ingen datakorruption eller tappad state vid appstÃ¤ngning.

---

## v1.5.0 â€“ Lokala profiler, Ã¥terupptagning och Spaced Repetition v2

**NÃ¤r:** NÃ¤r v1.4.x Ã¤r stabil och reward-MVP inte lÃ¤ngre skapar datamÃ¤ssiga regressionsfel.  
**TidsfÃ¶nster:** 2â€“3 veckor.

**ProduktmÃ¥l:** GÃ¶ra appen bÃ¤ttre fÃ¶r familjer och sÃ¤krare fÃ¶r lÃ¤ngre anvÃ¤ndning genom robust lokal profilscoping och bÃ¤ttre trÃ¤ningsÃ¥terkoppling.

**Vad som ingÃ¥r:**

- Flera barnprofiler offline.
- Tydligt scoped state per profil.
- Resume av quiz dÃ¤r det Ã¤r rimligt och tryggt.
- Spaced Repetition v2 och ett fÃ¶rsta â€œDagens trÃ¤ningslÃ¤gerâ€.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. BÃ¶rja i data- och providerlagret, inte i UI.
2. Definiera stabila anvÃ¤ndaridentifierare och vilken state som ska vara profilscopad.
3. Flytta profilberoende providers till family-baserade providers dÃ¤r det passar.
4. LÃ¤gg migrationsplan fÃ¶r `settings`, `user_progress` och `quiz_history` innan ny UI byggs.
5. InfÃ¶r deterministic saving fÃ¶r in-progress quiz pÃ¥ sÃ¤kra checkpoints: start, svar, frÃ¥ga-vÃ¤xling, resultat, och vid app-paus nÃ¤r det Ã¤r relevant.
6. Koppla in SRS v2 i generatorflÃ¶det gradvis och verifiera fÃ¶rst med smal testmatris.

**Best way enligt extern vÃ¤gledning:**

- Riverpod rekommenderar `family` fÃ¶r flera oberoende tillstÃ¥nd baserat pÃ¥ parameter, och rekommenderar ocksÃ¥ `autoDispose` nÃ¤r gamla parametrar inte lÃ¤ngre behÃ¶vs.
- Riverpod varnar fÃ¶r parametrar utan stabil `==`/`hashCode`. Profilscoping ska dÃ¤rfÃ¶r alltid ske med stabila vÃ¤rden som `userId`, inte lÃ¶sa listor eller ad hoc-objekt.
- Hive rekommenderar transaktioner fÃ¶r relaterade uppdateringar och att man inte skapar fÃ¶r mÃ¥nga boxar. FÃ¶r detta steg Ã¤r det bÃ¤ttre med tydligt Ã¤gda boxar och versionsmigrering Ã¤n att skapa nya smÃ¥boxar fÃ¶r varje feature.

**FÃ¶rebygg problem:**

- LÃ¤gg inte vald flik, knappstate, controllers eller annan route-ephemeral state i providers bara fÃ¶r att â€œallt ska vara i Riverpodâ€.
- FÃ¶rlita dig inte bara pÃ¥ app lifecycle-callbacks fÃ¶r resume. Spara Ã¤ven vid domÃ¤nhÃ¤ndelser i quizflÃ¶det.
- GÃ¶r migrationstester innan UI-test. Resume och profiler Ã¤r dataproblem fÃ¶rst, UX-problem sen.

**Klart nÃ¤r:**

- Minst tvÃ¥ profiler kan anvÃ¤ndas lokalt utan att deras state blandas ihop.
- Ett pÃ¥bÃ¶rjat quiz kan Ã¥terupptas utan dubbelrÃ¤kning eller fel merge mot persistent user state.
- SRS-v2 kan presentera due-frÃ¥gor utan att bryta huvudgeneratorn.

---

## v1.6.0 â€“ Camp-grund och hemflÃ¶dets fÃ¶rsta metaspel

**NÃ¤r:** Efter att v1.5.0 har stabiliserats.  
**TidsfÃ¶nster:** 2â€“3 veckor.

**ProduktmÃ¥l:** GÃ¶ra hemskÃ¤rmen mer levande och ge barnet ett tydligare visuellt â€œhemâ€ som kan vÃ¤xa Ã¶ver tid.

**Vad som ingÃ¥r:**

- En ny camp-bakgrund eller camp-scen som ersÃ¤tter dagens platta startsida.
- Ett fÃ¶rsta datadrivet lager fÃ¶r placerbara eller synliga upplÃ¥sningar.
- En mycket liten mÃ¤ngd mÃ¶bler/dekorationer.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. BÃ¶rja med statisk camp-scen utan drag-and-drop.
2. NÃ¤r scenen kÃ¤nns rÃ¤tt, lÃ¤gg till datadrivna objekt ovanpÃ¥ scenen.
3. FÃ¶rst dÃ¤refter avgÃ¶r vi om barnet faktiskt behÃ¶ver repositionering.
4. Om repositionering tillfÃ¶r tydligt vÃ¤rde: bygg ett begrÃ¤nsat drag-system fÃ¶r nÃ¥gra fÃ¥ objekt, inte ett generellt redigeringslÃ¤ge frÃ¥n dag ett.

**Best way enligt extern vÃ¤gledning:**

- Flutters `DragTarget` och `Draggable` fungerar, men moderna callbacks anvÃ¤nder `onWillAcceptWithDetails` och `onAcceptWithDetails`. Om vi bygger drag/drop ska vi anvÃ¤nda de nya callbacks, inte Ã¤ldre deprecated varianter.
- FÃ¶r animation och rÃ¶relse i campet gÃ¤ller samma princip som i v1.4.0: bÃ¶rja med enkel visuell respons, inte ett fullskaligt fysik- eller editor-system.

**FÃ¶rebygg problem:**

- BÃ¶rja inte med fri mÃ¶blering. Det skapar direkt krav pÃ¥ layout, snap-logik, lagring och Ã¥terstÃ¤llning.
- LÃ¥t inte campet bli ett separat progressionstrÃ¤d. Det ska bygga ovanpÃ¥ samma reward- och inventorymodell som redan finns.

**Klart nÃ¤r:**

- HemskÃ¤rmen kÃ¤nns tydligt mer vÃ¤rldslik utan att bli tyngre att fÃ¶rstÃ¥.
- Minst ett upplÃ¥st objekt kan visas konsekvent i campet.

---

## v1.6.1 â€“ FÃ¶ljeslagare och samlarobjekt

**NÃ¤r:** Direkt efter v1.6.0 om inventory-modellen hÃ¥ller.  
**TidsfÃ¶nster:** 1â€“2 veckor.

**ProduktmÃ¥l:** Bredda belÃ¶ningar utan att uppfinna Ã¤nnu ett parallellt system.

**Vad som ingÃ¥r:**

- Ett fÃ¶rsta pet-slot.
- Ett enkelt klistermÃ¤rkesalbum eller badge-flÃ¶de.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. Ã…teranvÃ¤nd inventory-strukturen frÃ¥n v1.4.1.
2. BegrÃ¤nsa fÃ¶rsta pet-slicen till en visuell plats och ett fÃ¥tal items.
3. LÃ¥t achievement-/badge-flÃ¶det bygga vidare pÃ¥ `AchievementService` i stÃ¤llet fÃ¶r att skapa en separat progressionstjÃ¤nst direkt.

**FÃ¶rebygg problem:**

- Skapa inte ett helt nytt pets-system med egen lagring om samma inventorymodell rÃ¤cker.
- LÃ¥t inte albumet bli ett vuxet checklistesystem. Det ska vara begripligt fÃ¶r barn.

**Klart nÃ¤r:**

- En pet och ett enkelt badge-/albumflÃ¶de fungerar utan att komplicera kÃ¤rnloopen.

---

## v1.7.0 â€“ FÃ¶rsta minspelet

**NÃ¤r:** Efter att metaspel och inventory inte lÃ¤ngre skapar regressionsarbete.  
**TidsfÃ¶nster:** 2â€“4 veckor.

**ProduktmÃ¥l:** Bryta upp quizformatet med exakt ett minispel som stÃ¤rker retention eller repetition.

**Vad som ingÃ¥r:**

- Ett minispel, inte flera.
- Egen results-loop.
- Merge tillbaka till samma profil- och progressionssystem som quiz anvÃ¤nder.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. VÃ¤lj minispel utifrÃ¥n verkligt behov i mÃ¤tetalen, inte bara idÃ©styrka.
2. Bygg det som en egen feature med minsta mÃ¶jliga koppling till resten.
3. Ã…teranvÃ¤nd existerande difficulty- och feedbacklogik nÃ¤r det Ã¤r rimligt.
4. LÃ¤gg till lokala analytics fÃ¶r start, completion och abandon Ã¤ven hÃ¤r.

**FÃ¶rebygg problem:**

- Bygg inte fyra minispel samtidigt.
- Undvik specialfall i `QuizNotifier` om minspelet egentligen fÃ¶rtjÃ¤nar ett eget notifier-flÃ¶de.

**Klart nÃ¤r:**

- Ett minispel kan spelas, slutfÃ¶ras och spara tillbaka relevant progression utan specialtrassel i resten av appen.

---

## v1.7.1 â€“ Pedagogiska hjÃ¤lpmedel

**NÃ¤r:** Efter fÃ¶rsta minspelet eller tidigare om data visar tydliga fastkÃ¶rningar i quiz.  
**TidsfÃ¶nster:** 1â€“2 veckor.

**ProduktmÃ¥l:** Ge barnet hjÃ¤lp nÃ¤r det behÃ¶vs, utan att fÃ¶rstÃ¶ra tempo eller sjÃ¤lvfÃ¶rtroende.

**Vad som ingÃ¥r:**

- Tipp-kort eller korta fÃ¶rklaringar.
- Tallinje eller annan visuell stÃ¶dmodell fÃ¶r de operationer dÃ¤r barnet ofta fastnar.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. Visa stÃ¶det fÃ¶rst vid tydliga struggle-signaler: flera fel, lÃ¥ng svarstid eller lÃ¥g sÃ¤kerhet i samma mÃ¶nster.
2. BÃ¶rja med en operation dÃ¤r nyttan Ã¤r hÃ¶gst.
3. MÃ¤t om hjÃ¤lpen faktiskt leder till slutfÃ¶rda sessioner.

**FÃ¶rebygg problem:**

- Visa inte hjÃ¤lpen konstant. DÃ¥ blir den bakgrundsbrus.
- GÃ¶r inte hjÃ¤lpen till vuxenfÃ¶rklaring. Den mÃ¥ste vara kort, visuell och handlingsbar.

**Klart nÃ¤r:**

- StÃ¶det hjÃ¤lper utan att stÃ¶ra.
- Barn med Ã¥terkommande svÃ¥righeter kommer lÃ¤ttare vidare i quizflÃ¶det.

---

## v1.8â€“v1.9 â€“ FÃ¶rdjupning, polish och ny biome

**NÃ¤r:** FÃ¶rst nÃ¤r v1.4â€“v1.7 faktiskt har fÃ¶rbÃ¤ttrat kÃ¤rnmÃ¤tetalen.  
**TidsfÃ¶nster:** 4â€“8 veckor totalt, uppdelat i mindre releaser.

**Vad som kan ingÃ¥:**

- Ny biome i Story Map.
- Fler camp-objekt och polish.
- Ytterligare ett minispel om det fÃ¶rsta verkligen fungerar.
- Ett strikt valfritt experimentspÃ¥r som lokal, generisk leaderboard.

**Regel fÃ¶r experiment i denna fas:**

- Allt som inte direkt stÃ¤rker retention, pedagogik eller begriplighet ska behandlas som experiment.
- Ett experiment mÃ¥ste kunna tas bort utan att pÃ¥verka kÃ¤rnloopen.

**COPPA-notering:** Om ett lokalt leaderboard-experiment byggs fÃ¥r botar inte presenteras som verkliga barn eller sociala motspelare.

---

## v2.0+ â€“ Planerade leveranser vs forskningsspÃ¥r

Vi ska skilja pÃ¥ sÃ¥dant som Ã¤r rimligt att planera och sÃ¥dant som Ã¤nnu Ã¤r research.

### Planerad leverans: Offline-TTS fÃ¶r tillgÃ¤nglighet

**NÃ¤r:** Tidigast efter att v1.7.x Ã¤r stabil och vi vet att kÃ¤rnloopen hÃ¥ller.  
**TidsfÃ¶nster:** 1 vecka spike + 1â€“2 veckor produktifiering.

**VarfÃ¶r:** TTS Ã¤r ett tydligt tillgÃ¤nglighetslyft och passar offline-first bÃ¤ttre Ã¤n mÃ¥nga andra â€œAIâ€-spÃ¥r.

**SÃ¥ gÃ¥r vi tillvÃ¤ga:**

1. Bygg fÃ¶rst en spike pÃ¥ Android.
2. Verifiera vilka sprÃ¥k och rÃ¶ster som faktiskt finns installerade pÃ¥ vÃ¥ra mÃ¥lenheter.
3. BÃ¶rja med upplÃ¤sning av frÃ¥ga och kort feedback, inte hela appen.
4. LÃ¤gg funktionen bakom tydlig instÃ¤llning i fÃ¶rÃ¤ldralÃ¤ge eller tillgÃ¤nglighetslÃ¤ge.

**Best way enligt extern vÃ¤gledning:**

- `flutter_tts` krÃ¤ver minst Android SDK 21.
- FÃ¶r Android 11+ anger pluginets dokumentation att TTS-service ska deklareras i manifestets `queries` om appen anvÃ¤nder text-till-tal.
- Pluginets pausstÃ¶d pÃ¥ Android bygger pÃ¥ workaround och fungerar fÃ¶rst frÃ¥n API 26+. Planera dÃ¤rfÃ¶r inte beroende logik kring â€œpause/resume narrationâ€ pÃ¥ lÃ¤gre Android-versioner.

**FÃ¶rebygg problem:**

- Blockera inte UI pÃ¥ speak-completion.
- Blanda inte TTS, celebration-ljud och musik utan att bestÃ¤mma prioritet i ljudflÃ¶det.
- GÃ¶r sprÃ¥kdetektion och fallback tydlig. Appen fÃ¥r inte bli tyst utan begriplig Ã¥terkoppling.

### ForskningsspÃ¥r: Handskrift och sifferigenkÃ¤nning

**NÃ¤r:** FÃ¶rst efter en separat spike. Inte som planerad huvudleverans nu.

**Nuvarande bedÃ¶mning:**

- Google ML Kit Digital Ink Ã¤r mer lovande Ã¤n att direkt bygga egen modell, eftersom den Ã¤r gjord fÃ¶r streckdata, kÃ¶r on-device och stÃ¶der mÃ¥nga sprÃ¥k.
- Samtidigt sÃ¤ger ML Kit-dokumentationen att sprÃ¥kmodeller hÃ¥lls smÃ¥ genom dynamisk nedladdning av sprÃ¥kpaket. Det gÃ¶r att spÃ¥ret inte Ã¤r ett rent offline-first-core-flÃ¶de dag ett.
- LiteRT/TensorFlow Lite Ã¤r kraftfullt, men krÃ¤ver egen modellkedja: modellval, konvertering, optimering/kvantisering, benchmark och size-budget. Det Ã¤r ett stÃ¶rre program Ã¤n en vanlig feature.

**Beslut:**

- Handskrift gÃ¥r inte in i committed roadmap fÃ¶rrÃ¤n vi har bevis fÃ¶r: rimlig modellstorlek, stabil latens pÃ¥ mÃ¥lenheter och ett fÃ¶rsta-lÃ¤ge som inte bryter offline-first-principen.

---

## Inte nu

Detta ska uttryckligen inte prioriteras i den hÃ¤r planen:

- molnsync och kontoberoenden
- riktiga sociala funktioner
- leaderboard som kÃ¤rnfeature
- ny mascot-runtime utanfÃ¶r SVG-first-spÃ¥ret
- stora ML-funktioner i kÃ¤rnflÃ¶det innan vi har lÃ¶st offline- och size-frÃ¥gor
- flera minispel samtidigt

---

## Samlad tidslinje

FÃ¶r ett litet team Ã¤r detta den rekommenderade ordningen:

1. **Fas 0**: 3â€“5 arbetsdagar
2. **v1.4.0**: 1â€“2 veckor
3. **v1.4.1**: 1 vecka
4. **v1.5.0**: 2â€“3 veckor
5. **v1.6.0**: 2â€“3 veckor
6. **v1.6.1**: 1â€“2 veckor
7. **v1.7.0**: 2â€“4 veckor
8. **v1.7.1**: 1â€“2 veckor
9. **v1.8â€“v1.9**: delas upp i smÃ¥ releaser efter mÃ¤tetal
10. **v2.0+**: TTS som planerat spÃ¥r, handskrift som separat research-spÃ¥r

Det hÃ¤r betyder i praktiken att det viktigaste under de nÃ¤rmaste 6â€“10 veckorna Ã¤r: `juice -> reward-MVP -> profiler/resume/SRS`.

---

## Externa kÃ¤llor som styr rekommendationerna

FÃ¶ljande vÃ¤gledning anvÃ¤ndes nÃ¤r denna roadmap skrevs om:

- Flutter animations docs: vÃ¤lj enklaste fungerande animationsapproach fÃ¶rst
- Flutter `HapticFeedback`: anvÃ¤nd plattformens standardfeedback sparsamt
- `audioplayers` getting started: separera spelare efter ansvar, anvÃ¤nd low latency bara fÃ¶r korta SFX
- Riverpod `family` och DO/DON'T: anvÃ¤nd stabila parametrar, undvik widget-init och ephemeral state i providers
- Flutter `DragTarget`: anvÃ¤nd moderna callbacks med details
- `flutter_tts` README: Android-krav, queries-deklaration och begrÃ¤nsningar fÃ¶r pause
- ML Kit Digital Ink: offline recognition pÃ¥ streckdata men smÃ¥ sprÃ¥kmodeller via dynamisk nedladdning
- LiteRT guide: ML-spÃ¥r krÃ¤ver modellanskaffning, optimering och benchmark innan produktplanering
