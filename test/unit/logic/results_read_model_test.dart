import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/quiz/presentation/results_read_model.dart';

void main() {
  group('[Unit] ResultsReadModel', () {
    test('calculateStars matches success bands', () {
      expect(ResultsReadModel.calculateStars(0.95), 3);
      expect(ResultsReadModel.calculateStars(0.75), 2);
      expect(ResultsReadModel.calculateStars(0.55), 1);
      expect(ResultsReadModel.calculateStars(0.2), 0);
    });

    test('fromState builds celebrate flag for high success rate', () {
      final session = QuizSession(
        sessionId: 's1',
        ageGroup: AgeGroup.young,
        operationType: OperationType.addition,
        difficulty: DifficultyLevel.easy,
        questions: const [],
        targetQuestionCount: 10,
        correctAnswers: 9,
        wrongAnswers: 1,
        totalPoints: 90,
        startTime: DateTime(2026, 1, 1),
      );

      final model = ResultsReadModel.fromState(
        quizState: QuizState(session: session),
        userState: const UserState(),
        storyProgress: null,
      );

      expect(model.shouldCelebrate, isTrue);
      expect(model.stars, 3);
    });
  });
}
