import 'package:flutter/material.dart';
import 'package:siffersafari/domain/services/next_goal.dart';

/// Tomorrow's reason, shown today.
///
/// The home screen answers "what do I do now". This strip answers the other
/// question a child never asks out loud: "what is next". It reads one locked
/// badge, the next level or the biome after the episode -- all of it already in
/// `UserProgress`, none of it a new counter -- and it never scolds.
class HomeNextGoalCard extends StatelessWidget {
  const HomeNextGoalCard({super.key, required this.goal});

  final NextGoal goal;

  static const Key cardKey = Key('home_next_goal_card');
  static const Key titleKey = Key('home_next_goal_title');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tint = scheme.secondary;

    return Semantics(
      container: true,
      label: 'Nästa mål. ${goal.spokenLabel}',
      child: ExcludeSemantics(
        child: Container(
          key: cardKey,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tint.withValues(alpha: 0.28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _GoalGlyph(goal: goal),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nästa mål',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.title,
                      key: titleKey,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.body,
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
}

/// The badge art when the catalog has it, the emoji when it does not.
class _GoalGlyph extends StatelessWidget {
  const _GoalGlyph({required this.goal});

  final NextGoal goal;

  @override
  Widget build(BuildContext context) {
    final assetPath = goal.assetPath;
    if (assetPath == null) {
      return Text(goal.emoji, style: const TextStyle(fontSize: 22));
    }
    return Image.asset(
      assetPath,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      // Badges are small; a cached 64 px is enough for a 3x screen.
      cacheWidth: 64,
      errorBuilder: (context, error, stackTrace) =>
          Text(goal.emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}
