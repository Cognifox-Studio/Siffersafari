import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_theme_config.dart';

/// Flexible character animation widget that supports multiple animation states
class CharacterAnimationPlayer extends StatelessWidget {
  const CharacterAnimationPlayer({
    super.key,
    required this.appThemeConfig,
    this.state = CharacterAnimationState.idle,
    this.height = 120,
    this.fit = BoxFit.contain,
  });

  final AppThemeConfig appThemeConfig;
  final CharacterAnimationState state;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final lottieAsset = appThemeConfig.getCharacterAnimation(state);
    
    return Lottie.asset(
      lottieAsset,
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
          Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.32),
          ),
          const SizedBox(height: 8),
          Text(
            'Animation loading...',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.48),
            ),
          ),
        ],
      ),
    );
  }
}
