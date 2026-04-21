import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/story_progress_provider.dart';
import 'package:siffersafari/core/utils/adaptive_layout.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: PlayfulPanel(
                hero: true,
                highlightColor: scheme.secondary,
                child: const PlayfulSectionHeading(
                  title: 'Ingen karta än',
                  subtitle: 'Spela först.',
                  center: true,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final currentNode = story.currentNode;
    final nextNode = _nextNode(story);
    final completedColor = themeCfg.progressCompletedColor;
    final currentColor = themeCfg.progressCurrentColor;
    final nextColor = themeCfg.progressNextColor;

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
                const PlayfulSectionHeading(
                  title: 'Djungelkartan',
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _MapHeroCard(
                  story: story,
                  heroAsset: themeCfg.questHeroAsset,
                  backgroundAsset: themeCfg.backgroundAsset,
                  completedColor: completedColor,
                  currentColor: currentColor,
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
                PlayfulPanel(
                  backgroundColor:
                      onPrimary.withValues(alpha: AppOpacities.panelFill),
                  highlightColor: scheme.secondary,
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Fler stopp',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            completedColor: completedColor,
                            currentColor: currentColor,
                            nextColor: nextColor,
                            accentColor: scheme.secondary,
                            onPrimary: onPrimary,
                            mutedOnPrimary: mutedOnPrimary,
                            subtleOnPrimary: subtleOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
          // Legend row
          Row(
            children: [
              _MapLegendDot(color: completedColor, label: 'Klar'),
              const SizedBox(width: AppConstants.smallPadding),
              _MapLegendDot(color: currentColor, label: 'Här nu'),
              const SizedBox(width: AppConstants.smallPadding),
              _MapLegendDot(
                color: onPrimary.withValues(alpha: 0.35),
                label: 'Kommande',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            story.worldTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
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

    return PlayfulPanel(
      highlightColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nästa stopp',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '${currentNode?.landmark ?? 'Starten'} → $nextLabel',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
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
          'Fler stopp',
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
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.90),
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
    required this.completedColor,
    required this.currentColor,
    required this.nextColor,
    required this.accentColor,
    required this.onPrimary,
    required this.backgroundAsset,
  });

  final StoryProgress story;
  final Color completedColor;
  final Color currentColor;
  final Color nextColor;
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
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: widget.accentColor.withValues(alpha: 0.35),
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
                    completedColor: widget.completedColor,
                    currentColor: widget.currentColor,
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
                                    color: widget.currentColor.withValues(
                                      alpha: 0.80,
                                    ),
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
                        completedColor: widget.completedColor,
                        currentColor: widget.currentColor,
                        nextColor: widget.nextColor,
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
    required this.completedColor,
    required this.currentColor,
    required this.accentColor,
  });

  final List<Offset> positions;
  final List<StoryNode> nodes;
  final Color completedColor;
  final Color currentColor;
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
            ? completedColor.withValues(alpha: 0.90)
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
            completedColor,
            completedColor.withValues(alpha: 0.75),
          ),
        StoryNodeState.current => (
            currentColor,
            currentColor.withValues(alpha: 0.75),
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
    required this.completedColor,
    required this.currentColor,
    required this.nextColor,
    required this.accentColor,
    required this.onPrimary,
  });

  final StoryNode node;
  final Color completedColor;
  final Color currentColor;
  final Color nextColor;
  final Color accentColor;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    final color = switch (node.state) {
      StoryNodeState.completed => completedColor,
      StoryNodeState.current => currentColor,
      StoryNodeState.upcoming => nextColor.withValues(alpha: 0.90),
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
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    switch (sceneTag) {
      case 'baslager':
        return _NodeVisual(
          icon: Icons.cabin,
          color: primaryColor.withValues(alpha: 0.88),
        );
      case 'frukt':
        return _NodeVisual(
          icon: Icons.apple,
          color: secondaryColor.withValues(alpha: 0.92),
        );
      case 'skugga':
        return _NodeVisual(
          icon: Icons.dark_mode,
          color: Color.alphaBlend(
            accentColor.withValues(alpha: 0.45),
            primaryColor,
          ),
        );
      case 'bro':
        return _NodeVisual(
          icon: Icons.linear_scale,
          color: Color.alphaBlend(
            primaryColor.withValues(alpha: 0.55),
            secondaryColor,
          ),
        );
      case 'karta':
        return _NodeVisual(
          icon: Icons.map,
          color: Color.alphaBlend(
            accentColor.withValues(alpha: 0.60),
            secondaryColor,
          ),
        );
      case 'fors':
        return _NodeVisual(
          icon: Icons.water,
          color: Color.alphaBlend(
            accentColor.withValues(alpha: 0.55),
            primaryColor,
          ),
        );
      case 'tempel':
        return _NodeVisual(
          icon: Icons.account_balance,
          color: primaryColor,
        );
      case 'soltempel':
        return _NodeVisual(
          icon: Icons.wb_sunny,
          color: accentColor,
        );
      case 'skog':
        return _NodeVisual(
          icon: Icons.park,
          color: secondaryColor,
        );
      case 'trumma':
        return _NodeVisual(
          icon: Icons.music_note,
          color: Color.alphaBlend(
            primaryColor.withValues(alpha: 0.65),
            accentColor,
          ),
        );
      case 'port':
        return _NodeVisual(
          icon: Icons.door_front_door,
          color: Color.alphaBlend(
            secondaryColor.withValues(alpha: 0.40),
            primaryColor,
          ),
        );
      case 'skatt':
        return _NodeVisual(
          icon: Icons.workspace_premium,
          color: accentColor.withValues(alpha: 0.92),
        );
    }

    return _NodeVisual(
      icon: Icons.explore,
      color: accentColor,
    );
  }
}
