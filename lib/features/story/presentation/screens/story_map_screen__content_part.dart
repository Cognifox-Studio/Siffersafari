part of 'story_map_screen.dart';

class _MapHeroCard extends StatelessWidget {
  const _MapHeroCard({
    required this.story,
    required this.heroAsset,
    required this.backgroundAsset,
    required this.completedColor,
    required this.currentColor,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryProgress story;
  final String heroAsset;
  final String backgroundAsset;
  final Color completedColor;
  final Color currentColor;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final overallProgress =
        story.totalNodes == 0 ? 0.0 : story.completedNodes / story.totalNodes;

    return PlayfulPanel(
      hero: true,
      highlightColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InteractiveMapCanvas(
            story: story,
            completedColor: completedColor,
            currentColor: currentColor,
            nextColor: accentColor,
            accentColor: accentColor,
            onPrimary: onPrimary,
            backgroundAsset: backgroundAsset,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            story.worldTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            '${story.actLabel}: ${story.actTitle}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            story.isEpisodeComplete ? story.endingBody : story.actBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: [
              _HeaderChip(
                label: 'Akt',
                value: story.actLabel,
                onPrimary: onPrimary,
                mutedOnPrimary: mutedOnPrimary,
              ),
              _HeaderChip(
                label: 'Klart',
                value: '${story.completedNodes}/${story.totalNodes}',
                onPrimary: onPrimary,
                mutedOnPrimary: mutedOnPrimary,
              ),
              if (story.nextBiome != null)
                _NextBiomeHeaderChip(
                  label: story.nextBiome!.previewPrefix,
                  biomeName: story.nextBiome!.name,
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: AppConstants.progressBarHeightSmall,
              backgroundColor: onPrimary.withValues(
                alpha: AppOpacities.progressTrackLight,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
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
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _NextBiomeHeaderChip extends StatelessWidget {
  const _NextBiomeHeaderChip({
    required this.label,
    required this.biomeName,
    required this.onPrimary,
    required this.mutedOnPrimary,
  });

  final String label;
  final String biomeName;
  final Color onPrimary;
  final Color mutedOnPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('story_map_next_biome_chip'),
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
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: mutedOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppConstants.microSpacing4),
              Text(
                biomeName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _NowAndNextPanel extends StatelessWidget {
  const _NowAndNextPanel({
    required this.story,
    required this.currentNode,
    required this.nextNode,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.onContinue,
  });

  final StoryProgress story;
  final StoryNode? currentNode;
  final StoryNode? nextNode;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final panelTitle =
        story.isEpisodeComplete ? story.endingTitle : story.actLabel;
    final panelBody =
        story.isEpisodeComplete ? story.endingBody : story.actBody;
    final currentLabel = story.isEpisodeComplete ? 'Sista stopp' : 'Nu';
    final currentTitle = currentNode?.landmark ?? 'Starten';
    final currentBody = story.isEpisodeComplete
        ? story.chapterTitle
        : story.currentObjectiveTitle;
    final nextLabel = story.isEpisodeComplete ? 'Senare' : 'Sedan';
    final nextTitle = story.isEpisodeComplete
        ? 'Nästa värld'
        : nextNode?.landmark ?? 'Djungeln klar snart';
    final nextBody = story.isEpisodeComplete
        ? story.endingBody
        : nextNode?.title ?? 'Ett sista steg kvar.';
    final buttonLabel =
        story.isEpisodeComplete ? 'Till hem' : 'Spela nästa stopp';
    final buttonIcon =
        story.isEpisodeComplete ? Icons.home_rounded : Icons.play_arrow_rounded;

    return PlayfulPanel(
      highlightColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            panelTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            panelBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
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
                  currentLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  currentTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  currentBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Container(
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
                  nextLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  nextTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  nextBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            onPressed: onContinue,
            icon: Icon(buttonIcon),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _NearbyStopsPanel extends StatelessWidget {
  const _NearbyStopsPanel({
    required this.story,
    required this.currentNode,
    required this.nextNode,
    required this.completedColor,
    required this.currentColor,
    required this.nextColor,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryProgress story;
  final StoryNode? currentNode;
  final StoryNode? nextNode;
  final Color completedColor;
  final Color currentColor;
  final Color nextColor;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final visibleNodes = _selectVisibleNodes(
      story.nodes,
      currentIndex: story.currentNodeIndex,
      windowSize: 5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Resten av stigen',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        for (final node in visibleNodes) ...[
          _StopCard(
            node: node,
            isCurrent: currentNode?.id == node.id,
            isNext: nextNode?.id == node.id,
            completedColor: completedColor,
            currentColor: currentColor,
            nextColor: nextColor,
            accentColor: accentColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            subtleOnPrimary: subtleOnPrimary,
          ),
          if (node != visibleNodes.last)
            const SizedBox(height: AppConstants.smallPadding),
        ],
        if (story.nextBiome != null) ...[
          const SizedBox(height: AppConstants.smallPadding),
          _LockedBiomePreviewCard(
            biome: story.nextBiome!,
            accentColor: accentColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            subtleOnPrimary: subtleOnPrimary,
          ),
        ],
      ],
    );
  }

  List<StoryNode> _selectVisibleNodes(
    List<StoryNode> nodes, {
    required int currentIndex,
    required int windowSize,
  }) {
    if (nodes.length <= windowSize) {
      return nodes;
    }

    final safeWindow = windowSize.clamp(3, nodes.length);
    final start = (currentIndex - 1).clamp(0, nodes.length - safeWindow);
    final end = (start + safeWindow).clamp(0, nodes.length);
    return nodes.sublist(start, end);
  }
}

class _LockedBiomeTeaser extends StatelessWidget {
  const _LockedBiomeTeaser({
    required this.biome,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
  });

  final StoryBiomePreview biome;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;

  @override
  Widget build(BuildContext context) {
    return PlayfulPanel(
      key: const Key('story_map_locked_biome_teaser'),
      highlightColor: accentColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BiomePreviewBubble(
            biome: biome,
            size: 48,
            accentColor: accentColor,
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biome.previewPrefix,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  biome.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  biome.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Container(
            key: const Key('story_map_locked_biome_chip'),
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
              'Låst',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

class _LockedBiomePreviewCard extends StatelessWidget {
  const _LockedBiomePreviewCard({
    required this.biome,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryBiomePreview biome;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final shadowColor = context.appThemeColors.panelShadowColor;

    return Container(
      key: const Key('story_map_locked_biome_preview'),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: mutedOnPrimary.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BiomePreviewBubble(
            biome: biome,
            size: 52,
            accentColor: accentColor,
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biome.previewPrefix,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppConstants.microSpacing4),
                Text(
                  biome.previewTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  biome.previewBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: subtleOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          _StatusChip(
            label: 'Låst',
            color: mutedOnPrimary.withValues(alpha: 0.65),
            onPrimary: onPrimary,
          ),
        ],
      ),
    );
  }
}

class _BiomePreviewBubble extends StatelessWidget {
  const _BiomePreviewBubble({
    required this.biome,
    required this.size,
    required this.accentColor,
  });

  final StoryBiomePreview biome;
  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final assetPath = _storyBiomePreviewAssetPath(biome);
    final cacheSize = imageCacheExtent(context, size);

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.24),
          width: 1.5,
        ),
      ),
      child: assetPath == null
          ? Icon(Icons.landscape_rounded, color: accentColor)
          : Image.asset(
              assetPath,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              cacheWidth: cacheSize,
              cacheHeight: cacheSize,
              errorBuilder: (_, __, ___) {
                return Icon(Icons.landscape_rounded, color: accentColor);
              },
            ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.node,
    required this.isCurrent,
    required this.isNext,
    required this.completedColor,
    required this.currentColor,
    required this.nextColor,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryNode node;
  final bool isCurrent;
  final bool isNext;
  final Color completedColor;
  final Color currentColor;
  final Color nextColor;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final shadowColor = context.appThemeColors.panelShadowColor;
    final visual = _NodeVisual.forSceneTag(
      node.sceneTag,
      primaryColor: nextColor,
      secondaryColor: completedColor,
      accentColor: currentColor,
    );

    final statusLabel = switch (node.state) {
      StoryNodeState.completed => 'Klar',
      StoryNodeState.current => 'Du är här',
      StoryNodeState.upcoming => isNext ? 'Nästa' : 'Senare',
    };

    final borderColor = switch (node.state) {
      StoryNodeState.completed => completedColor,
      StoryNodeState.current => currentColor,
      StoryNodeState.upcoming =>
        isNext ? nextColor : mutedOnPrimary.withValues(alpha: 0.55),
    };

    final fillColor = switch (node.state) {
      StoryNodeState.completed => completedColor.withValues(alpha: 0.18),
      StoryNodeState.current => currentColor.withValues(alpha: 0.18),
      StoryNodeState.upcoming => onPrimary.withValues(alpha: 0.08),
    };
    final visualCacheSize = imageCacheExtent(context, 28);

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.10),
            blurRadius: isCurrent ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: visual.assetPath != null
                ? Center(
                    child: Image.asset(
                      visual.assetPath!,
                      width: 28,
                      height: 28,
                      cacheWidth: visualCacheSize,
                      cacheHeight: visualCacheSize,
                    ),
                  )
                : Icon(visual.icon, color: onPrimary),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stopp ${node.stepIndex + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: mutedOnPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppConstants.microSpacing4),
                          Text(
                            node.landmark,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    _StatusChip(
                      label: statusLabel,
                      color: borderColor,
                      onPrimary: onPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  node.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: subtleOnPrimary,
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
