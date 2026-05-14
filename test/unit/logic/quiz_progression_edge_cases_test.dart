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
  group('[Unit] Quiz progression â€“ Edge cases', () {
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
      expect(repo.quizHistory[inProgressId]!['questions'], isNotEmpty);

      // First answer should overwrite the same in-progress session with answered so far.
      notifier.submitAnswer(
        answer: FakeQuestionGeneratorService.question.correctAnswer,
        responseTime: const Duration(seconds: 3),
        ageGroup: AgeGroup.middle,
      );

      await pumpEventQueue();

      expect(repo.quizHistory[inProgressId]!['totalQuestions'], 10);
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

    test(
        'Unit (LocalStorageRepository): getQuizSession returns latest in-progress session for the user',
        () {
      final repo = InMemoryLocalStorageRepository();

      repo.quizHistory['inprogress_old_add'] = {
        'sessionId': 'inprogress_old_add',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.easy.name,
        'startTime': DateTime(2026, 5, 12, 10).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 10).toIso8601String(),
        'isComplete': false,
        'questions': const <Map<String, dynamic>>[],
      };
      repo.quizHistory['inprogress_new_mult'] = {
        'sessionId': 'inprogress_new_mult',
        'userId': 'u1',
        'operationType': OperationType.multiplication.name,
        'difficulty': DifficultyLevel.easy.name,
        'startTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'isComplete': false,
        'questions': const <Map<String, dynamic>>[],
      };
      repo.quizHistory['inprogress_other_user'] = {
        'sessionId': 'inprogress_other_user',
        'userId': 'u2',
        'operationType': OperationType.division.name,
        'difficulty': DifficultyLevel.easy.name,
        'startTime': DateTime(2026, 5, 12, 12).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 12).toIso8601String(),
        'isComplete': false,
        'questions': const <Map<String, dynamic>>[],
      };

      final session = repo.getQuizSession('u1');

      expect(session, isNotNull);
      expect(session!['sessionId'], 'inprogress_new_mult');
      expect(session['operationType'], OperationType.multiplication.name);
    });

    test(
        'Unit (LocalStorageRepository): getQuizSession can target a specific operation deterministically',
        () {
      final repo = InMemoryLocalStorageRepository();

      repo.quizHistory['legacy_without_questions'] = {
        'sessionId': 'legacy_without_questions',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.easy.name,
        'startTime': DateTime(2026, 5, 12, 8).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 8).toIso8601String(),
        'isComplete': false,
      };
      repo.quizHistory['inprogress_add_old'] = {
        'sessionId': 'inprogress_add_old',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.easy.name,
        'startTime': DateTime(2026, 5, 12, 9).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 9).toIso8601String(),
        'isComplete': false,
        'questions': const <Map<String, dynamic>>[],
      };
      repo.quizHistory['inprogress_add_new'] = {
        'sessionId': 'inprogress_add_new',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.medium.name,
        'startTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'isComplete': false,
        'questions': const <Map<String, dynamic>>[],
      };
      repo.quizHistory['complete_add'] = {
        'sessionId': 'complete_add',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.hard.name,
        'startTime': DateTime(2026, 5, 12, 12).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 12).toIso8601String(),
        'isComplete': true,
        'questions': const <Map<String, dynamic>>[],
      };

      final session = repo.getQuizSession(
        'u1',
        operationTypeName: OperationType.addition.name,
      );

      expect(session, isNotNull);
      expect(session!['sessionId'], 'inprogress_add_new');
      expect(session['difficulty'], DifficultyLevel.medium.name);
    });

    test(
        'Unit (LocalStorageRepository): getQuizHistory skippar legacy in-progress utan questions men behåller complete lightweight history',
        () {
      final repo = InMemoryLocalStorageRepository();

      repo.quizHistory['legacy_inprogress_without_questions'] = {
        'sessionId': 'legacy_inprogress_without_questions',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.easy.name,
        'correctAnswers': 5,
        'totalQuestions': 7,
        'successRate': 0.71,
        'points': 35,
        'startTime': DateTime(2026, 5, 12, 10).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 10).toIso8601String(),
        'isComplete': false,
      };
      repo.quizHistory['complete_lightweight'] = {
        'sessionId': 'complete_lightweight',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.medium.name,
        'correctAnswers': 8,
        'totalQuestions': 10,
        'successRate': 0.8,
        'points': 80,
        'startTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'isComplete': true,
      };

      final history = repo.getQuizHistory('u1');

      expect(history.map((s) => s['sessionId']), ['complete_lightweight']);
    });

    test(
        'Unit (QuizNotifier): cancelSession preserves in-progress session for later resume',
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
      );

      await pumpEventQueue();

      notifier.cancelSession('u1');
      await pumpEventQueue();

      final inProgressId = repo.inProgressQuizSessionId(
        userId: 'u1',
        operationTypeName: OperationType.multiplication.name,
      );

      expect(repo.quizHistory.containsKey(inProgressId), isTrue);
      expect(
        repo.getQuizSession(
          'u1',
          operationTypeName: OperationType.multiplication.name,
        ),
        isNotNull,
      );
    });

    test(
        'Unit (QuizNotifier): resumeLatestSessionForUser restores the latest in-progress session deterministically',
        () {
      final repo = InMemoryLocalStorageRepository();
      final audio = MockAudioService();
      when(() => audio.playCorrectSound()).thenAnswer((_) async {});
      when(() => audio.playWrongSound()).thenAnswer((_) async {});

      repo.quizHistory['inprogress_add'] = {
        'sessionId': 'inprogress_add',
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.easy.name,
        'startTime': DateTime(2026, 5, 12, 10).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 10).toIso8601String(),
        'isComplete': false,
        'questions': const [
          {
            'id': 'q_add',
            'operationType': 'addition',
            'difficulty': 'easy',
            'operand1': 2,
            'operand2': 3,
            'correctAnswer': 5,
            'wrongAnswers': [4, 6, 7],
            'explanation': '2 + 3 = 5',
          },
        ],
        'targetQuestionCount': 1,
        'currentQuestionIndex': 0,
        'correctAnswers': 0,
        'wrongAnswers': 0,
        'totalPoints': 0,
        'answers': const <String, int>{},
        'responseTimes': const <String, int>{},
        'difficultyStepsByOperation': const {'addition': 4},
        'wordProblemsEnabled': true,
        'missingNumberEnabled': true,
        'ageGroup': AgeGroup.middle.name,
      };
      repo.quizHistory['inprogress_mult'] = {
        'sessionId': 'inprogress_mult',
        'userId': 'u1',
        'operationType': OperationType.multiplication.name,
        'difficulty': DifficultyLevel.medium.name,
        'startTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'isComplete': false,
        'questions': const [
          {
            'id': 'q_mult',
            'operationType': 'multiplication',
            'difficulty': 'medium',
            'operand1': 3,
            'operand2': 4,
            'correctAnswer': 12,
            'wrongAnswers': [11, 13, 14],
            'explanation': '3 × 4 = 12',
          },
        ],
        'targetQuestionCount': 1,
        'currentQuestionIndex': 0,
        'correctAnswers': 0,
        'wrongAnswers': 0,
        'totalPoints': 0,
        'answers': const <String, int>{},
        'responseTimes': const <String, int>{},
        'difficultyStepsByOperation': const {'multiplication': 6},
        'wordProblemsEnabled': true,
        'missingNumberEnabled': true,
        'ageGroup': AgeGroup.middle.name,
      };

      final notifier = QuizNotifier(
        FakeQuestionGeneratorService(),
        FeedbackService(),
        audio,
        repo,
        adaptiveDifficultyService: AdaptiveDifficultyService(),
        spacedRepetitionService: SpacedRepetitionService(),
      );

      final didResume = notifier.resumeLatestSessionForUser(userId: 'u1');

      expect(didResume, isTrue);
      expect(notifier.state.userId, 'u1');
      expect(
        notifier.state.session?.operationType,
        OperationType.multiplication,
      );
      expect(notifier.state.session?.difficulty, DifficultyLevel.medium);
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
