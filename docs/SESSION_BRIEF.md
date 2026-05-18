# Session Status Brief

> Syfte: Sammanfattar aktuellt projektläge, pågående arbete, och nästa steg för att underlätta kontextöverföring mellan sessioner.
>
> Uppdateras efter större milestones. Historiska beslut finns i docs/DECISIONS_LOG.md.

---

## Nuläge (2026-05-16)

**Version:** 1.4.1+17
**Tester:** Reward-svit, `app_quiz_flow`, core smoke och screenshot-integration passerar ✅  
**flutter analyze:** Global analyze passerar utan issues ✅  
**Integration smoke:** Core smoke passerar på Android-emulator ✅  

### Senaste leveranser

**2026-05-16 – Episode 1 i djungeln känns nu som en sammanhållen första episod**
- **Story-first start:** `HomeScreen`, `HomeStoryProgressCard`, `InitialProfileSetupScreen` och `create_user_dialog.dart` pekar nu tydligare mot aktivt uppdrag, enklare första minut och barnvänligare figurval.
- **Lätt aktlager ovanpå befintlig path:** `StoryProgress` och `StoryProgressionService` bär nu `Akt X av Y`, akt-copy och ett explicit `Djungeln klar!`-slutläge utan ny persistens eller nytt progressionsträd.
- **Karta och resultat hänger ihop:** `StoryMapScreen` visar nu episodrytm i hero- och nu/sedan-panelerna, och `ResultsScreen` prioriterar storyfortsättning med `Fortsätt storyn` eller episodepilog före replayvalen.
- **Verifiering:** `app_home_test.dart`, `app_onboarding_test.dart`, `app_results_test.dart`, `results_screen_test.dart`, `app_quiz_flow_test.dart`, `story_progression_service_test.dart`, `quest_progression_service_test.dart`, `flutter analyze` och `scripts/flutter_pixel6.ps1 -Action sync` passerar.

**2026-05-16 – theme-lagret delades upp i semantiska tokens och assets**
- **Hybrid theme-lager:** `AppThemeColors` ar nu en `ThemeExtension` for semantiska farg-, panel- och progress-tokens, medan `AppThemeConfig` fortsatt ager assetval och `ThemeData`-bygget.
- **Settings visar bara verkliga teman:** `SettingsScreen` listar nu bara `Djungel` och `Rymd`, och profiler med gamla `underwater`/`fantasy` fallbackar deterministiskt till `Rymd` i runtime.
- **Verifiering:** `app_home_test.dart`, `settings_screen_test.dart` och `flutter analyze` passerar.

**2026-05-16 – story/quest-pathen fick fast skala per nivåspann**
- **Samma karta, tydligare storlek:** `QuestProgressionService` normaliserar nu pathen efter grade- och operationsfilter till minst 10 stopp for easy-only-path och 30 stopp nar medium ar med.
- **Ingen ny story-persistens:** Om den filtrerade questpoolen ar for kort skapas deterministiska sena delstopp med `__del_N` i samma befintliga service i stallet for ny provider eller nytt storytrad.
- **Verifiering:** `quest_progression_service_test.dart`, `story_progression_service_test.dart`, `user_quest_completion_event_test.dart`, `flutter analyze` och Pixel_6 sync passerar.

**2026-05-16 – profilstart och hemhierarki forenklades**
- **Onboarding ager nu arskursen:** `create_user_dialog.dart` samlar bara namn + figur och skapar profilen med `AgeGroup.young`; `OnboardingScreen` satter sedan arskurs och effektiv `ageGroup`.
- **Home och story blev tydligare:** Hemskarmen prioriterar nu `Välj räknesätt` och lagger storykort + badgealbum under `Mer att göra`, medan `StoryMapScreen`-CTA:n `Spela nästa stopp` startar questet direkt i stallet for att bara stanga kartflodet.
- **Verifiering:** `app_onboarding_test.dart`, `app_home_test.dart`, `settings_screen_test.dart`, `app_parent_mode_test.dart`, `app_results_test.dart`, `results_screen_test.dart`, `quiz_screen_tts_test.dart`, `flutter analyze` och Pixel_6 sync passerar.

