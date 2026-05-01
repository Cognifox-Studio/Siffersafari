---
description: "Konventioner för Dependency Injection (GetIt) och service-registrering"
applyTo: "lib/core/di/**, lib/**/injection.dart, **/*_service.dart"
---

# Dependency Injection (GetIt)

- **Guard mot dubbelregistrering:** Innan du registrerar en ny service i `injection.dart`, använd **alltid** en guard: `if (!getIt.isRegistered<ServiceType>()) { ... }`. Detta förhindrar krascher vid varma omstarter i testning och Flutter.
- **Prestandalogging:** Tyngre services (t.ex. databaser, ljudmotorer) ska wrappas i appens interna `_perf(...)`-logger under initialiseringen för att säkerställa att uppstartstider kan spåras.
- **Lazy Load som Standard:** Föredra `getIt.registerLazySingleton()` över vanliga singletons om inte servicen uttryckligen krävs direkt vid app-start (runApp). Omedelbar initiering kan bromsa TTI (Time to Interactive).
- **Riverpod Brygga:** GetIt hanterar den faktiska instansieringen, men UI/feature-lagret ska alltid få tillgång till servicen via en Riverpod `Provider`. Om du skapar be `AuthService`, skapa också en `final authServiceProvider = Provider((ref) => getIt<AuthService>());`. App-kod använder **måste** använda `ref.read(authServiceProvider)`.