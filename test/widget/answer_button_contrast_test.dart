import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/theme/color_contrast.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/answer_button.dart';

/// The mechanism above is only worth anything if the button actually uses it,
/// so these pump the real widget and read the ink off the rendered digit.
void main() {
  Widget harness(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: 160, child: child))),
      ),
    );
  }

  Color digitInk(WidgetTester tester, int answer) {
    final style = tester.widget<Text>(find.text('$answer')).style;
    return style!.color!;
  }

  void expectReadable(Color fill, Color ink, String state) {
    expect(
      contrastRatio(fill, ink),
      greaterThanOrEqualTo(AppConstants.minTextContrastRatio),
      reason: '$state: textfärgen ger ${contrastRatio(fill, ink).toStringAsFixed(2)}:1 '
          'mot fyllningen, under ${AppConstants.minTextContrastRatio}:1',
    );
  }

  for (final theme in <String, (Color, Color)>{
    'space': (AppColors.spacePrimary, AppColors.spaceSecondary),
    'jungle': (AppColors.junglePrimary, AppColors.jungleSecondary),
    'desert': (AppColors.desertPrimary, AppColors.desertSecondary),
  }.entries) {
    final (idle, selected) = theme.value;

    testWidgets('siffran är läsbar på ${theme.key}-temat', (tester) async {
      await tester.pumpWidget(
        harness(
          AnswerButton(
            answer: 12,
            idleBackgroundColor: idle,
            selectedBackgroundColor: selected,
            idleTextColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      expectReadable(idle, digitInk(tester, 12), '${theme.key} idle');

      await tester.pumpWidget(
        harness(
          AnswerButton(
            answer: 12,
            isSelected: true,
            idleBackgroundColor: idle,
            selectedBackgroundColor: selected,
            idleTextColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expectReadable(selected, digitInk(tester, 12), '${theme.key} vald');
    });
  }

  testWidgets('siffran är läsbar i rätt/fel-läget', (tester) async {
    await tester.pumpWidget(
      harness(
        AnswerButton(
          answer: 12,
          isSelected: true,
          isCorrect: true,
          onPressed: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expectReadable(AppColors.correctAnswer, digitInk(tester, 12), 'rätt svar');

    await tester.pumpWidget(
      harness(
        AnswerButton(
          answer: 12,
          isSelected: true,
          isCorrect: false,
          onPressed: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expectReadable(AppColors.wrongAnswer, digitInk(tester, 12), 'fel svar');
  });
}
