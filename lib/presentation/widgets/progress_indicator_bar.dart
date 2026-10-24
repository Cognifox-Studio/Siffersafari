import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:siffersafari/core/constants/app_constants.dart';

class ProgressIndicatorBar extends StatelessWidget {
  const ProgressIndicatorBar({
    required this.progress,
    this.backgroundColor,
    this.valueColor,
    this.currentQuestion,
    this.totalQuestions,
    super.key,
  });

  final double progress;
  final Color? backgroundColor;
  final Color? valueColor;
  final int? currentQuestion;
  final int? totalQuestions;

  @override
  Widget build(BuildContext context) {
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    final scheme = Theme.of(context).colorScheme;
    final fallbackValueColor = Theme.of(context).colorScheme.secondary;
    final questionLabel =
        currentQuestion != null && totalQuestions != null
            ? 'Fråga $currentQuestion av $totalQuestions. '
            : '';
    return Semantics(
      liveRegion: true,
      label: '${questionLabel}Framsteg $percent procent',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: AppConstants.progressBarHeightMedium.h,
            backgroundColor: backgroundColor ??
                scheme.onPrimary
                    .withValues(alpha: AppOpacities.progressTrackMedium),
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? fallbackValueColor,
            ),
          ),
        ),
      ),
    );
  }
}
