part of 'parent_dashboard_screen.dart';

class _WeakArea {
  const _WeakArea({
    required this.key,
    required this.rate,
    required this.label,
  });

  final String key;
  final double rate;
  final String label;
}

String _prettyEnumLabel(String raw) {
  switch (raw) {
    case 'addition':
      return 'Plus';
    case 'subtraction':
      return 'Minus';
    case 'multiplication':
      return 'Gånger';
    case 'division':
      return 'Delat';
    case 'easy':
      return 'Lätt';
    case 'medium':
      return 'Medel';
    case 'hard':
      return 'Svår';
    default:
      return raw;
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final topColor = Color.alphaBlend(
      scheme.secondary.withValues(alpha: 0.14),
      onPrimary.withValues(alpha: 0.18),
    );
    final bottomColor = Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.08),
      onPrimary.withValues(alpha: 0.14),
    );

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [topColor, bottomColor],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorderStrong),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: scheme.secondary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.history});

  final Map<String, dynamic> history;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final operation = (history['operationType'] as String?) ?? '-';
    final difficulty = (history['difficulty'] as String?) ?? '-';
    final correct = (history['correctAnswers'] as int?) ?? 0;
    final total = (history['totalQuestions'] as int?) ?? 0;
    final pointsWithBonus = (history['pointsWithBonus'] as int?) ??
        ((history['points'] as int?) ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.microSpacing8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_prettyEnumLabel(operation)} • ${_prettyEnumLabel(difficulty)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            '$correct/$total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            '$pointsWithBonus p',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.history});

  final Map<String, dynamic> history;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final operation = (history['operationType'] as String?) ?? '-';
    final difficulty = (history['difficulty'] as String?) ?? '-';
    final correct = (history['correctAnswers'] as int?) ?? 0;
    final total = (history['totalQuestions'] as int?) ?? 0;
    final pointsWithBonus = (history['pointsWithBonus'] as int?) ??
        ((history['points'] as int?) ?? 0);

    return _InsetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_prettyEnumLabel(operation)} • ${_prettyEnumLabel(difficulty)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            _formatHistoryTime(history),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Expanded(
                child: _HistoryMetric(
                  label: 'Resultat',
                  value: '$correct/$total',
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: _HistoryMetric(
                  label: 'Poäng',
                  value: '$pointsWithBonus p',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            total <= 0
                ? 'Ingen underlag än'
                : 'Träffsäkerhet: ${((correct / total) * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _formatHistoryTime(Map<String, dynamic> history) {
    final raw = history['endTime'] ?? history['startTime'];
    if (raw is! String || raw.isEmpty) return 'Tid okänd';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'Tid okänd';

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month kl $hour:$minute';
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtleOnPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppConstants.microSpacing4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({required this.area});

  final _WeakArea area;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    return Row(
      children: [
        Expanded(
          child: Text(
            area.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Text(
          '${(area.rate * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _InsetPanel extends StatelessWidget {
  const _InsetPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.10),
              onPrimary.withValues(alpha: 0.16),
            ),
            onPrimary.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorderStrong),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OverviewMetricTile extends StatelessWidget {
  const _OverviewMetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.toneColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final background = Color.alphaBlend(
      toneColor.withValues(alpha: 0.18),
      onPrimary.withValues(alpha: 0.14),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, onPrimary.withValues(alpha: 0.12)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorderStrong),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: toneColor, size: 18),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.toneColor,
  });

  final String label;
  final IconData icon;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.microSpacing8,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          toneColor.withValues(alpha: 0.18),
          onPrimary.withValues(alpha: 0.12),
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: toneColor.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: toneColor),
          const SizedBox(width: AppConstants.microSpacing6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentEmptyStatePanel extends StatelessWidget {
  const _ParentEmptyStatePanel({
    required this.title,
    required this.message,
    required this.icon,
    required this.toneColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          toneColor.withValues(alpha: 0.14),
          onPrimary.withValues(alpha: 0.10),
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorderStrong),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: toneColor, size: 20),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationToggleTile extends StatelessWidget {
  const _OperationToggleTile({
    required this.operation,
    required this.selected,
    required this.enabled,
    required this.toneColor,
    required this.onTap,
  });

  final OperationType operation;
  final bool selected;
  final bool enabled;
  final Color toneColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final icon = switch (operation) {
      OperationType.addition => Icons.add_rounded,
      OperationType.subtraction => Icons.remove_rounded,
      OperationType.multiplication => Icons.close_rounded,
      OperationType.division => Icons.drag_handle_rounded,
      OperationType.mixed => Icons.shuffle_rounded,
    };
    final background = selected
        ? Color.alphaBlend(
            toneColor.withValues(alpha: 0.22),
            onPrimary.withValues(alpha: 0.14),
          )
        : onPrimary.withValues(alpha: 0.12);

    return Opacity(
      opacity: enabled ? 1 : 0.60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          onTap: enabled ? onTap : null,
          child: Ink(
            padding: const EdgeInsets.all(AppConstants.smallPadding),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: selected
                    ? toneColor.withValues(alpha: 0.90)
                    : onPrimary.withValues(alpha: AppOpacities.hudBorderStrong),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: toneColor.withValues(alpha: 0.14),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: toneColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: toneColor, size: 18),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    operation.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected ? onPrimary : mutedOnPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: AppConstants.microSpacing6),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 20,
                  color: selected ? toneColor : mutedOnPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LatestQuizSnapshot extends StatelessWidget {
  const _LatestQuizSnapshot({required this.history});

  final Map<String, dynamic> history;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final operation = (history['operationType'] as String?) ?? '-';
    final difficulty = (history['difficulty'] as String?) ?? '-';
    final correct = (history['correctAnswers'] as int?) ?? 0;
    final total = (history['totalQuestions'] as int?) ?? 0;
    final pointsWithBonus = (history['pointsWithBonus'] as int?) ??
        ((history['points'] as int?) ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Senaste rundan',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppConstants.microSpacing4),
        Text(
          '${_prettyEnumLabel(operation)} • ${_prettyEnumLabel(difficulty)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: mutedOnPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppConstants.microSpacing6),
        Text(
          _formatHistoryTimeLabel(history),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtleOnPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            Expanded(
              child: _HistoryMetric(
                label: 'Resultat',
                value: '$correct/$total',
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: _HistoryMetric(
                label: 'Poäng',
                value: '$pointsWithBonus p',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ParentSectionHeader extends StatelessWidget {
  const _ParentSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppConstants.microSpacing4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtleOnPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DashboardExpansionSection extends StatelessWidget {
  const _DashboardExpansionSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              scheme.secondary.withValues(alpha: 0.10),
              onPrimary.withValues(alpha: 0.14),
            ),
            onPrimary.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorderStrong),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.microSpacing4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            0,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
          iconColor: onPrimary,
          collapsedIconColor: onPrimary,
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          children: [child],
        ),
      ),
    );
  }
}

String _formatHistoryTimeLabel(Map<String, dynamic> history) {
  final raw = history['endTime'] ?? history['startTime'];
  if (raw is! String || raw.isEmpty) return 'Tid okänd';

  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return 'Tid okänd';

  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month kl $hour:$minute';
}

class _CharacterPickerTile extends ConsumerWidget {
  const _CharacterPickerTile({required this.userId});

  final String userId;

  static const _characters = [
    (
      'loke',
      'Loke',
      'Ser mönster',
      'assets/characters/loke/png/loke_base.png',
    ),
    (
      'signe',
      'Signe',
      'Springer snabbt',
      'assets/characters/signe/png/signe_base.png',
    ),
    (
      'astrid',
      'Astrid',
      'Minns mycket',
      'assets/characters/astrid/png/astrid_base.png',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final primaryActionColor = Theme.of(context).colorScheme.primary;
    final accentColor = Theme.of(context).colorScheme.secondary;
    final secondaryActionColor = accentColor.withValues(alpha: 0.88);
    final characterCacheHeight = imageCacheExtent(context, 62);

    final user = ref.watch(userProvider).activeUser;
    if (user == null || user.userId != userId) return const SizedBox.shrink();

    final current = user.selectedCharacterId;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Karaktär',
            style: theme.textTheme.titleSmall?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            'Välj vilken figur som ska synas i appen.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtleOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppConstants.smallPadding;
              final maxWidth =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
              final columns = maxWidth >= 340 ? 3 : 2;
              final tileWidth = columns == 3
                  ? (maxWidth - (spacing * 2)) / 3
                  : (maxWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _characters.map((entry) {
                  final (slug, label, description, assetPath) = entry;
                  final selected = slug == current;
                  final toneColor = switch (slug) {
                    'loke' => primaryActionColor,
                    'signe' => secondaryActionColor,
                    'astrid' => accentColor,
                    _ => accentColor,
                  };
                  final cardBackground = selected
                      ? Color.alphaBlend(
                          toneColor.withValues(alpha: 0.22),
                          onPrimary.withValues(alpha: AppOpacities.panelFill),
                        )
                      : onPrimary.withValues(alpha: AppOpacities.panelFill);
                  final cardBorder = selected
                      ? toneColor.withValues(alpha: 0.95)
                      : onPrimary.withValues(alpha: AppOpacities.borderSubtle);

                  return SizedBox(
                    width: tileWidth,
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: 'Välj $label',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius * 1.3,
                          ),
                          onTap: () async {
                            if (selected) return;
                            await ref
                                .read(userProvider.notifier)
                                .setCharacter(slug);
                          },
                          child: AnimatedContainer(
                            duration: AppConstants.shortAnimationDuration,
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(
                              AppConstants.smallPadding,
                            ),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius * 1.3,
                              ),
                              border: Border.all(
                                color: cardBorder,
                                width: selected ? 1.8 : 1.0,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color:
                                            toneColor.withValues(alpha: 0.18),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 26,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              AppConstants.microSpacing8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              toneColor.withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          selected ? 'Vald nu' : 'Välj',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: selected
                                                ? onPrimary
                                                : toneColor,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppConstants.microSpacing6,
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? toneColor
                                            : onPrimary.withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        selected
                                            ? Icons.check_rounded
                                            : Icons.touch_app_rounded,
                                        size: 14,
                                        color: selected
                                            ? onPrimary
                                            : mutedOnPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: AppConstants.smallPadding,
                                ),
                                SizedBox(
                                  height: 62,
                                  child: Image.asset(
                                    assetPath,
                                    fit: BoxFit.contain,
                                    cacheHeight: characterCacheHeight,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person_rounded,
                                        size: 42,
                                        color: toneColor,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.smallPadding,
                                ),
                                Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.microSpacing4,
                                ),
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: selected
                                        ? onPrimary.withValues(alpha: 0.88)
                                        : mutedOnPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
