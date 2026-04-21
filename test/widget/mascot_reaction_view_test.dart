import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/theme/app_theme_config.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:siffersafari/presentation/widgets/mascot_reaction_view.dart';

void main() {
  testWidgets(
      '[Widget] MascotReactionView.withState renders the shared SVG runtime mascot',
      (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotReactionView.withState(
            height: 120,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MascotReactionView), findsOneWidget);
    expect(find.byType(GameCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets(
      '[Widget] MascotReactionView.withState stays on the SVG path for active states',
      (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MascotReactionView.withState(
            state: CharacterAnimationState.celebrate,
            height: 120,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(GameCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