**2026-05-14 – första offline-TTS-slicen är landad**
- **Profilscopad uppläsning i Föräldraläge:** `ParentDashboardScreen` har nu en `Uppläsning`-toggle som sparas per profil via `ttsEnabledProvider`.
- **Quizet kan läsa upp fråga och kort feedback:** `QuizScreen` visar nu `Läs upp` när funktionen är på och använder `TextToSpeechService` för både frågan och den korta feedbacksammanfattningen.
- **Verifiering:** `tts_enabled_provider_test.dart`, `quiz_screen_tts_test.dart`, `app_parent_mode_test.dart`, riktad analyze på TTS-filerna och Pixel_6 sync passerar.

**2026-05-14 – biome-previewen blev datadriven**
- **Samma nästa-biome-data i hem och story:** `StoryProgressionService` bygger nu `StoryProgress.nextBiome`, och både `HomeStoryProgressCard` och `StoryMapScreen` läser samma preview i stället för att bära egen hårdkodad biome-copy.
- **Fortfarande read-only och låg risk:** Ingen ny persistens, inga nya providers och ingen ny progression skrivs till disk. Det är fortfarande en read-only berättelsesignal ovanpå befintlig quest-status.
- **Verifiering:** `story_progression_service_test.dart`, `app_home_test.dart` och riktad analyze på story-slicen passerar.

**2026-05-14 – pedagogisk quizhjälp täcker nu alla fyra räknesätt**
- **Hjälpen stannar i samma feedbackväg:** `FeedbackService` bär nu både tallinje för addition/subtraktion och grupperad hjälp för multiplikation/division i samma `FeedbackResult`.
- **Dialogen visar rätt stödmodell per operation:** `FeedbackDialog` renderar nu antingen `numberLine` eller `groupModel`, utan ny quiz-state eller separat coachningssystem.
- **Verifiering:** `feedback_service_test.dart`, `feedback_dialog_test.dart` och riktad analyze på feedback-slicen passerar.

**2026-05-14 – v1.8 biome-signalen nådde hemkortet**
- **Nästa biome syns nu även på hemskärmen:** `HomeStoryProgressCard` visar nu en liten låst chip för `Nattskogen`, så nästa värld anas redan innan barnet öppnar storykartan.
- **Samma signal i två närliggande ytor:** Hemkortet och `StoryMapScreen` använder nu samma lilla biome-preview-tanke utan att införa ny progression, nya providers eller nya assets.
- **Verifiering:** `app_home_test.dart`, riktad analyze på `home_story_progress_card.dart` + home-testet och Pixel_6 sync passerar. Home-testet verifierar nu även biome-chipen på hemkortet före kartnavigationen.

**2026-05-13 – v1.8 storykartan fick ett litet nästa-biome-paket**
- **Nästa biome syns nu på flera nivåer i kartan:** `StoryMapScreen` visar nu nästa biome som ett låst chip i hero-delen, en separat teaserpanel under `Nästa stopp` och en låst preview-rad i listan under `Fler stopp`.
- **Fortfarande bara presentationslager:** Allt är fortfarande hårt avgränsat till storykartans UI. Ingen ny progression, inga nya providers och inga nya assets krävdes för att ge tydligare känsla av vad som väntar efter djungeln.
- **Verifiering:** `app_home_test.dart`, riktad analyze på `story_map_screen.dart` + home-testet och Pixel_6 sync passerar. Home-testet verifierar nu hero-chip, teaserpanel och list-preview i samma kartflöde.

**2026-05-13 – v1.8 första biome-teasern landad på storykartan**
- **Storykartan antyder nu nästa större plats:** `StoryMapScreen` visar nu en liten låst teaser för en kommande biome direkt under panelen för nästa stopp, i stället för att bara visa den nuvarande djungelsträckan.
- **Slicen hålls helt i presentationen:** Teasern kräver ingen ny progression, inga nya providers och inga nya assets. Den fungerar som en enkel visuell krok med kort copy och låst markering.
- **Verifiering:** `app_home_test.dart`, riktad analyze på `story_map_screen.dart` + home-testet och Pixel_6 sync passerar. Home-testet verifierar att kartan öppnas och att biome-teasern faktiskt syns.

