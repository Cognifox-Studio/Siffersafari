import '../enums/age_group.dart';
import '../enums/difficulty_level.dart';
import '../enums/operation_type.dart';
import 'question_json.dart';
import 'quiz_session.dart';

/// Resolve an enum value by its `name`, falling back instead of throwing.
///
/// Persisted sessions outlive refactors: an enum value may be renamed or an old
/// build may have written a record with a value that no longer exists. A missing
/// enum must never crash the resume flow.
T _enumByName<T extends Enum>(List<T> values, Object? rawName, T fallback) {
  for (final value in values) {
    if (value.name == rawName) return value;
  }
  return fallback;
}

extension QuizSessionJson on QuizSession {
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'ageGroup': ageGroup.name,
      'gradeLevel': gradeLevel,
      'operationType': operationType.name,
      'difficulty': difficulty.name,
      'questions': questions.map((q) => q.toJson()).toList(),
      'targetQuestionCount': targetQuestionCount,
      'totalQuestions': targetQuestionCount,
      'wordProblemsEnabled': wordProblemsEnabled,
      'missingNumberEnabled': missingNumberEnabled,
      'difficultyStepsByOperation': difficultyStepsByOperation.map((k, v) => MapEntry(k.name, v)),
      'currentQuestionIndex': currentQuestionIndex,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'totalPoints': totalPoints,
      'successRate': successRate,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'answers': answers,
      'responseTimes': responseTimes.map((k, v) => MapEntry(k, v.inMilliseconds)),
      'isComplete': isComplete,
    };
  }

  static QuizSession fromJson(Map<dynamic, dynamic> json) {
    final questions =
        (json['questions'] as List).map((q) => QuestionJson.fromJson(q as Map)).toList();

    final rawSteps = json['difficultyStepsByOperation'] as Map?;
    final stepsByOperation = <OperationType, int>{};
    if (rawSteps != null) {
      for (final entry in rawSteps.entries) {
        stepsByOperation[
          _enumByName(OperationType.values, entry.key, OperationType.values.first)
        ] = entry.value as int;
      }
    }

    return QuizSession(
      sessionId: json['sessionId'] as String,
      ageGroup: _enumByName(
        AgeGroup.values,
        json['ageGroup'],
        AgeGroup.values.first,
      ),
      gradeLevel: json['gradeLevel'] as int?,
      operationType: _enumByName(
        OperationType.values,
        json['operationType'],
        OperationType.values.first,
      ),
      difficulty: _enumByName(
        DifficultyLevel.values,
        json['difficulty'],
        DifficultyLevel.values.first,
      ),
      questions: questions,
      // Older rows only stored `totalQuestions`; the oldest rows stored neither.
      targetQuestionCount: (json['targetQuestionCount'] as int?) ??
          (json['totalQuestions'] as int?) ??
          questions.length,
      wordProblemsEnabled: json['wordProblemsEnabled'] as bool? ?? true,
      missingNumberEnabled: json['missingNumberEnabled'] as bool? ?? true,
      difficultyStepsByOperation: stepsByOperation,
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      answers: (json['answers'] as Map?)?.map((k, v) => MapEntry(k as String, v as int)) ?? {},
      responseTimes: (json['responseTimes'] as Map?)?.map((k, v) => MapEntry(k as String, Duration(milliseconds: v as int))) ?? {},
    );
  }
}
