---
name: "Städa upp snurrig kod"
description: "Use when refactoring, cleaning up dead code, removing stale side effects or moving legacy Dart code to the right layer. Covers feature-first cleanup and safe validation."
applyTo: "**/*.dart"
---

# Regler för uppstädning och refaktorering

## Sidoeffekter och UI
- Ha inga sidoeffekter i `build()`. Navigering, dialoger och liknande ska styras via `ref.listen(...)` eller annan tydlig livscykelpunkt.
- Använd `addPostFrameCallback` i `initState()` bara för verkliga engångshändelser, inte som allmän räddningsplanka.
- Lämna inte sentinel-variabler i `build()` för att blockera effekter som egentligen hör hemma någon annanstans.

## Struktur och feature-first
- När du rör legacy-UI: utvärdera om den hör hemma under `lib/features/<feature>/presentation/...` eller som verkligt delad widget i `lib/presentation/widgets/`.
- Lägg inte feature-specifik logik i delade widgets.

## Död kod och dokumentation
- Ta bort orphan-filer, oanvända funktioner, kommenterad framtidskod och tester som bara täcker borttagna features.
- Uppdatera eller ta bort kommentarer som blivit felaktiga.
- När ett helt experimentspår tas bort ska du också rensa docs, instruktioner, testdata och andra stödartefakter som pekar på det.

## Validering
- Kör `dart fix --apply` när det hjälper till att städa upp lint- och formatrester efter refaktorering.
- Kör minst `flutter analyze` och riktad testning för den yta du ändrat.
- Blanda inte stor refaktorering med ny featurekod om det går att undvika.

## Säker arbetsmetod
- Arbeta i små steg och verifiera mellan stegen.
- Om något ser korrupt eller oväntat ut: stoppa, inspektera diffen och återställ inte filer på chans.
