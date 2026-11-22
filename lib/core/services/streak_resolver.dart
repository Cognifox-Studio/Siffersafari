/// The result of applying one finished session to the daily streak.
class StreakOutcome {
  const StreakOutcome({
    required this.streak,
    required this.previousStreak,
    required this.continued,
    required this.graceUsed,
    required this.broken,
  });

  /// Streak after this session.
  final int streak;

  /// Streak before this session (0 when the profile has never played).
  final int previousStreak;

  /// True when today continued an existing streak, including via a grace day.
  final bool continued;

  /// True when a missed day was forgiven instead of resetting the streak.
  final bool graceUsed;

  /// True when a real streak (2+ days) was lost.
  final bool broken;

  @override
  String toString() => 'StreakOutcome(streak: $streak, previous: $previousStreak, '
      'continued: $continued, grace: $graceUsed, broken: $broken)';
}

/// How many days between grace days. One forgiven day per week.
const int streakGraceWindowDays = 7;

/// A grace day only rescues a *single* missed day; longer gaps still reset.
const int streakGraceMaxGapDays = 2;

/// Whether a grace day may be spent now.
///
/// Pure on purpose: the forgiving part of the streak rule is the part most
/// likely to drift, so it is decided here and tested directly.
bool isGraceAvailable({
  required DateTime? lastGraceUsedAt,
  required DateTime now,
}) {
  if (lastGraceUsedAt == null) return true;
  return _day(now).difference(_day(lastGraceUsedAt)).inDays >=
      streakGraceWindowDays;
}

/// Applies one session to the streak.
///
/// Same day: unchanged. Next day: plus one. One missed day: plus one and a
/// grace day is spent, so a sick day cannot wipe out weeks of practice. Anything
/// longer: the streak resets, and the caller is told what was lost so the app
/// can say something kind about it.
StreakOutcome resolveStreak({
  required int currentStreak,
  required DateTime? lastSessionDate,
  required DateTime now,
  bool graceAvailable = false,
}) {
  final today = _day(now);
  final safeCurrent = currentStreak < 1 ? 1 : currentStreak;

  if (lastSessionDate == null) {
    return const StreakOutcome(
      streak: 1,
      previousStreak: 0,
      continued: false,
      graceUsed: false,
      broken: false,
    );
  }

  final gap = today.difference(_day(lastSessionDate)).inDays;

  if (gap <= 0) {
    // Second session the same day, or a clock that moved backwards. Neither
    // should inflate the streak.
    return StreakOutcome(
      streak: safeCurrent,
      previousStreak: safeCurrent,
      continued: false,
      graceUsed: false,
      broken: false,
    );
  }

  if (gap == 1) {
    return StreakOutcome(
      streak: safeCurrent + 1,
      previousStreak: safeCurrent,
      continued: true,
      graceUsed: false,
      broken: false,
    );
  }

  if (graceAvailable && gap == streakGraceMaxGapDays && safeCurrent >= 2) {
    return StreakOutcome(
      streak: safeCurrent + 1,
      previousStreak: safeCurrent,
      continued: true,
      graceUsed: true,
      broken: false,
    );
  }

  return StreakOutcome(
    streak: 1,
    previousStreak: safeCurrent,
    continued: false,
    graceUsed: false,
    broken: safeCurrent >= 2,
  );
}

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
