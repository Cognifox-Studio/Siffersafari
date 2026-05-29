import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import 'question_generator_service.dart';
import 'quiz_review_schedule_service.dart';

class QuizDueQuestionPlan {
  const QuizDueQuestionPlan({
    required this.initialQuestions,
    required this.pendingDueKeys,
  });

  final List<Question> initialQuestions;
  final List<String> pendingDueKeys;

  static const empty = QuizDueQuestionPlan(
    initialQuestions: <Question>[],
    pendingDueKeys: <String>[],
  );
}

class QuizDueQuestionPlanner {
  const QuizDueQuestionPlanner({
    required QuestionGeneratorService questionGenerator,
    required QuizReviewScheduleService reviewScheduleService,
  })  : _questionGenerator = questionGenerator,
        _reviewScheduleService = reviewScheduleService;

  final QuestionGeneratorService _questionGenerator;
  final QuizReviewScheduleService _reviewScheduleService;

  QuizDueQuestionPlan buildPlan({
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required int targetQuestionCount,
    required Map<String, ReviewSchedule> schedules,
    required DateTime now,
  }) {
    final dueKeys = _reviewScheduleService.getDueKeysForSession(
      schedules,
      operationType,
      targetQuestionCount,
      now,
    );
    if (dueKeys.isEmpty) return QuizDueQuestionPlan.empty;

    Question? firstDueQuestion;
    final remainingDueKeys = <String>[];

    for (final key in dueKeys) {
      final parsed = _questionGenerator.tryGenerateFromSrsKey(key, difficulty);
      if (parsed == null) continue;

      if (firstDueQuestion == null) {
        firstDueQuestion = parsed;
      } else {
        remainingDueKeys.add(key);
      }
    }

    if (firstDueQuestion == null) return QuizDueQuestionPlan.empty;

    return QuizDueQuestionPlan(
      initialQuestions: List<Question>.unmodifiable([firstDueQuestion]),
      pendingDueKeys: List<String>.unmodifiable(remainingDueKeys),
    );
  }
}
