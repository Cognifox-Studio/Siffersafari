# Siffersafari CI/PR README

Detta repo kör automatiska tester och releaseflöden via GitHub Actions:

- **core smoke** (snabb, happy-path) körs på pull requests.
- **full smoke** (alla scenarier) + **audit** körs på push till main/master.

Viktigaste workflow-ankare:

- `.github/workflows/ci.yaml` för core smoke på PR och full smoke + audit på huvudgrenen
- `.github/workflows/flutter.yml` för grundläggande analyze + test
- `.github/workflows/release-guard.yml` för release-sanity