**2026-05-13 – v1.8 camp-polish fortsatte med tydligare samlingssignal**
- **Campet visar nu också hur mycket barnet redan samlat:** `CampSceneView` har fått en liten badge som visar antal upplåsta camp-saker direkt i scenen.
- **Dold rest blir synlig utan nytt system:** När fler saker är upplåsta än vad som ryms i scenen visas en kort `+N till`-signal i samma badge, så campet känns levande även när alla rewards inte får plats samtidigt.
- **Verifiering:** `app_home_test.dart`, riktad analyze på `camp_scene_view.dart` + home-testet och Pixel_6 sync passerar. Widgettest skyddar både badge-texten och overflow-fallet.

**2026-05-13 – v1.8 första camp-polish-slice landad på hemskärmen**
- **Fler upplåsta saker syns i campet:** `CampSceneView` visar nu upp till fyra vanliga reward-props i stället för att stanna vid två, så camp-progressionen fortsätter synas när fler items låses upp.
- **Pet-spåret hålls separat:** Campets vanliga prop-lista filtrerar nu bort pets, så följeslagare fortsätter visas endast i pet-slotten och inte dupliceras som vanliga podium-objekt.
- **Verifiering:** `app_home_test.dart`, riktad analyze på `camp_scene_view.dart` + home-testet och Pixel_6 sync passerar. Widgettest skyddar både fler visade props och att pet inte renderas dubbelt.

**2026-05-13 – v1.7.0 pedagogiska hjälpmedel landade i quiz-feedbacken**
- **Pedagogisk hjälp stannar i befintlig feedbackväg:** `FeedbackService` lägger nu till en kort `💡`-tråd och strukturerad tallinjedata direkt i `FeedbackResult` i stället för att införa ny quiz-UI-state eller ett separat hjälpsystem.
- **Två grundoperationer täcks i samma lilla system:** Addition och subtraktion visar nu samma typ av hjälp vid fel svar eller långsam men korrekt lösning. `FeedbackDialog` renderar en gemensam tallinje med tydlig startmarkör och rätt riktning framåt eller tillbaka beroende på operation.
- **Verifiering:** `feedback_service_test.dart`, `feedback_dialog_test.dart`, `app_quiz_flow_test.dart`, riktad analyze på hjälptråds-/dialogfilerna och Pixel_6 sync passerar. Tester täcker både addition och subtraktion medan övriga räknesätt fortfarande lämnas utan extra tallinje.

**2026-05-13 – v1.6.1 första pet-slot landad i campet**
- **Campet har nu en följeslagarplats:** `CampSceneView` visar nu en liten pet-slot med låst plats som standard och en synlig följeslagare när ett camp-pet-item finns i `unlockedItems`.
- **Samma inventory-modell, ingen ny pet-persistens:** Ett första pet-item ligger nu i reward-/inventory-ordningen men är markerat som camp-only, så det kan visas i campet utan att skapa ett separat pets-system eller störa garderobens nuvarande UI.
- **Verifiering:** `app_home_test.dart`, `inventory_reward_unlock_test.dart`, `wardrobe_hit_shape_audit_test.dart`, riktad analyze på ändrade filer och Pixel_6 sync passerar.

**2026-05-13 – v1.6.1 första badgealbum-slice landad på hemvyn**
- **Badgealbum utan ny persistens:** Hemskärmen visar nu en enkel märkespanel som bygger direkt på `UserProgress.achievements` och `AchievementService` i stället för ett nytt samlarsystem.
- **Earned + locked i samma vy:** Panelen visar upplåsta märken med egna symboler och återstående märken som låsta platser, så barnet får en enkel samlingskänsla utan att lämna hemskärmen.
- **Verifiering:** `achievement_service_test.dart`, `app_home_test.dart`, riktad analyze på ändrade badge/home-filer och Pixel_6 sync passerar.

**2026-05-13 – v1.6.0 första verkliga camp-slice landad på hemskärmen**
- **Campet är inte längre en placeholder:** `CampSceneView` visar nu en riktig liten camp-yta med `cabin.png` och `campfire.png` i stället för placeholder-text och hårdkodade ikonrutor.
- **Upplåsta rewards syns i hemmet:** De första upplåsta inventory-föremålen visas nu konsekvent som små camp-props, styrda av befintlig reward-/inventory-ordning i stället för separat camp-state.
- **Verifiering:** `app_home_test.dart` täcker nu att ett upplåst objekt faktiskt syns i campet, ändrade filer är fria från nya fel, och Pixel_6 sync/install/start passerade efter UI-ändringen.

