part of 'home_story_progress_card.dart';

class HomeStoryProgressCard extends StatelessWidget {
  const HomeStoryProgressCard({
    required this.story,
    required this.heroAsset,
    required this.backgroundAsset,
    required this.characterAsset,
    required this.primaryActionColor,
    required this.secondaryActionColor,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.faintOnPrimary,
    required this.cacheWidth,
    required this.cacheHeight,
    required this.onStartQuest,
    this.onOpenMap,
    super.key,
  });

  final StoryProgress story;
  final String heroAsset;
  final String backgroundAsset;
  final String characterAsset;
  final Color primaryActionColor;
  final Color secondaryActionColor;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color faintOnPrimary;
  final int cacheWidth;
  final int cacheHeight;
  final VoidCallback onStartQuest;
  final VoidCallback? onOpenMap;

  @override
  Widget build(BuildContext context) {
    final currentNode = story.currentNode;
    final nextNode = _nextNode();
    final visibleNodes = _selectVisibleNodes();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: PlayfulPanel(
        key: const Key('home_story_progress_card'),
        margin: EdgeInsets.zero,
        highlightColor: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroBanner(
              story: story,
              heroAsset: heroAsset,
              backgroundAsset: backgroundAsset,
              characterAsset: characterAsset,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
              onPrimary: onPrimary,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              story.worldTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppConstants.microSpacing6),
            Text(
              story.isEpisodeComplete ? story.endingBody : story.worldSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: mutedOnPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: [
                _InfoChip(
                  label: 'Akt',
                  value: story.actLabel,
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
                _InfoChip(
                  label: 'Klart',
                  value: '${story.completedNodes}/${story.totalNodes}',
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
                if (story.nextBiome != null)
                  _LockedBiomeChip(
                    biomeName: story.nextBiome!.name,
                    onPrimary: onPrimary,
                    mutedOnPrimary: mutedOnPrimary,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _JourneyPreviewPanel(
              story: story,
              currentNode: currentNode,
              nextNode: nextNode,
              visibleNodes: visibleNodes,
              primaryActionColor: primaryActionColor,
              secondaryActionColor: secondaryActionColor,
              accentColor: accentColor,
              onPrimary: onPrimary,
              mutedOnPrimary: mutedOnPrimary,
              faintOnPrimary: faintOnPrimary,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: onStartQuest,
              icon: Icon(
                story.isEpisodeComplete
                    ? Icons.auto_stories_rounded
                    : Icons.explore_rounded,
              ),
              label: Text(
                story.isEpisodeComplete ? 'Se episoden' : 'Spela nästa stopp',
              ),
            ),
            if (onOpenMap != null) ...[
              const SizedBox(height: AppConstants.microSpacing6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onOpenMap,
                  icon: Image.asset(
                    'assets/images/ui/ic_ui_map.png',
                    width: 20,
                    height: 20,
                  ),
                  label: const Text('Öppna kartan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  StoryNode? _nextNode() {
    final nextIndex = story.currentNodeIndex + 1;
    if (nextIndex < 0 || nextIndex >= story.nodes.length) {
      return null;
    }
    return story.nodes[nextIndex];
  }

  List<StoryNode> _selectVisibleNodes() {
    if (story.nodes.length <= 4) {
      return story.nodes;
    }

    final start = (story.currentNodeIndex - 1).clamp(0, story.nodes.length - 4);
    final end = (start + 4).clamp(0, story.nodes.length);
    return story.nodes.sublist(start, end);
  }
}

class _JourneyPreviewPanel extends StatelessWidget {
  const _JourneyPreviewPanel({
    required this.story,
    required this.currentNode,
    required this.nextNode,
    required this.visibleNodes,
    required this.primaryActionColor,
    required this.secondaryActionColor,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.faintOnPrimary,
  });

  final StoryProgress story;
  final StoryNode? currentNode;
  final StoryNode? nextNode;
  final List<StoryNode> visibleNodes;
  final Color primaryActionColor;
  final Color secondaryActionColor;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color faintOnPrimary;

  @override
  Widget build(BuildContext context) {
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final baseFill = onPrimary.withValues(alpha: AppOpacities.subtleFill);
    final panelBackground = Color.alphaBlend(
      accentColor.withValues(alpha: 0.08),
      baseFill,
    );

    final currentCard = _JourneyStepCard(
      label: story.isEpisodeComplete ? 'Klart' : 'Nu',
      title: story.isEpisodeComplete
          ? story.endingTitle
          : story.currentObjectiveTitle,
      meta: 'Plats: ${currentNode?.landmark ?? 'Djungelstigen'}',
      body: story.isEpisodeComplete
          ? story.endingBody
          : story.currentObjectiveDescription,
      icon: story.isEpisodeComplete
          ? Icons.celebration_rounded
          : Icons.place_rounded,
      toneColor: accentColor,
      onPrimary: onPrimary,
      mutedOnPrimary: mutedOnPrimary,
      subtleOnPrimary: subtleOnPrimary,
    );

    final nextCard = _JourneyStepCard(
      label: story.isEpisodeComplete ? 'Senare' : 'Sedan',
      title: story.isEpisodeComplete
          ? 'Nästa värld'
          : nextNode?.landmark ?? 'Djungeln klar snart',
      meta: story.isEpisodeComplete ? 'Fortsättning' : 'Nästa stopp',
      body: story.isEpisodeComplete
          ? story.endingBody
          : nextNode == null
              ? 'Ett sista steg kvar.'
              : nextNode?.title ?? 'Ett sista steg kvar.',
      icon: story.isEpisodeComplete ? Icons.public_rounded : Icons.flag_rounded,
      toneColor: primaryActionColor,
      onPrimary: onPrimary,
      mutedOnPrimary: mutedOnPrimary,
      subtleOnPrimary: subtleOnPrimary,
    );

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            panelBackground,
            baseFill,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.2),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Icon(
                  story.isEpisodeComplete
                      ? Icons.auto_stories_rounded
                      : Icons.explore_rounded,
                  color: onPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.isEpisodeComplete ? 'Storyn just nu' : 'Vår stig',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppConstants.microSpacing4),
                    Text(
                      story.isEpisodeComplete
                          ? 'Epilogen och nästa värld väntar.'
                          : 'Nu och sedan i ett kort.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtleOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 560;
              if (useTwoColumns) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: currentCard),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(child: nextCard),
                  ],
                );
              }

              return Column(
                children: [
                  currentCard,
                  const SizedBox(height: AppConstants.smallPadding),
                  nextCard,
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Stigen framåt',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          _StoryPathPreview(
            nodes: visibleNodes,
            currentNodeId: currentNode?.id,
            nextNodeId: nextNode?.id,
            completedColor: secondaryActionColor,
            currentColor: accentColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            faintOnPrimary: faintOnPrimary,
          ),
        ],
      ),
    );
  }
}

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({
    required this.label,
    required this.title,
    required this.meta,
    required this.body,
    required this.icon,
    required this.toneColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final String label;
  final String title;
  final String meta;
  final String body;
  final IconData icon;
  final Color toneColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final cardBackground = Color.alphaBlend(
      toneColor.withValues(alpha: 0.10),
      onPrimary.withValues(alpha: AppOpacities.panelFill),
    );

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: toneColor.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: toneColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: onPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            meta,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.story,
    required this.heroAsset,
    required this.backgroundAsset,
    required this.characterAsset,
    required this.cacheWidth,
    required this.cacheHeight,
    required this.onPrimary,
  });

  final StoryProgress story;
  final String heroAsset;
  final String backgroundAsset;
  final String characterAsset;
  final int cacheWidth;
  final int cacheHeight;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    final shadowColor = context.appThemeColors.panelShadowColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: SizedBox(
        height: 126,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                heroAsset,
                fit: BoxFit.cover,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    backgroundAsset,
                    fit: BoxFit.cover,
                    cacheWidth: cacheWidth,
                    cacheHeight: cacheHeight,
                    excludeFromSemantics: true,
                  );
                },
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      shadowColor.withValues(alpha: 0.05),
                      shadowColor.withValues(alpha: 0.28),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppConstants.defaultPadding,
              top: AppConstants.defaultPadding,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: AppConstants.microSpacing6,
                ),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
                  ),
                ),
                child: Text(
                  story.chapterTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            Positioned(
              left: AppConstants.defaultPadding,
              right: 112,
              bottom: AppConstants.defaultPadding,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.smallPadding,
                  vertical: AppConstants.microSpacing6,
                ),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
                  ),
                ),
                child: Text(
                  story.currentNode?.landmark ?? 'Djungelstigen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  characterAsset,
                  height: 112,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.onPrimary,
    required this.mutedOnPrimary,
  });

  final String label;
  final String value;
  final Color onPrimary;
  final Color mutedOnPrimary;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96, maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: mutedOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppConstants.microSpacing4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedBiomeChip extends StatelessWidget {
  const _LockedBiomeChip({
    required this.biomeName,
    required this.onPrimary,
    required this.mutedOnPrimary,
  });

  final String biomeName;
  final Color onPrimary;
  final Color mutedOnPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_story_next_biome_chip'),
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: mutedOnPrimary,
          ),
          const SizedBox(width: AppConstants.microSpacing6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sen',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: mutedOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppConstants.microSpacing4),
              Text(
                biomeName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryPathPreview extends StatelessWidget {
  const _StoryPathPreview({
    required this.nodes,
    required this.currentNodeId,
    required this.nextNodeId,
    required this.completedColor,
    required this.currentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.faintOnPrimary,
  });

  final List<StoryNode> nodes;
  final String? currentNodeId;
  final String? nextNodeId;
  final Color completedColor;
  final Color currentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color faintOnPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < nodes.length; i++) ...[
          Expanded(
            child: _StoryNodeBadge(
              node: nodes[i],
              isCurrent: nodes[i].id == currentNodeId,
              isNext: nodes[i].id == nextNodeId,
              completedColor: completedColor,
              currentColor: currentColor,
              onPrimary: onPrimary,
              mutedOnPrimary: mutedOnPrimary,
              faintOnPrimary: faintOnPrimary,
            ),
          ),
          if (i < nodes.length - 1)
            Container(
              width: 20,
              height: 4,
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.microSpacing6,
              ),
              decoration: BoxDecoration(
                color: nodes[i].state == StoryNodeState.completed
                    ? completedColor
                    : faintOnPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ],
    );
  }
}

