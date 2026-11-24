/// One calendar week, Monday 00:00 to the next Monday 00:00.
///
/// The quests on the story map measure *mastery* -- they never expire, which is
/// why they are kind. This window is the other half: a small goal that resets
/// every Monday so week two has something of its own, without turning a missed
/// day into a lost streak.
class WeekWindow {
  const WeekWindow(this.start);

  /// Monday 00:00 of the week that contains [now].
  factory WeekWindow.containing(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    // DateTime.weekday is 1 for Monday, 7 for Sunday.
    return WeekWindow(day.subtract(Duration(days: day.weekday - 1)));
  }

  final DateTime start;

  DateTime get end => start.add(const Duration(days: 7));

  /// True when [time] falls inside the window. The end is exclusive, so
  /// exactly midnight on Monday belongs to the new week.
  bool contains(DateTime time) =>
      !time.isBefore(start) && time.isBefore(end);

  /// Days until the window closes, counted from [now]: 0 on Sunday.
  int daysLeft(DateTime now) {
    final days = end.difference(DateTime(now.year, now.month, now.day)).inDays;
    return days.clamp(0, 7);
  }

  /// "denna vecka" is what a child reads; the number is for the parent.
  String get label {
    // ISO week number, without a dependency: week 1 is the week holding the
    // first Thursday of the year.
    final thursday = start.add(const Duration(days: 3));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstMonday = firstThursday.subtract(
      Duration(days: firstThursday.weekday - 1),
    );
    final week = 1 + thursday.difference(firstMonday).inDays ~/ 7;
    return 'Vecka $week';
  }
}
