import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/quiz_due_question_planner.dart';
import 'package:siffersafari/core/services/quiz_review_schedule_service.dart';
import 'package:siffersafari/domain/constants/learning_constants.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import '../../test_utils.dart';

void main() {
  late FakeQuestionGeneratorService generator;
  late InMemoryLocalStorageRepository repo;
  late QuizReviewScheduleService review;
  late QuizDueQuestionPlanner planner;

  setUp(() {
    generator = FakeQuestionGeneratorService();
    repo = InMemoryLocalStorageRepository();
    review = QuizReviewScheduleService(
      questionGenerator: generator,
      repository: repo,
      spacedRepetitionService: SpacedRepetitionService(),
    );
    planner = QuizDueQuestionPlanner(
      questionGenerator: generator,
      reviewScheduleService: review,
    );
  });

  Question q({
    required String id,
    int a = 3,
    int b = 4,
  }) {
    return Question(
      id: id,
      operand1: a,
      operand2: b,
      correctAnswer: a * b,
      operationType: OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
    );
  }

  test('collectAbandonSeedKeys empty when no answers and no pending', () {
    final session = QuizSession(
      sessionId: 's1',
      ageGroup: AgeGroup.middle,
      operationType: OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
      questions: [q(id: 'q1')],
      targetQuestionCount: 5,
    );
    expect(
      planner.collectAbandonSeedKeys(
        session: session,
        pendingDueKeys: const [],
        keyForQuestion: review.keyForQuestion,
      ),
      isEmpty,
    );
  });

  test('collectAbandonSeedKeys includes answered, current, and pending', () {
    final answered = q(id: 'q1', a: 2, b: 5);
    final current = q(id: 'q2', a: 3, b: 6);
    final session = QuizSession(
      sessionId: 's1',
      ageGroup: AgeGroup.middle,
      operationType: OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
      questions: [answered, current],
      targetQuestionCount: 5,
      currentQuestionIndex: 1,
      answers: {answered.id: 10},
    );
    final pending = 'v2|multiplication|7|8|56|7 × 8';
    final keys = planner.collectAbandonSeedKeys(
      session: session,
      pendingDueKeys: [pending],
      keyForQuestion: review.keyForQuestion,
    );
    expect(keys, contains(review.keyForQuestion(answered)));
    expect(keys, contains(review.keyForQuestion(current)));
    expect(keys, contains(pending));
  });

  test('seedDueKeys marks schedules due at now', () {
    final now = DateTime(2026, 10, 24, 12);
    final key = 'v2|multiplication|2|5|10|2 × 5';
    final existing = {
      key: ReviewSchedule(
        questionId: key,
        nextReviewDate: now.add(const Duration(days: 5)),
        intervalDays: LearningConstants.firstReviewInterval,
        consecutiveCorrect: 1,
      ),
    };
    final seeded = review.seedDueKeys(
      existing: existing,
      keys: [key, 'v2|multiplication|3|6|18|3 × 6'],
      now: now,
    );
    expect(seeded[key]!.nextReviewDate, now);
    expect(seeded[key]!.consecutiveCorrect, 1);
    expect(
      seeded['v2|multiplication|3|6|18|3 × 6']!.nextReviewDate,
      now,
    );
  });
}
