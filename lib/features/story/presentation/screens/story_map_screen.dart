import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

class StoryMapScreen extends ConsumerWidget {
  const StoryMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(storyProgressProvider);
    final themeCfg = ref.watch(appThemeConfigProvider);
    final size = MediaQuery.sizeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final onPrimary = scheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final layout = AdaptiveLayoutInfo.fromConstraints(
      BoxConstraints(maxWidth: size.width, maxHeight: size.height),
    );

    if (story == null) {
      return ThemedBackgroundScaffold(
        appBar: AppBar(
          title: const Text('Djungelkartan'),
        ),
        body: Center(
          child: Text(
            'Ingen karta finns än.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }

    final currentNode = story.currentNode;
    final nextNode = _nextNode(story);

    return ThemedBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Djungelkartan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: layout.isExpandedWidth ? 860 : 720,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MapHeroCard(
                  story: story,
                  heroAsset: themeCfg.questHeroAsset,
                  backgroundAsset: themeCfg.backgroundAsset,
                  accentColor: scheme.secondary,
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                  subtleOnPrimary: subtleOnPrimary,
                ),
                const SizedBox(height: AppConstants.largePadding),
                _NowAndNextPanel(
                  story: story,
                  currentNode: currentNode,
                  nextNode: nextNode,
                  accentColor: scheme.secondary,
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                  onContinue: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                ExpansionTile(
                  title: Text(
                    'Se fler stopp',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  iconColor: scheme.secondary,
                  collapsedIconColor: scheme.secondary,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppConstants.microSpacing6,
                        right: AppConstants.microSpacing6,
                        bottom: AppConstants.microSpacing6,
                      ),
                      child: _NearbyStopsPanel(
                        story: story,
                        currentNode: currentNode,
                        nextNode: nextNode,
                        accentColor: scheme.secondary,
                        onPrimary: onPrimary,
                        mutedOnPrimary: mutedOnPrimary,
                        subtleOnPrimary: subtleOnPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StoryNode? _nextNode(StoryProgress story) {
    final nextIndex = story.currentNodeIndex + 1;
    if (nextIndex < 0 || nextIndex >= story.nodes.length) {
      return null;
    }
    return story.nodes[nextIndex];
  }
}

class _MapHeroCard extends StatelessWidget {
  const _MapHeroCard({
    required this.story,
    required this.heroAsset,
    required this.backgroundAsset,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryProgress story;
  final String heroAsset;
  final String backgroundAsset;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final overallProgress =
        story.totalNodes == 0 ? 0.0 : story.completedNodes / story.totalNodes;
    final chapterNumber = (story.currentNodeIndex ~/ 5) + 1;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            onPrimary.withValues(alpha: 0.16),
            onPrimary.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: accentColor.withValues(alpha: AppOpacities.borderSubtle),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppOpacities.shadowAmbient),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InteractiveMapCanvas(
            story: story,
            accentColor: accentColor,
            onPrimary: onPrimary,
            backgroundAsset: backgroundAsset,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          // Legend row
          Row(
            children: [
              const _MapLegendDot(color: Color(0xFF7AAE3E), label: 'Klar'),
              const SizedBox(width: AppConstants.smallPadding),
              const _MapLegendDot(color: Color(0xFFD39A2F), label: 'Här nu'),
              const SizedBox(width: AppConstants.smallPadding),
              _MapLegendDot(
                color: onPrimary.withValues(alpha: 0.35),
                label: 'Kommande',
              ),
            ],
          ),
          // Keep the bottom badge (chapter label) as a fallback info pill
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: AppConstants.microSpacing6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Följ stigen steg för steg',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            story.worldTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            'Du ser bara det viktigaste: var du är och vart du ska nu.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: [
              _HeaderChip(
                label: 'Klart',
                value: '${story.completedNodes}/${story.totalNodes}',
                onPrimary: onPrimary,
                mutedOnPrimary: mutedOnPrimary,
              ),
              _HeaderChip(
                label: 'Kapitel',
                value: '$chapterNumber',
                onPrimary: onPrimary,
                mutedOnPrimary: mutedOnPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hur långt du har kommit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                '${(overallProgress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
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
    final nextLabel = nextNode?.landmark ?? 'målet';

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.hudBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nu kör vi!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Du är vid ${currentNode?.landmark ?? 'starten'}. Nästa stopp är $nextLabel.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (currentNode?.landmarkHint.isNotEmpty ?? false) ...[
            const SizedBox(height: AppConstants.microSpacing6),
            Text(
              '📖 ${currentNode!.landmarkHint}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: mutedOnPrimary.withValues(alpha: 0.75),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Spela nästa stopp'),
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
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryProgress story;
  final StoryNode? currentNode;
  final StoryNode? nextNode;
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

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            onPrimary.withValues(alpha: 0.15),
            onPrimary.withValues(alpha: 0.09),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.borderSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stigen nära dig',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing6),
          Text(
            'Grönt är klart, gult är du och grått kommer senare.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          for (final node in visibleNodes) ...[
            _StopCard(
              node: node,
              isCurrent: currentNode?.id == node.id,
              isNext: nextNode?.id == node.id,
              accentColor: accentColor,
              onPrimary: onPrimary,
              mutedOnPrimary: mutedOnPrimary,
              subtleOnPrimary: subtleOnPrimary,
            ),
            if (node != visibleNodes.last)
              const SizedBox(height: AppConstants.smallPadding),
          ],
        ],
      ),
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

class _StopCard extends StatelessWidget {
  const _StopCard({
    required this.node,
    required this.isCurrent,
    required this.isNext,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryNode node;
  final bool isCurrent;
  final bool isNext;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final visual = _NodeVisual.forSceneTag(
      node.sceneTag,
      accentColor: accentColor,
    );

    final statusLabel = switch (node.state) {
      StoryNodeState.completed => 'Klar',
      StoryNodeState.current => 'Du är här',
      StoryNodeState.upcoming => isNext ? 'Nästa' : 'Senare',
    };

    final borderColor = switch (node.state) {
      StoryNodeState.completed => const Color(0xFF7AAE3E),
      StoryNodeState.current => const Color(0xFFD39A2F),
      StoryNodeState.upcoming => mutedOnPrimary.withValues(alpha: 0.55),
    };

    final fillColor = switch (node.state) {
      StoryNodeState.completed =>
        const Color(0xFF7AAE3E).withValues(alpha: 0.18),
      StoryNodeState.current => const Color(0xFFD39A2F).withValues(alpha: 0.18),
      StoryNodeState.upcoming => onPrimary.withValues(alpha: 0.08),
    };

    final body = switch (node.state) {
      StoryNodeState.completed => 'Du har redan klarat det här stoppet.',
      StoryNodeState.current => 'Nu spelar du: ${node.title}',
      StoryNodeState.upcoming => isNext
          ? 'Sedan kommer: ${node.title}'
          : 'Detta stopp kommer senare på stigen.',
    };

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
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
            child: Icon(visual.icon, color: onPrimary),
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
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onPrimary.withValues(alpha: 0.90),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (isCurrent || isNext) ...[
                  const SizedBox(height: AppConstants.microSpacing6),
                  Text(
                    node.landmarkHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtleOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Interactive map canvas ────────────────────────────────────────────────

class _MapLegendDot extends StatelessWidget {
  const _MapLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _InteractiveMapCanvas extends StatefulWidget {
  const _InteractiveMapCanvas({
    required this.story,
    required this.accentColor,
    required this.onPrimary,
    required this.backgroundAsset,
  });

  final StoryProgress story;
  final Color accentColor;
  final Color onPrimary;
  final String backgroundAsset;

  @override
  State<_InteractiveMapCanvas> createState() => _InteractiveMapCanvasState();
}

class _InteractiveMapCanvasState extends State<_InteractiveMapCanvas> {
  StoryNode? _tapped;

  @override
  Widget build(BuildContext context) {
    final nodes = widget.story.nodes;
    if (nodes.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: SizedBox(
        height: 320,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            const h = 320.0;
            final positions = _computePositions(nodes.length, w, h);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(
                  widget.backgroundAsset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFF2D5A1B),
                  ),
                ),
                // Dark overlay for readability
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.32),
                ),
                // Path + nodes via CustomPaint
                CustomPaint(
                  painter: _MapPathPainter(
                    positions: positions,
                    nodes: nodes,
                    accentColor: widget.accentColor,
                  ),
                ),
                // Tap targets & node labels
                ...List.generate(nodes.length, (i) {
                  final pos = positions[i];
                  final node = nodes[i];
                  final isActive = node.state == StoryNodeState.current;
                  const r = _MapPathPainter.nodeRadius;
                  const tapArea = 52.0;

                  return Positioned(
                    left: pos.dx - tapArea / 2,
                    top: pos.dy - tapArea / 2,
                    child: GestureDetector(
                      onTap: () => setState(() => _tapped = node),
                      child: SizedBox(
                        width: tapArea,
                        height: tapArea,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow ring on current
                            if (isActive)
                              Container(
                                width: r * 2 + 12,
                                height: r * 2 + 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFD39A2F)
                                        .withValues(alpha: 0.80),
                                    width: 3,
                                  ),
                                ),
                              ),
                            // Node circle drawn via paint – label only here
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${node.stepIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // Tooltip bubble for tapped node
                if (_tapped != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => setState(() => _tapped = null),
                      child: _MapNodeTooltip(
                        node: _tapped!,
                        accentColor: widget.accentColor,
                        onPrimary: widget.onPrimary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Produces snake-path positions in a tight S-curve fitting the given bounds.
  static List<Offset> _computePositions(int count, double w, double h) {
    if (count == 0) return [];
    const cols = 5;
    final rows = (count / cols).ceil();
    final cellW = w / cols;
    final cellH = h / rows;
    final positions = <Offset>[];

    for (var i = 0; i < count; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      // Reverse every other row (snake/zigzag)
      final effectiveCol = row.isOdd ? (cols - 1 - col) : col;
      final x = cellW * effectiveCol + cellW / 2;
      final y = cellH * row + cellH / 2;
      positions.add(Offset(x, y));
    }
    return positions;
  }
}

class _MapPathPainter extends CustomPainter {
  const _MapPathPainter({
    required this.positions,
    required this.nodes,
    required this.accentColor,
  });

  final List<Offset> positions;
  final List<StoryNode> nodes;
  final Color accentColor;

  static const nodeRadius = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    // Draw path lines
    for (var i = 0; i < positions.length - 1; i++) {
      final isDone = nodes[i].state == StoryNodeState.completed &&
          nodes[i + 1].state != StoryNodeState.upcoming;
      final paint = Paint()
        ..color = isDone
            ? const Color(0xFF7AAE3E).withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.30)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(positions[i], positions[i + 1], paint);
    }

    // Draw node circles
    for (var i = 0; i < positions.length; i++) {
      final node = nodes[i];
      final pos = positions[i];

      final (fillColor, strokeColor) = switch (node.state) {
        StoryNodeState.completed => (
            const Color(0xFF7AAE3E),
            const Color(0xFF5A8C2E),
          ),
        StoryNodeState.current => (
            const Color(0xFFD39A2F),
            const Color(0xFFB07A1A),
          ),
        StoryNodeState.upcoming => (
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.50),
          ),
      };

      final fill = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = strokeColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pos, nodeRadius, fill);
      canvas.drawCircle(pos, nodeRadius, stroke);

      // Icon: checkmark for done, dot for current
      if (node.state == StoryNodeState.completed) {
        final iconPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        final cx = pos.dx;
        final cy = pos.dy;
        canvas.drawLine(
          Offset(cx - 5, cy),
          Offset(cx - 1.5, cy + 4),
          iconPaint,
        );
        canvas.drawLine(
          Offset(cx - 1.5, cy + 4),
          Offset(cx + 5, cy - 4),
          iconPaint,
        );
      } else if (node.state == StoryNodeState.current) {
        canvas.drawCircle(
          pos,
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MapPathPainter old) =>
      old.positions != positions || old.nodes != nodes;
}

class _MapNodeTooltip extends StatelessWidget {
  const _MapNodeTooltip({
    required this.node,
    required this.accentColor,
    required this.onPrimary,
  });

  final StoryNode node;
  final Color accentColor;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    final color = switch (node.state) {
      StoryNodeState.completed => const Color(0xFF7AAE3E),
      StoryNodeState.current => const Color(0xFFD39A2F),
      StoryNodeState.upcoming => Colors.white.withValues(alpha: 0.60),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.80), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stopp ${node.stepIndex + 1} · ${node.landmark}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  node.landmarkHint,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.close_rounded,
            color: Colors.white.withValues(alpha: 0.50),
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ─── End interactive map canvas ───────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.onPrimary,
  });

  final String label;
  final Color color;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.microSpacing6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _NodeVisual {
  const _NodeVisual({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  factory _NodeVisual.forSceneTag(
    String sceneTag, {
    required Color accentColor,
  }) {
    switch (sceneTag) {
      case 'baslager':
        return const _NodeVisual(
          icon: Icons.cabin,
          color: Color(0xFF7A5A34),
        );
      case 'frukt':
        return const _NodeVisual(
          icon: Icons.apple,
          color: Color(0xFF7AAE3E),
        );
      case 'skugga':
        return const _NodeVisual(
          icon: Icons.dark_mode,
          color: Color(0xFF56607A),
        );
      case 'bro':
        return const _NodeVisual(
          icon: Icons.linear_scale,
          color: Color(0xFF8A6C45),
        );
      case 'karta':
        return const _NodeVisual(
          icon: Icons.map,
          color: Color(0xFF3A8E8A),
        );
      case 'fors':
        return const _NodeVisual(
          icon: Icons.water,
          color: Color(0xFF3A7BC1),
        );
      case 'tempel':
        return const _NodeVisual(
          icon: Icons.account_balance,
          color: Color(0xFF8B6F42),
        );
      case 'soltempel':
        return const _NodeVisual(
          icon: Icons.wb_sunny,
          color: Color(0xFFD39A2F),
        );
      case 'skog':
        return const _NodeVisual(
          icon: Icons.park,
          color: Color(0xFF4E8B52),
        );
      case 'trumma':
        return const _NodeVisual(
          icon: Icons.music_note,
          color: Color(0xFF8C5632),
        );
      case 'port':
        return const _NodeVisual(
          icon: Icons.door_front_door,
          color: Color(0xFF6D667C),
        );
      case 'skatt':
        return const _NodeVisual(
          icon: Icons.workspace_premium,
          color: Color(0xFFB88C2E),
        );
    }

    return _NodeVisual(
      icon: Icons.explore,
      color: accentColor,
    );
  }
}
