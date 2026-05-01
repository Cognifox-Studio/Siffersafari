---
description: "Regler för affärslogik, tjäster och domändriven arkitektur (Separation of Concerns)"
applyTo: "lib/domain/**, lib/core/services/**, **/*_service.dart, **/*_usecase.dart"
---

# Domain & Core Services (Affärslogik och Tjänster)

För att bevara appens plattformsoberoende testbarhet (`flutter test`) och "offline-first"-fokus måste service-lagret vara extremt isolerat från UI:t.

## lib/domain/ (Kärnlogik & Modeller)
- **Pure Dart (Flutter-fritt):** Kod under `lib/domain/` får **ABSOLUT INTE** importera `package:flutter/...` (t.ex. `material.dart`, `widgets.dart` eller `colors.dart`). Detta lager är för ren affärslogik (t.ex. svårighetsgradsberäkningar, Spaced Repetition, validering) och ska kunna köras i enkla Dart-script. 
- **Oberoende:** Får inte referera till eller ha kännedom om databaser (Hive, SQL) eller yttre ramverk (Riverpod).

## lib/core/services/ (Appnära Tjänster)
- **Teknisk Integration:** Här ligger integrationer med plattformen (ljud via `AudioService`, mätning via `AnalyticsService`, Hive via `StorageService`). Dessa tjänster får använda Flutter-paket och bibliotek. 
- **Ingen UI-kännedom:** Tjänster får aldrig ta emot `BuildContext` som parameter. De får inte visa dialoger, "toasts" eller navigera (`context.push`). Fel och resultat returneras (t.ex. via Exceptions, Result-klasser eller returvärden) som UI-lagret (`Presentation`/`Features`) sedan tolkar och bestämmer hur det ska visas.

## API-Kontrakt och Koppling
- **Exponering:** En service anropas asynkront (`Future<T>`) eller synkront och tar emot basdata (Primitives, Entities) och returnerar basdata. Skicka aldrig hela Riverpod `Notifier`-states in i en service. 
- **Ingen State Management i Services:** Tjänsterna (services) upprätthåller bara tillfällig runtime-funktionalitet eller statisk beräkningseffekt, all reaktiv state som ritar om UI ska ligga i Riverpod `Notifiers`, som i sin tur konsumerar dessa tjänster.