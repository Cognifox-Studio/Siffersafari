# Session Status Brief

> Syfte: Sammanfattar aktuellt projektläge, pågående arbete, och nästa steg för att underlätta kontextöverföring mellan sessioner.
>
> Uppdateras efter större milestones. Historiska beslut finns i docs/DECISIONS_LOG.md.

---

## Nuläge (2026-05-09)

**Version:** 1.4.0+15
**Tester:** Alla 190 tester passerar ✅  
**flutter analyze:** 0 fel ✅  
**Integration smoke:** 3/3 passed (FULL_SMOKE=false) ✅  

### Senaste leveranser

**2026-05-10 – Haptik, Confetti, Resume Quiz och Camp-grund**
- **Camp-grund:** Introducerade `CampSceneView` som en dedikerad bas på hemskärmen.
- **Resume Quiz:** Löst imperativt genom att kolla om session state finns, i stället för att införa ny formaliserad flow-state.
- **Belöningar:** Lagt till haptisk feedback och Confetti-effekter (partiklarsystem) för lyckade quiz-slut.
- **Prestandaoptimering:** Åtgärdade prestandaläckage genom att införa `cacheHeight` för avatarrenderaren (`GameCharacter`).

**2026-05-09 – UI-förenkling av Hemskärm & Quiz**
- **Quiz:** Tog bort onödig hjälpinformation ("Hur mycket blir det?", "Läs och räkna") från frågekortet.
- **Svarsalternativ:** Tog bort extra-etiketter ("Tryck", "Valt", "Svar") under siffran. Tvingade fram en 2x2 grid (istället för kolumn på små skärmar) så användaren aldrig behöver scrolla för att se alla svarsalternativ.
- **Hemskärm:** Tog bort "Fortsätt" (Primary Play Action) som dök upp högst upp på Hemskärmen baserat på story progress eller daily challenge.
- **Daily Challenge:** Tog helt bort "Dagens runda" från Hemskärmen. Fokus på hemskärmen är nu endast "Spela" via de fyra räknesätten (Grid) samt maskoten och profilen. UI:t är extremt avskalat.

**2026-05-06 – Hemskärm & Garderobens UI-logik**
- **Hemskärmslayout (Home Screen):** Förenklad layout genom att centrera spelets logga och minimera onödigt vertikalt utrymme.
- **Större Maskot:** Siffersafari-maskoten Loke gjordes väsentligt mycket större på hemskärmen (SizedBox höjd 190/210 i hemskärmen).
- **Garderobsfunktion (WardrobeDialog):** Återställde och kopplade ihop garderoben med Home Screen via maskotens `onTap`. När man klickar på apan öppnas profilens inventarie-fönster (Wardrobe).
- **Riverpod State Propagation:** Rättade ett data-flödesfel där Lokes karaktärsvy (`GameCharacter`) i hemskärmen inte uppdaterades när ny utrustning (till exempel hatten) tog på sig. Man tryckte in `user.equippedItems` till `GameCharacter()`.
- **Clip.none för Stack:** Rättade problem med avklippta items, till exempel en hatt på huvudet, genom att lägga till `clipBehavior: Clip.none` på maskotens renderande `Stack`.

**2026-05-05 – UI Assets & Instruktionssanering**
- **Grafiska UI-ikoner:** Bytt ut Flutter standardikoner (även emojis) mot anpassade PNG-ikoner (ex. `ic_math_addition.png`, `img_avatar_animal.png`) i Home och Profile för att ge appen en mjukare trä/safari-känsla.
- **Skapa-bildbeställning:** Uppdaterat `.github/skills/skapa-bildbestallning/SKILL.md` för att tvinga AI-bildverktyg till rätt platt 2D-stil, exakta UI-mått och tydliga Markdown-tabeller för nya beställningar.
- **Nya Copilot-instruktioner:** Lagt till formella agent-instruktioner för navigering (`regler-for-app-navigation`), formulär/validering (`regler-for-formular-och-validering`) samt async/laddning (`regler-for-async-och-loading`) och kopplat dessa till `copilot-instructions.md`.
- **Customization-härdning:** Städade hela `.github`-lagret så att instructions, skills, agents och promptar nu speglar repoets faktiska nuläge. Skill-namn matchar mappnamn, stale referenser togs bort och agent/prompt-routing pekar nu på verkliga filer i repot.

**2026-05-03 – Karaktär & UI Asset Uppstädning**
- **Bytt namn & runtime för Maskot:** Maskoten är formellt omdöpt till Loke i appen (AppConstants.mascotName = 'Loke'). Vi bytte även den gröna SVG-baserade fallbacklådan (Ville) till en fullt frilagd loke.png.
- **Förenklad Maskotanimation:** Skrotade komplicerad SVG-parsad pose-logik för Lokes idle state. Använder istället enkla matematiska (sin/cos) transformationer i Flutters AnimatedBuilder för att ge honom en livfull idle-animation ("breathing").
- **Custom Karta & Belöningar:** Lade in anpassade PNG-ikoner i story_map_screen.dart (cabin.png, campfire.png) i stället för standardikoner. Förberedelser gjorda inför belönings-MVP (Safarihatt, Hänglås etc.).
- **Svensk Agentlokalisering:** Döpte om .github/skills/ och .github/instructions/ filnamn till svenska för att matcha förväntningar och rensade bort utfasade konfigurationsfiler.

**2026-05-01 – Play Console Compliance & v1.3.6**
- Systematisk utrensning av ota_update och behörigheten REQUEST_INSTALL_PACKAGES i Android-manifestet för att uppfylla Plays rigorösa barnpolicy (COPPA).
- Genererade App Bundle (v1.3.6+14) för sluten alfatestning.

**2026-04-18 – Teknisk sanering och Mocks-centralisering**
- **Borttagning av Lottie/Rive**: Omfattande rensning av gamla Lottie- och Rive-beroenden från pubspec.yaml, testfiler och `tools/pipeline.py`. Endast procedurgenererade karaktärer är nu kvar som primär asset-runtime.
- **Centraliserade Mocks**: Flyttade utspridda fakes/mocks till gemensamma `test/test_utils.dart` för att undvika kodduplicering.


---

## Nästa steg (v1.4.1 Reward MVP)

### Aktuell fas: Reward MVP (Polering)
- Vi har apan (Loke), inventory-modellen och wardrobe-dialogen i fungerande skick. `user.equippedItems` passas numera framgångsrikt till UI-skärmarna.
- Belönings-MVP: Nästa steg är att polera upplåsnings-flödet och bekräfta hur items låses upp ordentligt genom spelets progression. All konfiguration finns redo under app_constants.dart (wardrobe items).
- Vi bör eventuellt validera att eventuella nya wardrobe items inte buggar i andra vyer än Home Screen, ex. Quiz-slutet.

---

## Stabila beslut (sammanfattning)
Se docs/DECISIONS_LOG.md för fullständig historik. Nyckelbeslut:
- COPPA-compliance först, inga trackers eller auto-update bibliotek [2026-05-01].
- PNG-first + procedural scale för enkel 2D maskotruntime [2026-05-03]. (SVG och Rive är utfasade).
- Riverpod + GetIt + Hive
- Feature-first UI-struktur (lib/features/)
- Hybrid adaptiv svårighet (micro + macro + cooldown)
- Daily Challenge personaliseras via getTodaysChallengeForUser (mastery + operationDifficultySteps)
