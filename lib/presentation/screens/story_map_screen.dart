import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_theme_provider.dart';
import '../../core/providers/story_progress_provider.dart';
import '../../core/utils/adaptive_layout.dart';
import '../../domain/entities/story_progress.dart';
import '../widgets/themed_background_scaffold.dart';

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

    return ThemedBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Djungelkartan'),
      ),
      body: story == null
          ? Center(
              child: Text(
                'Ingen karta tillgänglig ännu.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: mutedOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: layout.isExpandedWidth ? 980 : 760,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StoryMapHeader(
                        story: story,
                        heroAsset: themeCfg.questHeroAsset,
                        backgroundAsset: themeCfg.backgroundAsset,
                        accentColor: scheme.secondary,
                        onPrimary: onPrimary,
                        mutedOnPrimary: mutedOnPrimary,
                        subtleOnPrimary: subtleOnPrimary,
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                      _StoryMapCanvas(
                        story: story,
                        accentColor: scheme.secondary,
                        onPrimary: onPrimary,
                        mutedOnPrimary: mutedOnPrimary,
                        subtleOnPrimary: subtleOnPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _StoryMapHeader extends StatelessWidget {
  const _StoryMapHeader({
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
    final totalChapters = ((story.totalNodes - 1) ~/ 5) + 1;

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
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: SizedBox(
              height: 150,
              child: Image.asset(
                heroAsset,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    backgroundAsset,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  );
                },
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
            story.chapterTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Hela expeditionen',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            story.worldSubtitle,
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
              SizedBox(
                width: 220,
                child: _HeaderStat(
                  label: 'Checkpoint',
                  value: '${story.completedNodes}/${story.totalNodes}',
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
              ),
              SizedBox(
                width: 220,
                child: _HeaderStat(
                  label: 'Ville nu',
                  value: story.currentNode?.landmark ?? 'Stigen',
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
              ),
              SizedBox(
                width: 220,
                child: _HeaderStat(
                  label: 'Etapper',
                  value: '$totalChapters delar',
                  onPrimary: onPrimary,
                  mutedOnPrimary: mutedOnPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
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
    return Container(
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
    );
  }
}

class _StoryMapCanvas extends StatelessWidget {
  const _StoryMapCanvas({
    required this.story,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryProgress story;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final totalChapters = ((story.nodes.length - 1) ~/ 5) + 1;

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
          _StoryMapLegend(
            accentColor: accentColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          for (var chapterIndex = 0;
              chapterIndex < totalChapters;
              chapterIndex++) ...[
            _ChapterMarker(
              title: _chapterTitle(chapterIndex),
              subtitle: _chapterSubtitle(chapterIndex),
              accentColor: accentColor,
              onPrimary: onPrimary,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            for (var i = chapterIndex * 5;
                i < ((chapterIndex + 1) * 5).clamp(0, story.nodes.length);
                i++) ...[
              _StoryTimelineRow(
                node: story.nodes[i],
                accentColor: accentColor,
                onPrimary: onPrimary,
                mutedOnPrimary: mutedOnPrimary,
                subtleOnPrimary: subtleOnPrimary,
                isLast: i == story.nodes.length - 1,
              ),
              if (i < ((chapterIndex + 1) * 5).clamp(0, story.nodes.length) - 1)
                const SizedBox(height: AppConstants.smallPadding),
            ],
            if (chapterIndex < totalChapters - 1)
              const SizedBox(height: AppConstants.largePadding),
          ],
        ],
      ),
    );
  }

  String _chapterTitle(int chapterIndex) => 'Etapp ${chapterIndex + 1}';

  String _chapterSubtitle(int chapterIndex) {
    switch (chapterIndex) {
      case 0:
        return 'Starten genom låglandet';
      case 1:
        return 'Djupare in bland stigarna';
      case 2:
        return 'Ruiner, forsar och portvakter';
      default:
        return 'Den sista vägen mot templet';
    }
  }
}

class _StoryTimelineRow extends StatelessWidget {
  const _StoryTimelineRow({
    required this.node,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
    required this.isLast,
  });

  final StoryNode node;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCurrent = node.state == StoryNodeState.current;
    final isCompleted = node.state == StoryNodeState.completed;
    final markerColor = isCompleted || isCurrent ? accentColor : mutedOnPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isCompleted ? accentColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: markerColor, width: 2),
                ),
                child: isCurrent
                    ? Icon(Icons.place, size: 10, color: accentColor)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 88,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: mutedOnPrimary.withValues(alpha: 0.45),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: _StoryMapNodeCard(
            node: node,
            accentColor: accentColor,
            onPrimary: onPrimary,
            mutedOnPrimary: mutedOnPrimary,
            subtleOnPrimary: subtleOnPrimary,
          ),
        ),
      ],
    );
  }
}

class _StoryMapNodeCard extends StatelessWidget {
  const _StoryMapNodeCard({
    required this.node,
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
  });

  final StoryNode node;
  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;

  @override
  Widget build(BuildContext context) {
    final isCurrent = node.state == StoryNodeState.current;
    final isCompleted = node.state == StoryNodeState.completed;
    final chapterIndex = node.stepIndex ~/ 5;
    final motif = _NodeMotif.forSceneTag(
      node.sceneTag,
      accentColor: accentColor,
      onPrimary: onPrimary,
    );
    final borderColor =
        isCompleted || isCurrent ? accentColor : subtleOnPrimary;
    final fillColor = isCompleted
        ? accentColor.withValues(alpha: AppOpacities.accentFillSubtle)
        : onPrimary.withValues(alpha: AppOpacities.subtleFill);

    final stateLabel = switch (node.state) {
      StoryNodeState.completed => 'Klar',
      StoryNodeState.current => 'Här är Ville nu',
      StoryNodeState.upcoming => 'Kommer snart',
    };

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fillColor,
            motif.tint.withValues(alpha: isCompleted ? 0.22 : 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: isCurrent ? 22 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Checkpoint ${node.stepIndex + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.microSpacing6,
                  vertical: AppConstants.microSpacing4,
                ),
                decoration: BoxDecoration(
                  color:
                      (isCompleted || isCurrent ? accentColor : mutedOnPrimary)
                          .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stateLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isCompleted || isCurrent
                            ? accentColor
                            : mutedOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            node.landmark,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            node.landmarkHint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.microSpacing6,
            children: [
              _MiniTag(
                icon: motif.icon,
                label: motif.label,
                color: motif.foreground,
                fill: motif.tint.withValues(alpha: 0.18),
              ),
              _MiniTag(
                icon: Icons.auto_awesome,
                label: '${node.operation.emoji} ${node.title}',
                color: onPrimary,
                fill: onPrimary.withValues(alpha: 0.10),
              ),
              _MiniTag(
                icon: Icons.flag_outlined,
                label: 'Etapp ${chapterIndex + 1}',
                color: mutedOnPrimary,
                fill: mutedOnPrimary.withValues(alpha: 0.10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterMarker extends StatelessWidget {
  const _ChapterMarker({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onPrimary,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: AppOpacities.borderSubtle),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onPrimary.withValues(alpha: 0.80),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StoryMapLegend extends StatelessWidget {
  const _StoryMapLegend({
    required this.accentColor,
    required this.onPrimary,
    required this.mutedOnPrimary,
  });

  final Color accentColor;
  final Color onPrimary;
  final Color mutedOnPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: AppOpacities.panelFill),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: onPrimary.withValues(alpha: AppOpacities.borderSubtle),
        ),
      ),
      child: Wrap(
        spacing: AppConstants.defaultPadding,
        runSpacing: AppConstants.smallPadding,
        children: [
          _LegendItem(
            color: accentColor,
            label: 'Klar checkpoint',
            textColor: onPrimary,
          ),
          _LegendItem(
            color: onPrimary,
            label: 'Villes position',
            textColor: onPrimary,
            outlined: true,
          ),
          _LegendItem(
            color: mutedOnPrimary,
            label: 'Nästa plats',
            textColor: onPrimary,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.textColor,
    this.outlined = false,
  });

  final Color color;
  final String label;
  final Color textColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: AppConstants.microSpacing6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({
    required this.icon,
    required this.label,
    required this.color,
    required this.fill,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.microSpacing6,
        vertical: AppConstants.microSpacing4,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppConstants.microSpacing4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeMotif {
  const _NodeMotif({
    required this.label,
    required this.description,
    required this.icon,
    required this.tint,
    required this.foreground,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color tint;
  final Color foreground;

  factory _NodeMotif.forSceneTag(
    String sceneTag, {
    required Color accentColor,
    required Color onPrimary,
  }) {
    switch (sceneTag) {
      case 'baslager':
        return _NodeMotif(
          label: 'Basläger',
          description: 'Packa mod, karta och första ledtråden.',
          icon: Icons.cabin,
          tint: const Color(0xFF7A5A34),
          foreground: onPrimary,
        );
      case 'frukt':
        return _NodeMotif(
          label: 'Fruktzon',
          description: 'Sifferfrukter lyser mellan grenarna.',
          icon: Icons.apple,
          tint: const Color(0xFF7AAE3E),
          foreground: onPrimary,
        );
      case 'skugga':
        return _NodeMotif(
          label: 'Skuggspår',
          description: 'Följ de dolda markeringarna i dunklet.',
          icon: Icons.dark_mode,
          tint: const Color(0xFF49506A),
          foreground: onPrimary,
        );
      case 'bro':
        return _NodeMotif(
          label: 'Brofäste',
          description: 'Håll balansen över den höga passagen.',
          icon: Icons.linear_scale,
          tint: const Color(0xFF8A6C45),
          foreground: onPrimary,
        );
      case 'karta':
        return _NodeMotif(
          label: 'Kartspår',
          description: 'Gamla tecken visar rätt riktning.',
          icon: Icons.map,
          tint: const Color(0xFF3A8E8A),
          foreground: onPrimary,
        );
      case 'fors':
        return _NodeMotif(
          label: 'Forskant',
          description: 'Fånga talen innan de sveps vidare.',
          icon: Icons.water,
          tint: const Color(0xFF3A7BC1),
          foreground: onPrimary,
        );
      case 'tempel':
        return _NodeMotif(
          label: 'Portvakt',
          description: 'Stenporten öppnar sig steg för steg.',
          icon: Icons.account_balance,
          tint: const Color(0xFF8B6F42),
          foreground: onPrimary,
        );
      case 'soltempel':
        return _NodeMotif(
          label: 'Solkammare',
          description: 'Det sista ljuset markerar målet.',
          icon: Icons.wb_sunny,
          tint: const Color(0xFFD39A2F),
          foreground: onPrimary,
        );
      case 'skog':
        return _NodeMotif(
          label: 'Vildskog',
          description: 'Tät grönska gömmer nästa riktmärke.',
          icon: Icons.park,
          tint: const Color(0xFF4E8B52),
          foreground: onPrimary,
        );
      case 'trumma':
        return _NodeMotif(
          label: 'Trumplats',
          description: 'Rytmen visar att något viktigt är nära.',
          icon: Icons.music_note,
          tint: const Color(0xFF8C5632),
          foreground: onPrimary,
        );
      case 'port':
        return _NodeMotif(
          label: 'Stenport',
          description: 'Passagen öppnar sig när du är redo.',
          icon: Icons.door_front_door,
          tint: const Color(0xFF6D667C),
          foreground: onPrimary,
        );
      case 'skatt':
        return _NodeMotif(
          label: 'Skattzon',
          description: 'Gamla fynd visar hur långt du kommit.',
          icon: Icons.workspace_premium,
          tint: const Color(0xFFB88C2E),
          foreground: onPrimary,
        );
    }

    return _NodeMotif(
      label: 'Expedition',
      description: 'Fortsätt framåt genom djungeln.',
      icon: Icons.explore,
      tint: accentColor,
      foreground: onPrimary,
    );
  }
}
