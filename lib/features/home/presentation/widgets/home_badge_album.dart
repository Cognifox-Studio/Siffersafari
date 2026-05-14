import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/achievement_service_provider.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';

class HomeBadgeAlbum extends ConsumerWidget {
  const HomeBadgeAlbum({required this.achievementIds, super.key});

  final List<String> achievementIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementService = ref.watch(achievementServiceProvider);
    final entries = achievementService.albumEntries;
    final unlockedIds = achievementIds.toSet();
    final unlockedCount =
        entries.where((entry) => unlockedIds.contains(entry.id)).length;
    final theme = Theme.of(context);
    final countLabel = '$unlockedCount av ${entries.length}';
    final helperText = unlockedCount == 0
        ? 'Spela och samla.'
        : unlockedCount == entries.length
            ? 'Alla märken klara!'
            : 'Fler väntar.';

    return PlayfulPanel(
      key: const Key('home_badge_album'),
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      highlightColor: theme.colorScheme.secondary,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Märken',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: AppConstants.microSpacing6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            helperText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: [
              for (final entry in entries)
                _BadgeTile(
                  entry: entry,
                  unlocked: unlockedIds.contains(entry.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.entry, required this.unlocked});

  final AchievementDefinition entry;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = unlocked
        ? _badgeColorFor(entry.id)
        : Colors.white.withValues(alpha: 0.08);
    final borderColor = unlocked
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.18);
    final labelColor =
        unlocked ? Colors.white : Colors.white.withValues(alpha: 0.74);

    return SizedBox(
      width: 92,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: Key('home_badge_tile_${entry.id}'),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tileColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: unlocked
                  ? Text(
                      entry.emoji,
                      key: Key('home_badge_icon_${entry.id}'),
                      style: theme.textTheme.headlineSmall,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/ui/locked_badge.png',
                        key: Key('home_badge_locked_${entry.id}'),
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            entry.albumLabel,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _badgeColorFor(String achievementId) {
    switch (achievementId) {
      case AppConstants.firstQuizAchievement:
        return const Color(0xFF4E8E68);
      case AppConstants.perfectScoreAchievement:
        return const Color(0xFFD9A326);
      case AppConstants.master100Achievement:
        return const Color(0xFF2E7BAA);
      case AppConstants.streak7Achievement:
        return const Color(0xFFC76A2C);
      case AppConstants.streak30Achievement:
        return const Color(0xFF8B4BB3);
      default:
        return const Color(0xFF5C6B73);
    }
  }
}
