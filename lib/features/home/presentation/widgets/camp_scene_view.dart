import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/utils/image_cache_size.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/features/home/presentation/widgets/camp_collection_album.dart';
import 'package:siffersafari/app/navigation/app_navigator.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

/// A small camp scene on home that can surface unlocked props and companions.
class CampSceneView extends ConsumerWidget {
  const CampSceneView({
    required this.mascotReaction,
    required this.mascotReactionNonce,
    this.isWideScreen = false,
    super.key,
  });

  final CharacterReaction mascotReaction;
  final int mascotReactionNonce;
  final bool isWideScreen;

  static const _visibleCampRewardCount = 4;
  static const _campRewardSpots = <_CampRewardSpotConfig>[
    _CampRewardSpotConfig(
      alignment: Alignment(-0.72, 0.82),
      pedestalWidth: 58,
      rotation: -0.08,
    ),
    _CampRewardSpotConfig(
      alignment: Alignment(0.74, 0.84),
      pedestalWidth: 62,
      rotation: 0.08,
    ),
    _CampRewardSpotConfig(
      alignment: Alignment(-0.56, 0.42),
      pedestalWidth: 54,
      rotation: -0.04,
    ),
    _CampRewardSpotConfig(
      alignment: Alignment(0.58, 0.44),
      pedestalWidth: 56,
      rotation: 0.04,
    ),
  ];