**2026-05-12 – Reward MVP verifierad och integrationstester härdade**
- **Explicit unlock-ordning för rewards:** Upplåsning av inventory-items vid level up styrs nu av en explicit reward-ordning i stället för att råka följa render/grid-listan. Det gör reward-progressionen stabil när fler items läggs till.
- **Resultatvy med riktat regressionsskydd:** Lade ett widgettest som verifierar att upplåst item-banner faktiskt syns i `ResultsScreen` efter level up och att itemet persisteras till profilen.
- **Quiz/result merge verifierad:** Lade fokuserade logiktester för `applyQuizResult(...)` och reward-upplåsning så att både state och diskpersistens skyddas.
- **Integrationstest härdade:** `app_smoke_test.dart` och `screenshots_test.dart` känner nu igen quizvyn via en robust UI-signatur i stället för skör textmatchning mot `Fråga `. Detta löste falska "fastnat"-fel på Android-emulatorn.
- **Renare testutdata:** Den kända benign teardown-varningen för testanimationer tystas nu i testbindingar, så gröna integrationstestkörningar inte ser trasiga ut.

**2026-05-12 – v1.5.0 påbörjad: deterministisk resume-data per profil**
- **Repository-lager:** `LocalStorageRepository.getQuizSession(...)` väljer nu senaste giltiga in-progress-session deterministiskt för en profil, och kan även filtrera på specifikt räknesätt.
- **Provider-lager:** `QuizNotifier` har nu en liten resume-entrypoint som återupptar senaste giltiga session för vald profil via repository-lagret i stället för att lämna resume-resolution till UI.
- **Regressionsskydd:** Lade fokuserade tester för flera samtidiga in-progress-sessioner per profil, så resume inte blir godtyckligt när barnet hunnit påbörja olika räknesätt lokalt.

**2026-05-12 – v1.5.0 fortsättning: resume fungerar nu även från hemflödet**
- **In-progress sparas redan vid quizstart:** `QuizNotifier` persisterar nu en riktig resumebar session direkt när ett quiz aktiveras, inte först efter första svaret. Det gör resume möjligt även om barnet lämnar väldigt tidigt.
- **Avbrott raderar inte längre resume-underlaget:** `cancelSession(...)` slutar ta bort den deterministiska in-progress-posten, så ett avbrutet quiz kan återupptas i stället för att försvinna från disk.
- **Hemskärmens primärknapp återanvänder resume:** Primär-CTA på Home visar nu `Fortsätt` när en sparad session finns och går då via `resumeLatestSessionForUser(...)` i stället för att alltid starta ett nytt quiz.
- **Verifiering:** Riktade tester för `quiz_progression_edge_cases.dart`, `app_home_test.dart`, `app_quiz_flow_test.dart` och `flutter analyze` passerar.

**2026-05-12 – v1.5.0 fortsättning: föräldrainställningar är nu strikt profilscopade i Riverpod**
- **Family-provider per profil:** `parentSettingsProvider` använder nu `userId` som stabil family-nyckel i stället för en delad map-provider. Det gör allowed operations tydligt ägda per profil och ligger i linje med roadmapens profilscoping.
- **UI:t slutade hydrera föräldrainställningar manuellt:** Home, Parent Dashboard, Story Progress, Onboarding och Results läser nu direkt den profilscopade providern i stället för att först göra separata `load/ensureLoaded`-anrop.
- **Regressionsskydd:** Lade ett fokuserat unit-test som verifierar att två profiler kan bära olika allowed-operations samtidigt utan att state blandas ihop, samt körde berörda widgettester för Home och Results.
- **Verifiering:** `parent_settings_provider_test.dart`, `app_home_test.dart`, `results_screen_test.dart` och `flutter analyze` passerar.

