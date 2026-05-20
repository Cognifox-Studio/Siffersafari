import 'package:flutter/material.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';

import '../constants/app_constants.dart';
import 'app_theme_colors.dart';

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
  Color get panelShadowColor => Colors.black;

  Color get progressCompletedColor => secondaryActionColor;
  Color get progressCurrentColor => accentColor;
  Color get progressNextColor => primaryActionColor;

  AppThemeColors get themeColors => AppThemeColors(
        baseBackgroundColor: baseBackgroundColor,
        primaryActionColor: primaryActionColor,
        secondaryActionColor: secondaryActionColor,
        accentColor: accentColor,
        cardColor: cardColor,
        disabledBackgroundColor: disabledBackgroundColor,
        panelBackgroundColor: panelBackgroundColor,
        panelBorderColor: panelBorderColor,
        panelShadowColor: panelShadowColor,
        progressCompletedColor: progressCompletedColor,
        progressCurrentColor: progressCurrentColor,
        progressNextColor: progressNextColor,
      );

  static const List<AppTheme> implementedThemes = <AppTheme>[
    AppTheme.jungle,
    AppTheme.space,
  ];

  static AppTheme resolveTheme(AppTheme theme) {
    switch (theme) {
      case AppTheme.space:
      case AppTheme.jungle:
        return theme;
      case AppTheme.underwater:
      case AppTheme.fantasy:
        return AppTheme.space;
    }
  }

  static AppThemeConfig forTheme(AppTheme theme) {
    final resolvedTheme = resolveTheme(theme);

    if (resolvedTheme == AppTheme.jungle) {
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
    }

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
    final appThemeColors = themeColors;
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
      displayMedium: baseTheme.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        height: 1.0,
      ),
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
        height: 1.0,
      ),
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.05,
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
      titleSmall: baseTheme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      labelMedium: baseTheme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
      labelSmall: baseTheme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.7),
    );
    final panelShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
    );
    final filledSurface =
        scheme.onPrimary.withValues(alpha: AppOpacities.subtleFill);

    return baseTheme.copyWith(
      extensions: <ThemeExtension<dynamic>>[appThemeColors],
      scaffoldBackgroundColor: appThemeColors.baseBackgroundColor,
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            AppConstants.minTouchTargetSize,
          ),
          backgroundColor: appThemeColors.primaryActionColor,
          foregroundColor: scheme.onPrimary,
          elevation: 4,
          shadowColor: appThemeColors.primaryActionColor.withValues(
            alpha: 0.28,
          ),
          surfaceTintColor: Colors.transparent,
          side: BorderSide(
            color: scheme.onPrimary.withValues(alpha: 0.10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding + 2,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: AppConstants.buttonFontSize,
            fontWeight: FontWeight.w800,
          ),
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            AppConstants.minTouchTargetSize,
          ),
          backgroundColor: appThemeColors.secondaryActionColor,
          foregroundColor: scheme.onPrimary,
          surfaceTintColor: Colors.transparent,
          shadowColor: appThemeColors.secondaryActionColor.withValues(
            alpha: 0.22,
          ),
          elevation: 3,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding + 2,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: AppConstants.buttonFontSize,
            fontWeight: FontWeight.w800,
          ),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            AppConstants.minTouchTargetSize,
          ),
          foregroundColor: scheme.onPrimary,
          backgroundColor: filledSurface,
          side: BorderSide(
            color: scheme.secondary.withValues(alpha: 0.75),
            width: 1.4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding + 2,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: AppConstants.buttonFontSize,
            fontWeight: FontWeight.w800,
          ),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.square(AppConstants.minTouchTargetSizeSmall),
          foregroundColor: scheme.secondary,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: filledSurface,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.square(AppConstants.minTouchTargetSize),
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadius * 1.3),
            side: BorderSide(
              color: scheme.onPrimary.withValues(alpha: AppOpacities.hudBorder),
            ),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appThemeColors.cardColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
          side: BorderSide(
            color: scheme.onPrimary.withValues(alpha: AppOpacities.hudBorder),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: appThemeColors.cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: filledSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.defaultPadding,
        ),
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
            appThemeColors.baseBackgroundColor.withValues(
              alpha: AppOpacities.menuSurface,
            ),
          ),
          shape: WidgetStatePropertyAll(panelShape),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: filledSurface,
        selectedColor: scheme.secondary.withValues(alpha: 0.22),
        secondarySelectedColor:
            appThemeColors.secondaryActionColor.withValues(alpha: 0.22),
        disabledColor: appThemeColors.disabledBackgroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.microSpacing4,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w800,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w800,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: scheme.onPrimary.withValues(alpha: AppOpacities.hudBorder),
          ),
        ),
      ),
      sliderTheme: baseTheme.sliderTheme.copyWith(
        activeTrackColor: appThemeColors.secondaryActionColor,
        inactiveTrackColor: scheme.onPrimary.withValues(alpha: 0.14),
        disabledActiveTrackColor: appThemeColors.disabledBackgroundColor,
        disabledInactiveTrackColor:
            scheme.onPrimary.withValues(alpha: AppOpacities.borderSubtle),
        thumbColor: appThemeColors.secondaryActionColor,
        disabledThumbColor: appThemeColors.disabledBackgroundColor,
        overlayColor: appThemeColors.secondaryActionColor.withValues(
          alpha: 0.16,
        ),
        valueIndicatorColor: appThemeColors.cardColor,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w800,
        ),
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onPrimary,
        textColor: scheme.onPrimary,
        tileColor: filledSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.microSpacing4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.3),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appThemeColors.secondaryActionColor.withValues(alpha: 0.56);
          }
          return scheme.onPrimary.withValues(alpha: 0.16);
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onSecondary;
          }
          return scheme.onPrimary;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return scheme.secondary.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.secondary.withValues(alpha: 0.10);
          }
          return null;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onPrimary.withValues(alpha: AppOpacities.divider),
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: appThemeColors.accentColor,
        linearMinHeight: AppConstants.progressBarHeightMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appThemeColors.cardColor,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      ),
    );
  }
}