class _StoryNodeBadge extends StatelessWidget {
  const _StoryNodeBadge({
    required this.node,
    required this.isCurrent,
    required this.isNext,
    required this.completedColor,
    required this.currentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.faintOnPrimary,
  });

  final StoryNode node;
  final bool isCurrent;
  final bool isNext;
  final Color completedColor;
  final Color currentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color faintOnPrimary;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (node.state) {
      StoryNodeState.completed => completedColor.withValues(
          alpha: AppOpacities.accentFillSubtle,
        ),
      StoryNodeState.current => currentColor.withValues(alpha: 0.18),
      StoryNodeState.upcoming => Colors.transparent,
    };

    final borderColor = switch (node.state) {
      StoryNodeState.completed => completedColor,
      StoryNodeState.current => currentColor,
      StoryNodeState.upcoming => isNext ? faintOnPrimary : mutedOnPrimary,
    };

    final icon = switch (node.state) {
      StoryNodeState.completed => Icons.check,
      StoryNodeState.current => Icons.place,
      StoryNodeState.upcoming =>
        isNext ? Icons.flag_outlined : Icons.circle_outlined,
    };

    final textColor = switch (node.state) {
      StoryNodeState.completed => onPrimary,
      StoryNodeState.current => onPrimary,
      StoryNodeState.upcoming => mutedOnPrimary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.microSpacing6,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: isCurrent ? 22 : 18),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            '${node.stepIndex + 1}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
