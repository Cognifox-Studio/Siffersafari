<!--
typ: reference
syfte: 25 steg för retention — kadens ovanpå den progression som redan finns
uppdaterad: 2026-11-22
-->

# Retentionplan — 25 steg

> Prioritering i stort: [ROI_BACKLOG.md](ROI_BACKLOG.md) · Now/Next: [ACTIVE_PLAN.md](ACTIVE_PLAN.md) · Beslut: [DECISIONS_LOG.md](DECISIONS_LOG.md)
> Den här filen ändrar inte backloggen; den ger en **retention-lins** på den och pekar ut vad som saknas helt.

---

## Levererat hittills

Fas 0–1 är byggd, med två delar kvar som kräver mer än en slice (se tabellen).

| Steg | Status |
|---|---|
| 1 | Klar — [RETENTION_BASELINE.md](RETENTION_BASELINE.md). Baslinjen fylls först när 30 dagars rullning finns. |
| 2 | Klar — `app_open` (en/dag/profil), `streak_extended`, `streak_lost`, `level_up` och `quiz_started{cta}` loggas. Nu även `home_cta_tapped{cta}` (primärknapp, räknesättskort, storykarta), `results_cta_tapped{cta}` (story, snabbträna, spela igen, hem) och `session_resumed`. Alla med `try/catch`: mätning får aldrig krascha en tap. |
| 3 | Klar — `DailyActivityService`: en post per dag och profil, 90 dagar, inga trackers. Läses nu i föräldravyn (steg 14). |
| 4 | Klar — `HomeStreakBadge` överst på hem, med sviten, längsta sviten och dagsstatus. |
| 5 | Klar — `streakCelebration` ger resultatvyn en svitrad ("5 · Dagar i rad – rekord!") som stat-pill, och konfetti/figur firar även när rundan bara förlängde sviten. Ingen ny lagring: läser `UserProgress` efter commit. |
| 6 | Klar — "Dagen är gjord" när dagens session är registrerad. |
| 7 | Klar — nåd-dag i `StreakResolver`: en per vecka, bara en enstaka missad dag, aldrig en betalning. |
| 8 | Klar — "Välkommen tillbaka!" med längsta sviten, aldrig en tillrättavisning. |
| 9 | Klar — åldersanpassat dagsmål (`dailyGoalSessions`: 1 runda för Åk 1–2, 2 från Åk 3) som räknas upp i svitbadgen på hem, med a11y-etikett. Bygger på `DailyActivityService`, ingen ny lagring. |
| 10 | Klar — "Nästa mål" högst upp på hem: ett låst märke med sin ledtråd, annars nästa nivå med poäng kvar, annars biomen efter episoden. Ren funktion `nextGoalFor` (`next_goal.dart`) ur befintlig state, ingen ny lagring, ingen ny räknare. |
| 11 | Klar — resultatvyn har nu **en** fylld knapp. När storyn gick framåt är det "Fortsätt storyn"; snabbträna och spela igen finns kvar som länkar med samma nycklar, så inget val försvinner — det slutar bara konkurrera. `results_cta_tapped` visar vilken dörr som används. |
| 14 | Klar — "Dagar med spel" i föräldradashboarden: 90 rutor, en per dag, mörkare ju mer spelat, plus "34 av 90 dagar med spel · längsta följden 9" och en uppläst sammanfattning. Ren funktion `ActivitySummary`, ingen ny lagring. |
| 18 | Klar — profilvalet visar varje barns egen svit ("🔥 5 dagar i rad") i sin ruta. Syskon delar platta, inte svit. Noll dagar syns inte alls. |
| 22 | Klar — personbästa per räknesätt: `personal_bests.dart` räknar bästa rundan ur historiken som redan finns (inga nya fält), och resultatvyn firar bara när rundan slog något som fanns *före* den. Första rundan är aldrig ett personbästa. |
| 13 | Klar — efter ≥3 dagars uppehåll startar första rundan ett steg lägre, bara för räknesättet hon möter (`comeback.dart`). Inget sparas: adaptiva trappan klättrar tillbaka så fort hon svarar bra. `quiz_started` får `comeback: true` så effekten går att mäta. |
| 17 | Klar — checklistan får ett slut som syns: onboardingkortet visar «Så här börjar vi: Årskurs 3 · plusraketer, minusgrottor, gånger-djungeln, delat-isbanan · Läshjälp på» innan man trycker Starta, och säger att allt kan ändras i Föräldraläge. `SetupPlan` speglar exakt det `OnboardingController.complete` skriver. |
| 12 | Klar — veckans mål på hem: fyra rundor (tre för Åk 1–2) inom veckofönstret mån–sön. Mätt ur historiken som redan finns, så det nollställs av sig själv på måndag i stället för att kräva en räknare som kan glida. Avbrutna rundor tickar inte. |
| 23 | Klar — experimenthake: `experimentVariant` (FNV-1a med avalanche, så två experiment inte lottas lika), varianten sparas per barn i settings och loggas som `experiment_assigned` vid första start. Ingen variant rör kärnloopen; `variantIsOn` finns för steg 24. |
| 16 | Klar — «Ikväll · tio minuter» i föräldradashboarden: en knapp, en färdig session på tio frågor (≈ tio minuter) på det svagaste området. Fast längd i stället för en bråkdel av sessionen, så siffran i rubriken stämmer. |
| 24 | Klar (regeln) — `ExperimentDecision`: behåll om D7 förbättras ≥3 procentenheter vid minst 30 profiler per arm, annars ta bort, annars samla mer. Regeln står i kod och i klartext (`explain`). Körningen väntar på data. |
| 15, 19–21, 25 | Kvar. |

