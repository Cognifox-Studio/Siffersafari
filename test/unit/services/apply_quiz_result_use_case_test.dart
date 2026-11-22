import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/apply_quiz_result_use_case.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/core/services/user_quest_state_service.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import '../../test_utils.dart';

/// Repository that can be told to fail the progress write, to exercise the
/// compensation path in [ApplyQuizResultUseCase.execute].
class _ControllableRepository extends InMemoryLocalStorageRepository {
  bool failUserSave = false;

  @override
  Future<void> saveUserProgress(UserProgress progress) async {
    if (failUserSave) {
      throw StateError('disk full');
    }
    return super.saveUserProgress(progress);
  }
}

void main() {
  group('[Unit] ApplyQuizResultUseCase', () {
    late _ControllableRepository repository;
    late ApplyQuizResultUseCase useCase;

    const userId = 'u1';
    const user = UserProgress(
      userId: userId,
      name: 'Test',
      ageGroup: AgeGroup.middle,
    );

    setUp(() {
      repository = _ControllableRepository();
      useCase = ApplyQuizResultUseCase(
        repository: repository,
        achievementService: AchievementService(),
        questStateService: UserQuestStateService(
          repository,
          const QuestProgressionService(),
        ),
      );
    });

    QuizSession buildSession({
      String sessionId = 'session-1',
      int totalPoints = 40,
    }) {
      const question = Question(
        id: 'q1',
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        operand1: 2,
        operand2: 3,
        correctAnswer: 5,
        wrongAnswers: [4, 6, 7],
        explanation: '2 + 3 = 5',
      );

      return QuizSession(
        sessionId: sessionId,
        ageGroup: AgeGroup.middle,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        questions: const [question],
        targetQuestionCount: 10,
        correctAnswers: 8,
        wrongAnswers: 2,
        totalPoints: totalPoints,
        startTime: DateTime(2026, 5, 12, 10),
        endTime: DateTime(2026, 5, 12, 10, 5),
        answers: const {'q1': 5},
      );
    }

    test('sparar avslutad session i historiken', () async {
      await repository.saveUserProgress(user);
      final session = buildSession();

      final result = await useCase.execute(user: user, session: session);

      final history = repository.quizHistory[session.sessionId];
      expect(history, isNotNull);
      expect(history!['isComplete'], isTrue);
      expect(history['userId'], userId);
      expect(history['totalQuestions'], session.totalQuestions);
      expect(history['correctAnswers'], session.correctAnswers);
      expect(history['points'], session.totalPoints);

      expect(result.finalUser.totalQuizzesTaken, 1);
      expect(repository.getUserProgress(userId)?.totalQuizzesTaken, 1);
    });

    test('samma avslutade session appliceras högst en gång', () async {
      await repository.saveUserProgress(user);
      final session = buildSession();

      final first = await useCase.execute(user: user, session: session);
      final second = await useCase.execute(user: user, session: session);

      expect(second.finalUser.totalQuizzesTaken, first.finalUser.totalQuizzesTaken);
      expect(second.finalUser.totalPoints, first.finalUser.totalPoints);
      expect(second.reward.unlockedIds, isEmpty);
      expect(second.reward.bonusPoints, 0);
      expect(second.questCompletion, isNull);

      expect(repository.getUserProgress(userId)?.totalQuizzesTaken, 1);
    });

    test('tar bort historikposten när användarlagringen misslyckas', () async {
      repository.failUserSave = true;
      final session = buildSession();

      await expectLater(
        useCase.execute(user: user, session: session),
        throwsA(isA<StateError>()),
      );

      expect(
        repository.quizHistory.containsKey(session.sessionId),
        isFalse,
        reason: 'En historikpost utan sparad progress skulle dubbelräknas '
            'vid nästa försök — den måste rullas tillbaka',
      );
      expect(repository.getUserProgress(userId), isNull);
    });
  });
}
