---
name: "Quiz-persistens"
description: "Use when editing quiz start, answer persistence, resume, replay, results merge or quiz history. Covers deterministic in-progress state and merge back to permanent user progress."
applyTo: "lib/core/providers/quiz_provider.dart, lib/core/providers/user_provider.dart, lib/data/repositories/local_storage_repository.dart, lib/features/quiz/presentation/screens/results_screen.dart, test/unit/logic/quiz_progression_edge_cases_test.dart, test/unit/logic/user_quest_completion_event_test.dart, test/widget/app_quiz_flow_test.dart"
---

# Quiz Persistence (Data & Pausade Flöden)

- **Data först, UI sen:** Resume, replay och quiz history är i första hand persistens- och mergeproblem. Börja i provider/repository-lagret innan du bygger ny UI kring flödet. (Se `docs/ARCHITECTURE.md`).
- **In-progress måste vara deterministiskt:** Det får finnas högst en aktiv in-progress-post per `userId` + `operation`. Start eller restart av samma operation ska skriva över en tidigare post, inte skapa dubbletter.
- **Första svaret måste sparas till samma nyckel:** Efter att ett quiz startat ska löpande svar fortfarande skrivas till den deterministiska session-nyckeln, inte flyta över i en ny post.
- **Avbrott är inte "completion":** Att lämna ett quiz i förtid får inte skapa en färdig history-post. Sessions-state ska finnas kvar oavbrutet tills en ny quizstart river upp den, eller tills den slutförs formellt.
- **Completion MÅSTE merga till spelares profil:** När `UserNotifier.applyQuizResult` anropas ska avslutad session mergas direkt till den permanenta `UserProgress`-profilen. Här appliceras stats, ny mastery och progression, utan att vi tappar den exakta operationens svårighetsgrad (`operationDifficultySteps`).
- **Rensa in-progress efter completion:** När sessionen sparats formellt, måste den gamla deterministiska in-progress-nyckeln slängas i papperskorgen från disken för att inte blockera nya startar.
- **Dashboard ska vara defensiv:** Läsning av historik-loggen får aldrig krascha dashboarden bara för att en gammal korrupt post från en äldre version av appen råkat ligga kvar. Defensiv rendering!
- **Verifiera med QA-skillen:** Om du ändrar start/reset, answer-persistens eller resultmergning, använd alltid `.github/skills/testa-att-quiz-sparas-ratt/SKILL.md` för validering istället för att sväva runt på måfå.