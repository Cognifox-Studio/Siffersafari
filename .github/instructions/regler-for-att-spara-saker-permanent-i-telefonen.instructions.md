---
name: "Offline-first och persistens"
description: "Use when editing Hive repositories, local storage, persistence formats or offline-first data handling. Covers defensive parsing, deterministic keys and merge back to user state."
applyTo: "lib/data/**, lib/core/services/storage/**, lib/features/**/data/**, **/*_repository.dart"
---

# Hive data och offline-first

- All Hive-åtkomst ska gå via repository-lagret. Gör inte `Hive.box()`-anrop i UI, providers eller domänlogik.
- Typvalidera data från disk defensivt innan den används. Lita inte blint på `dynamic` eller gammal lagrad struktur.
- Appen är strikt offline-first. Lägg inte in molnsync eller externa lagringstjänster för profil- eller spelardata.
- Använd deterministiska nycklar för tillfälligt state när en gammal session ska kunna skrivas över säkert.
- Mergea avslutad session tillbaka till spelarens permanenta profil. Mellansparning ersätter inte slutlig merge.
- När strängifierad data riskerar att ändras visuellt: versionsprefixa formatet, till exempel `v2|...`, i stället för att regex-parsa display-text i efterhand.
- Returnera säkra fallbacks om lagrad data är korrupt så att appen fortsätter fungera.
