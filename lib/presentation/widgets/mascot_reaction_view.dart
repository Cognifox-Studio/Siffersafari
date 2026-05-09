import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/gen/assets.g.dart';

import 'game_character.dart';

class MascotReactionView extends ConsumerWidget {
  const MascotReactionView.withState({
    super.key,
    required this.height,
    this.state = CharacterAnimationState.idle,
    this.fit = BoxFit.contain,
    this.interactiveItems = false,
  });

  final double height;
  final CharacterAnimationState state;
  final BoxFit fit;
  final bool interactiveItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(userProvider).activeUser;

    return SizedBox(
      height: height,
      child: GameCharacter(
        characterId: activeUser?.selectedCharacterId == 'signe'
            ? CharacterId.signe
            : activeUser?.selectedCharacterId == 'astrid'
                ? CharacterId.astrid
                : CharacterId.loke,
        height: height,
        fit: fit,
        reaction: _mapReaction(state),
        reactionNonce: state.index,
        equippedItems: activeUser?.equippedItems,
        customItemOffsets: activeUser?.customItemOffsets,
        interactiveItems: interactiveItems,
        onItemOffsetUpdated: (itemSlug, dx, dy, scale, rot) {
          ref.read(userProvider.notifier).setCustomItemOffset(itemSlug, dx, dy,
              scale: scale, rotation: rot);
        },
      ),
    );
  }

  CharacterReaction _mapReaction(CharacterAnimationState state) {
    switch (state) {
      case CharacterAnimationState.idle:
        return CharacterReaction.idle;
      case CharacterAnimationState.happy:
        return CharacterReaction.answerCorrect;
      case CharacterAnimationState.celebrate:
        return CharacterReaction.celebrate;
      case CharacterAnimationState.error:
        return CharacterReaction.answerWrong;
    }
  }
}
