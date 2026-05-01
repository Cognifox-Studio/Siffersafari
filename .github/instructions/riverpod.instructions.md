---
description: "Regler för Riverpod state management, provider-typer, och UI-isolering"
applyTo: "lib/**/providers/**, lib/core/providers/**, lib/features/**/providers/**, **/*_provider.dart, **/*_notifier.dart"
---

# Riverpod State Management

- **Provider-typer:** Använd konsekvent rätt typ:
  - `Provider` för Service Providers (t.ex. `getIt<AudioService>()`) och Computed Providers (skrivskyddade värden härledda från andra providers).
  - `StateProvider` för enkel muterbar UI-state.
  - `StateNotifierProvider` (eller moderna `NotifierProvider`/`AsyncNotifierProvider`) för komplex state med affärslogik.
- **Namngivning:** Notifiers ska heta `[Namn]Notifier` (t.ex. `QuizNotifier`), men själva provider-variabeln heter bara `[namn]Provider` (inte `[namn]NotifierProvider`). Service-providers slutar på `ServiceProvider`.
- **Watch vs Read:**
  - Använd **ALLTID** `ref.watch()` i widgetens `build`-metod.
  - Använd **ALLTID** `ref.read()` inuti event-handlers (t.ex. `onPressed`).
- **Ingen UI i State:** Providers får **INTE** ha beroenden till `BuildContext` eller trigga UI-element som dialoger eller snackbars. Sidpeffekter ska döljas bakom state-variabler (t.ex. `errorMessage`) som UI sedan reagerar på.
- **Oföränderlighet:** State för Notifiers ska vara klasser som är *immutable* (oföränderliga) och modifieras via `copyWith`.
