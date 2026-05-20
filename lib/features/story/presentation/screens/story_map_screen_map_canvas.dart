part of 'story_map_screen.dart';

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
    final shadowColor = context.appThemeColors.panelShadowColor;
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
                Image.asset(
                  widget.backgroundAsset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: widget.accentColor.withValues(alpha: 0.35),
                  ),
                ),
                ColoredBox(
                  color: shadowColor.withValues(alpha: 0.32),
                ),
                CustomPaint(
                  painter: _MapPathPainter(
                    positions: positions,
                    nodes: nodes,
                    completedColor: widget.completedColor,
                    currentColor: widget.currentColor,
                    accentColor: widget.accentColor,
                    onPrimary: widget.onPrimary,
                  ),
                ),
                ...List.generate(nodes.length, (i) {
                  final pos = positions[i];
                  final node = nodes[i];
                  final isActive = node.state == StoryNodeState.current;
                  const radius = _MapPathPainter.nodeRadius;
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
                            if (isActive)
                              Container(
                                width: radius * 2 + 12,
                                height: radius * 2 + 12,
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
                            if (_storyLandmarkAssetPath(node.sceneTag)
                                case final assetPath?)
                              Positioned(
                                bottom: 6,
                                child: Image.asset(
                                  assetPath,
                                  width: node.sceneTag == 'baslager' ? 48 : 54,
                                  height: node.sceneTag == 'baslager' ? 48 : 54,
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: shadowColor.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${node.stepIndex + 1}',
                                  style: TextStyle(
                                    color: widget.onPrimary,
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
    required this.onPrimary,
  });

  final List<Offset> positions;
  final List<StoryNode> nodes;
  final Color completedColor;
  final Color currentColor;
  final Color accentColor;
  final Color onPrimary;

  static const nodeRadius = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    for (var i = 0; i < positions.length - 1; i++) {
      final isDone = nodes[i].state == StoryNodeState.completed &&
          nodes[i + 1].state != StoryNodeState.upcoming;
      final paint = Paint()
        ..color = isDone
            ? completedColor.withValues(alpha: 0.90)
            : onPrimary.withValues(alpha: 0.30)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(positions[i], positions[i + 1], paint);
    }

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
            onPrimary.withValues(alpha: 0.22),
            onPrimary.withValues(alpha: 0.50),
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

      if (node.state == StoryNodeState.completed) {
        final iconPaint = Paint()
          ..color = onPrimary
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
            ..color = onPrimary
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
    final shadowColor = context.appThemeColors.panelShadowColor;
    final color = switch (node.state) {
      StoryNodeState.completed => completedColor,
      StoryNodeState.current => currentColor,
      StoryNodeState.upcoming => nextColor.withValues(alpha: 0.90),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: shadowColor.withValues(alpha: 0.82),
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
                  style: TextStyle(
                    color: onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.close_rounded,
            color: onPrimary.withValues(alpha: 0.50),
            size: 16,
          ),
        ],
      ),
    );
  }
}

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
    this.icon,
    this.assetPath,
    required this.color,
  });

  final IconData? icon;
  final String? assetPath;
  final Color color;

  factory _NodeVisual.forSceneTag(
    String sceneTag, {
    required Color primaryColor,
    required Color secondaryColor,
    required Color accentColor,
  }) {
    final assetPath = _storyLandmarkAssetPath(sceneTag);
    if (assetPath != null) {
      return _NodeVisual(
        assetPath: assetPath,
        color: _storyLandmarkVisualColor(
          sceneTag,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
        ),
      );
    }

    switch (sceneTag) {
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
      case 'fors':
        return _NodeVisual(
          icon: Icons.water,
          color: Color.alphaBlend(
            accentColor.withValues(alpha: 0.55),
            primaryColor,
          ),
        );
    }

    return _NodeVisual(
      icon: Icons.explore,
      color: accentColor,
    );
  }
}

String? _storyLandmarkAssetPath(String sceneTag) {
  switch (sceneTag) {
    case 'baslager':
      return 'assets/images/story/campfire.png';
    case 'koja':
      return 'assets/images/story/cabin.png';
    case 'monkey_rock':
      return 'assets/images/story/map_monkey_rock.png';
    case 'skugga':
      return 'assets/images/story/map_shadow_trail.png';
    case 'fors':
      return 'assets/images/story/map_waterfall.png';
    case 'frukt':
      return 'assets/images/story/map_fruit_glade.png';
    case 'bro':
      return 'assets/images/story/map_bridge.png';
    case 'karta':
      return 'assets/images/story/map_cartography_camp.png';
    case 'tempel':
      return 'assets/images/story/map_temple_gate.png';
    case 'soltempel':
      return 'assets/images/story/map_sun_temple.png';
    case 'skog':
      return 'assets/images/story/map_forest_grove.png';
    case 'trumma':
      return 'assets/images/story/map_drum_grove.png';
    case 'port':
      return 'assets/images/story/map_stone_gate.png';
    case 'skatt':
      return 'assets/images/story/map_treasure_cache.png';
  }

  return null;
}

String? _storyBiomePreviewAssetPath(StoryBiomePreview biome) {
  switch (biome.name) {
    case 'Nattskogen':
      return 'assets/images/story/biome_night_forest_preview.png';
    case 'Stjärnöknen':
      return 'assets/images/story/biome_star_desert_preview.png';
  }

  return null;
}

Color _storyLandmarkVisualColor(
  String sceneTag, {
  required Color primaryColor,
  required Color secondaryColor,
  required Color accentColor,
}) {
  switch (sceneTag) {
    case 'baslager':
    case 'koja':
      return primaryColor.withValues(alpha: 0.88);
    case 'monkey_rock':
      return Color.alphaBlend(
        secondaryColor.withValues(alpha: 0.55),
        primaryColor,
      );
    case 'fors':
      return Color.alphaBlend(
        accentColor.withValues(alpha: 0.55),
        primaryColor,
      );
    case 'frukt':
      return secondaryColor.withValues(alpha: 0.92);
    case 'bro':
      return Color.alphaBlend(
        primaryColor.withValues(alpha: 0.55),
        secondaryColor,
      );
    case 'karta':
      return Color.alphaBlend(
        accentColor.withValues(alpha: 0.60),
        secondaryColor,
      );
    case 'tempel':
      return primaryColor;
    case 'soltempel':
    case 'skatt':
      return accentColor.withValues(alpha: 0.92);
    case 'skog':
      return secondaryColor;
    case 'trumma':
      return Color.alphaBlend(
        primaryColor.withValues(alpha: 0.65),
        accentColor,
      );
    case 'port':
      return Color.alphaBlend(
        secondaryColor.withValues(alpha: 0.40),
        primaryColor,
      );
  }

  return accentColor;
}
