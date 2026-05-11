---
description: "Use when handling raw art in _incoming/, promoting approved images into assets/, or updating asset-bound code for inventory, story maps, theme bundles or character overlays."
applyTo: "_incoming/**, assets/**/*.png, lib/domain/entities/inventory_item.dart, lib/presentation/widgets/game_character.dart, lib/core/theme/app_theme_config.dart, lib/features/story/presentation/screens/story_map_screen.dart, pubspec.yaml"
---

# Hantering av _incoming och assets/

Anpassa bildflödet till appens verkliga assetfamiljer och PNG-first-runtime.

## Namngivning enligt ägande yta

1. Byt namn på råa filer innan de används i appen.
2. Följ den familj som den ägande koden redan använder:
   - inventory och wearables: `item_*`
   - UI-ikoner: `ic_*`
   - större UI-bilder och panelillustrationer: `img_*`
   - avatarer: följ befintlig `avatar_*`- eller `img_avatar_*`-familj i den aktuella ytan
   - theme-buntar: `background.png`, `quest_hero.png` och `character.png` under `assets/images/themes/<theme>/`
   - karaktärsposer: följ karaktärens befintliga posefamilj i `assets/characters/<character>/png/` i stället för att hitta på en ny standard
3. Skapa inte nya prefix eller mappfamiljer när en passande redan finns i repo:t.

## Cutout vs full scen

1. Frilagda objekt som inventory-items, ikoner och andra overlay-assets ska sparas som par:
   - original: `item_shoes_safari.png`
   - transparent version: `item_shoes_safari_nobg.png`
2. Gamla suffix som `_clear` är förbjudna.
3. Fulla bakgrunder och scenbilder, som theme backgrounds, quest heroes, story art och andra hela kart- eller miljöbilder, behöver inte `_nobg` om koden inte uttryckligen kräver det.

## Inkorg och arkiv i _incoming

1. Oanvända WIP-filer ligger löst i roten av `_incoming/`.
2. När en bild har kopierats in i appen ska originalen sorteras i rätt rå-arkiv:
   - `_incoming/items/`
   - `_incoming/characters/`
   - `_incoming/ui/`
   - `_incoming/icons/`
   - `_incoming/story/`
   - `_incoming/themes/`
3. Original och eventuell `_nobg`-variant ska ligga kvar tillsammans.

## Promotion till assets/

1. Kopiera alltid från `_incoming/` till `assets/`. Flytta inte.
2. Lägg bilden i den familj som den ägande koden redan refererar till:
   - inventory: `assets/images/items/`
   - UI: `assets/images/ui/`
   - story: `assets/images/story/`
   - themes: `assets/images/themes/<theme>/`
   - karaktärer: `assets/characters/<character>/png/`
3. Om du introducerar en ny target-mapp eller ett nytt theme-spår, verifiera att `pubspec.yaml` fortfarande täcker den mappen innan du anser jobbet klart.

## Repo-specifika bildkrav

1. Inventory-bilder ska fungera som overlay ovanpå `GameCharacter`: tydlig siluett, transparent bakgrund när asseten ska ligga framför eller ovanpå kroppen, och centrum/tyngdpunkt som fungerar med offset-placering.
2. Theme-art bör normalt beställas som en sammanhängande bunt: `background`, `quest_hero` och `character`.
3. Story map-art ska passa en rullbar kartvy och inte anta text, fotorealism eller små detaljer som försvinner i mobilstorlek.

## Asset manifest

1. När helt nya filer kopieras in i `assets/` räcker inte alltid Hot Reload eller Hot Restart, särskilt inte på Flutter Web.
2. Starta om `flutter run` helt för att bygga om asset-manifestet när nya filer inte hittas.