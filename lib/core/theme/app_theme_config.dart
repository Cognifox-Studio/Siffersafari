import 'package:flutter/material.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';

import '../constants/app_constants.dart';

/// Character animation states for flexible mascot animation control
enum CharacterAnimationState {
  /// Default idle/resting state
  idle,

  /// Happy/pleased state
  happy,

  /// Celebration/victory state
  celebrate,

  /// Error/confused state
  error,
}

class AppThemeConfig {
  const AppThemeConfig({
    required this.theme,
    required this.backgroundAsset,
    required this.questHeroAsset,
    required this.characterAsset,
    required this.baseBackgroundColor,
    required this.primaryActionColor,
    required this.secondaryActionColor,
    required this.accentColor,
    required this.cardColor,
    required this.disabledBackgroundColor,
  });

  final AppTheme theme;

  final String backgroundAsset;
  final String questHeroAsset;
  final String characterAsset;

  final Color baseBackgroundColor;
  final Color primaryActionColor;
  final Color secondaryActionColor;
  final Color accentColor;

  /// Semi-transparent card/surface used on top of themed backgrounds.
  final Color cardColor;

  /// Used for disabled answer buttons etc.
  final Color disabledBackgroundColor;

  Color get panelBackgroundColor => cardColor;
  Color get panelBorderColor =>
      colorScheme().onPrimary.withValues(alpha: AppOpacities.hudBorder);
  Color get panelShadowColor =>
      Colors.black.withValues(alpha: AppOpacities.shadowAmbient);

  Color get progressCompletedColor => secondaryActionColor;
  Color get progressCurrentColor => accentColor;
  Color get progressNextColor => primaryActionColor;

  static AppThemeConfig forTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.jungle:
        return const AppThemeConfig(
          theme: AppTheme.jungle,
          backgroundAsset: 'assets/images/themes/jungle/background.png',
          questHeroAsset: 'assets/images/themes/jungle/quest_hero.png',
          characterAsset: 'assets/images/themes/jungle/character.png',
          baseBackgroundColor: AppColors.jungleBackground,
          primaryActionColor: AppColors.junglePrimary,
          secondaryActionColor: AppColors.jungleSecondary,
          accentColor: AppColors.jungleAccent,
          cardColor: Color(0xCC2A4F36),
          disabledBackgroundColor: Color(0xCC3D6C50),
        );
      case AppTheme.space:
      case AppTheme.underwater:
      case AppTheme.fantasy:
        return const AppThemeConfig(
          theme: AppTheme.space,
          backgroundAsset: 'assets/images/themes/space/background.png',
          questHeroAsset: 'assets/images/themes/space/quest_hero.png',
          characterAsset: 'assets/images/themes/space/character.png',
          baseBackgroundColor: AppColors.spaceBackground,
          primaryActionColor: AppColors.spacePrimary,
          secondaryActionColor: AppColors.spaceSecondary,
          accentColor: AppColors.spaceAccent,
          cardColor: Color(0xCC485466),
          disabledBackgroundColor: Color(0xCC5B6575),
        );
    }
  }

  ColorScheme colorScheme() {
    return ColorScheme.light(
      primary: primaryActionColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      surface: AppColors.neutralBackground,
      onSurface: AppColors.textPrimary,
      error: AppColors.wrongAnswer,
      onError: Colors.white,
    );
  }

  ThemeData themeData() {
    final scheme = colorScheme();
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      displayLarge: baseTheme.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
        height: 0.98,
      ),
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
        height: 1.0,
      ),
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
        height: 1.05,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: baseBackgroundColor,
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            AppConstants.minTouchTargetSize,
          ),
          backgroundColor: primaryActionColor,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.buttonFontSize,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius * 1.5,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            AppConstants.minTouchTargetSize,
          ),
          foregroundColor: scheme.onPrimary,
          backgroundColor:
              scheme.onPrimary.withValues(alpha: AppOpacities.subtleFill),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          side: BorderSide(color: scheme.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius * 1.5,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.buttonFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.square(AppConstants.minTouchTargetSizeSmall),
          foregroundColor: scheme.secondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.onPrimary.withValues(alpha: AppOpacities.subtleFill),
        labelStyle: TextStyle(
          color: scheme.onPrimary.withValues(alpha: AppOpacities.mutedText),
        ),
        hintStyle: TextStyle(
          color: scheme.onPrimary.withValues(alpha: AppOpacities.subtleText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: scheme.onPrimary.withValues(
              alpha: AppOpacities.borderMedium,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: scheme.secondary),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: scheme.onPrimary),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            baseBackgroundColor.withValues(alpha: AppOpacities.menuSurface),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onPrimary.withValues(alpha: AppOpacities.divider),
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearMinHeight: AppConstants.progressBarHeightMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
