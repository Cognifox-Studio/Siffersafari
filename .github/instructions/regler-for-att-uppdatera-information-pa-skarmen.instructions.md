---
name: "Riverpod state management"
description: "Use when editing providers, notifiers, provider state, Riverpod side effects or UI state isolation. Covers naming, state ownership and persistence handoff."
applyTo: "lib/**/providers/**/*.dart, **/*_provider.dart, **/*_notifier.dart"
---

# Riverpod state management

## Provider-typer och repo-linje
- Följ den provider-stil som redan äger området. I kärnflödena använder repot idag främst `StateNotifierProvider` tillsammans med immutabla state-klasser.
- Introducera inte en ny provider-paradigm mitt i samma slice utan tydlig anledning och verifiering.
- Använd `Provider` för servicebryggor och rena härledda värden som inte själva äger muterbar state.

## Namngivning och ansvar
- Notifier-klasser ska heta `[Namn]Notifier`.
- Provider-variabeln ska heta `[namn]Provider`.
- Låt en provider äga ett tydligt ansvar. Splitta hellre state än att lägga flera orelaterade flöden i samma notifier.

## Watch, read och sidoeffekter
- Använd `ref.watch(...)` i widgeters `build()`.
- Använd `ref.read(...)` i callbacks och init-logik.
- Providers får inte importera UI, använda `BuildContext` eller trigga dialoger, snackbar eller navigation direkt. Exponera state och låt UI reagera via `ref.listen(...)`.

## State-kvalitet
- Håll state immutabel och uppdatera via `copyWith` eller ny instans.
- Modellera fel, loading och submission-status uttryckligt i state i stället för att låta UI gissa.
- Session-state i quiz, progression eller adaptiv svårighet måste mergas tillbaka till persistent state när flödet avslutas.