Två saker som ändrades under bygget, värda att veta:

- Nåd-dagen ändrar streaken från "alltid nollställ vid lucka" till "en missad dag förlåts". Det är avsiktligt, men det är en *beteendeförändring* i `ApplyQuizResultUseCase`, inte bara UI, och den ligger därför i en egen testbar enhet (`StreakResolver`) med sju fall.
- Sviten kunde inte läsas direkt från inställningarna i hemvyn: `modular_boundaries_audit_test` förbjuder storage-access i presentationslagret. Värdet härleds därför i `UserNotifier` och läses som state — samma regel som resten av appen.

## Utgångsläge — vad appen redan har

- **Progression är byggd**: poäng och nivåer (200 p/nivå, `user_progress.dart:121`), nivåtitlar, 18 achievements (`achievement_catalog.dart`), camp med samlarobjekt och garderob, story-karta med biomer och `nextBiome`-teaser, mastery-quests (`quest_progression_service.dart`).
- **Streak finns i data men syns inte**: `currentStreak`/`longestStreak` beräknas i `apply_quiz_result__progress_merger_part.dart:62` och sparas, men `currentStreak` förekommer **inte i någon widget i `lib/features/`**. Barnet kan alltså hålla en svit i veckor utan att någonsin få veta det.
- **Ingen kadens utanför appen**: `flutter_local_notifications` finns inte i `pubspec.yaml`. Det finns ingen väg tillbaka in i appen annat än att barnet eller föräldern kommer ihåg den.
- **Mätning finns lokalt men är osynlig**: `app_analytics_service.dart` loggar sex händelser (`quiz_started`, `quiz_completed`, `quiz_abandoned`, `parent_mode_opened`, `parent_tonight_practice_started`, `level_up`) i en ring med `_maxStoredEvents = 500` — och inget läser den.

**Diagnos:** appen har gott om *belöningar* och nästan ingen *kadens*. Fler achievements löser inte det; det gör en synlig svit, ett litet dagsmål och en artig väg tillbaka.

## Spelregler för hela planen

