---
name: "inventory-rendering-pass"
description: "Use when du ska ändra garderob, GameCharacter, camp-props/souvenirer, equip-logik eller inventory-items och vill få rätt instruction, call sites och minsta QA-slice först"
argument-hint: "Valfritt: wardrobe, GameCharacter, camp/piedestal, souvenir, equip, reward-unlock"
agent: "agent"
---

Gör en snabb routing för inventory-/rendering-slicen innan implementation, så att equip-regler, camp-ytor och dolda call sites inte missas.

Utgå från dessa källor:

- [.github/instructions/regler-for-z-index-inventory.instructions.md](../instructions/regler-for-z-index-inventory.instructions.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [lib/features/inventory/START_HERE.md](../../lib/features/inventory/START_HERE.md)
- [lib/presentation/widgets/game_character.dart](../../lib/presentation/widgets/game_character.dart)
- [lib/features/inventory/presentation/screens/wardrobe_screen.dart](../../lib/features/inventory/presentation/screens/wardrobe_screen.dart)
- [lib/domain/entities/inventory_item.dart](../../lib/domain/entities/inventory_item.dart)
- [lib/features/home/presentation/widgets/camp_scene_view.dart](../../lib/features/home/presentation/widgets/camp_scene_view.dart)
- [lib/features/home/presentation/widgets/camp_collection_album.dart](../../lib/features/home/presentation/widgets/camp_collection_album.dart)
- [lib/features/quiz/presentation/screens/results_screen.dart](../../lib/features/quiz/presentation/screens/results_screen.dart)
- [lib/features/quiz/presentation/dialogs/feedback_dialog.dart](../../lib/features/quiz/presentation/dialogs/feedback_dialog.dart)
- [test/unit/audits/wardrobe_hit_shape_audit_test.dart](../../test/unit/audits/wardrobe_hit_shape_audit_test.dart)
- [test/unit/logic/inventory_reward_unlock_test.dart](../../test/unit/logic/inventory_reward_unlock_test.dart)
- [test/widget/app_home_test.dart](../../test/widget/app_home_test.dart)

Arbetsordning:

1. Läs Z-index-instruktionen först och sammanfatta vilka regler som styr ändringen.
2. Klassificera ytan: equip/wardrobe, `GameCharacter`-rendering, **camp-souvenir/piedestal** (`slot == 'camp'`), pet-slot, reward-unlock, eller hit-testing.
3. Peka ut sekundära call sites:
   - wardrobe + `GameCharacter` (home, results, feedback)
   - camp: `camp_scene_view.dart` (`visibleCampPedestalItems`), `camp_collection_album.dart` (`campSouvenirItems`)
   - pets hör **inte** hemma som vanliga piedestal-props
4. Välj minsta verifiering:
   - `wardrobe_hit_shape_audit_test.dart` / `wardrobe_screen_test.dart` för garderobsytor
   - `inventory_reward_unlock_test.dart` för katalog/unlock/souvenirordning
   - `app_home_test.dart` för camp-scen, badge/album, piedestaler
   - riktad analyze för rena renderingsändringar
5. Flagga om ändringen bryter fri mix via Z-index eller återinför hårda slots.
6. Om det egentligen är assetarbete: `integrera-nya-assets` eller `skapa-bildbestallning` via `asset-flow-router`.

Svarskrav:

- Börja med vilken inventory/camp/rendering-slice det gäller.
- Lista instruction, berörda filer och dolda call sites.
- Nämn minsta verifiering innan implementation.
- Om scopet inte är inventory/rendering: peka vidare direkt.
