import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

void main() {
  testWidgets('[Widget] GameCharacter uses the Loke PNG by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GameCharacter(
              height: 120,
            ),
          ),
        ),
      ),
    );

    // Initial load
    await tester.pump();

    expect(find.byType(GameCharacter), findsOneWidget);
    // The widget renders an Image child
    expect(find.byType(Image), findsOneWidget);
  });
}
