<!--
typ: explanation
syfte: Plan för att färdigställa Episode 1 i djungeln och finslipa barnflödet
uppdaterad: 2026-05-16
-->

# Plan: Färdigställ Episode 1 i djungeln

> Status: Revised Draft
> Horisont: Nuvarande biom, inga nya biom-assets
> Mål: Göra djungeln till ett färdigt, releasebart Episode 1-system innan nästa värld byggs

Den här planen styr polish-arbetet för nuvarande djungelbiom. Fokus är inte att bygga fler system, utan att göra det som redan finns lättare att förstå, roligare att använda och tydligare som en sammanhållen första episod.

## Releaseobjektiv

- Göra appen lättare att förstå för barn i första sekunden.
- Göra djungeln till en sammanhållen episod, inte bara en lång rad stopp.
- Behålla interaktivitet och lust att fortsätta spela genom tydlig progression, omedelbar återkoppling och kort barnvänlig copy.
- Avsluta Episode 1 på ett sätt som känns färdigt även om nästa biom byggs senare.

## Definition av releaseklar Episode 1

- Ett barn förstår huvudspåret direkt från home.
- Djungeln känns som en episod med början, mitt och slut.
- Resultatvyn visar att världen gick framåt, inte bara att ett quiz tog slut.
- Första profilstarten är enkel, kort och lekfull.
- Sista djungelsteget ger ett tydligt avslut.
- Nästa biom antyds utan att låtsas vara spelbar redan nu.

## Verifierad nulägesbild

- Home, story map, quiz och results är redan tydligare och bygger på samma `storyProgressProvider`.
- `QuestProgressionService` normaliserar redan kartlängden till 10 eller 30 stopp beroende på svårighetsspann.
- `StoryProgressionService` har redan djungelvärld, landmarks, chapter-copy och teaser för nästa biom.
- `ResultsScreen` och `StoryMapScreen` kan redan föra barnet vidare i storyflödet, men mycket copy och CTA-hierarki är fortfarande generisk.
- Onboarding och profilsättning är förenklade, men första minuten kan fortfarande bli mer lekfull och tydlig.

## Produktprinciper

- En tydlig primär handling per vy.
- Kort copy: verb + mål.
- Progress ska kännas i världen, inte bara i statistik.
- Barnet ska förstå vad som hände, vad som händer nu och vad nästa lilla mål är.
- Motivation ska bygga på kompetens, förväntan och samlande, inte på stress, skuld eller överlastad UI.

## Psykologisk riktning

- Kompetens: barnet ska snabbt känna `jag klarade det`.
- Förväntan: nästa lilla mål ska alltid vara synligt men inte överlastat.
- Identitet: figur, camp och story ska kännas som barnets egen resa.
- Samlande: små tydliga framsteg är bättre än många parallella belöningar.

## Externt verifierade krav för denna revision

Planen är skärpt mot verifierad vägledning från Flutter docs, Nielsen Norman Group och Self-Determination Theory.

- Tillgänglighet: tappbara mål ska vara minst `48x48`, kontrast bör nå minst `4.5:1`, och UI ska fungera vid stora textskalor.
- Kontextskiften: UI ska inte byta användarens kontext automatiskt medan information skrivs in.
- Touch first: barnflödet ska lösas för touch först och därefter kompletteras för mus och tangentbord.
- Layoutval: använd constraints och tillgänglig yta, inte device-typ eller orientering, som huvudsaklig layoutsignal.
- Progressiv visning: primärvyn ska visa det viktigaste först och sekundärt innehåll ska öppnas tydligt och sparsamt.
- Motivation: stöd för autonomi, kompetens och samhörighet ska väga tyngre än yttre kontroll eller pressande belöningar.
- Prestanda: bildtunga och animerade ytor ska undvika onödigt dyra opacity-, clipping- och rebuildmönster.

## Tvärgående kvalitetsbar före ship

- Max en visuell primär-CTA per barnvy ovanför huvudfolden.
- Inga fler än två disclosure-nivåer i barnflödet.
- Ingen viktig state ska tappas vid resize eller layoutskifte.
- Primära knappar, kartnoder och tydliga interaktionsytor ska hålla barnvänlig touchstorlek.
- Primära handlingar ska ha meningsfull semantics och gå att förstå med skärmläsare.
- Animationer får inte konkurrera med nästa steg eller skapa märkbar jank.

## I scope

- Story-first polish av home, story map, quiz-resultat och första profilstart.
- Tydligare episodstruktur ovanpå nuvarande djungelpath.
- Bättre CTA-hierarki och mer konkret copy för barn.
- Ett verkligt slut för Episode 1 i djungeln.

## Utanför scope

- Ny biom eller nya biom-assets.
- Ny story-persistens eller nytt progressionsträd.
- Större ombyggnad av navigation eller state-arkitektur.
- Mörka motivationsmönster, tidsstress eller fler samtidiga val i barnflödet.

