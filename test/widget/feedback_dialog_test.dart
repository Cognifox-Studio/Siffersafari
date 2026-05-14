import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/features/quiz/presentation/dialogs/feedback_dialog.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;
  late FeedbackService feedbackService;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
    await repository.clearAllData();
    feedbackService = FeedbackService();
  });

  testWidgets(
    '[Widget] FeedbackDialog – visar additionstips och enkel tallinje',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const question = Question(
        id: 'q_feedback_add',
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        operand1: 7,
        operand2: 3,
        correctAnswer: 10,
      );

      final feedback = feedbackService.buildFeedback(
        question: question,
        userAnswer: 8,
        ageGroup: AgeGroup.middle,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => MaterialApp(
              home: Scaffold(
                body: FeedbackDialog(
                  feedback: feedback,
                  onContinue: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('💡 Titta lugnt en gång till nästa gång.'),
        findsOneWidget,
      );
      expect(find.text('💡 Börja på 7 och räkna 3 steg till.'), findsOneWidget);
      expect(find.byKey(const Key('feedback_number_line')), findsOneWidget);
      expect(
        find.byKey(const Key('feedback_number_line_jump')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('feedback_number_line_start_chip')),
        findsOneWidget,
      );
      expect(find.text('7'), findsWidgets);
      expect(find.text('10'), findsWidgets);
    },
  );

  testWidgets(
    '[Widget] FeedbackDialog – visar subtraktionstips och steg tillbaka',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const question = Question(
        id: 'q_feedback_sub',
        operationType: OperationType.subtraction,
        difficulty: DifficultyLevel.easy,
        operand1: 9,
        operand2: 4,
        correctAnswer: 5,
      );

      final feedback = feedbackService.buildFeedback(
        question: question,
        userAnswer: 6,
        ageGroup: AgeGroup.middle,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => MaterialApp(
              home: Scaffold(
                body: FeedbackDialog(
                  feedback: feedback,
                  onContinue: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('💡 Börja på 9 och räkna 4 steg tillbaka.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('feedback_number_line')), findsOneWidget);
      expect(
        find.byKey(const Key('feedback_number_line_jump')),
        findsOneWidget,
      );
      expect(find.text('-4'), findsOneWidget);
      expect(find.text('5'), findsWidgets);
      expect(find.text('9'), findsWidgets);
    },
  );

  testWidgets(
    '[Widget] FeedbackDialog – visar grupperad hjälp för multiplikation',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const question = Question(
        id: 'q_feedback_mul',
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        operand1: 3,
        operand2: 4,
        correctAnswer: 12,
      );

      final feedback = feedbackService.buildFeedback(
        question: question,
        userAnswer: 10,
        ageGroup: AgeGroup.middle,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => MaterialApp(
              home: Scaffold(
                body: FeedbackDialog(
                  feedback: feedback,
                  onContinue: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('💡 Se det som 3 grupper med 4 i varje.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('feedback_group_model')), findsOneWidget);
      expect(find.byKey(const Key('feedback_group_chip_0')), findsOneWidget);
      expect(find.byKey(const Key('feedback_group_chip_1')), findsOneWidget);
      expect(find.byKey(const Key('feedback_group_chip_2')), findsOneWidget);
      expect(find.text('Tillsammans 12'), findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] FeedbackDialog – visar delningshjälp för division',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const question = Question(
        id: 'q_feedback_div',
        operationType: OperationType.division,
        difficulty: DifficultyLevel.easy,
        operand1: 12,
        operand2: 3,
        correctAnswer: 4,
      );

      final feedback = feedbackService.buildFeedback(
        question: question,
        userAnswer: 5,
        ageGroup: AgeGroup.middle,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (_, __) => MaterialApp(
              home: Scaffold(
                body: FeedbackDialog(
                  feedback: feedback,
                  onContinue: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('💡 Dela 12 i 3 lika grupper.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('feedback_group_model')), findsOneWidget);
      expect(find.text('3 grupper med 4'), findsNothing);
      expect(find.text('Tillsammans 12'), findsOneWidget);
    },
  );
}
