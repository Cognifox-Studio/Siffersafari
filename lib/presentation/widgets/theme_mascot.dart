import 'package:flutter/material.dart';

import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'mascot_character.dart';

class ThemeMascot extends StatelessWidget {
  const ThemeMascot.withState({
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
      child: MascotCharacter(
        height: height,
        fit: fit,
        reaction: _mapReaction(state),
        reactionNonce: state.index,
      ),
    );
  }

  MascotReaction _mapReaction(CharacterAnimationState state) {
    switch (state) {
      case CharacterAnimationState.idle:
        return MascotReaction.idle;
      case CharacterAnimationState.happy:
        return MascotReaction.answerCorrect;
      case CharacterAnimationState.celebrate:
        return MascotReaction.celebrate;
      case CharacterAnimationState.error:
        return MascotReaction.answerWrong;
    }
  }
}
