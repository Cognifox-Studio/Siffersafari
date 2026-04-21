import 'package:flutter/material.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';

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
    final overallProgress =
        story.totalNodes == 0 ? 0.0 : story.completedNodes / story.totalNodes;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: PlayfulPanel(
        hero: true,
        margin: const EdgeInsets.only(top: AppConstants.defaultPadding),
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
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              story.worldTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: [
                _InfoChip(
                  label: 'Klart',
                  value: '${story.completedNodes}/${story.totalNodes}',
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
                if (currentNode != null)
                  _InfoChip(
                    label: 'Nu',
                    value: currentNode.landmark,
                    onPrimary: onPrimary,
                    mutedOnPrimary: mutedOnPrimary,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _FocusCard(
              label: 'Nästa stopp',
              nextTitle: nextNode?.landmark ?? 'Målet är nära',
              nextBody: nextNode == null ? 'Snart klar' : nextNode.title,
              nextColor: primaryActionColor,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
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
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: onStartQuest,
              child: const Text('Spela nästa stopp'),
            ),
            if (onOpenMap != null) ...[
              const SizedBox(height: AppConstants.smallPadding),
              OutlinedButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Öppna kartan'),
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
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.28),
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
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
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

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.label,
    required this.nextTitle,
    required this.nextBody,
    required this.nextColor,
  });

  final String label;
  final String nextTitle;
  final String nextBody;
  final Color nextColor;

  @override
  Widget build(BuildContext context) {
    return PlayfulAccentCard(
      label: label,
      title: nextTitle,
      body: nextBody,
      icon: Icons.flag_rounded,
      accentColor: nextColor,
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
