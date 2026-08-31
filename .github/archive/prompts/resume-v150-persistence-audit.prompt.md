---
name: "resume-v150-persistence-audit"
description: "Kör en kort resume v1.5.0 persistence audit och peka ut minsta nästa slice med evidens"
argument-hint: "Valfritt: begränsa till SRS v2, resume, in-progress keys, quiz_history, settings eller en viss fil"
agent: "agent"
---

Granska den återstående v1.5.0-ytan för resume och quiz-persistens utan att börja med bred scanning.

Utgå från dessa källor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/DECISIONS_LOG.md](../../docs/DECISIONS_LOG.md)
- [.github/instructions/regler-for-hur-pabade-quiz-avbryts-och-sparas.instructions.md](../instructions/regler-for-hur-pabade-quiz-avbryts-och-sparas.instructions.md)
- [.github/instructions/regler-for-att-spara-saker-permanent-i-telefonen.instructions.md](../instructions/regler-for-att-spara-saker-permanent-i-telefonen.instructions.md)
- [.github/skills/testa-att-quiz-sparas-ratt/SKILL.md](../skills/testa-att-quiz-sparas-ratt/SKILL.md)
- [lib/core/providers/quiz_provider.dart](../../lib/core/providers/quiz_provider.dart)
- [lib/core/providers/user_provider.dart](../../lib/core/providers/user_provider.dart)
- [lib/data/repositories/local_storage_repository.dart](../../lib/data/repositories/local_storage_repository.dart)
- [test/unit/logic/quiz_progression_edge_cases_test.dart](../../test/unit/logic/quiz_progression_edge_cases_test.dart)
- [test/unit/logic/quiz_provider_srs_test.dart](../../test/unit/logic/quiz_provider_srs_test.dart)
- [test/widget/app_quiz_flow_test.dart](../../test/widget/app_quiz_flow_test.dart)

Arbetsordning:

1. Läs `docs/SESSION_BRIEF.md` först och bekräfta vad som redan är klart i v1.5.0.
2. Läs bara de provider-, repository- och testankare som faktiskt behövs för det givna scopet.
3. Leta efter kvarvarande versionslösa nycklar, displaytext-baserade identifierare, otestade resumevägar eller merge-pathar som fortfarande kan tappa state.
4. Separera verifierade fynd från antaganden.
5. Föreslå en enda minsta nästa slice. Gör bara kodändring om användaren uttryckligen bad om att få saker fixade nu.

Svarskrav:

- Börja med om auditten hittade en faktisk kvarvarande risk eller inte.
- Lista bara de filer som bar signal.
- Nämn rekommenderad nästa slice och minsta QA-slice som skulle falsifiera den.
- Om ingen tydlig kvarvarande legacy-yta hittas, säg det uttryckligen.