- **COPPA/offline först**: inga trackers, ingen molnexport. Retention mäts lokalt och läses i appen.
- **Notiser är förälderns, inte barnets**: opt-in, max en per dag, tysta timmar.
- **Inga skuldkänslor**: ingen copy som hotar med förlorad svit, inga "du sviker din safari"-formuleringar. Se §Inte göra.
- **Experiment ska gå att ta bort** utan att knäcka hem → quiz → resultat → story (guardrail i `ACTIVE_PLAN.md`).
- **Copy är inline svenska** tills i18n-grinden öppnas (`I18N_GATE.md`).
- Oförändrat exkluderat: molnsync, sociala funktioner, leaderboard som kärna, Daily Challenge-återupplivning.

## Mätvärden (låses i steg 1)

| Mätvärde | Definition |
|---|---|
| D1 / D7 / D30 | Andel profiler med minst en avslutad session dag N efter första dagen |
| Session | `quiz_started` → `quiz_completed` för samma profil |
| Sessioner/vecka | Median antal avslutade sessioner per aktiv profil och ISO-vecka |
| Streak-kvarhållning | Andel profiler med svit *n* som når *n+1* nästa dag |
| Comeback | Andel profiler som gör en session inom 7 dagar efter ≥3 dagars uppehåll |
| Dagsmålsfyllnad | Andel dagar där dagens mål (steg 9) nås |

---

## Fas 0 — Mät först (1–3)

Utan de här tre går inget senare steg att försvara, och "retention blev bättre" blir en känsla.

1. **Lås mätvärdena och skriv baslinjen.** Tabellen ovan + en `docs/RETENTION_BASELINE.md` som fylls när första 30 dagarna finns. S.
2. **Fyll händelsegapet.** `app_analytics_service.dart` saknar `app_open` (en/dag/profil), `streak_extended`, `streak_lost`, `home_cta_tapped{cta}`, `results_cta_tapped{cta}`, `session_resumed`. Utan dem går inte sviten eller CTA:erna att följa. S.
3. **Daglig rullning istället för 500-eventsringen.** En aktiv familj fyller 500 händelser på några dagar, och då raderas just den historik retention vilar på. Lägg `Map<dagKey, räknare>` (90 dagar) i `SettingsKeys`/`LocalStorageRepository`, läsbar i föräldravyn med "kopiera som text". M.

## Fas 1 — Gör återkomsten synlig (4–8)

4. **Svit på hemmets första viewport.** Data finns redan (`user_progress.dart:66`); detta är en render, inte ny state. Den enskilt billigaste retention-åtgärden i listan. S.
5. **Svitfirande i resultatet.** Namnge milstolparna 3/7/14/30 och knyt dem till befintliga achivements. Ett firande utan namn glöms. S.
6. **"Dagen är gjord"-tillstånd på hem.** Efter dagens första avslutade session markeras dagen klar istället för att truga en runda till. Ger dagen som enhet och tar bort känslan av oändlig grind. S–M.
7. **Nåd-dag utan betalning.** En missad dag per vecka räddar sviten automatiskt. Sjuåringar som tappar en lång svit på grund av en sjukdag slutar ofta helt; det är den vanligaste baksidan av streaks i den här åldern. S–M.
8. **Återkomst-copy när sviten brustit.** "Välkommen tillbaka" + `longestStreak` som stolthet. Aldrig en tillrättavisning. Copygranskas mot §Inte göra. S.

## Fas 2 — Ge morgondagen ett skäl (9–13)

