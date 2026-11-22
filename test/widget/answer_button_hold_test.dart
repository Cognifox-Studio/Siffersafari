import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/answer_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required bool requireHold,
    required VoidCallback onPressed,
  }) {
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 160,
                height: 80,
                child: AnswerButton(
                  answer: 4,
                  requireHoldToConfirm: requireHold,
                  holdDuration: const Duration(milliseconds: 200),
                  onPressed: onPressed,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('tap alone does not confirm when hold required', (tester) async {
    var pressed = 0;
    await pumpButton(
      tester,
      requireHold: true,
      onPressed: () => pressed++,
    );

    await tester.tap(find.byType(AnswerButton));
    await tester.pumpAndSettle();
    expect(pressed, 0);
  });

  testWidgets('hold to duration confirms answer', (tester) async {
    var pressed = 0;
    await pumpButton(
      tester,
      requireHold: true,
      onPressed: () => pressed++,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AnswerButton)),
    );
    await tester.pump(const Duration(milliseconds: 220));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(pressed, 1);
  });

  testWidgets('early release cancels hold', (tester) async {
    var pressed = 0;
    await pumpButton(
      tester,
      requireHold: true,
      onPressed: () => pressed++,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AnswerButton)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(pressed, 0);
  });

  testWidgets('normal tap confirms when hold not required', (tester) async {
    var pressed = 0;
    await pumpButton(
      tester,
      requireHold: false,
      onPressed: () => pressed++,
    );

    await tester.tap(find.byType(AnswerButton));
    await tester.pumpAndSettle();
    expect(pressed, 1);
  });
}
