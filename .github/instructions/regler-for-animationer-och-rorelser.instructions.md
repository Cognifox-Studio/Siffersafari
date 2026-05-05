---
name: "Animationer och rörelser"
description: "Use when editing Flutter animations, TweenSequence, mascot motion, loading effects or other UI movement. Covers crash pitfalls, hot restart caveats and current runtime limits."
applyTo: "lib/**/presentation/**/*.dart, lib/presentation/**/*.dart, **/*_animation*.dart, **/*_widget.dart"
---

# Flutter-animationer och UI-rörelser

- Undvik overshoot-kurvor som `Curves.easeOutBack` på hela `TweenSequence`. Det kan trigga krascher som `t >= 0.0 && t <= 1.0`. Lägg i stället starkare kurvor på item-nivå när det behövs.
- Om en animation konfigureras i `initState()` räcker inte alltid hot reload. Kör hot restart när ändringen annars inte verkar slå igenom.
- Följ repoets aktiva runtime: mascot-rörelser byggs i Flutter ovanpå PNG-assets. Lägg inte till ny Rive-, Lottie- eller pseudo-rigged PNG-runtime som kärnlösning.
- Återanvänd befintliga mascot-komponenter när det går, i stället för att skapa ännu en animationstack för samma figur.
- Tuning av timing och amplitud görs bäst i en isolerad preview eller liten testyta innan den flyttas in i en tung produktionsvy.