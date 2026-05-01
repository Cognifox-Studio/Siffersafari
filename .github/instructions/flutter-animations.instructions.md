---
description: "Regler och fallgropar för Flutter-animationer och UI-effekter"
applyTo: "lib/**/presentation/**/*.dart, **/*_animation*.dart, **/*_widget.dart"
---

# Flutter Animationer & Assets

- **TweenSequence och Overshoot:** För att undvika krascher (`Failed assertion: 't >= 0.0 && t <= 1.0'`), undvik kurvor med overshoot (som `Curves.easeOutBack`) för *hela* sekvensen i en `TweenSequence`. Använd i stället säkra base-kurvor (t.ex. `Curves.easeOut`) för sekvensen som helhet och sätt overshoot enbart på underliggande unika sekvens-items.
- **Hot Restart vid initState:** Om du byter värde på t.ex. en `Tween`, en kurva eller durations som initialiseras i `initState()`, kom ihåg att en vanlig Hot Reload *inte* uppdaterar befinliga State-objekt. Genomför en **Hot Restart** för att tillämpa ändringen, annars kan märkliga krascher eller uteblivna uppdateringar inträffa.
- **Mascot Runtime är procedurell SVG:** I produktions-UI ska rörelser och action-states (som "run") för maskotar ritas fram via procedurella biomekaniska SVG-skelett.
  - Vi pseudo-riggar *inte* enkla, statiska PNG-filer.
  - `.riv`-filerna är *research/future enhancement* och ingår inte i runtime nu.
- **Tuning av timing/amplitud:** Prova primärt ut timing och rörelseutslag separat via `motion-lab`/`clean preview` i stället för att gissa dig fram direkt i den sammansatta, tyngre produktionsvyn.