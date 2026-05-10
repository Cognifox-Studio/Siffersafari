import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
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
    final themeCfg = ref.watch(appThemeConfigProvider);

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: AppConstants.smallPadding,
                  bottom: AppConstants.defaultPadding,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ReactionButton(
                    label: 'Vanlig',
                    themeCfg: themeCfg,
                    isSelected: _selectedReaction == CharacterReaction.idle,
                    onTap: () {
                      setState(
                          () => _selectedReaction = CharacterReaction.idle,);
                      ref.read(audioServiceProvider).playClickSound();
                    },
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  _ReactionButton(
                    label: 'TÃ¤nker',
                    themeCfg: themeCfg,
                    isSelected:
                        _selectedReaction == CharacterReaction.answerWrong,
                    onTap: () {
                      setState(
                        () => _selectedReaction = CharacterReaction.answerWrong,
                      );
                      ref.read(audioServiceProvider).playClickSound();
                    },
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  _ReactionButton(
                    label: 'Glad!',
                    themeCfg: themeCfg,
                    isSelected:
                        _selectedReaction == CharacterReaction.answerCorrect,
                    onTap: () {
                      setState(
                        () =>
                            _selectedReaction = CharacterReaction.answerCorrect,
                      );
                      ref.read(audioServiceProvider).playClickSound();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape =
                      constraints.maxWidth > constraints.maxHeight;

                  if (isLandscape) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: _buildCharacter(activeUser, themeCfg),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppConstants.largePadding,
                              bottom: AppConstants.largePadding,
                            ),
                            child: PlayfulPanel(
                              backgroundColor: themeCfg.cardColor,
                              padding: const EdgeInsets.all(
                                  AppConstants.defaultPadding,),
                              child: _buildGrid(
                                context,
                                unlockedItems,
                                equippedItems,
                                themeCfg,
                                _selectedReaction,
                              ),
                            ),
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
                          child: _buildCharacter(activeUser, themeCfg),
                        ),
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                            vertical: AppConstants.defaultPadding,
                          ),
                          child: PlayfulPanel(
                            backgroundColor: themeCfg.cardColor,
                            padding: const EdgeInsets.all(
                                AppConstants.defaultPadding,),
                            child: _buildGrid(
                              context,
                              unlockedItems,
                              equippedItems,
                              themeCfg,
                              _selectedReaction,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacter(UserProgress activeUser, AppThemeConfig themeCfg) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: GameCharacter(
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
                  itemSlug,
                  dx,
                  dy,
                  scale: scale,
                  rotation: rot,
                );
          },
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<String> unlockedItems,
    Map<String, String> equippedItems,
    AppThemeConfig themeCfg,
    CharacterReaction pose,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: InventoryConfig.allItems.length,
      itemBuilder: (context, index) {
        final item = InventoryConfig.allItems[index];
        final isUnlocked = kDebugMode || unlockedItems.contains(item.id);

        final poseKey = '${pose.name}_${item.id}';
        final isEquippedInPose = equippedItems.containsKey(poseKey) ||
            (pose == CharacterReaction.idle &&
                equippedItems.entries
                    .any((e) => e.value == item.id && !e.key.contains('_')));

        return GestureDetector(
          onTap: () {
            if (isUnlocked) {
              ref.read(audioServiceProvider).playClickSound();
              if (isEquippedInPose) {
                final existingKey =
                    equippedItems.containsKey(poseKey) ? poseKey : item.id;
                ref.read(userProvider.notifier).unequipItem(existingKey);
              } else {
                ref.read(userProvider.notifier).equipItem(poseKey, item.id);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isEquippedInPose
                  ? themeCfg.secondaryActionColor
                  : themeCfg.cardColor.withValues(alpha: 0.8),
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadius * 1.5),
              border: Border.all(
                color: isEquippedInPose
                    ? themeCfg.primaryActionColor
                    : Colors.transparent,
                width: isEquippedInPose ? 4 : 0,
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
                  const Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      Icons.lock,
                      size: 24,
                      color: Colors.black54,
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
    this.themeCfg,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppThemeConfig? themeCfg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? themeCfg?.primaryActionColor ?? theme.colorScheme.primary
              : (themeCfg?.cardColor ?? theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