## Beslutsgrind före varje slice

En slice får gå vidare när detta är sant:

1. Scope är liten nog att shipa separat.
2. Det är tydligt vad som uttryckligen inte ingår.
3. QA-snittet är definierat innan patch.
4. Copy, CTA-hierarki och storyeffekt pekar åt samma håll.
5. Slicen kan klara den tvärgående kvalitetsbaren utan nytt system eller ny persistens.

## Releaseordning

Planen är avsiktligt uppdelad i små releaser i stället för ett stort polish-pass.

### Release A: Story-first start och första minuten

Mål: Göra start, home och barnets första riktning tydlig direkt.

När:
- Först. Detta ger störst effekt på begriplighet med lägst arkitekturrisk.

Varför nu:
- Den största nuvarande friktionen är inte att system saknas, utan att huvudspåret fortfarande är för generiskt märkt.

Scope:
- `lib/features/home/presentation/screens/home_screen.dart`
- `lib/features/home/presentation/widgets/home_story_progress_card.dart`
- `lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart`
- `lib/features/profiles/presentation/dialogs/create_user_dialog.dart`

Implementationsordning:
1. Byt generisk primär-CTA på home till storystyrd copy när aktivt quest finns.
2. Gör storykortet mer konkret: var är jag, vad gör jag nu, vad väntar härnäst.
3. Korta första copy-stegen i initial profile setup och create-profile-flödet.
4. Behåll fri träning som sekundärt, lättåtkomligt val.
5. Säkerställ tydlig touchyta och semantics på primära handlingar och figurval.

Förebygg risker:
- Gör inte home till en ren storyskärm; räknesätten måste finnas kvar.
- Lägg inte till nya flöden eller modalsteg i första minuten.
- Använd inte längre text för att förklara sådant som kan visas som ett nästa mål.
- Låt inte story och fri träning konkurrera som två lika starka primärval.
- Undvik automatiska fokus- eller kontextskiften under textinmatning.

QA-gate:
- `test/widget/app_home_test.dart`
- `test/widget/app_onboarding_test.dart`
- `test/widget/settings_screen_test.dart`
- `flutter analyze`
- `scripts/flutter_pixel6.ps1 -Action sync`

Manuell check:
- Barnet förstår snabbt vad huvudspåret är.
- Primär CTA är lätt att träffa och lätt att läsa.
- Första minuten fungerar utan flera lika starka val samtidigt.

Klart när:
- Barnet ser direkt att `djungeln` är huvudspåret.
- Första minuten är snabbare, kortare och mer lekfull.

### Release B: Episodstruktur och karta

Mål: Göra djungeln till en riktig episod med akter i stället för en platt rad stopp.

När:
- Efter Release A, när home redan pekar tydligt mot storyn.

Varför nu:
- När home väl leder rätt måste kartan och storydatan kännas lika sammanhängande, annars tappar barnet riktning igen.

Scope:
- `lib/core/services/story_progression_service.dart`
- `lib/features/home/presentation/widgets/home_story_progress_card.dart`
- `lib/features/story/presentation/screens/story_map_screen.dart`

Implementationsordning:
1. Lägg ett lätt akt-lager ovanpå nuvarande 10/30-path.
2. Visa enkel episodsignal som `Akt X av Y` eller motsvarande i home/karta.
3. Byt eller korta generisk copy som `Fler stopp` om en tydligare etikett fungerar bättre.
4. Lyft fram nuvarande stopp och nästa stopp ännu tydligare än framtida stopp.
5. Säkerställ att sekundär information verkligen är sekundär enligt progressiv visning.

Förebygg risker:
- Bygg inte ett nytt storysystem; använd nuvarande path och landmarks.
- Rör inte questpersistens eller progressionsträd.
- Låt inte kartan få fler samtidiga paneler än i nuläget.
- Undvik en tredje disclosure-nivå under karta eller hemkort.
- Låt inte framtida stopp kräva mer uppmärksamhet än nästa stopp.

QA-gate:
- `test/unit/services/story_progression_service_test.dart`
- `test/widget/app_home_test.dart`
- `flutter analyze`
- `scripts/flutter_pixel6.ps1 -Action sync`

Manuell check:
- Barnet ser snabbt vilket stopp som är nu, vilket som är nästa och vilket som är senare.
- Kartan går att läsa utan att tolka flera textblock i följd.

Klart när:
- Djungeln känns som en episod med rytm och riktning.
- Nästa steg är enklare att läsa än resten av kartan.

### Release C: Results som storykonsekvens

Mål: Göra resultaten till en tydlig världseffekt i stället för enbart statistik och replayval.

När:
- Efter att episodstrukturen sitter i home och karta.

Varför nu:
- Först då går det att ge barnet en payoff som känns kopplad till själva djungelepisoden.

Scope:
- `lib/features/quiz/presentation/screens/results_screen.dart`

