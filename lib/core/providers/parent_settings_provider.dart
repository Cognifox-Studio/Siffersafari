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

Set<OperationType> _defaultAllowedOperations() => _baseOperations.toSet();

/// Manages parent-controlled settings: per-user allowed math operations.
///
/// Uses a stable [userId] family key so each profile gets isolated provider
/// state and persisted settings.
class ParentSettingsNotifier extends StateNotifier<Set<OperationType>> {
  ParentSettingsNotifier(this._repository, this._userId)
      : super(
          _readAllowedOperations(repository: _repository, userId: _userId),
        );

  final LocalStorageRepository _repository;
  final String _userId;

  static Set<OperationType> _readAllowedOperations({
    required LocalStorageRepository repository,
    required String userId,
    Set<OperationType>? defaultOperations,
  }) {
    final rawList = repository.getAllowedOperationNames(userId);
    final fallback = defaultOperations ?? _defaultAllowedOperations();

    var ops = rawList
        .map(_operationFromName)
        .whereType<OperationType>()
        .where(_baseOperations.contains)
        .toSet();

    if (ops.isEmpty) {
      ops = fallback;
    }

    return ops;
  }

  static OperationType? _operationFromName(String name) {
    if (name.isEmpty) return null;
    return OperationType.values.asNameMap()[name];
  }

  Future<void> setOperationAllowed(
    OperationType operation,
    bool allowed,
  ) async {
    if (state.contains(operation) == allowed) return;

    final updated = allowed
        ? {...state, operation}
        : state.where((op) => op != operation).toSet();

    if (updated.isEmpty) {
      // Never allow an empty set; keep current.
      return;
    }

    state = updated;

    await _repository.setAllowedOperationNames(
      _userId,
      updated.map((op) => op.name).toList(growable: false),
    );
  }

  Future<void> setAllowedOperations(Set<OperationType> ops) async {
    final sanitized = ops.where(_baseOperations.contains).toSet();
    if (sanitized.isEmpty) return;

    state = sanitized;

    await _repository.setAllowedOperationNames(
      _userId,
      sanitized.map((op) => op.name).toList(growable: false),
    );
  }
}

final parentSettingsProvider = StateNotifierProvider.family<
    ParentSettingsNotifier, Set<OperationType>, String>((ref, userId) {
  final repository = ref.watch(localStorageRepositoryProvider);
  return ParentSettingsNotifier(repository, userId);
});
