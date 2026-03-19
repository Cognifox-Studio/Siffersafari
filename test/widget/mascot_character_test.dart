import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/presentation/widgets/mascot_character.dart';

void main() {
  testWidgets('[Widget] MascotCharacter uses the composite SVG runtime path', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: MascotCharacter(height: 120),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(MascotCharacter), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SvgPicture &&
            widget.bytesLoader.toString().contains('mascot_composite.svg'),
      ),
      findsOneWidget,
    );
  });
}
