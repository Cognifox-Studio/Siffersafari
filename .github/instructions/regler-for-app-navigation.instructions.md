---
name: "Navigering och övergångar"
description: "Use when editing push/pop, route handling, dialogs, back navigation or screen transitions in Flutter without an external router package."
applyTo: "lib/features/**/presentation/**/*.dart, lib/app/app.dart"
---

# App Navigation och övergångar

Siffersafari använder imperativ Flutter-navigering utan externt router-paket.

## Grundmönster
- Använd `context.pushSmooth(...)` för att gå djupare in i ett flöde där användaren ska kunna gå tillbaka.
- Använd `context.pushReplacementSmooth(...)` eller annan replacement bara när den gamla vyn inte längre ska ligga kvar i stacken, till exempel onboarding -> home eller quiz -> resultat.
- Använd `Navigator.of(context).maybePop()` när back-navigation kan träffa en tom stack.
- Stäng dialoger och modaler med `Navigator.of(context).pop(result)` när ett returvärde behövs.

## Context-säkerhet
- Efter `await` och före navigering eller dialog: kör alltid `if (!context.mounted) return;`.
- Håll navigation i UI-lagret. Services, repositories och providers ska inte ta emot `BuildContext` eller navigera själva.
- Om navigation måste triggas av global state: lyssna högt upp i widgetträdet via provider/listener i stället för att skicka navigator-nycklar djupt ned i arkitekturen.

## Praktiska regler
- Föredra repoets befintliga page transition-hjälpare framför att uppfinna nya transition-mönster per feature.
- Byt inte till replacement av slentrian. Om användaren rimligen ska kunna backa, använd vanlig push.
- Behåll dialog- och bottom-sheet-logik nära den feature som äger flödet.