import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/presentation/widgets/loke_walk_character.dart';

void main() {
  testWidgets('[Widget] Loke walk character renders svg parts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: LokeWalkCharacter(height: 120),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(LokeWalkCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SvgPicture &&
            widget.bytesLoader.toString().contains('loke_arm_upper_left.svg'),
      ),
      findsOneWidget,
    );
  });
}
