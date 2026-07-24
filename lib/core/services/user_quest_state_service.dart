import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

class UserQuestReconciliationResult {
  const UserQuestReconciliationResult({
    required this.questStatus,
    this.questNotice,
  });

  final QuestStatus questStatus;
  final String? questNotice;
}

class UserQuestStateService {
  const UserQuestStateService(this._repository, this._questProgressionService);

  final LocalStorageRepository _repository;
  final QuestProgressionService _questProgressionService;

  static const _baseOperations = <OperationType>{
    OperationType.addition,
    OperationType.subtraction,
    OperationType.multiplication,
    OperationType.division,
  };

  Set<OperationType> effectiveAllowedOperationsFor(UserProgress user) {
    final parentAllowed = _readParentAllowedOperations(user.userId);
    return DifficultyConfig.effectiveAllowedOperations(
      parentAllowedOperations: parentAllowed,
      gradeLevel: user.gradeLevel,
    );
  }

  Set<String> readCompletedQuestIds(String userId) {
    return _repository.getCompletedQuestIds(userId);
  }

  String? readCurrentQuestId(String userId) {
    return _repository.getCurrentQuestId(userId);
  }

  String firstQuestIdFor(UserProgress user) {
    return _questProgressionService.firstQuestId(
      user,
      allowedOperations: effectiveAllowedOperationsFor(user),
    );
  }

  String? nextQuestIdFor({
    required UserProgress user,
    required String currentQuestId,
  }) {
    return _questProgressionService.nextQuestId(
      user: user,
      currentQuestId: currentQuestId,
      allowedOperations: effectiveAllowedOperationsFor(user),
    );
  }

  QuestStatus getQuestStatusWith({
    required UserProgress user,
    required String? currentQuestId,
    required Set<String> completedQuestIds,
  }) {
    return _questProgressionService.getCurrentStatus(
      user: user,
      currentQuestId: currentQuestId,
      completedQuestIds: completedQuestIds,
      allowedOperations: effectiveAllowedOperationsFor(user),
    );
  }

  Future<void> setQuestState({
    required String userId,
    required String currentQuestId,
    required Set<String> completedQuestIds,
  }) async {
    await _repository.setCurrentQuestId(userId, currentQuestId);
    await _repository.setCompletedQuestIds(userId, completedQuestIds);
  }

  Future<UserQuestReconciliationResult> reconcileQuestPointer(
    UserProgress user,
  ) async {
    await _ensureQuestInitialized(user);

    final completed = readCompletedQuestIds(user.userId);
    final current = readCurrentQuestId(user.userId);

    final status = getQuestStatusWith(
      user: user,
      currentQuestId: current,
      completedQuestIds: completed,
    );

    if (current == status.quest.id) {
      return UserQuestReconciliationResult(questStatus: status);
    }

    await _repository.setCurrentQuestId(user.userId, status.quest.id);
    final label = user.gradeLevel != null
        ? 'Årskurs ${user.gradeLevel}'
        : user.ageGroup.displayName;

    final charId = user.selectedCharacterId;
    final charName = charId.isNotEmpty
        ? charId[0].toUpperCase() + charId.substring(1)
        : AppConstants.mascotName;

    return UserQuestReconciliationResult(
      questStatus: status,
      questNotice: '$charName anpassade uppdraget till $label.',
    );
  }

  Set<OperationType> _readParentAllowedOperations(String userId) {
    final rawList = _repository.getAllowedOperationNames(userId);
    if (rawList.isNotEmpty) {
      final ops = rawList
          .map(_operationFromName)
          .whereType<OperationType>()
          .where(_baseOperations.contains)
          .toSet();

      if (ops.isNotEmpty) return ops;
    }

    return {..._baseOperations};
  }

  OperationType? _operationFromName(String name) {
    for (final op in OperationType.values) {
      if (op.name == name) return op;
    }
    return null;
  }

  Future<void> _ensureQuestInitialized(UserProgress user) async {
    final current = readCurrentQuestId(user.userId);
    if (current != null) return;

    await _repository.setCurrentQuestId(user.userId, firstQuestIdFor(user));
    await _repository.setCompletedQuestIds(user.userId, <String>{});
  }
}
