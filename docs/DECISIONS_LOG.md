<!--
typ: explanation
syfte: Historik, varför vi gjort vissa arkitekturval
uppdaterad: 2026-05-05
-->
# Beslut och antaganden (Siffersafari)

Syfte: samla stabila beslut utanfor chatten.
Princip: senaste datum vinner vid konflikt.

## Gällande nuläge (2026-05-09)

- Plattform: Android-first, offline-first, flera barnprofiler.
- Gränssnitt: Extremt reducerat och barnvänligt. Skärmar som Quiz och Home har städats på all överflödig text och UI för att leda fokus direkt till interaktionen.
- Arkitektur: lagerindelad Flutter-app med Riverpod + GetIt + Hive.
- Animation:
  - Procedurgenererade transformationer på enkla PNG-bilder prioriteras över komplicerad cut-out layout med SVG för mascots. Rive och Lottie är slopade.
- Responsiv layout styrs av tillganglig bredd (compact < 600, medium >= 600, expanded >= 840).
- Quizens adaptiva svarighetsmodell ar hybrid (micro + macro + cooldown) och persisteras per raknesatt.
- Distribution och uppdateringar for produktappen sker via Google Play. Inget OTA- eller in-app update-flode ar en aktiv del av produktens nulage.
- Copilot-customizations i `.github/` ska vara repoanknutna, länka vidare till docs i stället för att duplicera innehåll, och använda skill-namn som matchar respektive mappnamn.

## Historik (kort)

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
