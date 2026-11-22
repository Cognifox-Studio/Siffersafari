import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
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
/// Two directions are pinned down:
///  * nothing may overflow at any supported text scale, and
///  * the answer digit must never be taller than the button containing it.
///
/// The second one cannot be checked with `tester.getSize`: a `Stack` clamps its
/// child, so a clipped paragraph still reports the box height and the assertion
/// passes while the child sees half a number. The size the glyphs actually need
/// is therefore measured with a `TextPainter` using the widget's own style and
/// the ambient text scaler.

const _longWordProblem = Question(
  id: 'q-long-word',
  operationType: OperationType.addition,
  difficulty: DifficultyLevel.easy,
  operand1: 7,
  operand2: 5,
  correctAnswer: 9,
  promptText: 'Loke plockar 7 mangoer i korgen och Signe plockar 5 mangoer '
      'till. Sedan äter de 3 mangoer. Hur många mangoer är kvar i korgen?',
);

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

/// Height the digit needs once the ambient text scaler is applied.
double _neededTextHeight(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(find.text(text));
  final painter = TextPainter(
    text: TextSpan(text: text, style: widget.style),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(tester.element(find.text(text))),
    maxLines: 1,
  )..layout();
  return painter.height;
}

const _equationQuestion = Question(
  id: 'q-add',
  operationType: OperationType.addition,
  difficulty: DifficultyLevel.easy,
  operand1: 7,
  operand2: 5,
  correctAnswer: 12,
);

const _shortWordProblem = Question(
  id: 'q-short-word',
  operationType: OperationType.addition,
  difficulty: DifficultyLevel.easy,
  operand1: 3,
  operand2: 0,
  correctAnswer: 3,
  promptText: 'Loke har 3 mangoer.',
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

  void useViewport(
    WidgetTester tester, {
    double width = 360,
    double height = 640,
  }) {
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
            const SizedBox(
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
            const SizedBox(
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
    testWidgets('siffran ryms i knappen vid normal textskala', (tester) async {
      useViewport(tester);

      await tester.pumpWidget(
        _harness(
          Center(
            child: SizedBox(
              height: 64,
              width: 160,
              // Samma väg som quiz-rutnätet tar: höjden kommer färdig i
              // logiska pixlar och får inte skalas en andra gång.
              child: AnswerButton(answer: 12, minHeight: 64, onPressed: () {}),
            ),
          ),
          textScale: 1.0,
        ),
      );

      final buttonSize = tester.getSize(find.byType(AnswerButton));
      expect(
        _neededTextHeight(tester, '12'),
        lessThanOrEqualTo(buttonSize.height),
        reason: 'Vid textskala 1.0 ska siffran rymmas utan att krympas',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('knappen kortas aldrig under minsta tryckyta', (tester) async {
      useViewport(tester);

      // En kort skärm (360×640) gjorde tidigare 64 px till 50 px eftersom
      // höjden skalgjordes med .h — under både siffrans behov och 56 dp.
      await tester.pumpWidget(
        _harness(
          Center(
            child: SizedBox(
              width: 160,
              child: AnswerButton(answer: 12, minHeight: 20, onPressed: () {}),
            ),
          ),
          textScale: 1.0,
        ),
      );

      expect(
        tester.getSize(find.byType(AnswerButton)).height,
        greaterThanOrEqualTo(AppConstants.minTouchTargetSize),
        reason: 'Svarsknappen får aldrig bli mindre än minsta tryckyta',
      );

      await tester.pumpWidget(
        _harness(
          Center(
            child: SizedBox(
              width: 160,
              child: AnswerButton(answer: 12, onPressed: () {}),
            ),
          ),
          textScale: 1.0,
        ),
      );

      expect(
        tester.getSize(find.byType(AnswerButton)).height,
        greaterThanOrEqualTo(AppConstants.minTouchTargetSize),
        reason: 'Inte heller standardhöjden får krympa under tryckytan',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('siffran klipps inte vid textskala 2.0', (tester) async {
      useViewport(tester);

      await tester.pumpWidget(
        _harness(
          Center(
            child: SizedBox(
              height: 64,
              width: 160,
              child: AnswerButton(answer: 12, minHeight: 64, onPressed: () {}),
            ),
          ),
          textScale: 2.0,
        ),
      );

      final buttonSize = tester.getSize(find.byType(AnswerButton));
      final needed = _neededTextHeight(tester, '12');

      // Guards the test itself: at 200 % the digit genuinely needs more room
      // than the button has, so the assertion below is exercising something.
      expect(
        needed,
        greaterThan(buttonSize.height),
        reason: 'Förutsättning: siffran behöver $needed px i en '
            '${buttonSize.height} px hög knapp vid textskala 2.0',
      );

      // ...and the widget has to deal with that instead of letting Stack clip it.
      final shrink = find.ancestor(
        of: find.text('12'),
        matching: find.byType(FittedBox),
      );
      expect(
        shrink,
        findsWidgets,
        reason: 'Siffran måste kunna krympas för att rymmas i knappen',
      );
      final shrinkSize = tester.getSize(shrink.first);
      expect(shrinkSize.height, lessThanOrEqualTo(buttonSize.height));
      expect(shrinkSize.width, lessThanOrEqualTo(buttonSize.width));
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
                    child: AnswerButton(
                      answer: answer,
                      minHeight: 64,
                      onPressed: () {},
                    ),
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
        final digit = find.text('$answer');
        expect(digit, findsOneWidget);
        final shrink = find.ancestor(of: digit, matching: find.byType(FittedBox));
        expect(
          shrink,
          findsWidgets,
          reason: 'Svar $answer klipps i en 64 px hög knapp vid textskala 2.0',
        );
        expect(tester.getSize(shrink.first).height, lessThanOrEqualTo(64));
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

      expect(find.text('8'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('[Widget] Textskala – textuppgift som inte får plats', () {
    testWidgets('vid textskala 2.0 rullas uppgiften i stället för att klippas',
        (tester) async {
      useViewport(tester, width: 360, height: 640);

      await tester.pumpWidget(
        _harness(
          const Center(
            child: SizedBox(
              width: 320,
              height: 220,
              child: QuestionCard(question: _longWordProblem),
            ),
          ),
          textScale: 2.0,
        ),
      );

      // Nothing is hidden: the text is laid out in full inside a scroller
      // instead of ending in "...".
      expect(
        find.byKey(const Key('question_card_scrollable_text')),
        findsOneWidget,
        reason: 'Vid textskala 2.0 ska uppgiften kunna läsas i sin helhet',
      );
      final text = tester.widget<Text>(find.text(_longWordProblem.promptText!));
      expect(text.maxLines, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vid textskala 1.0 klipps inget och ingen scrollning behövs',
        (tester) async {
      useViewport(tester, width: 360, height: 640);

      // Short sentence in a roomy card: this must fit, so the card keeps its
      // ordinary capped layout.
      await tester.pumpWidget(
        _harness(
          const Center(
            child: SizedBox(
              width: 360,
              height: 320,
              child: QuestionCard(question: _shortWordProblem),
            ),
          ),
          textScale: 1.0,
        ),
      );

      // A prompt that fits keeps the plain, capped layout: scrolling is a
      // fallback for text that would otherwise be cut off, not the new normal.
      expect(
        find.byKey(const Key('question_card_scrollable_text')),
        findsNothing,
        reason: 'Normal textstorlek ska inte behöva scrollas',
      );
      final text = tester.widget<Text>(find.text(_shortWordProblem.promptText!));
      expect(text.maxLines, isNotNull);
      expect(tester.takeException(), isNull);
    });
  });
}
