import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/answer_button.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/question_card.dart';

/// Åk 1–2 / accessibility: the quiz has to survive the user's own font setting.
///
/// The app lays quiz widgets out in fixed-height boxes computed from the screen,
/// while every `Text` still honours `MediaQuery.textScaler`. At the upper end of
/// the OS font slider (200 %) those two facts fight, and the loser is a child
/// who cannot read the question or the answer they are choosing.
///
/// These tests pin the behaviour down in both directions:
///  * nothing may throw an overflow error at any supported text scale, and
///  * the answer digit may never be taller than the button that contains it
///    (a silent clip - `Stack` clips without complaining, so an overflow
///    exception alone would not catch it).

Widget _harness(
  Widget child, {
  required double textScale,
  double width = 360,
  double height = 640,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (_, __) => MaterialApp(
      home: Scaffold(body: child),
      builder: (context, appChild) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          size: Size(width, height),
        ),
        child: appChild!,
      ),
    ),
  );
}

const _equationQuestion = Question(
  id: 'q-add',
  operationType: OperationType.addition,
  difficulty: DifficultyLevel.easy,
  operand1: 7,
  operand2: 5,
  correctAnswer: 12,
);

const _wordProblemQuestion = Question(
  id: 'q-word',
  operationType: OperationType.addition,
  difficulty: DifficultyLevel.easy,
  operand1: 7,
  operand2: 5,
  correctAnswer: 12,
  promptText:
      'Loke har 7 mangoer i korgen och hittar 5 till på stigen. '
      'Hur många mangoer har Loke nu?',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const scales = <double>[1.0, 1.3, 1.5, 2.0];

  void useViewport(WidgetTester tester, {double width = 360, double height = 640}) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(width, height);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('[Widget] Textskala – frågekort', () {
    for (final scale in scales) {
      testWidgets('ekvationsfråga ryms vid textskala $scale', (tester) async {
        useViewport(tester);

        await tester.pumpWidget(
          _harness(
            SizedBox(
              width: 360,
              height: 260,
              child: QuestionCard(question: _equationQuestion),
            ),
            textScale: scale,
          ),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'Frågekortet får inte overflowa vid textskala $scale',
        );
      });

      testWidgets('textuppgift ryms vid textskala $scale', (tester) async {
        useViewport(tester);

        await tester.pumpWidget(
          _harness(
            SizedBox(
              width: 360,
              height: 320,
              child: QuestionCard(question: _wordProblemQuestion),
            ),
            textScale: scale,
          ),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'Textuppgiften får inte overflowa vid textskala $scale',
        );
      });
    }
  });

  group('[Widget] Textskala – svarsknapp', () {
    testWidgets('siffran klipps inte vid textskala 2.0', (tester) async {
      useViewport(tester);

      await tester.pumpWidget(
        _harness(
          Center(
            child: SizedBox(
              width: 160,
              child: AnswerButton(answer: 12, onPressed: () {}),
            ),
          ),
          textScale: 2.0,
        ),
      );

      final buttonSize = tester.getSize(find.byType(AnswerButton));
      final digitSize = tester.getSize(find.text('12'));

      expect(
        digitSize.height,
        lessThanOrEqualTo(buttonSize.height),
        reason: 'Siffran ($digitSize) är högre än knappen ($buttonSize) och '
            'klipps därför bort vid textskala 2.0',
      );
      expect(digitSize.width, lessThanOrEqualTo(buttonSize.width));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fyra svarsknappar i ett rutnät vid textskala 2.0',
        (tester) async {
      useViewport(tester, width: 320, height: 520);

      await tester.pumpWidget(
        _harness(
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final answer in [12, 13, 11, 10])
                  SizedBox(
                    width: 148,
                    height: 64,
                    child: AnswerButton(answer: answer, onPressed: () {}),
                  ),
              ],
            ),
          ),
          textScale: 2.0,
          width: 320,
          height: 520,
        ),
      );

      for (final answer in [12, 13, 11, 10]) {
        final digit = tester.getSize(find.text('$answer'));
        expect(
          digit.height,
          lessThanOrEqualTo(64),
          reason: 'Svar $answer klipps i en 64 px hög knapp vid textskala 2.0',
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('hold-to-confirm-knappen ryms vid textskala 1.5',
        (tester) async {
      useViewport(tester);

      await tester.pumpWidget(
        _harness(
          Center(
            child: SizedBox(
              width: 160,
              child: AnswerButton(
                answer: 8,
                onPressed: () {},
                requireHoldToConfirm: true,
              ),
            ),
          ),
          textScale: 1.5,
        ),
      );

      final buttonSize = tester.getSize(find.byType(AnswerButton));
      final digitSize = tester.getSize(find.text('8'));
      expect(digitSize.height, lessThanOrEqualTo(buttonSize.height));
      expect(tester.takeException(), isNull);
    });
  });
}
