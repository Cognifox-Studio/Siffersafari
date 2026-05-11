---
name: skapa-bildbestallning
description: 'Generate a repo-specific illustrator brief and AI image prompts for missing UI art, story-map art, theme bundles, inventory items or character overlays in the current app.'
argument-hint: 'Beskriv vilken vy, assetfamilj eller kodyta som saknar grafik.'
---

# Skapa bildbeställning

## Syfte
Den här skillen tar fram en repo-specifik bildbeställning för redan byggda ytor i Siffersafari. Den ska utgå från faktisk kod, faktiska asset-paths och repo:ts PNG-first-runtime.

## Arbetsflöde
1. Identifiera ägande kodväg först. Kontrollera relevanta ytor i `lib/features/`, `lib/core/theme/app_theme_config.dart`, `lib/domain/entities/inventory_item.dart`, `lib/presentation/widgets/game_character.dart` eller annan faktiskt ägande fil.
2. Bekräfta att behovet gäller en befintlig yta i appen, inte en roadmap-idé.
3. Sök i `assets/` och `_incoming/` först för att bevisa vad som redan finns. Använd `artifacts/` endast som visuell referens, inte som facit för asset-existens.
4. Klassificera asseten innan briefen skrivs:
   - `cutout`: item, ikon, UI-objekt eller overlay som normalt behöver transparent version (`_nobg`)
   - `full scene`: bakgrund, story-scen, quest hero eller annan hel miljöbild som normalt inte kräver `_nobg`
   - `theme bundle`: ett sammanhängande paket med `background`, `quest_hero` och `character`
5. Skapa en illustratörsbrief i två delar:
   - **Globala krav:** platt 2D-stil, barnvänlig form, tydliga siluetter, inga gradients eller 3D-effekter, COPPA-säker grafik och leverans som PNG eller format som enkelt kan exporteras till PNG för repo:ts PNG-first-runtime.
   - **Asset-lista:** Markdown-tabell med `| Föreslaget filnamn | Kategori | Föreslagen target path | Target size i UI | Behöver _nobg? | Plats och syfte | Beskrivning |`.
6. Gör briefen repo-specifik:
   - inventory ska följa `item_*` och fungera som overlay ovanpå `GameCharacter`
   - UI-ikoner och UI-bilder ska följa befintliga `ic_*`, `img_*`, `avatar_*` eller `img_avatar_*`-familjer där de redan finns
   - theme-art ska använda `assets/images/themes/<theme>/`
   - story-art ska passa `assets/images/story/` och story map-flödet
7. Generera engelska AI-prompter för ChatGPT/Copilot. Inled med: `CRITICAL INSTRUCTION: Do not rewrite this prompt. Use it EXACTLY as written.`
8. Promptarna ska vara COPPA-säkra: inga fotorealistiska ansikten, inga verkliga personer, ingen text i bilden om den inte uttryckligen behövs, och inga bakgrundsscener när bara ett frilagt objekt efterfrågas.
9. Om asseten är `cutout`, be om ren enkel bakgrund eller tydlig friläggning så att `_nobg`-versionen kan tas fram utan artefakter.
10. **Automatiskt utförande (när du ges tillåtelse):**
   - skapa eller hämta originalbilden
   - spara originalet i `_incoming/<filnamn>.png`
   - skapa vid behov `_incoming/<filnamn>_nobg.png`
   - kontrollera att original och eventuell `_nobg` följer repo:ts namngivning
   - kopiera därefter filer till rätt plats i `assets/` i stället för att flytta dem
11. Svara kort på svenska.
12. Säg bara att filer ligger klara i `_incoming/` när bilder faktiskt har skapats eller laddats ner. Om du bara har skrivit en brief ska svaret tydligt säga det.
