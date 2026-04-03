import '../../domain/entities/user_progress.dart';
import '../../domain/enums/difficulty_level.dart';
import '../../domain/enums/operation_type.dart';

/// Immutable data class for a single daily challenge.
class DailyChallenge {
  const DailyChallenge({
    required this.operation,
    required this.difficulty,
    required this.dateKey,
    required this.title,
  });

  final OperationType operation;
  final DifficultyLevel difficulty;

  /// Date in 'YYYY-MM-DD' format – used as persistence key.
  final String dateKey;
  final String title;
}

/// Generates the daily challenge parameters based on today's date.
///
/// Operation cycles every day through all four operations.
/// Difficulty alternates: easy on even days, medium on odd days.
/// The child always gets the same challenge for a given calendar day.
class DailyChallengeService {
  const DailyChallengeService();

  static const _operations = [
    OperationType.addition,
    OperationType.multiplication,
    OperationType.subtraction,
    OperationType.division,
  ];

  DailyChallenge getTodaysChallenge() {
    final now = DateTime.now();
    final day = _dayOfYear(now);
    final operation = _operations[day % _operations.length];
    final difficulty =
        day.isEven ? DifficultyLevel.easy : DifficultyLevel.medium;

    return DailyChallenge(
      operation: operation,
      difficulty: difficulty,
      dateKey: _todayKey(now),
      title: '${operation.emoji} ${operation.displayName}',
    );
  }

  DailyChallenge getTodaysChallengeForUser({
    required UserProgress user,
    required Set<OperationType> allowedOperations,
  }) {
    final now = DateTime.now();
    final day = _dayOfYear(now);

    final candidates = allowedOperations
        .where((op) => _operations.contains(op))
        .toList(growable: false);
    final operations = candidates.isNotEmpty ? candidates : _operations;

    final sortedByNeed = List<OperationType>.from(operations)
      ..sort((a, b) {
        final aScore = _learningScoreForOperation(user, a);
        final bScore = _learningScoreForOperation(user, b);
        final cmp = aScore.compareTo(bScore);
        if (cmp != 0) return cmp;
        return a.index.compareTo(b.index);
      });

    final poolSize = sortedByNeed.length >= 2 ? 2 : 1;
    final selectedOperation = sortedByNeed[day % poolSize];
    final selectedDifficulty =
        _difficultyForOperation(user, selectedOperation, day: day);

    return DailyChallenge(
      operation: selectedOperation,
      difficulty: selectedDifficulty,
      dateKey: _todayKey(now),
      title: '${selectedOperation.emoji} ${selectedOperation.displayName}',
    );
  }

  String todayKey() => _todayKey(DateTime.now());

  String _todayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  int _dayOfYear(DateTime date) {
    final start = DateTime(date.year);
    return date.difference(start).inDays;
  }

  double _learningScoreForOperation(UserProgress user, OperationType op) {
    final keyPrefix = '${op.name}_';
    final relevant = user.masteryLevels.entries
        .where((entry) => entry.key.startsWith(keyPrefix))
        .map((entry) => entry.value)
        .toList(growable: false);

    final masteryAverage = relevant.isEmpty
        ? 0.35
        : relevant.reduce((a, b) => a + b) / relevant.length;

    final step = (user.operationDifficultySteps[op.name] ?? 3).clamp(1, 10);
    final normalizedStep = (step - 1) / 9;

    // Lower score means the child likely benefits more from this operation.
    return (masteryAverage * 0.75) + (normalizedStep * 0.25);
  }

  DifficultyLevel _difficultyForOperation(
    UserProgress user,
    OperationType op, {
    required int day,
  }) {
    final keyPrefix = '${op.name}_';
    final relevant = user.masteryLevels.entries
        .where((entry) => entry.key.startsWith(keyPrefix))
        .map((entry) => entry.value)
        .toList(growable: false);
    final masteryAverage = relevant.isEmpty
        ? 0.35
        : relevant.reduce((a, b) => a + b) / relevant.length;

    final step = (user.operationDifficultySteps[op.name] ?? 3).clamp(1, 10);

    if (step >= 8 && masteryAverage >= 0.8) {
      return day.isEven ? DifficultyLevel.medium : DifficultyLevel.hard;
    }
    if (step >= 4 || masteryAverage >= 0.55) {
      return DifficultyLevel.medium;
    }
    return DifficultyLevel.easy;
  }
}
