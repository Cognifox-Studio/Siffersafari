import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.baseBackgroundColor,
    required this.primaryActionColor,
    required this.secondaryActionColor,
    required this.accentColor,
    required this.cardColor,
    required this.disabledBackgroundColor,
    required this.panelBackgroundColor,
    required this.panelBorderColor,
    required this.panelShadowColor,
    required this.progressCompletedColor,
    required this.progressCurrentColor,
    required this.progressNextColor,
  });

  final Color baseBackgroundColor;
  final Color primaryActionColor;
  final Color secondaryActionColor;
  final Color accentColor;
  final Color cardColor;
  final Color disabledBackgroundColor;
  final Color panelBackgroundColor;
  final Color panelBorderColor;
  final Color panelShadowColor;
  final Color progressCompletedColor;
  final Color progressCurrentColor;
  final Color progressNextColor;

  static AppThemeColors fallback(ThemeData theme) {
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;
    final surfaceColor = theme.cardTheme.color ??
        onPrimary.withValues(alpha: AppOpacities.panelFill);

    return AppThemeColors(
      baseBackgroundColor: theme.scaffoldBackgroundColor,
      primaryActionColor: scheme.primary,
      secondaryActionColor: scheme.secondary,
      accentColor: scheme.secondary,
      cardColor: surfaceColor,
      disabledBackgroundColor: theme.disabledColor.withValues(alpha: 0.7),
      panelBackgroundColor: surfaceColor,
      panelBorderColor: onPrimary.withValues(alpha: AppOpacities.hudBorder),
      panelShadowColor: Colors.black,
      progressCompletedColor: scheme.secondary,
      progressCurrentColor: scheme.secondary,
      progressNextColor: scheme.primary,
    );
  }

  @override
  AppThemeColors copyWith({
    Color? baseBackgroundColor,
    Color? primaryActionColor,
    Color? secondaryActionColor,
    Color? accentColor,
    Color? cardColor,
    Color? disabledBackgroundColor,
    Color? panelBackgroundColor,
    Color? panelBorderColor,
    Color? panelShadowColor,
    Color? progressCompletedColor,
    Color? progressCurrentColor,
    Color? progressNextColor,
  }) {
    return AppThemeColors(
      baseBackgroundColor: baseBackgroundColor ?? this.baseBackgroundColor,
      primaryActionColor: primaryActionColor ?? this.primaryActionColor,
      secondaryActionColor: secondaryActionColor ?? this.secondaryActionColor,
      accentColor: accentColor ?? this.accentColor,
      cardColor: cardColor ?? this.cardColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      panelBackgroundColor: panelBackgroundColor ?? this.panelBackgroundColor,
      panelBorderColor: panelBorderColor ?? this.panelBorderColor,
      panelShadowColor: panelShadowColor ?? this.panelShadowColor,
      progressCompletedColor:
          progressCompletedColor ?? this.progressCompletedColor,
      progressCurrentColor: progressCurrentColor ?? this.progressCurrentColor,
      progressNextColor: progressNextColor ?? this.progressNextColor,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      baseBackgroundColor:
          Color.lerp(baseBackgroundColor, other.baseBackgroundColor, t) ??
              baseBackgroundColor,
      primaryActionColor:
          Color.lerp(primaryActionColor, other.primaryActionColor, t) ??
              primaryActionColor,
      secondaryActionColor:
          Color.lerp(secondaryActionColor, other.secondaryActionColor, t) ??
              secondaryActionColor,
      accentColor: Color.lerp(accentColor, other.accentColor, t) ?? accentColor,
      cardColor: Color.lerp(cardColor, other.cardColor, t) ?? cardColor,
      disabledBackgroundColor: Color.lerp(
            disabledBackgroundColor,
            other.disabledBackgroundColor,
            t,
          ) ??
          disabledBackgroundColor,
      panelBackgroundColor:
          Color.lerp(panelBackgroundColor, other.panelBackgroundColor, t) ??
              panelBackgroundColor,
      panelBorderColor:
          Color.lerp(panelBorderColor, other.panelBorderColor, t) ??
              panelBorderColor,
      panelShadowColor:
          Color.lerp(panelShadowColor, other.panelShadowColor, t) ??
              panelShadowColor,
      progressCompletedColor: Color.lerp(
            progressCompletedColor,
            other.progressCompletedColor,
            t,
          ) ??
          progressCompletedColor,
      progressCurrentColor:
          Color.lerp(progressCurrentColor, other.progressCurrentColor, t) ??
              progressCurrentColor,
      progressNextColor:
          Color.lerp(progressNextColor, other.progressNextColor, t) ??
              progressNextColor,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appThemeColors {
    final theme = Theme.of(this);
    return theme.extension<AppThemeColors>() ?? AppThemeColors.fallback(theme);
  }
}
