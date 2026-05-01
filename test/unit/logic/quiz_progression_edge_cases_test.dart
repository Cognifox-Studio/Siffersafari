import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] Quiz progression – Edge cases', () {
    test(
        'Unit (QuizNotifier): startSession resets in-progress underlag and purges legacy entries',
        () async {
      final repo = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});

      // Seed a legacy in-progress session that should be purged.
      repo.quizHistory['legacy_inprogress'] = {
        'sessionId': 'legacy_inprogress',
        'userId': 'u1',
        'operationType': OperationType.multiplication.name,
        'difficulty': DifficultyLevel.easy.name,
        'correctAnswers': 1,
        'totalQuestions': 1,
        'successRate': 1.0,
        'points': 10,
        'bonusPoints': 0,
        'pointsWithBonus': 10,
        'startTime': DateTime(2026, 1, 1).toIso8601String(),
        'endTime': DateTime(2026, 1, 1).toIso8601String(),
        'isComplete': false,
      };

      final notifier = QuizNotifier(
        FakeQuestionGeneratorService(),
        FeedbackService(),
        audio,
        repo,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );

      notifier.startSession(
        userId: 'u1',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
      );

      // Flush fire-and-forget writes.
      await pumpEventQueue();

      final inProgressId = repo.inProgressQuizSessionId(
        userId: 'u1',
        operationTypeName: OperationType.multiplication.name,
      );

      expect(repo.quizHistory.containsKey('legacy_inprogress'), isFalse);
      expect(repo.quizHistory.containsKey(inProgressId), isTrue);
      expect(repo.quizHistory[inProgressId]!['totalQuestions'], 0);
      expect(repo.quizHistory[inProgressId]!['correctAnswers'], 0);

      // First answer should overwrite the same in-progress session with answered so far.
      notifier.submitAnswer(
        answer: FakeQuestionGeneratorService.question.correctAnswer,
        responseTime: const Duration(seconds: 3),
        ageGroup: AgeGroup.middle,
      );

      await pumpEventQueue();

      expect(repo.quizHistory[inProgressId]!['totalQuestions'], 1);
      expect(repo.quizHistory[inProgressId]!['correctAnswers'], 1);
      expect(repo.quizHistory[inProgressId]!['isComplete'], isFalse);
      expect(repo.quizHistory[inProgressId]!['successRate'], 1.0);
    });

    test(
        'Unit (QuizNotifier): startCustomSession with empty questions is a no-op',
        () async {
      final repo = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});

      final notifier = QuizNotifier(
        FakeQuestionGeneratorService(),
        FeedbackService(),
        audio,
        repo,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );

      notifier.startCustomSession(
        userId: 'u1',
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        questions: const [],
        ageGroup: AgeGroup.middle,
      );

      await pumpEventQueue();

      expect(notifier.state.session, isNull);
      expect(repo.quizHistory, isEmpty);
    });

    test('Unit (QuizNotifier): hybrid step increases when micro+macro agree',
        () async {
      final repo = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});

      final notifier = QuizNotifier(
        FakeQuestionGeneratorService(),
        FeedbackService(),
        audio,
        repo,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );

      notifier.startSession(
        userId: 'u1',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        initialDifficultyStepsByOperation: const {
          OperationType.multiplication: 5,
        },
      );

      for (var i = 0; i < 5; i++) {
        notifier.submitAnswer(
          answer: FakeQuestionGeneratorService.question.correctAnswer,
          responseTime: const Duration(seconds: 3),
          ageGroup: AgeGroup.middle,
        );
        notifier.advanceToNextQuestion();
      }

      final step = notifier
          .state.difficultyStepsByOperation[OperationType.multiplication];
      expect(step, 6);
    });

    test('Unit (QuizNotifier): cooldown blocks immediate second increase',
        () async {
      final repo = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});

      final notifier = QuizNotifier(
        FakeQuestionGeneratorService(),
        FeedbackService(),
        audio,
        repo,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );

      notifier.startSession(
        userId: 'u1',
        ageGroup: AgeGroup.middle,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        initialDifficultyStepsByOperation: const {
          OperationType.multiplication: 5,
        },
      );

      for (var i = 0; i < 6; i++) {
        notifier.submitAnswer(
          answer: FakeQuestionGeneratorService.question.correctAnswer,
          responseTime: const Duration(seconds: 3),
          ageGroup: AgeGroup.middle,
        );
        notifier.advanceToNextQuestion();
      }

      final step = notifier
          .state.difficultyStepsByOperation[OperationType.multiplication];
      expect(step, 6);
    });
  });
}
