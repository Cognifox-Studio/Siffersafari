---
name: "night-low-risk-apply"
description: "Kor ett langt lag-risk-cleanup-pass over natten, verifiera batchvis och lamna allt ocommittat med rapport"
argument-hint: "Valfritt: begransa scopet till docs, .github, ett featureomrade eller lag-risk-cleanup i lib/test"
agent: "agent"
---

Kor ett autonomt nattpass for lag-risk-cleanup i Siffersafari.

Mal:

- Stada avtalat scope utan att fraga under passet sa lange andringarna stannar inom lag-risk-reglerna nedan.
- Verifiera varje batch med smalast mojliga kontroll.
- Lamna alla andringar ocommittade och dokumenterade for morgongranskning.
- Om inget scope anges: anvand `.github` och `docs` som standardscope. Ror inte `lib/` eller `test/` utan explicit scope.

Utga fran dessa kallor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/PROJECT_STRUCTURE.md](../../docs/PROJECT_STRUCTURE.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md](../instructions/regler-for-att-stada-upp-snurrig-kod.instructions.md)
- [.github/agents/beastmode.agent.md](../agents/beastmode.agent.md)
- [.github/prompts/repo-qa-slice.prompt.md](./repo-qa-slice.prompt.md)

Tillatet utan att fraga:

- docs- och `.github`-stadning
- stale referenser och felaktiga interna lankar
- smala lokala cleanup-fixar i en fil
- dod privat hjalpmetod eller privat klass med tydligt noll usage
- kommenterad framtidskod eller kommentarer som ar bevisat felaktiga
- liten forenkling eller rename med billig verifiering och utan korsande riskyta

Inte tillatet utan att fraga:

- persistensformat, migreringsnycklar eller bakatkompatibilitet
- navigation, quizfloden eller `UserProgress`-relaterad merge-logik
- radering av aktiv Dart-fil i `lib/`
- bred multi-file-refaktor over flera features eller lager
- andringar i publika wrappers, providers eller delad UI med flera call sites
- stage, commit eller push

Arbetsordning:

1. Las `docs/SESSION_BRIEF.md` forst och bygg sedan en liten arbetslista for scopet.
2. Om inget scope gavs, begransa passet till `.github` och `docs` och prioritera stale referenser, felaktiga instruktioner, brutna lankar och dokumentationsstadning.
3. Arbeta batchvis i sma patchar med hog signal och lag dramatik.
4. Efter varje batch: kor smalaste verifieringen som kan falsifiera andringen.
5. Om en kandidat visar sig riskig eller osaker: hoppa over patchen och logga den i rapporten under `Krav pa beslut`.
6. Skriv en lopande rapport till `artifacts/cleanup_runs/<date>-night-low-risk-apply.md` med:
   - vad som andrades
   - varfor
   - vilka bevis som anvandes
   - vilken verifiering som kordes
   - vad som lamnades orort och varfor
7. Hall allt ocommittat nar passet ar klart.

Svarskrav:

- Borja med att repetera vilket scope du faktiskt kommer att rora.
- Om scopet ar for brett eller riskigt for lag-risk-lage: krymp det sjalv till en saker batch och sag vad som skots upp.
- Avsluta med en kort morgonrapport: vad som andrades, vad som verifierades, vad som ar kvar och att inget ar commitat.