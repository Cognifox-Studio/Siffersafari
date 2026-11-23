import 'package:siffersafari/domain/enums/operation_type.dart';

/// One round that a child can point at and say "that was my best".
///
/// Read-only: it is derived from the quiz history that is already stored, so
/// there is no new field to migrate and no way for it to drift out of sync with
/// what the child actually did.
class PersonalBest {
  const PersonalBest({
    required this.operation,
    required this.correct,
    required this.total,
  });

  final OperationType operation;
  final int correct;
  final int total;

  /// 0..1. A child who answered 9 of 10 is at 0.9.
  double get accuracy => total <= 0 ? 0 : correct / total;

  /// "9 av 10 i Gånger-djungeln" -- correct answers first, because that is the
  /// number a child counts.
  String get label =>
      '$correct av $total i ${operation.displayName.toLowerCase()}';
}

/// Best round per operation, from history records that are already complete.
///
/// [excludeSessionId] keeps the round that just ended out of the comparison, so
/// "nytt personbästa" means it beat something that existed before it.
Map<OperationType, PersonalBest> personalBestsFrom(
  Iterable<Map<String, dynamic>> history, {
  String? excludeSessionId,
}) {
  final best = <OperationType, PersonalBest>{};

  for (final session in history) {
    if (session['isComplete'] != true) continue;
    if (excludeSessionId != null &&
        session['sessionId']?.toString() == excludeSessionId) {
      continue;
    }
    final operation = _operationFrom(session['operationType']);
    if (operation == null) continue;

    final total = _asInt(session['totalQuestions']);
    final correct = _asInt(session['correctAnswers']);
    if (total <= 0 || correct < 0) continue;

    final candidate = PersonalBest(
      operation: operation,
      correct: correct,
      total: total,
    );
    final current = best[operation];
    if (current == null || _isBetter(candidate, current)) {
      best[operation] = candidate;
    }
  }

  return best;
}

/// True when [session] is a better round in [operation] than anything in
/// [history] -- used to celebrate, never to scold.
bool isNewPersonalBest({
  required String operationType,
  required int correct,
  required int total,
  required Iterable<Map<String, dynamic>> history,
  String? excludeSessionId,
}) {
  final operation = _operationFrom(operationType);
  if (operation == null || total <= 0) return false;

  final previous = personalBestsFrom(
    history,
    excludeSessionId: excludeSessionId,
  )[operation];
  if (previous == null) return false;

  return _isBetter(
    PersonalBest(operation: operation, correct: correct, total: total),
    previous,
  );
}

/// More correct answers wins; at equal accuracy the round that asked more
/// questions wins, so 9/10 beats 5/5 -- a bigger round is the braver one.
bool _isBetter(PersonalBest candidate, PersonalBest current) {
  if (candidate.correct != current.correct) {
    return candidate.correct > current.correct;
  }
  return candidate.total > current.total;
}

OperationType? _operationFrom(Object? raw) {
  if (raw == null) return null;
  final name = raw.toString();
  for (final operation in OperationType.values) {
    if (operation.name == name) return operation;
  }
  return null;
}

int _asInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  return int.tryParse(raw?.toString() ?? '') ?? 0;
}
