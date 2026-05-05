---
name: "Formulär och validering"
description: "Use when editing TextField, TextFormField, dialogs, create-profile flows, TextEditingController, FocusNode or validation UX in Flutter UI."
applyTo: "lib/features/**/presentation/**/*.dart, lib/presentation/**/*.dart, **/*_dialog.dart, **/*_screen.dart"
---

# Formulär, inputs och validering

- Skapa `TextEditingController` och `FocusNode` i en stateful widget när de behövs, och stäng alltid ned dem i `dispose()`.
- Lägg inte controllers eller focus-noder i `build()` och låt dem inte bo i providers om de bara är UI-livscykel.
- Använd `Form` och `GlobalKey<FormState>` när flera fält eller samlad validering behövs. För små en-fältsdialoger räcker lokal `String?` för feltext.
- Visa fel intill fältet via `errorText`, hjälprad eller tydlig text nära inputen. Använd inte snackbar som primär valideringsyta.
- Trimma och normalisera input innan du sparar. Kontrollera tomma värden, dubbletter och uppenbara bounds innan repository-anrop.
- Vid async-validering eller sparning: disable primary action eller visa spinner så att dubbelsubmit inte kan ske.
- Håll dialogen eller skärmen öppen när användaren behöver rätta datan efter ett valideringsfel.