---
name: "Städa upp snurrig kod"
description: "Use when refactoring, retiring legacy Dart code, removing stale side effects or moving code to the right layer. Covers feature-first cleanup, compatibility guardrails and safe validation."
applyTo: "**/*.dart"
---

# Regler för uppstädning och refaktorering

## Nulägesfacit före städning
- Kontrollera först `docs/SESSION_BRIEF.md`, `docs/ARCHITECTURE.md` och `docs/PROJECT_STRUCTURE.md` innan du kallar något legacy eller dött.
- Använd aktiva importer, call sites och audit-tester som facit före historiska planer, gamla TODOs eller åldrade kommentarer.
- Om en fil bara ser gammal ut men fortfarande används i onboarding, wrappers eller tester: behandla den som aktiv tills motsatsen är verifierad.

## Sidoeffekter och UI
- Ha inga sidoeffekter i `build()`. Navigering, dialoger och liknande ska styras via `ref.listen(...)` eller annan tydlig livscykelpunkt.
- Använd `addPostFrameCallback` i `initState()` bara för verkliga engångshändelser, inte som allmän räddningsplanka.
- Lämna inte sentinel-variabler i `build()` för att blockera effekter som egentligen hör hemma någon annanstans.

## Struktur och feature-first
- När du rör legacy-UI: utvärdera om den hör hemma under `lib/features/<feature>/presentation/...` eller som verkligt delad widget i `lib/presentation/widgets/`.
- När en widget blivit för smart: flytta affärslogik, parsing eller sidoeffekter till provider, notifier, use case eller service i stället för att lämna kvar dem i UI-lagret.
- Lägg inte feature-specifik logik i delade widgets.

## Död kod, kompatibilitet och dokumentation
- Ta bort orphan-filer, oanvända funktioner, kommenterad framtidskod och tester som bara täcker borttagna features.
- Radera inte bakåtkompatibilitet för sparformat, migreringsnycklar, alias eller legacy-cleanup i providers och repositories utan bevis att gammal data inte längre kan finnas.
- Om ett gammalt format ska pensioneras: gör det med explicit migrering eller medveten reset-strategi, och verifiera berörd persistence-yta riktat.
- Uppdatera eller ta bort kommentarer som blivit felaktiga.
- När ett helt experimentspår tas bort ska du också rensa docs, instruktioner, prompts, testdata och andra stödartefakter som pekar på det.

## Säker radering
- Innan du tar bort en Dart-fil: verifiera att inga aktiva importer, skapade instanser, tester eller docs-flöden fortfarande pekar på den.
- Föredra en liten retire-patch framför en bred cleanup som blandar flera system samtidigt.
- Behåll aktiva wrappers eller adaptrar tills alla call sites faktiskt är flyttade eller ersatta.

## Godkännandegrind för riskig cleanup
- Vid filradering, borttagning av bakåtkompatibilitet, retirement över flera filer eller cleanup som rör persistens, navigation eller publika wrappers: gör först en read-only inventering och vänta på användarens val innan patch.
- Presentera små numrerade förslag i stället för en bred cleanup-plan när flera kandidater konkurrerar om samma patchutrymme.
- För varje riskig kandidat ska motiveringen bygga på verifierbara signaler, till exempel importer, call sites, tester, audit-tester eller docsreferenser.
- Små lokala städningar i en fil med tydlig verifiering får göras direkt utan separat godkännanderunda.

## Validering
- Kör `dart fix --apply` när det hjälper till att städa upp lint- och formatrester efter refaktorering.
- Kör minst `flutter analyze` och den smalaste riktade testningen för den yta du ändrat.
- Vid refaktorering av persistens, navigation eller quizflöden: välj först ett riktat test eller audit som snabbt kan falsifiera ändringen.
- Blanda inte stor refaktorering med ny featurekod om det går att undvika.
- Om ändringen bara tar bort legacy-spår: verifiera även att inga stale referenser finns kvar i audit-tester, docs eller instruktioner.

## Säker arbetsmetod
- Arbeta i små steg och verifiera mellan stegen.
- Om något ser korrupt eller oväntat ut: stoppa, inspektera diffen och återställ inte filer på chans.
- Om du inte säkert kan skilja död kod från bakåtkompatibilitet: stoppa och gör en liten read-only audit före radering.
