import 'package:siffersafari/domain/entities/question.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/spaced_repetition_service.dart';

import 'question_generator_service.dart';
import 'quiz_due_question_planner.dart';
import 'quiz_review_schedule_service.dart';

class QuizSessionQuestionPlan {
  const QuizSessionQuestionPlan({
    required this.initialQuestions,
    required this.pendingDueKeys,
  });

  final List<Question> initialQuestions;
  final List<String> pendingDueKeys;
}

class QuizNextQuestionPlan {
  const QuizNextQuestionPlan({
    required this.question,
    required this.pendingDueKeys,
  });

  final Question question;
  final List<String> pendingDueKeys;
}

class QuizSessionPlanner {
  QuizSessionPlanner({
    required QuestionGeneratorService questionGenerator,
    required QuizReviewScheduleService reviewScheduleService,
    QuizDueQuestionPlanner? dueQuestionPlanner,
  })  : _questionGenerator = questionGenerator,
        _dueQuestionPlanner = dueQuestionPlanner ??
            QuizDueQuestionPlanner(
              questionGenerator: questionGenerator,
              reviewScheduleService: reviewScheduleService,
            );

  final QuestionGeneratorService _questionGenerator;
  final QuizDueQuestionPlanner _dueQuestionPlanner;

  QuizSessionQuestionPlan buildGeneratedSessionPlan({
    required AgeGroup ageGroup,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required int targetQuestionCount,
    required Map<OperationType, int> difficultyStepsByOperation,
    required Map<String, ReviewSchedule> schedules,
    required DateTime now,
    required bool wordProblemsEnabled,
    required bool missingNumberEnabled,
    int? gradeLevel,
  }) {
    final duePlan = _dueQuestionPlanner.buildPlan(
      operationType: operationType,
      difficulty: difficulty,
      targetQuestionCount: targetQuestionCount,
      schedules: schedules,
      now: now,
    );

    final firstQuestion = duePlan.initialQuestions.isNotEmpty
        ? duePlan.initialQuestions.first
        : _questionGenerator.generateQuestion(
            ageGroup: ageGroup,
            operationType: operationType,
            difficulty: difficulty,
            difficultyStepsByOperation: difficultyStepsByOperation,
            gradeLevel: gradeLevel,
            wordProblemsEnabledOverride: wordProblemsEnabled,
            missingNumberEnabledOverride: missingNumberEnabled,
          );

    return QuizSessionQuestionPlan(
      initialQuestions: List<Question>.unmodifiable([firstQuestion]),
      pendingDueKeys: duePlan.pendingDueKeys,
    );
  }

  QuizSessionQuestionPlan buildCustomSessionPlan({
    required List<Question> questions,
    required DifficultyLevel difficulty,
    required OperationType operationType,
    required Map<String, ReviewSchedule> schedules,
    required DateTime now,
  }) {
    final duePlan = _dueQuestionPlanner.buildPlan(
      operationType: operationType,
      difficulty: difficulty,
      targetQuestionCount: questions.length,
      schedules: schedules,
      now: now,
    );
    if (duePlan.initialQuestions.isEmpty) {
      return QuizSessionQuestionPlan(
        initialQuestions: List<Question>.unmodifiable(questions),
        pendingDueKeys: const <String>[],
      );
    }

    final totalDueCount =
        duePlan.initialQuestions.length + duePlan.pendingDueKeys.length;
    final retainedCustomCount =
        questions.length > totalDueCount ? questions.length - totalDueCount : 0;

    return QuizSessionQuestionPlan(
      initialQuestions: List<Question>.unmodifiable([
        duePlan.initialQuestions.first,
        ...questions.take(retainedCustomCount),
      ]),
      pendingDueKeys: duePlan.pendingDueKeys,
    );
  }

  QuizNextQuestionPlan buildNextQuestionPlan({
    required QuizSession session,
    required Map<OperationType, int> difficultyStepsByOperation,
    required List<String> pendingDueKeys,
  }) {
    final candidate = pendingDueKeys.isNotEmpty
        ? _questionGenerator.tryGenerateFromSrsKey(
            pendingDueKeys.first,
            session.difficulty,
          )
        : null;

    return QuizNextQuestionPlan(
      question: candidate ??
          _questionGenerator.generateQuestion(
            ageGroup: session.ageGroup,
            operationType: session.operationType,
            difficulty: session.difficulty,
            difficultyStepsByOperation: difficultyStepsByOperation,
            gradeLevel: session.gradeLevel,
            wordProblemsEnabledOverride: session.wordProblemsEnabled,
            missingNumberEnabledOverride: session.missingNumberEnabled,
          ),
      pendingDueKeys: pendingDueKeys.isNotEmpty
          ? List<String>.unmodifiable(pendingDueKeys.skip(1))
          : const <String>[],
    );
  }
}
