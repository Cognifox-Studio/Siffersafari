---
name: "inventory-rendering-pass"
description: "Use when du ska ändra garderob, GameCharacter-rendering, equip-logik eller inventory-items och vill få rätt instruction, dolda call sites och minsta QA-slice först"
argument-hint: "Valfritt: ange fil, bugg eller yta som wardrobe, GameCharacter, item-rendering, equip-beteende eller inventory-reward"
agent: "agent"
---

Gör en snabb och repo-specifik routing för inventory- och rendering-slicen innan implementation, så att equip-regler, pose-koppling och dolda renderingsytor inte missas.

Utgå från dessa källor:

- [.github/instructions/regler-for-z-index-inventory.instructions.md](../instructions/regler-for-z-index-inventory.instructions.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [lib/presentation/widgets/game_character.dart](../../lib/presentation/widgets/game_character.dart)
- [lib/features/inventory/presentation/screens/wardrobe_screen.dart](../../lib/features/inventory/presentation/screens/wardrobe_screen.dart)
- [lib/domain/entities/inventory_item.dart](../../lib/domain/entities/inventory_item.dart)
- [lib/features/quiz/presentation/screens/results_screen.dart](../../lib/features/quiz/presentation/screens/results_screen.dart)
- [lib/features/quiz/presentation/dialogs/feedback_dialog.dart](../../lib/features/quiz/presentation/dialogs/feedback_dialog.dart)
- [test/unit/audits/wardrobe_hit_shape_audit_test.dart](../../test/unit/audits/wardrobe_hit_shape_audit_test.dart)
- [test/unit/logic/inventory_reward_unlock_test.dart](../../test/unit/logic/inventory_reward_unlock_test.dart)

Arbetsordning:

1. Läs Z-index-instruktionen först och sammanfatta vilka regler som faktiskt styr ändringen.
2. Klassificera ytan: equip-logik, renderingsordning, pose-kompatibilitet, offset/placering, hit-testing eller reward/inventory-koppling.
3. Peka ut vilka dolda eller sekundära call sites som måste kontrolleras utöver den namngivna filen, särskilt `results_screen.dart`, `feedback_dialog.dart` och andra vyer som återanvänder `GameCharacter`.
4. Välj minsta rimliga verifiering för slicen i stället för bred QA:
   - `wardrobe_hit_shape_audit_test.dart` för hit-testing och utrustningsytor
   - `inventory_reward_unlock_test.dart` för reward- och unlock-koppling
   - riktad analyze eller närmaste widgettest för rena renderings- eller call site-ändringar
5. Säg uttryckligen om användarens önskade ändring bryter mot fri mix via Z-index eller riskerar att återinföra hårda slots.
6. Om behovet egentligen gäller assetarbete i stället för renderingslogik:
   - använd `.github/skills/integrera-nya-assets/SKILL.md` när bilden redan finns i `_incoming/` eller ska föras in säkert i `assets/`
   - använd `.github/skills/skapa-bildbestallning/SKILL.md` när korrekt bildunderlag fortfarande saknas och behöver beställas

Svarskrav:

- Börja med vilken inventory/rendering-slice det faktiskt gäller.
- Lista matchande instruction först, sedan berörda filer och dolda call sites.
- Nämn minsta verifiering du rekommenderar innan implementation.
- Om scopet egentligen inte är inventory/rendering, säg det direkt och peka vidare till bättre prompt eller skill.