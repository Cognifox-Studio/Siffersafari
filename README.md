# Siffersafari

<p align="center"><strong>Offline-first mattespel för barn (ca 6–12 år).</strong><br>
Quiz, storyäventyr och PIN-skyddat föräldraläge — utan konto eller molnsync.</p>

<p align="center">
  <a href="https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/flutter.yml"><img src="https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/flutter.yml/badge.svg" alt="Flutter CI"></a>
  <a href="https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/build.yml"><img src="https://github.com/Cognifox-Studio/Siffersafari/actions/workflows/build.yml/badge.svg" alt="Build and Release APK"></a>
  <a href="https://github.com/Cognifox-Studio/Siffersafari/releases"><img src="https://img.shields.io/github/v/release/Cognifox-Studio/Siffersafari?display_name=tag" alt="Latest release"></a>
</p>

<p align="center">
  <a href="https://github.com/Cognifox-Studio/Siffersafari/releases/latest/download/app-release.apk"><strong>Ladda ner APK</strong></a>
  ·
  <a href="docs/SESSION_BRIEF.md"><strong>Aktuellt läge</strong></a>
  ·
  <a href="docs/README.md"><strong>Dokumentation</strong></a>
</p>

**Kodversion i repo:** `1.4.3+21` (se `pubspec.yaml`).  
**Senaste GitHub Release-tagg:** kan ligga lite efter — kolla [Releases](https://github.com/Cognifox-Studio/Siffersafari/releases) för installbar APK.

---

## Vad appen är i dag

Barnets väg:

**Profil → Hem → Quiz → Resultat → Storykarta / Camp**

| Del | Status |
| --- | --- |
| Quiz med adaptiv svårighet | Redo — Åk 1–9, valda räknesätt |
| Flera barnprofiler på samma telefon | Redo |
| Storykarta + uppdrag / biome-teaser | Redo (presentation-first; nästa värld teasas) |
| Camp, belöningar, garderob | Redo |
| Pedagogisk hjälp i feedbackdialogen | Redo (alla fyra räknesätt) |
| Uppläsning (TTS) per profil, föräldrarstyrd | Redo, offline |
| Föräldraläge bakom PIN | Redo |
| Teman Djungel och Rymd | Redo |

**Medvetet senare** (inte buggar, utan avgränsning): bråk/decimaler, diagram/grafer som frågeform, full visuell geometri, handskrift, molnsync, sociala funktioner. Se [docs/ACTIVE_PLAN.md](docs/ACTIVE_PLAN.md) och [docs/KUNSKAPSNIVA_PER_AK.md](docs/KUNSKAPSNIVA_PER_AK.md).

---

## Varför Siffersafari?

- Fungerar **offline** — ingen inloggning, ingen tracking i kärnflödet
- **Adaptiv** träning i stället för fasta paket
- **Förälder** kan styra innehåll och se översikt utan att störa barnets fokus
- Android-first, COPPA-medveten riktning (inga trackers / ingen OTA i produkten)

---

## Installera

### Från GitHub Releases

1. Öppna [Releases](https://github.com/Cognifox-Studio/Siffersafari/releases).
2. Ladda ner `app-release.apk`.
3. Installera på Android (tillåt okända källor om enheten frågar).

Direktlänk: [app-release.apk (latest)](https://github.com/Cognifox-Studio/Siffersafari/releases/latest/download/app-release.apk)

### Play / closed beta

Distribution via Google Play används också i teamets releaseflöde. Repo-APK:n ovan är den öppna installvägen från GitHub.

---

## Förstå repot (börja här)

Du behöver inte läsa hela `docs/` först.

| Du vill… | Öppna |
| --- | --- |
| Veta hur vi jobbar (Now, DoD, AI-loop) | [docs/DEV_SYSTEM.md](docs/DEV_SYSTEM.md) |
| Veta när något är “klart” | [docs/DEFINITION_OF_DONE.md](docs/DEFINITION_OF_DONE.md) |
| Veta vad som är Now / levererat | [docs/SESSION_BRIEF.md](docs/SESSION_BRIEF.md) |
| Se Next / Later | [docs/ACTIVE_PLAN.md](docs/ACTIVE_PLAN.md) |
| Hitta rätt skärm / feature | [lib/features/START_HERE.md](lib/features/START_HERE.md) |
| Spåra quiz → resultat → lagring | [docs/TRACE_MAP.md](docs/TRACE_MAP.md) |
| Förstå matte per årskurs | [docs/KUNSKAPSNIVA_PER_AK.md](docs/KUNSKAPSNIVA_PER_AK.md) |
| Full doc-index | [docs/README.md](docs/README.md) |

---

## Snabbstart för utveckling

Full miljö: [docs/SETUP_ENVIRONMENT.md](docs/SETUP_ENVIRONMENT.md)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Rekommenderat lokalflöde på emulatorn `Pixel_6`:

```bash
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action sync
powershell -ExecutionPolicy Bypass -File scripts/flutter_pixel6.ps1 -Action run
```

Kvalitet:

```bash
flutter analyze
flutter test
```

CI kör analyze/test. Release-workflow bygger signerad APK från `v*`-taggar. Mer: [docs/DEPLOY_ANDROID.md](docs/DEPLOY_ANDROID.md).

---

## Teknik (kort)

- Flutter / Dart 3, Android-first
- Riverpod + GetIt + Hive
- Feature-first UI under `lib/features/`
- PNG-first maskot/figur (Loke), proceduranimationer i Flutter
- Curriculum/facit i `docs/curriculum_facit.json` + årskursbanker

```text
lib/
├── app/           # bootstrap, routing
├── features/      # home, quiz, story, parent, …
├── presentation/  # delade widgets (t.ex. GameCharacter)
├── core/          # services, providers, theme
├── domain/
└── data/
```

---

## Bidra / säkerhet

- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)
- [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md)
- [SECURITY.md](SECURITY.md)

---

## Licens

Privat projekt. Alla rättigheter förbehållna.
