---
name: "play-release-router"
description: "Use when releasefrågan är oklar och du först behöver avgöra om den gäller Play closed beta-upload, listing-sync, release notes, versionsbump eller GitHub-release innan verifiering eller beslut"
argument-hint: "Beskriv målet, till exempel alpha-upload, butikstext, screenshots, versionsbump, release notes eller release readiness"
agent: "agent"
---

Gör en snabb routing av release- och Play-relaterat arbete så att rätt workflow, metadatafiler och QA-nivå väljs innan implementation, copy-pass eller go/no-go-bedömning.

Utgå från dessa källor:

- [docs/DEPLOY_ANDROID.md](../../docs/DEPLOY_ANDROID.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/prompts/play-listing-copy-pass.prompt.md](./play-listing-copy-pass.prompt.md)
- [.github/prompts/release-go-no-go.prompt.md](./release-go-no-go.prompt.md)
- [.github/workflows/build.yml](../workflows/build.yml)
- [.github/workflows/play-closed-beta.yml](../workflows/play-closed-beta.yml)
- [.github/workflows/play-store-listing.yml](../workflows/play-store-listing.yml)
- [fastlane/metadata/android/README.md](../../fastlane/metadata/android/README.md)
- [play/release-notes/whatsnew-sv-SE](../../play/release-notes/whatsnew-sv-SE)
- [play/release-notes/whatsnew-en-US](../../play/release-notes/whatsnew-en-US)
- [pubspec.yaml](../../pubspec.yaml)

Arbetsordning:

1. Klassificera målet först: GitHub-release med APK, Play closed beta-upload med AAB, Play listing-sync, copy/release notes eller ren go/no-go-bedömning.
2. Peka ut exakt källsanning för den ytan:
   - `build.yml` för signerad APK till GitHub Releases
   - `play-closed-beta.yml` för Play-upload av `.aab` och release notes från `play/release-notes/`
   - `play-store-listing.yml` och `fastlane/metadata/android/` för titel, beskrivningar, bilder och screenshots
3. Flagga när användarens fråga blandar binär-upload och listing-sync, och dela då upp arbetet i två separata spår.
4. Nämn om versionsbump, taggmatchning eller secrets är nödvändiga för just det spåret, utan att be om hemligheter i chatten.
5. Välj minsta rimliga nästa steg:
   - copy-pass för metadata-only
   - workflow-körning eller releaseplan för upload
   - `release-go-no-go` när användaren egentligen vill ha ett beslut, inte en ändring
6. Fatta inte själva go/no-go-beslutet här om användaren främst behöver routing; lämna då vidare till rätt nästa steg.

Svarskrav:

- Börja med `Detta gäller ...` och namnge rätt releaseyta.
- Lista rätt workflow, metadatafiler eller release notes-filer först.
- Säg tydligt vad som inte ingår i samma spår.
- Avsluta med ett enda rekommenderat nästa steg eller rätt prompt/agent att köra vidare.