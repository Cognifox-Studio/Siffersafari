---
name: flytta-ut-logik-fran-ui
description: 'Extract business logic, side effects or heavy state handling from Flutter widgets into providers, notifiers or domain use cases. Use when UI code is too smart or hard to test.'
argument-hint: 'Beskriv vilken widget eller callback som innehåller för mycket logik i dag.'
---

# Flytta ut logik från UI

## Syfte
Den här skillen används när affärslogik, sidoeffekter eller tung tillståndshantering behöver bort från widgetträdet och in i testbara enheter.

## Arbetsflöde
1. Identifiera logiken i widgeten: `setState`, komplexa callbacks, livscykelkopplad affärslogik eller UI som direkt anropar flera services.
2. Avgör om logiken hör hemma i provider-lagret eller i ren domän/use case.
3. Flytta app-state till provider/notifier som följer den stil som redan äger området i repo:t.
4. Flytta ren affärslogik till `lib/domain/` eller use case-klass och håll den fri från Flutter-beroenden.
5. Peka om UI till `ref.read(...)` för actions och `ref.watch(...)` för rendering.
6. Säkerställ att lösningen följer `.github/instructions/regler-for-att-uppdatera-information-pa-skarmen.instructions.md` och `.github/instructions/regler-for-appens-inre-logik.instructions.md`.
7. Verifiera med `flutter analyze` och relaterade tester.