9. **Dagens mål, åldersanpassat.** Åk 1–2: en session eller 5–10 frågor; högre åk: 10–20. Bygger på befintlig sessionskonfiguration, visas som ring på hem. M.
10. **Morgondagens teaser.** Ett låst mål synligt redan idag: badge-hint (ROI #11), camp-objekt eller story-nod. Stänger loopar som redan är byggda. S.
11. **En enda nästa-steg-CTA i resultatet.** Antingen story-nod eller fokuserad övning — med samma copy som hem och karta (ROI #18/#20). Fem val är inget val. S–M.
12. **Veckoquest ovanpå mastery-quests.** `QuestDefinition` mäter mastery, inte tid; lägg ett veckofönster som refreshar på måndag. Detta är *inte* Daily Challenge-återupplivning. M.
13. **Comeback-session efter uppehåll.** ≥3 dagars gap → första sessionen på känt material via `adaptive_difficulty_service.dart`. Målet är att avsluta med kompetens, inte att maxa utmaning. M.

## Fas 3 — Släpp in föräldern (14–18)

Föräldern är den som startar appen i den här åldern. Allt här är offline.

14. **Veckodigest i appen.** Sessioner, svit, svagaste område, ett förslag på tio minuter — ur befintlig read model (ROI #24), ingen ny data. M.
15. **Opt-in påminnelse, en per dag.** Lokal notis som föräldern slår på, med tysta timmar och inexact schemaläggning (exact alarm kräver extra permission). Kräver `flutter_local_notifications` — den enda nya beroendet i planen. M–L.
16. **En-tryck "ikväll, tio minuter".** Från digesten direkt in i en färdig session utan menyval (ROI #24). S–M.
17. **Första-körningens checklista får ett slut.** Åk → uppläsning → räknesätt (ROI #22). Ofullbordad setup är en D1-dödare: barnet får fel nivå och slutar. S.
18. **Svit per barn på profilvalet.** Syskon ska inte kunna ärva eller tappa varandras svit (ROI #69). S.

## Fas 4 — Innehållskadens (19–22)

19. **Varje release ska synas för barnet.** Ny badge, camp-objekt eller story-beat per release, och en barnvy "nytt i appen" — inte bara release notes för vuxna. S per release.
20. **Horisont efter `nextBiome`.** Nattskogen som soft landing (ROI #19) plus ett långt mål som syns, så dag 30 har en riktning. M.
21. **Säsongsbetonade samlarobjekt.** Ett djur per vecka in i befintligt inventory, WebP-first, ingen ny runtime. M.
22. **Personbästa per räknesätt.** För Åk 4–9, som tappar nybörjarglädjen när nivåerna planar ut. S–M.

## Fas 5 — Pröva och håll (23–25)

23. **Experimenthake som går att ta bort.** Variant per `userId`-hash, sparas i settings, taggas i analytics. Ingen variant får röra kärnloopen. M.
24. **Två experiment med beslutsregel skriven i förväg.** (a) svit synlig på hem, (b) opt-in påminnelse. Exempel på regel: behåll om D7 förbättras med ≥3 procentenheter vid n ≥ 30 profiler; annars ta bort. S–M per analys.
25. **Månadsvis retention-genomgång.** En sida ur rullningarna, behåll/döda-beslut, uppdatera `ROI_BACKLOG.md`/`ACTIVE_PLAN.md`, och copygranska allt nytt mot §Inte göra. S per månad.

---

## Om bara tre steg görs

**4, 9, 15** — sviten synlig, dagens mål, förälderns påminnelse.

Steg 4 kostar nästan ingenting eftersom datat redan finns och sviten redan räknas. Steg 9 gör dagen till en enhet istället för en oändlig lista frågor. Steg 15 är den enda bryggan tillbaka in i appen som inte bygger på att ett barn minns något. Alla tre mäts av steg 1–3, så effekten går att läsa av inom två veckor.

## Inte göra (oavsett vad siffrorna säger)

- Ingen copy som hotar: "sviten förstörs om…", "du har inte spelat på…".
- Inga notiser till barnet, ingen notis som kräver att barnet svarar.
- Inga förlorade mynt, ingen energi/väntetid, ingen artificiell grind.
- Ingen falsk social jämförelse, inga botar som låtsas vara klasskamrater.
- Ingen leaderboard som kärna, ingen molnsync — se "Inte nu" i `ACTIVE_PLAN.md`.

## Vad planen medvetet inte tar upp

Cloud, konton, sociala funktioner och Daily Challenge-återupplivning ligger kvar som exkluderade i `ACTIVE_PLAN.md`. Planen lägger heller inget nytt på quiz-motorn: om D7 inte rör sig efter fas 1–2 är problemet sannolikt innehållet och inlärningskurvan, och då är ROI #26–40 rätt väg — inte fler belöningar.
