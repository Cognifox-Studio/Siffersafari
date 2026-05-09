import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  CharacterReaction _selectedReaction = CharacterReaction.idle;

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(userProvider).activeUser;
    final scheme = Theme.of(context).colorScheme;

    if (activeUser == null) {
      return const SizedBox.shrink();
    }

    final unlockedItems = activeUser.unlockedItems;
    final equippedItems = activeUser.equippedItems;

    return ThemedBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            ref.read(audioServiceProvider).playClickSound();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          activeUser.selectedCharacterId == 'signe'
              ? 'Signes garderob'
              : activeUser.selectedCharacterId == 'astrid'
                  ? 'Astrids garderob'
                  : 'Lokes garderob',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Återställ placering',
            onPressed: () {
              ref.read(audioServiceProvider).playClickSound();
              ref.read(userProvider.notifier).clearCustomItemOffsets();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;

            if (isLandscape) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _buildCharacter(activeUser),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: AppConstants.largePadding,
                          bottom: AppConstants.largePadding),
                      child: _buildGrid(context, unlockedItems, equippedItems),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                const SizedBox(height: AppConstants.defaultPadding),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _buildCharacter(activeUser),
                  ),
                ),
                const SizedBox(height: AppConstants.largePadding),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.borderRadius * 2),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: AppConstants.largePadding),
                    child: _buildGrid(context, unlockedItems, equippedItems),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacter(UserProgress activeUser) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ReactionButton(
                label: 'Vanlig',
                isSelected: _selectedReaction == CharacterReaction.idle,
                onTap: () {
                  setState(() => _selectedReaction = CharacterReaction.idle);
                  ref.read(audioServiceProvider).playClickSound();
                },
              ),
              const SizedBox(width: AppConstants.smallPadding),
              _ReactionButton(
                label: 'Tänker',
                isSelected: _selectedReaction == CharacterReaction.answerWrong,
                onTap: () {
                  setState(
                      () => _selectedReaction = CharacterReaction.answerWrong);
                  ref.read(audioServiceProvider).playClickSound();
                },
              ),
              const SizedBox(width: AppConstants.smallPadding),
              _ReactionButton(
                label: 'Glad!',
                isSelected:
                    _selectedReaction == CharacterReaction.answerCorrect,
                onTap: () {
                  setState(() =>
                      _selectedReaction = CharacterReaction.answerCorrect);
                  ref.read(audioServiceProvider).playClickSound();
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          GameCharacter(
            characterId: activeUser.selectedCharacterId == 'signe'
                ? CharacterId.signe
                : activeUser.selectedCharacterId == 'astrid'
                    ? CharacterId.astrid
                    : CharacterId.loke,
            height: 200,
            reaction: _selectedReaction,
            reactionNonce: DateTime.now().millisecondsSinceEpoch,
            persistentReaction: true,
            equippedItems: activeUser.equippedItems,
            customItemOffsets: activeUser.customItemOffsets,
            interactiveItems: true,
            onItemOffsetUpdated: (itemSlug, dx, dy, scale, rot) {
              ref.read(userProvider.notifier).setCustomItemOffset(
                  itemSlug, dx, dy,
                  scale: scale, rotation: rot);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<String> unlockedItems,
      Map<String, String> equippedItems) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: InventoryConfig.allItems.length,
      itemBuilder: (context, index) {
        final item = InventoryConfig.allItems[index];
        final isUnlocked = unlockedItems.contains(item.id);
        final isEquipped = equippedItems.values.contains(item.id);

        return GestureDetector(
          onTap: () {
            if (isUnlocked) {
              ref.read(audioServiceProvider).playClickSound();
              if (isEquipped) {
                final existingKey = equippedItems.entries
                    .firstWhere(
                      (entry) => entry.value == item.id,
                      orElse: () => MapEntry(item.id, item.id),
                    )
                    .key;
                ref.read(userProvider.notifier).unequipItem(existingKey);
              } else {
                ref.read(userProvider.notifier).equipItem(item.id, item.id);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isEquipped
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: isEquipped
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Opacity(
                    opacity: isUnlocked ? 1.0 : 0.3,
                    child: Image.asset(item.assetPath),
                  ),
                ),
                if (!isUnlocked)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Image.asset(
                      'assets/images/ui/ic_reward_locked.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
