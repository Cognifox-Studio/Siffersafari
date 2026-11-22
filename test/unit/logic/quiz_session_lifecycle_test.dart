import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import '../../test_utils.dart';

/// Regression tests for the quiz session lifecycle.
///
/// `QuizSession.questions` grows lazily (one question appended per step), so it
/// is easy to confuse `questions.length` with the session length. These tests
/// pin the two invariants that broke before:
///   1. `endTime` stays null until the session is actually finished.
///   2. The persisted in-progress record carries the *adapted* difficulty steps,
///      so resuming does not roll the child back.
void main() {
  group('[Unit] QuizNotifier – session lifecycle', () {
    late InMemoryLocalStorageRepository repository;
    late QuizNotifier notifier;
    const userId = 'lifecycle_user';

    /// The answer the fake generator always produces (`6 × 7`).
    const correctAnswer = 42;

    setUp(() {
      repository = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});
      when(() => audio.playCelebrationSound()).thenAnswer((_) async {});

      notifier = QuizNotifier(
        FakeQuestionGeneratorService(),
        FeedbackService(),
        audio,
        repository,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );
    });

    tearDown(() => notifier.dispose());

    void startSession(int questionCount) {
      notifier.startSession(
        userId: userId,
        ageGroup: AgeGroup.young,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        targetQuestionCountOverride: questionCount,
      );
    }

    void answerCorrectly() {
      notifier.submitAnswer(
        answer: correctAnswer,
        responseTime: const Duration(seconds: 1),
        ageGroup: AgeGroup.young,
      );
    }

    test('endTime är null tills sista frågan är besvarad', () async {
      startSession(3);
      await pumpEventQueue();

      expect(notifier.state.session?.totalQuestions, 3);

      // Question 1 of 3.
      answerCorrectly();
      await pumpEventQueue();
      expect(
        notifier.state.session?.endTime,
        isNull,
        reason: 'Fråga 1 av 3 får inte stämpla endTime',
      );

      notifier.advanceToNextQuestion();
      answerCorrectly();
      await pumpEventQueue();
      expect(
        notifier.state.session?.endTime,
        isNull,
        reason: 'Fråga 2 av 3 får inte stämpla endTime',
      );

      notifier.advanceToNextQuestion();
      answerCorrectly();
      await pumpEventQueue();
      expect(
        notifier.state.session?.endTime,
        isNotNull,
        reason: 'Sista frågan ska stämpla endTime',
      );

      // `isComplete` only flips once the index moves past the last question.
      notifier.advanceToNextQuestion();
      expect(notifier.state.session?.isComplete, isTrue);
    });

    test('endTime stämplas inte heller efter advance till sista frågan',
        () async {
      startSession(2);
      await pumpEventQueue();

      answerCorrectly();
      await pumpEventQueue();
      notifier.advanceToNextQuestion();
      await pumpEventQueue();

      // Now on the last question but it is not answered yet.
      expect(notifier.state.session?.currentQuestionIndex, 1);
      expect(
        notifier.state.session?.endTime,
        isNull,
        reason: 'endTime ska vänta på att sista frågan besvaras',
      );
    });

    test('resume kastar en oläsbar session istället för att krascha', () async {
      const corruptId = 'inprogress_lifecycle_user_multiplication';
      await repository.saveQuizSession(<String, dynamic>{
        'sessionId': corruptId,
        'userId': userId,
        'operationType': OperationType.multiplication.name,
        'difficulty': DifficultyLevel.easy.name,
        'isComplete': false,
        'startTime': DateTime(2026, 5, 12).toIso8601String(),
        // Question is missing the required `id` field.
        'questions': <Map<String, dynamic>>[
          <String, dynamic>{'operand1': 1},
        ],
      });

      final resumed = notifier.resumeLatestSessionForUser(userId: userId);
      await pumpEventQueue();

      expect(resumed, isFalse);
      expect(notifier.state.session, isNull);
      expect(
        repository.quizHistory.containsKey(corruptId),
        isFalse,
        reason: 'En trasig rad ska städas bort så CTA:n slutar erbjuda den',
      );
    });

    test('persisterad session behåller adapterade difficulty-steg', () async {
      startSession(10);
      await pumpEventQueue();

      final initialStep = notifier.state
          .session!.difficultyStepsByOperation[OperationType.multiplication]!;
      expect(
        initialStep,
        lessThan(DifficultyConfig.maxDifficultyStep),
        reason: 'Setup: steget måste ha utrymme att öka',
      );

      // Five correct answers trip the macro signal (5 results, 100 % success)
      // and the micro signal (3 in a row), so the step is raised.
      for (var i = 0; i < 5; i++) {
        answerCorrectly();
        await pumpEventQueue();
        notifier.advanceToNextQuestion();
        await pumpEventQueue();
      }

      final stateSteps =
          notifier.state.session!.difficultyStepsByOperation;
      expect(
        stateSteps[OperationType.multiplication],
        initialStep + 1,
        reason: 'Setup: fem rätt i rad ska höja steget',
      );

      final inProgressId =
          repository.inProgressQuizSessionId(
        userId: userId,
        operationTypeName: OperationType.multiplication.name,
      );
      final persisted = repository.quizHistory[inProgressId];
      expect(persisted, isNotNull, reason: 'Sessionen ska vara sparad');

      final persistedSteps =
          Map<String, dynamic>.from(persisted!['difficultyStepsByOperation'] as Map);
      expect(
        persistedSteps,
        stateSteps.map((op, step) => MapEntry(op.name, step)),
        reason: 'Den sparade sessionen måste matcha minnesläget — annars '
            'rullas barnet tillbaka vid resume',
      );
    });
  });
}
