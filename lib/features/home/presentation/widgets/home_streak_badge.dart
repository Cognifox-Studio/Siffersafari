import 'package:flutter/material.dart';

/// The daily practice streak, on the home screen.
///
/// The streak has always been persisted (`UserProgress.currentStreak`) and it
/// resets itself correctly, but nothing ever rendered it: a child could practise
/// for weeks without learning that the days add up. Loss aversion only works if
/// the thing in danger is visible.
///
/// Deliberately a plain strip rather than a badge: it has to survive a 200 %
/// text scale on a small phone, and it must never look like a threat.
class HomeStreakBadge extends StatelessWidget {
  const HomeStreakBadge({
    super.key,
    required this.streak,
    required this.longestStreak,
    required this.lastSessionDate,
    this.brokenStreak,
    this.now,
  });

  final int streak;
  final int longestStreak;
  final DateTime? lastSessionDate;

  /// The streak that was lost, if the child has not practised since it broke.
  final int? brokenStreak;

  /// Injectable clock so the states can be tested without waiting a day.
  final DateTime? now;

  static const Key badgeKey = Key('home_streak_badge');
  static const Key textKey = Key('home_streak_badge_text');
  static const Key dayDoneKey = Key('home_day_done');
  static const Key comebackKey = Key('home_streak_comeback');

  static bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get playedToday => isSameDay(lastSessionDate, now ?? DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = _resolveState(scheme);

    return Semantics(
      container: true,
      label: '${state.headline}. ${state.detail}',
      child: ExcludeSemantics(
        child: Container(
          key: badgeKey,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: state.tint.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: state.tint.withValues(alpha: 0.35)),
          ),
          child: Row(
            key: state.stateKey,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.headline,
                      key: textKey,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({String headline, String detail, Key? stateKey, Color tint}) _resolveState(
    ColorScheme scheme,
  ) {
    final days = streak < 0 ? 0 : streak;
    final lost = brokenStreak ?? 0;

    if (!playedToday && lost > 1) {
      return (
        headline: 'Välkommen tillbaka!',
        detail: 'Din längsta svit är $longestStreak dagar. Idag börjar en ny.',
        stateKey: comebackKey,
        tint: scheme.tertiary,
      );
    }

    if (playedToday) {
      return (
        headline: days == 1 ? 'Dag 1 är gjord' : '$days dagar i rad',
        detail: 'Dagen är gjord – vi ses imorgon.',
        stateKey: dayDoneKey,
        tint: scheme.primary,
      );
    }

    if (days <= 1) {
      return (
        headline: 'Starta en svit idag',
        detail: 'En runda räcker för att dag 1 ska räknas.',
        stateKey: null,
        tint: scheme.primary,
      );
    }

    return (
      headline: '$days dagar i rad',
      detail: 'Spela idag för att behålla sviten.',
      stateKey: null,
      tint: scheme.primary,
    );
  }
}