  void _openWardrobe(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider).activeUser;
    if (user != null) {
      AppNavigator.openWardrobe(context);
    }
  }

  void _openCampCollection(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider).activeUser;
    if (user == null) return;

    ref.read(audioServiceProvider).playClickSound();
    showCampCollectionAlbum(
      context,
      unlockedItemIds: user.unlockedItems,
    );
  }

  int _unlockedCampItemCount(List<String> unlockedItemIds) {
    final unlocked = unlockedItemIds.toSet();
    return InventoryConfig.levelUnlockOrderIds.where(unlocked.contains).length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).activeUser;
    final characterId = user?.selectedCharacterId == 'signe'
        ? CharacterId.signe
        : user?.selectedCharacterId == 'astrid'
            ? CharacterId.astrid
            : CharacterId.loke;

    final theme = Theme.of(context);
    final unlockedItemIds = user?.unlockedItems ?? const <String>[];
    final campRewards = InventoryConfig.visibleCampPedestalItems(
      unlockedItemIds,
      maxVisible: _visibleCampRewardCount,
    );
    final arrivalItemId = ref.watch(userProvider).newlyUnlockedItem?.id;
    final campPet = InventoryConfig.firstUnlockedCampCompanion(
      unlockedItemIds,
    );
    final unlockedCampItemCount = _unlockedCampItemCount(unlockedItemIds);
    final visibleCampItemCount = campRewards.length + (campPet != null ? 1 : 0);
    final hiddenCampItemCount = (unlockedCampItemCount - visibleCampItemCount)
        .clamp(0, unlockedCampItemCount);

    // The height of the camp scene.
    final height = isWideScreen ? 220.0 : 160.0;

    return Container(
      key: const Key('camp_scene_view'),
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF79BC87), Color(0xFF3E7B57)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF28543C).withValues(alpha: 0.75),
          width: 4,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(-0.9, -0.92),
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 1.0),
                    child: Container(
                      height: height * 0.36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B5B3E), Color(0xFF4E3E29)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.elliptical(260, 58),
                        ),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: isWideScreen ? 18 : 12,
            bottom: isWideScreen ? 60 : 54,
            child: _SceneDecoration(
              key: const Key('camp_scene_cabin'),
              assetPath: 'assets/images/story/cabin.png',
              width: isWideScreen ? 96 : 82,
            ),
          ),
          Positioned(
            right: isWideScreen ? 24 : 16,
            bottom: isWideScreen ? 52 : 46,
            child: _SceneDecoration(
              key: const Key('camp_scene_campfire'),
              assetPath: 'assets/images/story/campfire.png',
              width: isWideScreen ? 84 : 72,
            ),
          ),

          for (var index = 0; index < campRewards.length; index++)
            Align(
              alignment: _campRewardSpots[index].alignment,
              child: _CampRewardSpot(
                item: campRewards[index],
                pedestalWidth: _campRewardSpots[index].pedestalWidth,
                rotation: _campRewardSpots[index].rotation,
                height: height,
                playArrival: arrivalItemId == campRewards[index].id,
              ),
            ),

          Align(
            alignment: const Alignment(-0.18, 0.82),
            child: _CampPetSpot(
              item: campPet,
              height: height,
            ),
          ),

          // Character
          Positioned(
            bottom: 10,
            child: SizedBox(
              height: height * 0.75, // Scale mascot slightly within camp
              child: GameCharacter(
                characterId: characterId,
                reaction: mascotReaction,
                reactionNonce: mascotReactionNonce,
                height: height * 0.75,
                equippedItems: user?.equippedItems ?? const {},
                customItemOffsets: user?.customItemOffsets ?? const {},
                onTap: () => _openWardrobe(context, ref),
                semanticLabel: 'Öppna garderoben',
              ),
            ),
          ),

          if (campRewards.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Center(
                child: Semantics(
                  button: true,
                  label: 'Öppna garderoben',
                  child: GestureDetector(
                    key: const Key('camp_scene_wardrobe_cta'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(audioServiceProvider).playClickSound();
                      _openWardrobe(context, ref);
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'Tryck här för garderoben',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.96),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: isWideScreen ? 16 : 12,
            right: isWideScreen ? 16 : 12,
            child: _CampCollectionBadge(
              itemCount: unlockedCampItemCount,
              hiddenCount: hiddenCampItemCount,
              onTap: () => _openCampCollection(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampRewardSpotConfig {
  const _CampRewardSpotConfig({
    required this.alignment,
    required this.pedestalWidth,
    required this.rotation,
  });

  final Alignment alignment;
  final double pedestalWidth;
  final double rotation;
}

class _CampCollectionBadge extends StatelessWidget {
  const _CampCollectionBadge({
    required this.itemCount,
    required this.hiddenCount,
    required this.onTap,
  });

  final int itemCount;
  final int hiddenCount;
  final VoidCallback onTap;

  String get _countLabel => itemCount == 0
      ? 'Samla'
      : '$itemCount ${itemCount == 1 ? 'sak' : 'saker'}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticsLabel = itemCount == 0
        ? 'Visa camp-samling. Inga saker än — se vad du kan samla.'
        : hiddenCount > 0
            ? 'Visa camp-samling. Du har $_countLabel i campet. $hiddenCount till syns inte här.'
            : 'Visa camp-samling. Du har $_countLabel i campet.';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        key: const Key('camp_scene_collection_badge'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8E7A7).withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF8B6A2C).withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _countLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF5C441C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (itemCount == 0)
                  Text(
                    'Vad kan du få?',
                    key: const Key('camp_scene_collection_empty_hint'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF6C5425),
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else if (hiddenCount > 0)
                  Text(
                    '+$hiddenCount till',
                    key: const Key('camp_scene_collection_hidden_count'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF6C5425),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneDecoration extends StatelessWidget {
  const _SceneDecoration({
    required this.assetPath,
    required this.width,
    super.key,
  });

  final String assetPath;
  final double width;

  @override
  Widget build(BuildContext context) {
    final cacheWidth = imageCacheExtent(context, width);

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
        cacheWidth: cacheWidth,
      ),
    );
  }
}

class _CampRewardSpot extends StatefulWidget {
  const _CampRewardSpot({
    required this.item,
    required this.pedestalWidth,
    required this.rotation,
    required this.height,
    this.playArrival = false,
  });

  final InventoryItem item;
  final double pedestalWidth;
  final double rotation;
  final double height;
  final bool playArrival;

  @override
  State<_CampRewardSpot> createState() => _CampRewardSpotState();
}

class _CampRewardSpotState extends State<_CampRewardSpot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrivalController;
  late final Animation<double> _scale;
  late final Animation<double> _offsetY;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _arrivalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 1.12), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 45),
    ]).animate(
      CurvedAnimation(parent: _arrivalController, curve: Curves.easeOutCubic),
    );
    _offsetY = Tween<double>(begin: -28, end: 0).animate(
      CurvedAnimation(parent: _arrivalController, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _arrivalController,
        curve: const Interval(0, 0.45, curve: Curves.easeOut),
      ),
    );
    if (widget.playArrival) {
      _arrivalController.forward(from: 0);
    } else {
      _arrivalController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _CampRewardSpot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.playArrival && widget.playArrival) {
      _arrivalController.forward(from: 0);
    }
    if (oldWidget.item.id != widget.item.id && widget.playArrival) {
      _arrivalController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _arrivalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseItemSize = (widget.height * 0.22).clamp(42.0, 72.0);
    final itemSize =
        (baseItemSize * (0.6 + (widget.item.renderScale * 0.45)))
            .clamp(38.0, 78.0)
            .toDouble();
    final cacheSize = imageCacheExtent(context, itemSize);

    return AnimatedBuilder(
      animation: _arrivalController,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.rotation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, _offsetY.value),
                child: Transform.scale(
                  scale: _scale.value,
                  child: Opacity(
                    opacity: _opacity.value,
                    child: child,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: widget.pedestalWidth,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A603B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          widget.item.assetPath,
          key: Key('camp_scene_prop_${widget.item.id}'),
          width: itemSize,
          height: itemSize,
          fit: BoxFit.contain,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
        ),
      ),
    );
  }
}

class _CampPetSpot extends StatelessWidget {
  const _CampPetSpot({
    required this.item,
    required this.height,
  });

  final InventoryItem? item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final petSize = (height * 0.2).clamp(44.0, 72.0).toDouble();
    final cacheSize = imageCacheExtent(context, petSize);
    final placeholderCacheSize = imageCacheExtent(context, petSize * 0.88);

    return Column(
      key: const Key('camp_scene_pet_slot'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item != null)
          DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              item!.assetPath,
              key: Key('camp_scene_pet_${item!.id}'),
              width: petSize,
              height: petSize,
              fit: BoxFit.contain,
              cacheWidth: cacheSize,
              cacheHeight: cacheSize,
            ),
          )
        else
          Container(
            key: const Key('camp_scene_pet_placeholder'),
            width: petSize * 0.88,
            height: petSize * 0.88,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 2,
              ),
            ),
            child: Image.asset(
              'assets/images/ui/ic_reward_locked_nobg.png',
              fit: BoxFit.contain,
              cacheWidth: placeholderCacheSize,
              cacheHeight: placeholderCacheSize,
            ),
          ),
        const SizedBox(height: 6),
        Container(
          width: petSize + 10,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF7A603B).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
        ),
      ],
    );
  }
}
