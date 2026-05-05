---
name: "Dependency injection"
description: "Use when editing GetIt registration, injection.dart, dependency wiring or service registration lifecycles. Covers singleton strategy, registration guards and Riverpod bridges."
applyTo: "lib/core/di/**, lib/**/injection.dart"
---

# Dependency Injection (GetIt)

- Håll service-registrering samlad i DI-lagret. Registrera inte beroenden ad hoc ute i features eller testad appkod.
- Skydda mot dubbelregistrering när samma init-väg kan köras flera gånger, till exempel vid testsetup eller varm omstart.
- Föredra `registerLazySingleton()` när servicen inte måste initieras direkt vid uppstart.
- Använd repoets `_perf(...)`-loggning i DI-lagret för tunga init-steg när uppstartstid är relevant.
- När en service ska användas i UI-lagret: exponera den via en liten Riverpod-brygga i stället för att sprida `getIt<T>()` över widgetträd och features.
- Behåll tydlig gräns mellan instansiering, wiring och faktisk affärslogik.