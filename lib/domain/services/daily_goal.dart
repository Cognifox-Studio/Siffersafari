/// How many finished rounds count as "today's goal".
///
/// One round for the youngest — a session is ten questions and a lot of reading
/// for a seven-year-old — and two from Åk 3. Deliberately small: a goal you reach
/// builds a habit, a goal you fail becomes a chore. An unknown grade gets the
/// gentle target, because guessing high punishes the child for a missing setting.
int dailyGoalSessions({int? gradeLevel}) {
  final grade = gradeLevel ?? 0;
  return grade <= 2 ? 1 : 2;
}

/// Progress toward today's goal.
({int done, int target, bool achieved}) dailyGoalProgress({
  required int sessionsToday,
  int? gradeLevel,
}) {
  final target = dailyGoalSessions(gradeLevel: gradeLevel);
  final done = sessionsToday < 0 ? 0 : sessionsToday;
  return (done: done, target: target, achieved: done >= target);
}

/// Short, child-facing text for the goal line.
String dailyGoalLabel({required int done, required int target}) {
  final safeDone = done < 0 ? 0 : done;
  if (safeDone >= target) return 'Dagens mål klart';
  if (target == 1) return 'Dagens mål: en runda';
  return 'Dagens mål: $safeDone av $target rundor';
}
