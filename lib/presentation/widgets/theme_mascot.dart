import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThemeMascot extends StatelessWidget {
  const ThemeMascot({
    super.key,
    required this.lottieAsset,
    required this.height,
    this.fit = BoxFit.contain,
  });

  final String lottieAsset;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
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
