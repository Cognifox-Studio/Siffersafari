import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/features/inventory/presentation/screens/wardrobe_screen.dart';
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

  static final Map<String, InventoryItem> _inventoryItemsById = {
    for (final item in InventoryConfig.allItems) item.id: item,
  };

  void _openWardrobe(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider).activeUser;
    if (user != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const WardrobeScreen(),
        ),
      );
    }
  }

  List<InventoryItem> _visibleCampRewards(List<String> unlockedItemIds) {
    final unlocked = unlockedItemIds.toSet();
    return InventoryConfig.levelUnlockOrderIds
        .where(unlocked.contains)
        .map((id) => _inventoryItemsById[id])
        .whereType<InventoryItem>()
        .where((item) => item.slot != 'pet')
        .take(_visibleCampRewardCount)
        .toList(growable: false);
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
    final campRewards = _visibleCampRewards(unlockedItemIds);
    final campPet = InventoryConfig.firstUnlockedCampCompanion(
      unlockedItemIds,
    );
    final unlockedCampItemCount = _unlockedCampItemCount(unlockedItemIds);
    final visibleCampItemCount = campRewards.length + (campPet != null ? 1 : 0);
    final hiddenCampItemCount = (unlockedCampItemCount - visibleCampItemCount)
        .clamp(0, unlockedCampItemCount);

    // The height of the camp scene.
    final height = isWideScreen ? 280.0 : 250.0;

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

          if (unlockedCampItemCount > 0)
            Positioned(
              top: isWideScreen ? 16 : 12,
              right: isWideScreen ? 16 : 12,
              child: IgnorePointer(
                child: _CampCollectionBadge(
                  itemCount: unlockedCampItemCount,
                  hiddenCount: hiddenCampItemCount,
                ),
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
              ),
            ),
          ),

          if (campRewards.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: IgnorePointer(
                child: Text(
                  'Fler saker dyker upp här.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
  });

  final int itemCount;
  final int hiddenCount;

  String get _countLabel => '$itemCount ${itemCount == 1 ? 'sak' : 'saker'}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: hiddenCount > 0
          ? 'Du har $_countLabel i campet. $hiddenCount till syns inte här.'
          : 'Du har $_countLabel i campet.',
      child: ExcludeSemantics(
        child: Container(
          key: const Key('camp_scene_collection_badge'),
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
              if (hiddenCount > 0)
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
      ),
    );
  }
}

class _CampRewardSpot extends StatelessWidget {
  const _CampRewardSpot({
    required this.item,
    required this.pedestalWidth,
    required this.rotation,
    required this.height,
  });

  final InventoryItem item;
  final double pedestalWidth;
  final double rotation;
  final double height;

  @override
  Widget build(BuildContext context) {
    final baseItemSize = (height * 0.22).clamp(42.0, 72.0);
    final itemSize = (baseItemSize * (0.6 + (item.renderScale * 0.45)))
        .clamp(38.0, 78.0)
        .toDouble();

    return Transform.rotate(
      angle: rotation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              item.assetPath,
              key: Key('camp_scene_prop_${item.id}'),
              width: itemSize,
              height: itemSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: pedestalWidth,
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
