import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import 'local_storage_repository_provider.dart';

const _baseOperations = <OperationType>[
  OperationType.addition,
  OperationType.subtraction,
  OperationType.multiplication,
  OperationType.division,
];

/// Manages parent-controlled settings: per-user allowed math operations.
///
/// Caches allowed operations for each user and persists changes to local storage.
/// Prevents empty sets (ensures at least one operation is always allowed).
/// Automatically loads settings on demand via [ensureLoaded].
class ParentSettingsNotifier
    extends StateNotifier<Map<String, Set<OperationType>>> {
  ParentSettingsNotifier(this._repository) : super(const {});

  final LocalStorageRepository _repository;

  Set<OperationType> allowedOperationsFor(String userId) {
    return state[userId] ?? _baseOperations.toSet();
  }

  void ensureLoaded(String userId) {
    if (state.containsKey(userId)) return;
    loadAllowedOperations(userId);
  }

  void loadAllowedOperations(
    String userId, {
    Set<OperationType>? defaultOperations,
  }) {
    final rawList = _repository.getAllowedOperationNames(userId);
    final fallback = defaultOperations ?? _baseOperations.toSet();

    var ops = rawList
        .map(_operationFromName)
        .whereType<OperationType>()
        .where(_baseOperations.contains)
        .toSet();

    if (ops.isEmpty) {
      ops = fallback;
    }

    state = {
      ...state,
      userId: ops,
    };
  }

  OperationType? _operationFromName(String name) {
    if (name.isEmpty) return null;
    return OperationType.values.asNameMap()[name];
  }

  Future<void> setOperationAllowed(
    String userId,
    OperationType operation,
    bool allowed,
  ) async {
    final current = allowedOperationsFor(userId);
    if (current.contains(operation) == allowed) return;

    final updated = allowed
        ? {...current, operation}
        : current.where((op) => op != operation).toSet();

    if (updated.isEmpty) {
      // Never allow an empty set; keep current.
      return;
    }

    state = {
      ...state,
      userId: updated,
    };

    await _repository.setAllowedOperationNames(
      userId,
      updated.map((op) => op.name).toList(growable: false),
    );
  }

  Future<void> setAllowedOperations(
    String userId,
    Set<OperationType> ops,
  ) async {
    final sanitized = ops.where(_baseOperations.contains).toSet();
    if (sanitized.isEmpty) return;

    state = {
      ...state,
      userId: sanitized,
    };

    await _repository.setAllowedOperationNames(
      userId,
      sanitized.map((op) => op.name).toList(growable: false),
    );
  }
}

final parentSettingsProvider = StateNotifierProvider<ParentSettingsNotifier,
    Map<String, Set<OperationType>>>(
  (ref) {
    final repository = ref.watch(localStorageRepositoryProvider);
    return ParentSettingsNotifier(repository);
  },
);
