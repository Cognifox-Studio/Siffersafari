---
description: "Use when editing GameCharacter rendering, wardrobe logic, or inventory items. Covers the Z-index based equipping system."
applyTo: "lib/presentation/widgets/game_character.dart, lib/features/inventory/presentation/widgets/wardrobe_dialog.dart, lib/domain/entities/inventory_item.dart"
---

# Regler för inventory och rendering (Z-index)

I Siffersafari använder vi inte "hardware slots" (t.ex. max en hatt, en tröja) för maskoten Loke. Målet är att barn ska kunna mixa utrustning hur som helst.

När du arbetar med `GameCharacter` och inventory, följ dessa regler:

1. **Ingen slot-begränsning:** 
   Logiken i `WardrobeDialog` måste tillåta att flera föremål av samma "typ" är utrustade samtidigt. Av/Påsättning styrs rent av item `id`, oberoende av vilka andra föremål som är valda.

2. **Z-index layout:** 
   I `GameCharacter` loopas de valda föremålen ut för rendering baserat på sitt `slotLayer` (Z-index). Mappa item ids direkt mot en definierad ordning. Vi hårdkodar inte platser i en Stack per föremålstyp, utan sorterar renderingsträdet dynamiskt.

3. **Maskot rendering:**
   Loke utgör baslagret. Alla föremål läggs sedan på som separata Positioned- eller Align-lager i en `Stack`, sorterade i Z-led.
