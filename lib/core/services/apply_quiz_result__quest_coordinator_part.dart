part of 'apply_quiz_result_use_case.dart';

class _QuestResultCoordinator {
  const _QuestResultCoordinator(this._questStateService);

  final UserQuestStateService _questStateService;

  Future<_QuestResult> apply({
    required UserProgress previousUser,
    required UserProgress updatedUser,
  }) async {
    QuestCompletionSummary? questCompletion;

    final initialReconciliation =
        await _questStateService.reconcileQuestPointer(previousUser);
    final completedQuestIds = _questStateService.readCompletedQuestIds(
      previousUser.userId,
    );
    final currentQuestId =
        _questStateService.readCurrentQuestId(previousUser.userId) ??
            _questStateService.firstQuestIdFor(previousUser);

    final beforeQuestStatus = _questStateService.getQuestStatusWith(
      user: updatedUser,
      currentQuestId: currentQuestId,
      completedQuestIds: completedQuestIds,
    );

    if (beforeQuestStatus.isCompleted &&
        !completedQuestIds.contains(beforeQuestStatus.quest.id)) {
      final updatedCompleted = {
        ...completedQuestIds,
        beforeQuestStatus.quest.id,
      };
      final nextId = _questStateService.nextQuestIdFor(
        user: updatedUser,
        currentQuestId: beforeQuestStatus.quest.id,
      );
      await _questStateService.setQuestState(
        userId: previousUser.userId,
        currentQuestId: nextId ?? beforeQuestStatus.quest.id,
        completedQuestIds: updatedCompleted,
      );
      questCompletion = QuestCompletionSummary(
        completedQuestId: beforeQuestStatus.quest.id,
        completedQuestTitle: beforeQuestStatus.quest.title,
        completedQuestDescription: beforeQuestStatus.quest.description,
      );
    }

    final finalReconciliation =
        await _questStateService.reconcileQuestPointer(updatedUser);
    final questStatus = finalReconciliation.questStatus;
    final resolvedQuestCompletion = questCompletion == null
        ? null
        : QuestCompletionSummary(
            completedQuestId: questCompletion.completedQuestId,
            completedQuestTitle: questCompletion.completedQuestTitle,
            completedQuestDescription:
                questCompletion.completedQuestDescription,
            nextQuestTitle:
                questStatus.quest.id == questCompletion.completedQuestId
                    ? null
                    : questStatus.quest.title,
          );

    return _QuestResult(
      questStatus: questStatus,
      resolvedQuestCompletion: resolvedQuestCompletion,
      questNotice:
          finalReconciliation.questNotice ?? initialReconciliation.questNotice,
    );
  }
}
