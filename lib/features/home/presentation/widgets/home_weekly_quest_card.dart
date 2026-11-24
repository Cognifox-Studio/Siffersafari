import 'package:flutter/material.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/domain/services/weekly_quest.dart';

/// "Veckans mål" -- the small goal that starts over on Monday.
///
/// The quests on the story map never expire, which is why they are kind. This
/// card is the other rhythm: four short rounds is a week, and next Monday there
/// is a new one instead of a debt.
class HomeWeeklyQuestCard extends StatelessWidget {
  const HomeWeeklyQuestCard({super.key, required this.quest});

  final WeeklyQuest quest;

  static const Key cardKey = Key('home_weekly_quest_card');
  static const Key progressKey = Key('home_weekly_quest_progress');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tint = quest.isComplete ? scheme.tertiary : scheme.primary;
    final daysLeft = quest.window.daysLeft(DateTime.now());

    return Semantics(
      container: true,
      label: '${quest.spokenLabel} ${_daysLabel(daysLeft)}',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    quest.isComplete ? '🏁' : '🗓️',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Veckans mål',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    _daysLabel(daysLeft),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                quest.progressLabel,
                key: progressKey,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: LinearProgressIndicator(
                  value: quest.progress,
                  minHeight: 8,
                  backgroundColor: scheme.onSurface.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(tint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Never a countdown, always a hand: "2 dagar kvar", not "2 dagar för sent".
  String _daysLabel(int daysLeft) {
    if (quest.isComplete) return 'klart';
    if (daysLeft <= 0) return 'sista dagen';
    return daysLeft == 1 ? '1 dag kvar' : '$daysLeft dagar kvar';
  }
}
