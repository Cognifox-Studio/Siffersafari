import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/core/services/quiz_review_schedule_service.dart';
import 'package:siffersafari/core/services/quiz_session_planner.dart';
import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] QuizSessionPlanner', () {
    late QuizSessionPlanner planner;
    late DateTime now;

    setUp(() {
      final questionGenerator = QuestionGeneratorService();
      final repository = InMemoryLocalStorageRepository();
      final reviewScheduleService = QuizReviewScheduleService(
        questionGenerator: questionGenerator,
        repository: repository,
        spacedRepetitionService: SpacedRepetitionService(),
      );
      planner = QuizSessionPlanner(
        questionGenerator: questionGenerator,
        reviewScheduleService: reviewScheduleService,
      );
      now = DateTime(2026, 5, 21, 10);
    });

    test('prioriterar första giltiga due-frågan i genererad session', () {
      final plan = planner.buildGeneratedSessionPlan(
        ageGroup: AgeGroup.middle,
        operationType: OperationType.multiplication,
        difficulty: DifficultyLevel.easy,
        targetQuestionCount: 10,
        difficultyStepsByOperation: const {OperationType.multiplication: 4},
        schedules: {
          'multiplication|4 × 7 = ?': ReviewSchedule(
            questionId: 'multiplication|4 × 7 = ?',
            nextReviewDate: now.subtract(const Duration(minutes: 1)),
            intervalDays: 1,
            consecutiveCorrect: 0,
          ),
        },
        now: now,
        wordProblemsEnabled: false,
        missingNumberEnabled: false,
      );

      expect(plan.initialQuestions, hasLength(1));
      expect(
        plan.initialQuestions.first.operationType,
        OperationType.multiplication,
      );
      expect(plan.initialQuestions.first.operand1, 4);
      expect(plan.initialQuestions.first.operand2, 7);
      expect(plan.initialQuestions.first.correctAnswer, 28);
      expect(plan.pendingDueKeys, isEmpty);
    });

    test('ersätter bara så många custom-frågor som due-planen behöver', () {
      final customQuestions = List<Question>.generate(
        6,
        (index) => Question(
          id: 'custom_$index',
          operationType: OperationType.multiplication,
          difficulty: DifficultyLevel.easy,
          operand1: index + 2,
          operand2: index + 2,
          correctAnswer: (index + 2) * (index + 2),
        ),
      );

      final plan = planner.buildCustomSessionPlan(
        questions: customQuestions,
        difficulty: DifficultyLevel.easy,
        operationType: OperationType.multiplication,
        schedules: {
          'multiplication|5 × 5 = ?': ReviewSchedule(
            questionId: 'multiplication|5 × 5 = ?',
            nextReviewDate: now.subtract(const Duration(minutes: 1)),
            intervalDays: 1,
            consecutiveCorrect: 0,
          ),
          'multiplication|6 × 6 = ?': ReviewSchedule(
            questionId: 'multiplication|6 × 6 = ?',
            nextReviewDate: now.subtract(const Duration(minutes: 1)),
            intervalDays: 1,
            consecutiveCorrect: 0,
          ),
        },
        now: now,
      );

      expect(plan.initialQuestions, hasLength(5));
      expect(plan.initialQuestions.first.correctAnswer, 25);
      expect(plan.initialQuestions.last.id, 'custom_3');
      expect(plan.pendingDueKeys, ['multiplication|6 × 6 = ?']);
    });
  });
}
