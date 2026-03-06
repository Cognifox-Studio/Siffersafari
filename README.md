# Siffersafari

Ett pedagogiskt mattespel för barn (6–12 år) som lär grundläggande matematik genom interaktiva övningar, quiz och progressionssystem.

Fokus: **Android-only**, **offline-first**, flera barnprofiler.

[![Flutter CI](https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/flutter.yml/badge.svg)](https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/flutter.yml)
[![Build and Release APK](https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/build.yml/badge.svg)](https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/Cognifox-Studio/Siffersafari?display_name=tag)](https://github.com/Cognifox-Studio/Siffersafari/releases)

## Installera APK (Android)

1. Gå till [Releases](https://github.com/Cognifox-Studio/Siffersafari/releases)
2. Ladda ner `app-release.apk` (senaste version)
3. Öppna filen på Android och installera
4. Tillåt "Installera okända appar" för webbläsare/filhanterare vid behov

Direktlänk till senaste APK (när release finns):
[https://github.com/Cognifox-Studio/Siffersafari/releases/latest/download/app-release.apk](https://github.com/Cognifox-Studio/Siffersafari/releases/latest/download/app-release.apk)

## Snabblänkar

- [📚 Dokumentation](#-dokumentation)
- [Status](#status-2026-03-05)
- [Funktioner](#funktioner)
- [Teknisk Stack](#teknisk-stack)
- [Arkitektur](#arkitektur)
- [Installation (Utveckling)](#installation-utveckling)
- [Testning](#testning)
- [Säkerhet](SECURITY.md)
- [Contributing](docs/CONTRIBUTING.md)

---

## 📚 Dokumentation

**Ny till projektet?** Börja här: **[docs/README.md](docs/README.md)** ← Central documentation hub

Dokumentationen är organiserad enligt **Diátaxis-ramverket**:
- 📖 **Tutorials** — Kom igång snabbt
- 🔧 **How-To Guides** — Praktiska instruktioner
- 📋 **Reference** — Tekniska detaljer
- 💡 **Explanation** — Förklara varför

---

## Status (2026-03-05)

Projektet är i ett fungerande MVP+-läge med:
- Quizflöde (hem → quiz → resultat)
- Multi-user profiler (skapa/välj aktiv användare)
- Profilval vid start när flera profiler finns
- Enkel profil-avatar (emoji) per barn
- Årskurs per användare (Åk 1-9) som styr effektiv svårighet
- Progression (poäng, nivå, titel, medalj, svit/streak, snabbbonus ⚡)
- Föräldraläge (PIN, dashboard, rekommenderad övning, räknesätt per användare)
	- PIN lagras som **SHA-256-hash** (inte klartext)
	- **Rate-limiting**: 5 felaktiga försök → 5 min lockout
- Onboarding och widget-test
- Global felhantering (för bättre diagnostik vid oväntade fel)

Senaste verifiering: kör `flutter test` lokalt för aktuell status.

## Funktioner

- **Adaptiv Svårighetsgrad**: Automatisk justering baserad på prestanda (70-80% framgångsfrekvens)
- **Spaced Repetition**: Vetenskapligt bevisad repetitionsalgoritm för långsiktig inlärning
- **Ålders-/Årskursanpassat Innehåll**: Tre åldersgrupper och stöd för Åk 1-9
- **Föräldra/Lärardashboard**: Detaljerad analys och framstegsvisualisering
- **Lokal datalagring (Hive)**: Kärnflödet använder lokal persistens
- **Temabaserad Design**: Engagerande teman (rymd, djungel)
- **Belöningssystem**: Stjärnor, medaljer, svit/streak och snabbbonus ⚡ för motivation

## Känd scope just nu

- Offline-funktionalitet är implementerad via lokal lagring men ej fullständigt validerad i testplan.
- Tillgänglighet, integrationstest och prestandaoptimering återstår.

## Teknisk Stack

- **Framework**: Flutter 3.x
- **Språk**: Dart 3.x
- **State Management**: Riverpod
- **Lokal Databas**: Hive
- **Ljud**: audioplayers
- **Animationer**: Lottie
- **UI**: flutter_screenutil

## Arkitektur

Projektet följer Clean Architecture-principer:

```
lib/
├── domain/          # Business logic, entiteter
├── data/            # Datakällor, repositories
├── presentation/    # UI, skärmar, widgets
└── core/            # Delad funktionalitet, services
```

**För arkitektur-detaljer:** se [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

**För folder-layout:** se [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)

**För pedagogisk mappning:** se [docs/KUNSKAPSNIVA_PER_AK.md](docs/KUNSKAPSNIVA_PER_AK.md)

## Installation (Utveckling)

**För detaljerad setup-guide:** se [docs/SETUP_ENVIRONMENT.md](docs/SETUP_ENVIRONMENT.md)

Kort version:

```bash
# Installera dependencies
flutter pub get

# Generera kod (Hive adapters, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Kör appen
flutter run
```

**QA före commit:** se [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)

**Rekommenderat (Android):** Pixel_6-script för deterministisk install

Om du märker att emulatorn ibland kör “fel APK” (gamla ändringar), använd scriptet som alltid riktar mot **Pixel_6** och kan köra ett deterministiskt build+install-flöde:

```bash
# SYNC: bygg + installera exakt APK + starta om appen (säkrast när emulatorn måste matcha koden)
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync

# RUN: dev-läge med hot reload
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action run
```

Det finns även VS Code tasks som använder samma flöde.

## Testning

Se `CONTRIBUTING.md` för rekommenderad QA-rutin och VS Code-tasks.

Snabbkommandon:

```bash
flutter analyze
flutter test
```

## Licens

Privat projekt - Alla rättigheter förbehållna.
