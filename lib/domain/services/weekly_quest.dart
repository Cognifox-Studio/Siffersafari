import 'package:siffersafari/domain/services/week_window.dart';

/// How many finished rounds a week asks for.
///
/// Four is one more than the gentle daily goal times three: reachable in four
/// short sittings, so a child who played Monday and Tuesday still has room to
/// finish on Sunday without a marathon.
int weeklyQuestTarget({int? gradeLevel}) => (gradeLevel ?? 0) <= 2 ? 3 : 4;

/// A week's small goal, measured from rounds that have already happened.
///
/// There is no new storage and no new counter: the quiz history already carries
/// a start time per finished round, so the quest is a *view* of the week -- and
/// on Monday it starts over by itself, because the window moved.
class WeeklyQuest {
  const WeeklyQuest({
    required this.window,
    required this.done,
    required this.target,
  });

  final WeekWindow window;
  final int done;
  final int target;

  bool get isComplete => done >= target;

  double get progress => target <= 0 ? 1 : (done / target).clamp(0, 1);

  /// "2 av 4 rundor" -- count first, like every other number in the app.
  String get progressLabel => isComplete
      ? 'Veckans mål klart'
      : '$done av $target rundor';

  /// Said out loud: no emoji, no ambiguity about whose week it is.
  String get spokenLabel =>
      '${window.label}. Veckans mål: $progressLabel.';
}

/// Builds this week's quest from rounds that ended inside the current window.
///
/// Rounds in progress are ignored: a quest should not tick because a session
/// was started and abandoned. Anything unreadable counts as zero instead of
/// throwing -- a broken history row must never block the home screen.
WeeklyQuest weeklyQuestFor({
  required Iterable<Map<String, dynamic>> history,
  required DateTime now,
  int? gradeLevel,
}) {
  final window = WeekWindow.containing(now);
  var done = 0;

  for (final round in history) {
    if (round['isComplete'] != true) continue;
    final finished = _finishedAt(round);
    if (finished == null || !window.contains(finished)) continue;
    done++;
  }

  return WeeklyQuest(
    window: window,
    done: done,
    target: weeklyQuestTarget(gradeLevel: gradeLevel),
  );
}

DateTime? _finishedAt(Map<String, dynamic> round) {
  for (final key in const ['endTime', 'startTime']) {
    final raw = round[key];
    if (raw == null) continue;
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed != null) return parsed.toLocal();
  }
  return null;
}
