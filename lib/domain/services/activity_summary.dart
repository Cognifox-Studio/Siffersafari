/// A compact read of the last days of play: how many sessions each day held,
/// oldest first.
///
/// The counters already exist on the device (`DailyActivityService`, 90 days,
/// no trackers). What was missing was a way to *read* them: a parent asking
/// "is this becoming a habit?" needs a shape, not an event log.
class ActivitySummary {
  const ActivitySummary({
    required this.sessionsPerDay,
    required this.activeDays,
    required this.longestRun,
    required this.currentRun,
  });

  /// One entry per day, oldest first. Negative counts are treated as zero --
  /// a corrupt value should never make a day look busier than it was.
  factory ActivitySummary.fromDailyCounts(Iterable<int> sessionsOldestFirst) {
    final days = sessionsOldestFirst
        .map((sessions) => sessions < 0 ? 0 : sessions)
        .toList(growable: false);

    var activeDays = 0;
    var longestRun = 0;
    var run = 0;
    for (final sessions in days) {
      if (sessions > 0) {
        activeDays++;
        run++;
        if (run > longestRun) longestRun = run;
      } else {
        run = 0;
      }
    }

    // The run that is still going: consecutive days with play, counting back
    // from the most recent day.
    var currentRun = 0;
    for (var index = days.length - 1; index >= 0; index--) {
      if (days[index] == 0) break;
      currentRun++;
    }

    return ActivitySummary(
      sessionsPerDay: days,
      activeDays: activeDays,
      longestRun: longestRun,
      currentRun: currentRun,
    );
  }

  final List<int> sessionsPerDay;

  /// Days with at least one finished session.
  final int activeDays;

  /// Longest stretch of consecutive days with play.
  final int longestRun;

  /// Stretch that ends on the most recent day (0 if that day was empty).
  final int currentRun;

  int get totalDays => sessionsPerDay.length;

  bool get isEmpty => activeDays == 0;

  /// The busiest single day, used to scale the darkest square.
  int get busiestDay =>
      sessionsPerDay.isEmpty
          ? 0
          : sessionsPerDay.reduce((a, b) => a > b ? a : b);

  /// Whether the day at [index] had any play. Out-of-range is false, so a
  /// layout bug shows an empty square instead of throwing in a parent's face.
  bool playedOn(int index) =>
      index >= 0 && index < sessionsPerDay.length && sessionsPerDay[index] > 0;
}
