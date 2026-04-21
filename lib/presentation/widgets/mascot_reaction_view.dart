import 'package:flutter/material.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';

import 'game_character.dart';

class MascotReactionView extends StatelessWidget {
  const MascotReactionView.withState({
    super.key,
    required this.height,
    this.state = CharacterAnimationState.idle,
    this.fit = BoxFit.contain,
  });

  final double height;
  final CharacterAnimationState state;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GameCharacter(
        height: height,
        fit: fit,
        reaction: _mapReaction(state),
        reactionNonce: state.index,
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
