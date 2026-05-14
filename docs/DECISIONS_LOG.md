<!--
typ: explanation
syfte: Historik, varför vi gjort vissa arkitekturval
uppdaterad: 2026-05-14
-->
# Beslut och antaganden (Siffersafari)

Syfte: samla stabila beslut utanfor chatten.
Princip: senaste datum vinner vid konflikt.

## Gällande nuläge (2026-05-14)

- Plattform: Android-first, offline-first, flera barnprofiler.
- Gränssnitt: Extremt reducerat och barnvänligt. Skärmar som Quiz och Home har städats på all överflödig text och UI för att leda fokus direkt till interaktionen.
- Arkitektur: lagerindelad Flutter-app med Riverpod + GetIt + Hive.
- Animation:
  - Procedurgenererade transformationer på enkla PNG-bilder prioriteras över komplicerad cut-out layout med SVG för mascots. Rive och Lottie är slopade.
- Responsiv layout styrs av tillganglig bredd (compact < 600, medium >= 600, expanded >= 840).
- Quizens adaptiva svarighetsmodell ar hybrid (micro + macro + cooldown) och persisteras per raknesatt.
- Distribution och uppdateringar for produktappen sker via Google Play. Inget OTA- eller in-app update-flode ar en aktiv del av produktens nulage.
- Pedagogisk quizhjälp ligger i den befintliga feedbackdialogen och använder små, strukturerade visuella stöd i stället för ett separat hjälpsystem.
- Nästa-biome-signalen ägs nu av `StoryProgressionService` och `StoryProgress.nextBiome` i stället för duplicerad, hårdkodad copy i hem- och story-UI.
- Quizhjälpen täcker nu alla fyra räknesätten i samma feedbackväg: tallinje för addition/subtraktion och grupperad hjälp för multiplikation/division.
- On-device TTS är profilscopad, föräldrastyrd och läser upp fråga/kort feedback utan att blockera UI eller kräva nät.
- Tidiga v1.8-slices för camp och storykarta hålls i presentationslagret tills tydligare produktnytta motiverar ny progression, nya providers eller nya assets.
- Copilot-customizations i `.github/` ska vara repoanknutna, länka vidare till docs i stället för att duplicera innehåll, och använda skill-namn som matchar respektive mappnamn.

## Historik (kort)

### 2026-05-14
- **Nästa biome centraliserades i read-only storydata:** När samma biome-signal började synas både på hemkortet och i storykartan flyttades den till `StoryProgressionService` som `nextBiome` i `StoryProgress`. Det minskar UI-duplicering utan att öppna ny persistens eller progression.
- **Quizhjälpen breddas utan nytt system:** Multiplikation och division lades till i samma `FeedbackService`/`FeedbackDialog`-väg i form av grupperad hjälp, i stället för att skapa ett separat coachnings- eller övningssystem för fler räknesätt.
- **TTS bakom föräldraläge och per profil:** Första uppläsningsslicen landades som en profilscopad inställning i Föräldraläge med on-device TTS i quizet. Det håller tillgänglighetsstödet offline-first och gör funktionen lätt att stänga av per barn.

### 2026-05-13
- **v1.8 hålls presentation-first:** Campets fortsatta polish och storykartans första biome-preview byggdes med små UI-slices i befintliga widgets i stället för att öppna ny progression, nya providers eller nya assetkrav direkt. Det håller risken låg medan vi provar vilken världsbyggnad som faktiskt ger produktnytta.
- **Quizhjälpen stannar i feedbackvägen:** Den första pedagogiska hjälpen för addition och subtraktion lades i `FeedbackDialog` och `FeedbackService` i stället för i ett separat övnings- eller coachningssystem. Det gör hjälpen lätt att rulla ut i små, verifierbara steg.

### 2026-05-10
- **Camp-scen layout:** Camp-scenen introducerades som en dedikerad widget (`CampSceneView`), direkt inbäddad i `HomeScreen`.
- **Resume Quiz Flow:** Implementerades implicit (genom att kolla om aktivt session state finns) istället för att lägga till en ny explicit flow-state, vilket minskar komplexiteten i navigeringen.
- **Prestandafix för GameCharacter:** För att motverka performance-läckage vid frekvent omritning av asset-lager (som uppstår när flera stora bilder ritas fram och tillbaka) sattes `cacheHeight` (och/eller width) vid rendingen.
- **Pose-specifikt inventory och fallback-keys:** Utrustning kan nu konfigureras per pose (CharacterReaction) i Garderoben och ritas ut därefter. Datapersistensen löstes genom att låta den aktuella posens namn fungera som prefix i `equippedItems`-nyckeln (ex. `answerWrong_<item_id>`). "Vanlig" (idle) har inget prefix, vilket säkerställde fullständig bakåtkompatibilitet för redan befintliga spara-filer och profiler.
- **Dolda vyer kräver prop-drilling:** All rendering av GameCharacter flyttades från lokala mock-ups till att kräva global persistens per pose (via attribut som `customItemOffsets`). 

### 2026-05-09
- **Avskalad Hemskärm & Quiz-vy:** "Dagens runda" och "Fortsätt" (Primary Action Card) togs bort helt från hemskärmen för att göra appen mer barnfokuserad, utan distractande moment. Quiz-knapparna bantades ner till renodlade grid-siffror (ingen helper-text under).

### 2026-05-05
- **Avskaffad hardware slot-injektion (Garderoben):** Tidigare logik där föremål byttes ut utifrån kroppsdel (t.ex. bara en sak på huvudet) togs bort från både domän och UI. Man kan nu fritt equippa och rendera obegränsat antal föremål samtidigt. `GameCharacter` loopar utifrån Z-index istället för hårdkodade positioner. Oanvända skript relaterade till container-patching för Rive-maskotar städades även ut i samband med detta.
- **Customization-systemet härdat:** `.github`-lagret för instructions, skills, agents och promptar sanerades så att stale referenser togs bort, relativa länkar pekar rätt och varje skill nu använder ett `name` som matchar sitt mappnamn. Detta låser discovery mot repoets faktiska filer i stället för gamla alias.

### 2026-05-03
- **Maskot-runtime bytt från SVG till PNG:** Föregående "SVG-first" beslut gav för hög komplexitet och överlappning. Mascot-runtime förenklades till en enda tajt beskuren loke.png med procedurgenererad scale/rotation i Flutter. All komposit-logik i SVG skrotades. Maskoten bytte namn permanent från Ville till Loke i hela projektet.
- **Svensk standard för Agenter:** Alla Github Copilot-instructions och SKILL.md filer bytte namn och beskrivningar till svenska för att fungera konsekvent med de globala svenskkraven för korta agent-svar.

### 2026-05-01
- **Inga autoupdates (Play COPPA):** Uppdateringar sker _endast_ via Google Play Console. Appen rullar helt bort fristående uppdateringsverktyg (ota_update) och permissions som REQUEST_INSTALL_PACKAGES.
- **Slopad bildgenerering i terminal:** Automationsverktygen för maskotskapande och riggning togs bort. Bilderna ska beställas och sparas direkt till project istället för via ett Python-mellanskikt.

### 2026-04-18
- UI-anrop via `PostFrameCallback` inuti `build()` ersattes med `ref.listen` for sidoeffekter.
- Borttagning av Lottie/Rive från primary runtime.
