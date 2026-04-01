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

  String todayKey() => _todayKey(DateTime.now());

  String _todayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  int _dayOfYear(DateTime date) {
    final start = DateTime(date.year);
    return date.difference(start).inDays;
  }
}
