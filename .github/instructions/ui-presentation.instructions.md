---
description: "Konventioner för UI, struktur och UX/Copy för skärmar, dialoger och widgets"
applyTo: "lib/features/**/presentation/**, lib/presentation/**, lib/features/**/widgets/**, lib/features/**/dialogs/**, lib/features/**/screens/**, lib/features/**"
---

# UI, Presentation & UX-konventioner (Siffersafari)

Dessa regler gäller för all presentationskod, oavsett om den ligger under en specifik feature (`lib/features/<feature>/presentation/`) eller är delad (`lib/presentation/`).

## 1. Struktur & Ägarskap (Feature-first)
- All ny UI som tillhör en specifik domän läggs i `lib/features/<feature>/presentation/...` (uppdelat i `screens/`, `dialogs/`, `widgets/`).
- `lib/presentation/` används **enbart** för genuint delade widgets och app-omslutande skalstruktur.
- Flytta bara kod till `lib/core/` när den är tydligt tvärgående och återanvänds av flera features. Undvik feature-korsberoenden; lägg delade abstraktioner i `core/` eller `domain/`.

## 2. Riverpod & UI-tillstånd
- `ref.watch(provider)` i `build()` – aldrig i `initState` eller callbacks.
- `ref.read(provider.notifier)` i event-handlers och `initState`.
- Screen-state relaterad till aktuell användare skyddas mot dubbla callbacks med sentinelvariabel i `WidgetsBinding.instance.addPostFrameCallback`.

## 3. Widget-Hierarki & Navigering
- **Screens:** Ärver `ConsumerStatefulWidget`. Wrappas i `ThemedBackgroundScaffold` om bakgrundsbild/gradient önskas.
- **Dialogs:** Implementeras som private `_XxxDialog extends ConsumerStatefulWidget` och lanseras via en top-level `showXxxDialog(...)`.
- **Widgets:** Rena widgets (`StatelessWidget`) ska ta sina beroenden som parametrar istället för att koppla mot providers internt.
- **Navigering:** Använd `context.pushSmooth(...)` och `context.pushReplacementSmooth(...)` från `core/utils/page_transitions.dart`. Undvik `Navigator.push`.

## 4. Layout (Responsivitet & ScreenUtil)
- Logiska Breakpoints via `AdaptiveLayoutInfo`: compact < 600, medium ≥ 600, expanded ≥ 840. Använd `LayoutBuilder`.
- `ScreenUtil`: Använd `.w` och `.h` för skalade element utifrån designens baseline (t.ex. `AppConstants.defaultPadding.w`). Undvik `.r`. Kör aldrig `ScreenUtil.init()` inuti enskilda widgets.

## 5. Barnvänlig UX & Copy (Viktigt!)
- **Korta instruktioner:** Ett verb + ett mål (t.ex. "Spela nu", "Tryck på en prick").
- **Ingen teknisk jargong i barnflödet:** Skydda felmeddelanden och teknisk data bakom `parent_features` (Föräldraläget).
- **Tydlig Primär CTA:** För att undvika kognitiv överbelastning hos barn (6-12 år), använd en enda supertydlig CTA på viktiga skärmar. Sidospår hanteras visuellt sekundärt.
- **Normalisering:** Alltid grammatiskt korrekt, enkel svenska med diakritik. Inga slarviga placeholders.