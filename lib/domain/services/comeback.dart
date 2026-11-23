import 'package:siffersafari/domain/enums/operation_type.dart';

/// Where the app stops being a habit and starts being a memory.
///
/// Two days off is a weekend. Three days off means the child has to *decide*
/// to come back, and the round she meets then decides whether she comes back
/// again -- so it should feel like something she can do.
const int comebackGapDays = 3;

/// True when the first round after a break should be gentler than usual.
///
/// Compared by calendar day, not by hours: a child who played Monday evening
/// and returns Thursday morning has been away three days, not two and a half.
bool isComebackGap({
  required DateTime? lastSessionDate,
  required DateTime now,
  int gapDays = comebackGapDays,
}) {
  if (lastSessionDate == null) return false;
  final gap = _day(now).difference(_day(lastSessionDate)).inDays;
  return gap >= gapDays;
}

/// One step down, never below [minStep].
///
/// Deliberately one step and not more: the goal is a first round that ends in
/// "jag kan det här", not a round that says the app thinks she forgot
/// everything. Mastery comes back on its own -- the adaptive service climbs
/// again as soon as she answers well.
int softenedStepForComeback(int step, {int minStep = 1}) {
  final safeMin = minStep < 1 ? 1 : minStep;
  if (step <= safeMin) return safeMin;
  return step - 1;
}

/// A softened copy of [steps] where only [operation] is one step easier.
///
/// The other operations keep their place: she has not been away from them in
/// this round, and the map is what the next rounds start from.
Map<OperationType, int> softenedStepsForComeback(
  Map<OperationType, int> steps, {
  required OperationType operation,
  int minStep = 1,
}) {
  final current = steps[operation];
  if (current == null) return Map<OperationType, int>.of(steps);
  return Map<OperationType, int>.of(steps)
    ..[operation] = softenedStepForComeback(current, minStep: minStep);
}

DateTime _day(DateTime time) => DateTime(time.year, time.month, time.day);
