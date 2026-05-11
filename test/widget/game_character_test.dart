import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

Finder _assetImageFinder(String assetPath) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Image) {
      return false;
    }

    final imageProvider = widget.image;
    if (imageProvider is AssetImage) {
      return imageProvider.assetName == assetPath;
    }

    if (imageProvider is ResizeImage &&
        imageProvider.imageProvider is AssetImage) {
      return (imageProvider.imageProvider as AssetImage).assetName == assetPath;
    }

    return false;
  });
}

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
      await tester.timedDragFrom(
        tester.getCenter(
          _assetImageFinder('assets/images/items/item_safari_hat.png'),
        ),
        const Offset(24, 0),
        const Duration(milliseconds: 150),
      );
      await tester.pump();

      expect(updatedItemSlug, 'item_safari_hat_idle');
      expect(updatedDx, greaterThan(0.75));
    },
  );

  testWidgets(
    '[Widget] GameCharacter renders the same item position regardless of wardrobe canvas size',
    (WidgetTester tester) async {
      Future<double> renderItemDeltaY(double canvasSize) async {
        const hatAssetPath = 'assets/images/items/item_safari_hat.png';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox.square(
                  dimension: canvasSize,
                  child: const GameCharacter(
                    height: 120,
                    equippedItems: {
                      'head': 'item_safari_hat',
                    },
                    customItemOffsets: {
                      'item_safari_hat': 'p,0,0,1.0,0.0',
                    },
                    interactiveItems: true,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        final itemCenter = tester.getCenter(_assetImageFinder(hatAssetPath));
        final characterCenter = tester.getCenter(find.byType(GameCharacter));

        return itemCenter.dy - characterCenter.dy;
      }

      final smallCanvasDeltaY = await renderItemDeltaY(160);
      final largeCanvasDeltaY = await renderItemDeltaY(500);

      expect((smallCanvasDeltaY - largeCanvasDeltaY).abs(), lessThan(0.001));
    },
  );

  testWidgets(
    '[Widget] GameCharacter keeps equipped items visible when tapping wardrobe character without onTap callback',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 320,
                child: GameCharacter(
                  height: 200,
                  reaction: CharacterReaction.idle,
                  persistentReaction: true,
                  interactiveItems: true,
                  equippedItems: {
                    'head': 'item_safari_hat',
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final hatFinder =
          _assetImageFinder('assets/images/items/item_safari_hat.png');
      expect(hatFinder, findsOneWidget);

      await tester.tap(find.byType(GameCharacter));
      await tester.pump(const Duration(milliseconds: 400));

      expect(hatFinder, findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] GameCharacter picks glasses instead of hat when dragging from glasses center',
    (WidgetTester tester) async {
      String? updatedItemSlug;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 360,
                child: GameCharacter(
                  height: 200,
                  reaction: CharacterReaction.answerWrong,
                  persistentReaction: true,
                  interactiveItems: true,
                  equippedItems: const {
                    'head': 'item_safari_hat',
                    'answerWrong_item_glasses_nerd': 'item_glasses_nerd',
                  },
                  onItemOffsetUpdated: (itemSlug, dx, dy, scale, rotation) {
                    updatedItemSlug = itemSlug;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.timedDragFrom(
        tester.getCenter(
          _assetImageFinder('assets/images/items/item_glasses_nerd_nobg.png'),
        ),
        const Offset(8, 0),
        const Duration(milliseconds: 150),
      );
      await tester.pump();

      expect(updatedItemSlug, 'item_glasses_nerd_answerWrong');
    },
  );

  testWidgets(
    '[Widget] GameCharacter does not pick glasses from empty area below the frame',
    (WidgetTester tester) async {
      String? updatedItemSlug;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: 360,
                child: GameCharacter(
                  height: 200,
                  reaction: CharacterReaction.answerWrong,
                  persistentReaction: true,
                  interactiveItems: true,
                  equippedItems: const {
                    'answerWrong_item_glasses_nerd': 'item_glasses_nerd',
                  },
                  onItemOffsetUpdated: (itemSlug, dx, dy, scale, rotation) {
                    updatedItemSlug = itemSlug;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final glassesCenter = tester.getCenter(
        _assetImageFinder('assets/images/items/item_glasses_nerd_nobg.png'),
      );

      await tester.timedDragFrom(
        glassesCenter + const Offset(0, 48),
        const Offset(10, 0),
        const Duration(milliseconds: 150),
      );
      await tester.pump();

      expect(updatedItemSlug, isNull);
    },
  );

  testWidgets(
    '[Widget] GameCharacter reuses answerCorrect wardrobe items in celebrate feedback pose',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GameCharacter(
                height: 120,
                reaction: CharacterReaction.celebrate,
                persistentReaction: true,
                equippedItems: {
                  'answerCorrect_item_hat_pirate': 'item_hat_pirate',
                },
                customItemOffsets: {
                  'item_hat_pirate_answerCorrect': 'p,150,0,1.0,0.0',
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final hatCenter = tester.getCenter(
        _assetImageFinder('assets/images/items/item_hat_pirate_nobg.png'),
      );
      final characterCenter = tester.getCenter(find.byType(GameCharacter));

      expect(hatCenter.dx, greaterThan(characterCenter.dx + 40));
    },
  );
}
