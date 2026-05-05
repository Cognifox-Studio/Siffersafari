---
name: "Async och loading"
description: "Use when editing async providers, AsyncValue, loading indicators, retry states or asynchronous submit flows in Flutter UI and providers."
applyTo: "lib/**/providers/**/*.dart, lib/features/**/presentation/**/*.dart"
---

# Async operationer och loading states

- Modellera async-status tydligt i provider-state. Använd `AsyncValue` där det passar, eller en explicit status i state-klassen om omgivande kod redan är `StateNotifier`-baserad.
- Sprid inte ut flera lokala `isLoading`-flaggor i widgetträdet när en och samma provider äger flödet.
- Under async-anrop ska knappar och andra actions skyddas mot dubbelanrop med disabled state eller spinner.
- Kapsla repository- och serviceanrop i `try/catch` och lyft upp tydliga fel till state. Svälj inte felet tyst.
- Om användaren kan återhämta sig från felet ska UI visa en tydlig felvy eller knapp för "Försök igen".
- Håll transienta UI-effekter som snackbar, dialog eller navigation i widget-lagret. Providern ska exponera state, inte trigga UI direkt.