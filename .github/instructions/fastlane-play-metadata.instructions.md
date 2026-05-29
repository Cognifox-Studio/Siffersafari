---
name: "Fastlane Play metadata"
description: "Use when editing fastlane/Fastfile, fastlane/metadata/android/**, play/release-notes/** or Play listing workflows. Covers track-safe metadata sync, localized file layout and Play copy hygiene."
applyTo: "fastlane/Fastfile, fastlane/metadata/android/**, play/release-notes/**, .github/workflows/play-store-listing.yml, .github/workflows/play-closed-beta.yml"
---

# Fastlane Play metadata

- `fastlane/metadata/android/` ar kallsanningen for butikssidetext och valfria listing-bilder.
- `play/release-notes/` ar kallsanningen for release notes som skickas med AAB-uploaden.
- Håll listing-sync och binär-upload separata: blanda inte full butikssides-metadata in i `play-closed-beta.yml` utöver `whatsNewDirectory`.
- Metadata-sync ska vara spårsäkert. Om inget annat uttryckligen efterfrågas ska listing-flödet utgå från `alpha`, inte `production`.
- Håll locale-filerna i sync för `sv-SE` och `en-US` när samma fält stöds i båda språken.
- Lova inte funktioner eller policyegenskaper som inte stöds av repo:t. Kontrollera särskilt påståenden mot [docs/PRIVACY_POLICY.md](../../docs/PRIVACY_POLICY.md) och [docs/DEPLOY_ANDROID.md](../../docs/DEPLOY_ANDROID.md).
- När listing-bilder förbereds: kopiera från verifierade källor som `assets/images/app_icon/` och `artifacts/play_console_phone_9x16/`; flytta inte originalen.
- Om `featureGraphic` eller annan obligatorisk listing-yta saknar verklig källa ska det sägas uttryckligen, inte döljas med placeholder eller rå skärmdump.