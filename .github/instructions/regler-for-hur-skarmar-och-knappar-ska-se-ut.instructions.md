---
name: "UI och presentation"
description: "Use when editing Flutter UI, screens, dialogs, widgets, copy or layout under lib/features/**/presentation/** or lib/presentation/**. Covers feature-first ownership, Riverpod in UI, responsive layout and child-friendly UX."
applyTo: "lib/features/**/presentation/**/*.dart, lib/presentation/**/*.dart"
---

# UI, Presentation och UX-konventioner

## Struktur och ägarskap
- Lägg ny featureägd UI i `lib/features/<feature>/presentation/`.
- Använd `lib/presentation/widgets/` bara för verkligt delade widgets och app-shell-komponenter.
- Flytta inte UI till `lib/core/` om det inte är tydligt tvärgående och återanvänds av flera features.

## Widgets och Riverpod i UI
- Välj `ConsumerWidget` som standard. Byt till `ConsumerStatefulWidget` först när widgeten behöver controllers, animationer eller annan livscykelstyrd state.
- Använd `ref.watch(...)` i `build()` och `ref.read(...)` i callbacks.
- Om en view bygger upp `ref.watch`-state för att skicka vidare till leaf-widgets (components), *säkerställ* att alla relevanta datafält skickas explicit i sub-widgetens constructor (undvik "data dropping" där widgeten ser statisk ut för att en specifik prop aldrig skickades vidare).
- Reagera på providerförändringar med `ref.listen(...)`, inte med `addPostFrameCallback` inuti `build()`.
- Låt mindre leaf-widgets ta data och callbacks som parametrar när det gör dem enklare att återanvända och testa.

## Skärmar, dialoger och navigering
- Wrappa skärmar i `ThemedBackgroundScaffold` när de ska följa appens vanliga bakgrund och layoutstil.
- Implementera dialoger som privata widgets eller små hjälpmetoder och håll skapandet nära den feature som äger flödet.
- Använd navigationshjälparna i `core/utils/page_transitions.dart` när de täcker behovet.

## Layout och responsivitet
- Följ `AdaptiveLayoutInfo` och repoets breakpoints: compact `<600`, medium `>=600`, expanded `>=840`.
- Använd `ScreenUtil` via `.w` och `.h` för skalade mått. Kör aldrig `ScreenUtil.init()` i enskilda widgets.
- Undvik hårdkodade bredder och höjder som bryter på surfplatta eller liten mobil om flex, constraints eller layout-info räcker.
- Om en widget ritar dekorativa element som sticker utanför sin ordinarie storlek (tex hattar på en karaktär), använd `clipBehavior: Clip.none` på relevanta `Stack`-komponenter.

## Barnvänlig UX och copy
- Håll copy kort: ett verb och ett mål, till exempel "Spela nu" eller "Tryck på en prick".
- Ha en tydlig primär CTA per viktig vy. Sekundära val ska vara visuellt underordnade.
- Lägg inte teknisk jargong, råa fel eller externa länkar i barnflödet. Sådant hör hemma i föräldraläget.
- Skriv korrekt och enkel svenska. Lämna inte placeholders eller engelska resttexter i barnvyer.

## UI-assets och animation i presentation
- Följ repoets PNG-first-linje för UI-assets och mascot-runtime. Loke animeras med Flutter-transforms ovanpå PNG, inte via ny Rive- eller Lottie-runtime.
- För mascot-ytor: återanvänd i första hand befintliga komponenter som `GameCharacter` och `MascotReactionView` i stället för att starta en ny runtime-variant.
- Undvik globala overshoot-kurvor på `TweenSequence`; använd säkra kurvor för hela sekvensen och lägg extra effekt på item-nivå vid behov.