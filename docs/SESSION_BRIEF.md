# Session Status Brief

> Syfte: Sammanfattar aktuellt projektläge, pågående arbete, och nästa steg för att underlätta kontextöverföring mellan sessioner.
>
> Uppdateras efter större milestones. Historiska beslut finns i docs/DECISIONS_LOG.md.

---

## Nuläge (2026-05-05)

**Version:** 1.3.6+14 (Mergad & Taggad, i Play Console Alpha)
**Tester:** Alla 190 tester passerar ✅  
**flutter analyze:** 0 fel ✅  
**Integration smoke:** 3/3 passed (FULL_SMOKE=false) ✅  
**Release AAB:** Laddad till Google Play Console för stängt test (Alpha) ✅  

### Senaste leveranser

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

### Aktuell fas: Inventory & Wardrobe Logik
- Vi har apan (Loke) och hans animation på plats.
- Nästa tekniska bit är att bygga in Riverpod/Hive-logiken för inventory, så drömmarna om att byta hattar (Safari hat) faktiskt fungerar beständigt.
- Belönings-MVP: Välja ett ställe där hatten ges/låses upp och läses av på karaktären i skärmen.

---

## Stabila beslut (sammanfattning)
Se docs/DECISIONS_LOG.md för fullständig historik. Nyckelbeslut:
- COPPA-compliance först, inga trackers eller auto-update bibliotek [2026-05-01].
- PNG-first + procedural scale för enkel 2D maskotruntime [2026-05-03]. (SVG och Rive är utfasade).
- Riverpod + GetIt + Hive
- Feature-first UI-struktur (lib/features/)
- Hybrid adaptiv svårighet (micro + macro + cooldown)
- Daily Challenge personaliseras via getTodaysChallengeForUser (mastery + operationDifficultySteps)
