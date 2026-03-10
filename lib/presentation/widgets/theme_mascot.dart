import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

import '../../core/theme/app_theme_config.dart';

class ThemeMascot extends StatelessWidget {
  /// Legacy constructor for backward compatibility
  /// Uses idle state by default
  const ThemeMascot({
    super.key,
    required this.lottieAsset,
    required this.height,
    this.fit = BoxFit.contain,
  })  : appThemeConfig = null,
        state = CharacterAnimationState.idle;

  /// New constructor using AppThemeConfig and animation state
  const ThemeMascot.withState({
    super.key,
    required this.appThemeConfig,
    required this.height,
    this.state = CharacterAnimationState.idle,
    this.fit = BoxFit.contain,
  }) : lottieAsset = null;

  final String? lottieAsset;
  final AppThemeConfig? appThemeConfig;
  final double height;
  final CharacterAnimationState state;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (appThemeConfig != null && appThemeConfig!.shouldUseRiveCharacter) {
      return SizedBox(
        height: height,
        child: RiveAnimation.asset(
          appThemeConfig!.characterRiveAsset!,
          fit: fit,
          stateMachines: appThemeConfig!.characterRiveStateMachine != null
              ? [appThemeConfig!.characterRiveStateMachine!]
              : const <String>[],
          onInit: (_) {},
        ),
      );
    }

    // Determine which asset to use
    final asset = lottieAsset ?? appThemeConfig?.getCharacterAnimation(state);
    
    if (asset == null) {
      return _buildMissingLottiePlaceholder(context);
    }

    return Lottie.asset(
      asset,
      height: height,
      fit: fit,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        return _buildMissingLottiePlaceholder(context);
      },
    );
  }

  Widget _buildMissingLottiePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height * 0.26,
            height: height * 0.26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withValues(alpha: 0.14),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: height * 0.16,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ville värmer upp',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Äventyret börjar strax',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
