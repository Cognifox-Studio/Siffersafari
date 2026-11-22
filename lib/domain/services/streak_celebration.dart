/// What the results screen says about a child's streak.
///
/// The streak has been persisted for a long time but only the home screen's
/// badge ever mentioned it -- the moment the child actually *earns* the next
/// day, the results screen said nothing. This is the one line that closes that
/// loop: after a round, the number is said out loud, and when the round also
/// set a new personal best the app says so.
///
/// Every day a growing streak is a new personal best, so `isRecord` is true on
/// any day the streak grows. That is deliberate: a record should be reachable
/// every day, not once in a childhood.
class StreakCelebration {
  const StreakCelebration({
    required this.days,
    required this.isRecord,
    required this.label,
    required this.value,
  });

  /// Days in a row, as the child counts them.
  final int days;

  /// True when this round set a new personal best.
  final bool isRecord;

  /// Stat-pill caption, e.g. `Dagar i rad`.
  final String label;

  /// Stat-pill number, e.g. `5`.
  final String value;
}

/// Returns the streak line for the results screen, or null when there is
/// nothing honest to celebrate.
///
/// [currentStreak] is read *after* the round has been committed, so it already
/// includes today. A streak of zero means the child is starting over; we stay
/// quiet rather than point at it.
StreakCelebration? streakCelebration({
  required int currentStreak,
  required int longestStreak,
}) {
  if (currentStreak <= 0) return null;

  // Two days is the shortest run that is worth calling a record; "1 dag" is
  // simply the first day, not an achievement to beat.
  final isRecord = currentStreak >= 2 && currentStreak >= longestStreak;

  final caption = currentStreak == 1 ? 'Dag i rad' : 'Dagar i rad';

  return StreakCelebration(
    days: currentStreak,
    isRecord: isRecord,
    label: isRecord ? '$caption – rekord!' : caption,
    value: '$currentStreak',
  );
}
