import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';
import 'package:siffersafari/features/quiz/presentation/screens/results_screen.dart';

import '../test_utils.dart';

class _SeededQuizNotifier extends QuizNotifier {
  _SeededQuizNotifier({
    required InMemoryLocalStorageRepository repository,
    required String userId,
    required QuizSession session,
  }) : super(
          FakeQuestionGeneratorService(),
          FeedbackService(),
          MockAudioService(),
          repository,
          adaptiveDifficultyService: AdaptiveDifficultyService(),
          spacedRepetitionService: SpacedRepetitionService(),
        ) {
    state = QuizState(
      userId: userId,
      session: session,
    );
  }
}

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] ResultsScreen – visar upplåst item-banner efter level up',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'reward-user';
      const initialUser = UserProgress(
        userId: userId,
        name: 'Lova',
        ageGroup: AgeGroup.middle,
        totalQuizzesTaken: 1,
        totalPoints: UserProgress.pointsPerLevel - 40,
      );

      await repository.saveUserProgress(initialUser);
      await repository.setActiveUserId(userId);

      const question = Question(
        id: 'reward_q1',
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        operand1: 4,
        operand2: 5,
        correctAnswer: 9,
        wrongAnswers: [8, 10, 11],
        explanation: '4 + 5 = 9',
      );

      const session = QuizSession(
        sessionId: 'reward_session',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        questions: [question],
        targetQuestionCount: 1,
        correctAnswers: 1,
        wrongAnswers: 0,
        totalPoints: 40,
        answers: {'reward_q1': 9},
      );

      final container = ProviderContainer(
        overrides: [
          quizProvider.overrideWith(
            (ref) => _SeededQuizNotifier(
              repository: repository,
              userId: userId,
              session: session,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(userProvider.notifier).loadUsers();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ScreenUtilInit(
            designSize: Size(375, 812),
            child: MaterialApp(home: ResultsScreen()),
          ),
        ),
      );

      await tester.pump();
      await pumpUntilFound(
        tester,
        find.text('Kolla in din nya Riktig Safarihatt i garderoben.'),
      );

      expect(
        find.text('Kolla in din nya Riktig Safarihatt i garderoben.'),
        findsOneWidget,
      );
      expect(
        container.read(userProvider).newlyUnlockedItem?.id,
        'item_safari_hat',
      );
      expect(
        repository.getUserProgress(userId)?.unlockedItems,
        contains('item_safari_hat'),
      );
    },
  );
}
