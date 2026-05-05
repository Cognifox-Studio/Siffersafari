---
name: "Domänlogik och tjänster"
description: "Use when editing lib/domain, services, use cases or business rules. Covers separation of concerns, pure Dart domain logic and UI-free orchestration."
applyTo: "lib/domain/**, lib/core/services/**, **/*_service.dart, **/*_usecase.dart"
---

# Domain och core services

För att bevara testbarhet och offline-first-arkitektur måste affärslogik hållas isolerad från UI-lagret.

## `lib/domain/`
- Kod i `lib/domain/` ska vara ren Dart och får inte importera `package:flutter/...`.
- Domänmodeller och regler ska inte känna till Hive, Riverpod eller andra yttre ramverk.
- Lägg spelregler, progression, SRS och annan plattformsoberoende logik här när den inte behöver UI eller device-API:er.

## `lib/core/services/` och use cases
- Services hanterar tekniska integrationer som ljud, analytics och lagring.
- Use cases används när ett flöde kräver flera steg eller flera beroenden och annars skulle svälla upp provider eller UI-kod.
- Services och use cases får inte ta emot `BuildContext`, visa dialoger eller navigera.

## API-kontrakt
- Skicka in rena datatyper, primitiver eller domänobjekt. Skicka inte in hela notifier- eller widget-state-objekt i tjänstelagret.
- Returnera tydliga resultat eller kasta välformulerade fel. UI-lagret ansvarar för hur det visas.
- Håll services så stateless som möjligt. Reaktiv state som påverkar rendering ska ägas av providers.