Implementationsordning:
1. Höj storyutfallet när quest progression finns.
2. Gör `fortsätt storyn` till tydlig primär handling när en storyeffekt faktiskt inträffat.
3. Behåll `Spela igen` och `Snabbträna` som sekundära val när storyn är huvudspåret.
4. Gör storypanelen mer konkret än `Nytt stopp` när tillståndet tillåter det.
5. Formulera resultatcopy så att den stödjer kompetens och framsteg, inte press eller skuld.

Förebygg risker:
- Förstör inte replay-flödet för barn som vill träna igen direkt.
- Lägg inte storystate i ny provider bara för att copy behöver bli bättre.
- Blanda inte statistik, belöning och story i tre lika starka primärpaneler.
- Låt inte belöningar bli den enda motorn; story och mästringskänsla ska bära flödet.

QA-gate:
- `test/widget/app_results_test.dart`
- `test/widget/results_screen_test.dart`
- `test/widget/app_quiz_flow_test.dart`
- `flutter analyze`
- `scripts/flutter_pixel6.ps1 -Action sync`

Manuell check:
- Resultatskärmen svarar tydligt på `vad hände nu?` och `vad gör jag härnäst?`.
- Flödet känns uppmuntrande även efter svagare resultat.

Klart när:
- Barnet förstår att quizet flyttade storyn framåt.
- Resultatskärmen leder naturligt tillbaka in i djungelspåret.

### Release D: Episode 1-slutläge

Mål: Ge djungeln ett verkligt avslut innan nästa biom byggs.

När:
- Sist. Detta ska landa först när tidigare slices redan gjort storyn tydlig.

Varför nu:
- Ett slutläge känns bara trovärdigt när barnets väg genom episoden redan är tydlig och konsekvent.

Scope:
- `lib/core/services/story_progression_service.dart`
- `lib/features/quiz/presentation/screens/results_screen.dart`
- `lib/features/story/presentation/screens/story_map_screen.dart`
- eventuellt `lib/features/home/presentation/widgets/home_story_progress_card.dart`

Implementationsordning:
1. Lägg ett tydligt `Djungeln klar`-tillstånd i storyn.
2. Byt sista payoff från generell teaser till avslutssignal för Episode 1.
3. Om nästa biom teasas, gör det som `kommer senare` och inte som redo nästa steg.
4. Säkerställ att slutläget fortfarande känns som en fortsättning av barnets resa, inte som ett tomt stopp.

Förebygg risker:
- Låt inte sista noden kännas som tomt slut utan payoff.
- Teasa inte nästa biom som spelbar om den inte finns.
- Rör inte assetpipeline eller nya biomkartor i samma slice.
- Skapa inte ett slutläge som gör barnet osäkert på om appen är klar eller trasig.

QA-gate:
- `test/unit/services/story_progression_service_test.dart`
- `test/unit/services/quest_progression_service_test.dart`
- `test/widget/app_results_test.dart`
- `flutter analyze`
- `scripts/flutter_pixel6.ps1 -Action sync`

Manuell check:
- En vuxen kan direkt förstå att Episode 1 är avslutad.
- Barnet får ett tydligt avslut utan att nästa biom lovas som spelbar.

Klart när:
- Barnet och vuxen kan uppfatta Episode 1 som avslutad.
- Systemet känns färdigt även utan nästa biom.

## Go / No-Go för hela Episode 1-polishen

Go:
- Home pekar tydligt mot djungelspåret.
- Karta, resultat och slutläge berättar samma episod.
- QA-snittet är grönt på riktade tester och analyze.
- Pixel_6-verifiering känns stabil i barnflödet.

No-Go:
- Om storyn fortfarande känns som flera lösa ytor i stället för en episod.
- Om CTA-hierarkin fortfarande växlar mellan story och fri träning utan tydlig prioritet.
- Om nästa biom ser ut att vara byggd fast den inte är det.
- Om polishen kräver ny persistens eller bred arkitekturomläggning för att fungera.
- Om barnflödet fortfarande bryter mot touch-, disclosure- eller tillgänglighetskraven ovan.
- Om polishen introducerar märkbar jank i home, karta eller resultat.

## Minsta QA-gate före varje patch

- `flutter analyze`
- berörd riktad widget- eller servicetest
- Pixel_6 sync när slice rör home, story map, onboarding eller resultatvy

## Extern grund för revisionen

- Flutter accessibility: `https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility`
- Flutter adaptive overview: `https://docs.flutter.dev/ui/adaptive-responsive`
- Flutter adaptive best practices: `https://docs.flutter.dev/ui/adaptive-responsive/best-practices`
- Flutter animations overview: `https://docs.flutter.dev/ui/animations/overview`
- Flutter performance best practices: `https://docs.flutter.dev/perf/best-practices`
- Nielsen Norman Group, progressive disclosure: `https://www.nngroup.com/articles/progressive-disclosure/`
- Self-Determination Theory overview: `https://selfdeterminationtheory.org/theory/`
