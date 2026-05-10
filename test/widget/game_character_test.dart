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

  testWidgets(
    '[Widget] GameCharacter can drag a far-away item in interactive mode',
    (WidgetTester tester) async {
      String? updatedItemSlug;
      double? updatedDx;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 500,
                child: GameCharacter(
                  height: 120,
                  equippedItems: const {
                    'head': 'item_safari_hat',
                  },
                  customItemOffsets: const {
                    'item_safari_hat': 'p,150,0,1.0,0.0',
                  },
                  interactiveItems: true,
                  onItemOffsetUpdated: (itemSlug, dx, dy, scale, rotation) {
                    updatedItemSlug = itemSlug;
                    updatedDx = dx;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final gameCharacterCenter = tester.getCenter(find.byType(GameCharacter));
      // itemCenter calculated by GameCharacter is at (400.0, 336.4) in local coords (center + 150, center + 86.4)
      await tester.timedDragFrom(
        gameCharacterCenter + const Offset(150.0, 86.4),
        const Offset(24, 0),
        const Duration(milliseconds: 150),
      );
      await tester.pump();

      expect(updatedItemSlug, 'item_safari_hat_idle');
      expect(updatedDx, greaterThan(150));
    },
  );
}
