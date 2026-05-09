---
description: "Use when editing text, copy, buttons or dialogs in Flutter UI. Covers short action-driven phrasing and separation of adult/child vocabulary."
applyTo: "lib/**/presentation/**/*.dart, lib/presentation/**/*.dart"
---

# Regler för språk och ton (Barn-UX)

När du lägger till eller ändrar texter i UI (Siffersafari):

- **Korta texter som grund:** Instruktioner kortas till ett verb och ett mål (t.ex. "Spela nu", "Tryck på en prick").
- **Inga komplicerade fraser:** Undvik tekniska, formella eller "vuxna" formuleringar i barnets huvudflöde.
- **Vuxen-UI isolerat:** Inställningar, hantering av personuppgifter, radering av data eller konfiguration läggs alltid bakom Parent Mode (`Föräldraläge`). Barnet ska aldrig råka på en destruktiv åtgärd eller systeminställning.
- **Primär åtgärd i fokus (1 primär CTA):** En skärm ska kännas omedelbart självklar, med begränsat antal utmanande val. Minska "clutter" (ex. ta bort undertexter i svar-knappar).