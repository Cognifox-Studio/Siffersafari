part of 'apply_quiz_result_use_case.dart';

class _LevelRewardUnlocker {
  _LevelRewardUnlockResult apply({
    required UserProgress user,
    required int oldLevel,
  }) {
    InventoryItem? newlyUnlockedItem;
    var finalUnlockedItems = user.unlockedItems;

    if (user.level > oldLevel) {
      newlyUnlockedItem = InventoryConfig.nextLevelUnlock(finalUnlockedItems);
      if (newlyUnlockedItem != null) {
        finalUnlockedItems = [...finalUnlockedItems, newlyUnlockedItem.id];
      }
    }

    final finalUser = user.copyWith(unlockedItems: finalUnlockedItems);

    return _LevelRewardUnlockResult(
      finalUser: finalUser,
      newlyUnlockedItem: newlyUnlockedItem,
      levelUpEvent: user.level > oldLevel
          ? LevelUpEvent(
              oldLevel: oldLevel,
              newLevel: user.level,
              newTitle: user.levelTitle,
            )
          : null,
    );
  }
}
