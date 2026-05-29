---
name: "play-listing-copy-pass"
description: "Granska eller skriv om Play Store-copy for Siffersafari innan manuell inklistring eller sync via fastlane/metadata/android. Use when short description, full description, release notes eller butikstext behover kortas, skarpas eller oversattas."
argument-hint: "Valfritt: ange sprak, yta som kort beskrivning/full beskrivning/release notes eller mal som closed beta eller butikssida."
agent: "agent"
---

Gor ett kort och repo-forankrat copy-pass for Play Store utan att blanda in appkod eller release-workflows.

Utga fran dessa källor:

- [fastlane/metadata/android/README.md](../../fastlane/metadata/android/README.md)
- [fastlane/metadata/android/sv-SE/title.txt](../../fastlane/metadata/android/sv-SE/title.txt)
- [fastlane/metadata/android/sv-SE/short_description.txt](../../fastlane/metadata/android/sv-SE/short_description.txt)
- [fastlane/metadata/android/sv-SE/full_description.txt](../../fastlane/metadata/android/sv-SE/full_description.txt)
- [fastlane/metadata/android/en-US/title.txt](../../fastlane/metadata/android/en-US/title.txt)
- [fastlane/metadata/android/en-US/short_description.txt](../../fastlane/metadata/android/en-US/short_description.txt)
- [fastlane/metadata/android/en-US/full_description.txt](../../fastlane/metadata/android/en-US/full_description.txt)
- [play/release-notes/whatsnew-sv-SE](../../play/release-notes/whatsnew-sv-SE)
- [play/release-notes/whatsnew-en-US](../../play/release-notes/whatsnew-en-US)
- [README.md](../../README.md)
- [docs/DEPLOY_ANDROID.md](../../docs/DEPLOY_ANDROID.md)
- [docs/PRIVACY_POLICY.md](../../docs/PRIVACY_POLICY.md)

Arbetsordning:

1. Las aktuell metadatafil forst, inte bara docs.
2. Hall copy repo-sann: lova inte features, onlinefunktioner, export, ads-frihet eller tracking-frihet utan att det stods av koden eller privacy-dokumenten.
3. Prioritera klar, vuxenlasbar butikstext framfor intern utvecklarjargong.
4. Om anvandaren bara ber om text, svara med fardiga block att klistra in manuellt.
5. Om anvandaren ber om uppdatering i repo:t, foresla eller skriv den minsta metadataandringen i ratt locale-fil.

Svarskrav:

- Lista exakt vilka metadatafalt du andrade eller foreslar.
- Ge sluttexten som ren inklistringstext.
- Om en text ar tveksam eller for marknadsig, sag det uttryckligen och ge en stramare version.
- Om svenska och engelska driver isar, namn ut det i stallet for att gissa.