**2026-05-12 – v1.5.0 fortsättning: profilradering och clear-all-data städar nu korrekt**
- **Central cleanup-väg i repository:** `LocalStorageRepository` har nu en explicit `deleteUserData(...)` som rensar `UserProgress`, profilens quizhistorik och alla kända profilscopade settings-nycklar, inklusive prefixbaserade daily-challenge-poster.
- **User state kan nu nollställas korrekt:** `UserState.copyWith(...)` kan nu faktiskt sätta `activeUser` och `questStatus` till `null`, vilket krävs när sista profilen raderas eller all data töms.
- **Settings-flödet gör riktiga rensningar:** `SettingsScreen` har nu fungerande `Radera profil` och `Radera all data` i stället för döda dialoger. Vid profilradering väljs nästa profil deterministiskt när en finns kvar.
- **Regressionsskydd:** Lade både en ny unit-svit för cleanup-kontraktet och ett isolerat widgettest för settings-raderingarna.
- **Verifiering:** `user_profile_cleanup_test.dart`, `user_quest_completion_event_test.dart`, `settings_screen_test.dart`, `app_home_test.dart` och `flutter analyze` passerar.

**2026-05-12 – v1.5.0 fortsättning: konkret legacy-migrering landad i SRS v2**
- **Historik-koll gav ingen nyckelalias-evidens:** Git-historiken visade att centrala profilnycklar som `onboarding_done_<userId>` och `allowed_ops_<userId>` redan använde samma prefix i äldre kod, så någon separat alias-migrering för dessa nyckelnamn visade sig inte vara den faktiska legacy-ytan.
- **Evidensbaserad migrering i stället för gissning:** Den verkliga legacy-ytan i Hive var SRS-schedule-poster med gamla displaytext-baserade review keys som `multiplication|4 × 7 = ?`. `QuizNotifier` skriver nu alltid versionsprefixade `v2|...`-nycklar och normaliserar äldre schedule-poster vid inläsning.
- **Framåtformat låst:** Sparade SRS-schedules canonicaliseras nu med samma `v2|`-nyckel i både `key` och `questionId`, så framtida cleanup och parsning slipper displaytext-gissningar.
- **Verifiering:** `quiz_provider_srs_test.dart` täcker både legacy-migrering på load och att nya schedules sparas i v2-format. `flutter analyze` passerar.

**2026-05-12 – v1.5.0 fortsättning: SRS due-kö överlever nu resume och fråga-växling**
- **Pending due-kö persisteras i in-progress-sessionen:** `QuizNotifier` sparar nu `pendingDueKeys` tillsammans med den deterministiska in-progress-posten och läser tillbaka kön defensivt vid resume.
- **Frågeväxling är nu en riktig checkpoint:** `advanceToNextQuestion()` persisterar nu uppdaterad session, så genererad due-fråga och tömd pending-kö inte bara lever i minnet mellan två svar.
- **Regressionsskydd:** `quiz_provider_srs_test.dart` täcker nu både resume före nästa due-fråga och resume efter fråga-växling. Den fokuserade SRS-sviten passerar.

**2026-05-12 – v1.5.0 fortsättning: replay-flödet konsumerar nu också SRS due-frågor**
- **Replay gick runt SRS-kön:** Den smala auditen av generator- och replay-flödet visade ingen ny konkret legacy-yta i quiz/session-data utöver den redan kända defensiva skippen för äldre sessioner utan `questions`, men däremot att `startCustomSession(...)` i replay/focus-flödet helt ignorerade due reviews.
- **Custom session använder nu due-planering:** `QuizNotifier.startCustomSession(...)` bygger nu en liten due-plan på samma schedules som vanliga sessioner, injicerar första due-frågan i replay-passet och låter återstående due-nycklar gå via `pendingDueKeys` utan att öka den totala frågelängden.
- **Regressionsskydd:** `quiz_provider_srs_test.dart` verifierar nu att replay-flödet faktiskt visar due-frågor i stället för att hoppa direkt till den skräddarsydda replay-listan. Den fokuserade SRS-sviten passerar.

**2026-05-12 – v1.5.0 fortsättning: legacy history utan questions påverkar inte längre benchmark-flöden**
- **Auditutfall:** Den återstående `questions`-lösa legacy-ytan visade sig inte kräva bred migrering. Lätta complete-poster utan `questions` är avsiktliga för parent dashboard, men gamla ofullständiga poster utan `questions` kunde fortfarande läcka in i `getQuizHistory(...)`.
- **Smal fix i repository-lagret:** `LocalStorageRepository.getQuizHistory(...)` skippar nu endast ofullständiga poster utan `questions`, så avsiktlig complete lightweight history behålls medan gamla icke-resumebara placeholder-poster inte längre påverkar benchmark och rekommendationer.
- **Regressionsskydd:** `quiz_progression_edge_cases_test.dart` verifierar nu att complete lightweight history fortfarande syns medan legacy in-progress utan `questions` filtreras bort. Fokuserad analyze på ändrade filer och edge-case-sviten passerar.

