---
name: "night-cleanup-audit"
description: "Kor en lang read-only cleanup-audit over natten och lamna en granskningsbar rapport utan kodandringar"
argument-hint: "Valfritt: begransa scopet till lib, test, docs, .github eller ett riskomrade som quiz, navigation eller persistens"
agent: "agent"
---

Kor ett nattligt cleanup-pass for Siffersafari i auditlage.

Mal:

- Ga igenom avtalat scope metodiskt utan att redigera koden.
- Identifiera kandidater for borttagning, flytt, forenkling eller dokumentationsstadning.
- Lamna en tydlig rapport som gar att granska pa morgonen.

Utga fran dessa kallor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/PROJECT_STRUCTURE.md](../../docs/PROJECT_STRUCTURE.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md](../instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md)
- [.github/agents/plan.agent.md](../agents/plan.agent.md)

Ramar:

- Andra inte koden eller docs under auditpasset.
- Skapa inte commit eller stagea inget.
- Den enda tillatna skrivningen ar en granskningsrapport under `artifacts/cleanup_runs/` om den inte redan finns.
- Om nagot ar osakert eller ser riskigt ut: logga det som kandidat, men gor ingen patch.
- Om inget scope anges: anvand `.github`, `docs` och en hog-signal-sokning efter stale referenser i resten av repot som standardscope.

Arbetsordning:

1. Las `docs/SESSION_BRIEF.md` forst.
2. Om inget scope gavs, borja med `.github`, sedan `docs`, och avsluta med en smal repo-wide sokning efter stale namn, brutna referenser och tydliga legacy-spor.
3. Inventera scopet omrade for omrade i stallet for att ga mekaniskt rad for rad genom hela repot.
4. For varje kandidat: ange kort motivering och vilka signaler som stodjer den, till exempel importer, call sites, tester, audit-guards, docsreferenser eller saknad anvandning.
5. Separera riskytor tydligt, sarskilt persistens, navigation, quizfloden, bakatkompatibilitet och publika wrappers.
6. Returnera hogst 10 kandidater totalt, prioriterade efter signal och risk.
7. Skriv en lopande rapport till `artifacts/cleanup_runs/<date>-night-cleanup-audit.md` med kandidater, bevis, riskniva och billigaste verifiering.
8. Avsluta med en kort sammanfattning av vilka forslag som ar lag-risk, vilka som maste beslutas manuellt och vilken ordning de bor tas i.

Svarskrav:

- Skriv inga patchar.
- Dela upp rapporten i `Lag risk`, `Krav pa beslut` och `Ror ej automatiskt`.
- Om scopet ar stort: prioritera hog signal framfor total tackning.
- Skriv uttryckligen att allt fortfarande ar ocommittat.