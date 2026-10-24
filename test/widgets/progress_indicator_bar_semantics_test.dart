import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/presentation/widgets/progress_indicator_bar.dart';

void main() {
  testWidgets('ProgressIndicatorBar announces fråga X av Y as live region',
      (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(
            body: ProgressIndicatorBar(
              progress: 0.3,
              currentQuestion: 3,
              totalQuestions: 10,
            ),
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.byType(ProgressIndicatorBar));
    expect(semantics.label, contains('Fråga 3 av 10'));
    expect(semantics.label, contains('30 procent'));
    expect(
      semantics.hasFlag(SemanticsFlag.isLiveRegion),
      isTrue,
    );
  });
}
