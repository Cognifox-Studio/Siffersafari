---
name: "asset-flow-router"
description: "Use when working with assets, _incoming/, missing art, screenshots, icons or Play listing graphics and you need the right Siffersafari workflow first."
argument-hint: "Valfritt: beskriv asset-uppgiften, namnge filer eller säg om det gäller app-assets, bildbeställning, rendering eller Play listing."
agent: "agent"
---

Starta asset-arbete i Siffersafari med minsta säkra routing och utan att blanda ihop råa filer, runtime-assets och Play-listingmaterial.

Utgå från dessa källor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/AGENTS.md](../AGENTS.md)
- [.github/instructions/regler-for-bildfiler-i-incoming.instructions.md](../instructions/regler-for-bildfiler-i-incoming.instructions.md)
- [.github/instructions/asset-runtime-consumption.instructions.md](../instructions/asset-runtime-consumption.instructions.md)
- [.github/instructions/fastlane-play-metadata.instructions.md](../instructions/fastlane-play-metadata.instructions.md)
- [.github/skills/integrera-nya-assets/SKILL.md](../skills/integrera-nya-assets/SKILL.md)
- [.github/skills/skapa-bildbestallning/SKILL.md](../skills/skapa-bildbestallning/SKILL.md)
- [.github/skills/synka-play-assets/SKILL.md](../skills/synka-play-assets/SKILL.md)
- [.github/prompts/inventory-rendering-pass.prompt.md](./inventory-rendering-pass.prompt.md)
- [.github/prompts/story-theme-asset-pass.prompt.md](./story-theme-asset-pass.prompt.md)

Arbetsordning:

1. Inventera faktiska filer i `assets/` och `_incoming/` först. Anta inte att en bild saknas innan disk-koll.
2. Klassificera sedan uppgiften i en huvudklass:
   - promotion av rå bild från `_incoming/` till appens `assets/` -> använd `integrera-nya-assets`
   - saknad grafik för en redan existerande yta -> använd `skapa-bildbestallning`
   - Play Console-bilder, screenshots, ikon eller feature graphic -> använd `synka-play-assets`
   - story map-, theme bundle-, home hero- eller startup-asset som verkar ägas av flera Dart-ytor -> använd `story-theme-asset-pass.prompt.md`
   - inventory-, wardrobe- eller `GameCharacter`-rendering kring items -> använd `inventory-rendering-pass.prompt.md`
3. Peka ut rätt instruction-yta innan implementation:
   - `regler-for-bildfiler-i-incoming.instructions.md` för `_incoming/`, namngivning och asset-promotion
   - `asset-runtime-consumption.instructions.md` för story/theme/home-ytor som redan konsumerar assets i runtime
   - `fastlane-play-metadata.instructions.md` för Fastlane-metadata, listing-copy och Play-workflows
4. Välj minsta rimliga verifiering:
   - filkontroll eller diffgranskning för briefar, rena metadataändringar eller listing-sync
   - `QA: Analyze` och fokuserad UI- eller widgetverifiering när runtime-kod ändras
   - Pixel_6 sync/install bara när rendering, navigation, asset-manifest eller devicebeteende faktiskt påverkas
5. Håll app-assets, råmaterial och listing-assets separerade. Flytta inte original ur `_incoming/`.

Svarskrav:

- Börja med en kort routingrekommendation.
- Nämn vald skill eller prompt, relevant instruction-yta och minsta QA-slice.
- Säg uttryckligen om ingen extra skill behövs.
- Skapa inte en stor plan om uppgiften är liten.