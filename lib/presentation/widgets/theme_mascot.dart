import 'package:flutter/material.dart';

import '../../core/theme/app_theme_config.dart';
import 'mascot_character.dart';

class ThemeMascot extends StatelessWidget {
  const ThemeMascot.withState({
    super.key,
    required this.appThemeConfig,
    required this.height,
    this.state = CharacterAnimationState.idle,
    this.fit = BoxFit.contain,
  });

  final AppThemeConfig appThemeConfig;
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
        riveAssetPath: appThemeConfig.shouldUseRiveCharacter
            ? appThemeConfig.characterRiveAsset
            : null,
        stateMachineName:
            appThemeConfig.characterRiveStateMachine ?? 'MascotStateMachine',
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
