import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';
import 'package:siffersafari/presentation/widgets/mascot_character.dart';
import 'package:siffersafari/presentation/widgets/theme_mascot.dart';

void main() {
  testWidgets(
      '[Widget] ThemeMascot.withState uses MascotCharacter in automated SVG mode',
      (
    WidgetTester tester,
  ) async {
    final config = AppThemeConfig.forTheme(AppTheme.jungle);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThemeMascot.withState(
            appThemeConfig: config,
            height: 120,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(config.shouldUseRiveCharacter, isFalse);
    expect(find.byType(ThemeMascot), findsOneWidget);
    expect(find.byType(MascotCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets(
      '[Widget] ThemeMascot.withState can still opt in to explicit Rive path', (
    WidgetTester tester,
  ) async {
    const riveConfig = AppThemeConfig(
      theme: AppTheme.jungle,
      backgroundAsset: 'assets/images/themes/jungle/background.png',
      questHeroAsset: 'assets/images/themes/jungle/quest_hero.png',
      characterAsset: 'assets/images/themes/jungle/character_v2.png',
      characterRiveAsset: 'assets/characters/mascot/rive/mascot_character.riv',
      characterRiveStateMachine: 'MascotStateMachine',
      preferRiveCharacter: true,
      baseBackgroundColor: AppColors.jungleBackground,
      primaryActionColor: AppColors.junglePrimary,
      secondaryActionColor: AppColors.jungleSecondary,
      accentColor: AppColors.jungleAccent,
      cardColor: Color(0xCC2A4F36),
      disabledBackgroundColor: Color(0xCC3D6C50),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );

    await tester.pump();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThemeMascot.withState(
            appThemeConfig: riveConfig,
            height: 120,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MascotCharacter), findsOneWidget);
  });
}
