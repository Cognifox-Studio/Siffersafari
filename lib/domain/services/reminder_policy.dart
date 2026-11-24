/// When a daily reminder is allowed to fire.
///
/// The platform call (`flutter_local_notifications`) is deliberately not here:
/// this is the part that must be right, and it must be provable in a test
/// without a device. The scheduler asks this, then schedules what it says.
class ReminderPolicy {
  const ReminderPolicy({
    required this.enabled,
    this.hour = 19,
    this.quietStartHour = 20,
    this.quietEndHour = 7,
  });

  /// Off unless a parent turned it on. Never a default.
  final bool enabled;

  /// Wished-for hour, local time.
  final int hour;

  /// Quiet hours wrap midnight: 20 -> 7 means no notification between them.
  final int quietStartHour;
  final int quietEndHour;

  bool get isQuietHours =>
      _inQuietRange(hour, quietStartHour, quietEndHour);

  /// The hour a reminder may actually use: the wish, moved into the allowed
  /// window rather than dropped. A reminder the parent asked for should be
  /// late, not missing.
  int get effectiveHour {
    if (!isQuietHours) return hour;
    return quietEndHour.clamp(0, 23);
  }

  /// The next time a reminder may fire, or null when it must not.
  ///
  /// At most one per day: if today's hour has passed, the answer is tomorrow.
  DateTime? nextFireTime({
    required DateTime now,
    required bool alreadySentToday,
  }) {
    if (!enabled) return null;
    if (alreadySentToday) return null;

    final today = DateTime(now.year, now.month, now.day, effectiveHour);
    if (today.isAfter(now)) return today;
    return today.add(const Duration(days: 1));
  }

  static bool _inQuietRange(int hour, int start, int end) {
    if (start == end) return false;
    if (start < end) return hour >= start && hour < end;
    // Wraps midnight.
    return hour >= start || hour < end;
  }
}