**2026-05-11 – Garderob: stabiliserad rendering, state-propagation och hit-testing**
- **Sparade item-positioner över vyer:** Fixade att hemskärmen tappade bort `customItemOffsets` till `GameCharacter`, vilket gjorde att placerade föremål visades rätt i garderoben men föll tillbaka till default-position på Home.
- **Tap på maskoten i garderoben:** Fixade att ett vanligt tryck på Loke kunde trigga `userTap`-pose utan faktisk callback. I garderoben, där `persistentReaction` används, gjorde det att utrustningen såg ut att försvinna tills posen byttes tillbaka.
- **Träffsäker draglogik:** Bytte från grov generell hit-area till item-specifika elliptiska hit-shapes i `GameCharacter`, med särskild åtstramning för glasögon och andra överlappande föremål.
- **Regressionsskydd:** Lade riktade widgettester för wardrobe-beteenden samt ett nytt audit-test som verifierar att alla aktiva wardrobe-items i inventory-listan har explicit hit-shape-täckning.

**2026-05-11 – UI Rendering Fix Wardrobe**
- **Garderobsfönster:** Löste ett problem där garderoben bara visade en svart skärm (men inga visuella fel från Flutter) på grund av en `hasSize` / `IntrinsicWidth` layout-krasch i bakgrunden. Garderobsvyn misslyckades med att mäta raden med knappar. Fixades genom att införa `Wrap` för knappar, `shrinkWrap: true` på inre scroll-vyer och gränsen `ConstrainedBox(maxWidth: 400)` runt allting. Dialogen syns nu som den ska på enheten.

**2026-05-11 – Init-audit av utvecklarytan**
- **Docs och customizations:** Synkade utvecklarlagret mot faktisk appstruktur. `docs/README.md` beskriver nu `SESSION_BRIEF.md` som aktuellt läge i stället för historisk logg, `docs/PROJECT_STRUCTURE.md` och `docs/ADD_FEATURE.md` följer feature-first-strukturen bättre, och `.github`-ytan är tydligare dokumenterad utan pensionerade prompts.

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
- **Garderobsfunktion:** Återställde och kopplade ihop garderoben med Home Screen via maskotens `onTap`. När man klickar på apan öppnas profilens inventarie-fönster.
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

## Nästa steg (efter roadmap-svepet 2026-05-14)

### Aktuell fas: kvarvarande committed roadmap-slices är nu landade
- v1.5.0:s SRS-, resume- och quiz/session-spår är fortsatt funktionellt låsta efter de senaste riktade fixarna och testerna.
- Hemskärmens camp- och samlarspår, quizets pedagogiska hjälp, storykartans biome-preview och den första offline-TTS-slicen är nu landade och verifierade i små delar.
- **Direkta nästa steg:** Nästa rimliga steg är en manuell känslokoll på enhet för TTS-röst/tempo och storykarta, därefter release-/polish-pass eller nya uttryckligt prioriterade produktmål. Undvik fortfarande stora experimentspår som leaderboard utan tydlig produktnytta.
- Behåll nuvarande guardrails: visa inte hjälpen konstant, bygg inte vuxenförklaringar och inför inte ett nytt stort hjälp- eller övningssystem utan tydlig nytta.

---

## Stabila beslut (sammanfattning)
Se docs/DECISIONS_LOG.md för fullständig historik. Nyckelbeslut:
- COPPA-compliance först, inga trackers eller auto-update bibliotek [2026-05-01].
- PNG-first + procedural scale för enkel 2D maskotruntime [2026-05-03]. (SVG och Rive är utfasade).
- Riverpod + GetIt + Hive
- Feature-first UI-struktur (lib/features/)
- Hybrid adaptiv svårighet (micro + macro + cooldown)
- Daily Challenge personaliseras via getTodaysChallengeForUser (mastery + operationDifficultySteps)
