import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/presentation/widgets/mascot_character.dart';
import 'package:siffersafari/presentation/widgets/theme_mascot.dart';

void main() {
  testWidgets(
      '[Widget] ThemeMascot.withState renders the shared SVG runtime mascot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThemeMascot.withState(
            height: 120,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(ThemeMascot), findsOneWidget);
    expect(find.byType(MascotCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets(
      '[Widget] ThemeMascot.withState stays on the SVG path for active states',
      (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThemeMascot.withState(
            state: CharacterAnimationState.celebrate,
            height: 120,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MascotCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
