# Siffersafari CI/PR README

Detta repo kör automatiska tester och releaseflöden via GitHub Actions:

- **core smoke** (snabb, happy-path) körs på pull requests.
- **full smoke** (alla scenarier) + **audit** körs på push till main/master.

Viktigaste workflow-ankare — varje ansvar har **exakt en** ägare, så en PR inte
kör samma sak flera gånger:

- `.github/workflows/ci.yaml` — **`flutter analyze`** + Android-emulatorsmoke (core på PR, full + audit på huvudgrenen). Den tidigare `android-smoke.yml` körde exakt samma emulatortest som `ci.yaml` och är borttagen; lägg inte tillbaka den.
- `.github/workflows/flutter.yml` — hela enhets-/widgetsviten (`flutter test test`). Kör inte `analyze` här; det ägs av `ci.yaml`.
- `.github/workflows/release-guard.yml` — release-sanity + AAB-storleksgräns. Eftersom PR-körningar saknar keystore signeras artefakten med debug-nyckeln, vilket kräver `SIFFERSAFARI_ALLOW_DEBUG_RELEASE_SIGNING=true` (annars vägrar Gradle bygga en release-artefakt).
