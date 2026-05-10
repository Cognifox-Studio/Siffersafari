import '../enums/age_group.dart';
import '../enums/difficulty_level.dart';
import '../enums/operation_type.dart';
import 'question_json.dart';
import 'quiz_session.dart';

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
    return QuizSession(
      sessionId: json['sessionId'] as String,
      ageGroup: AgeGroup.values.firstWhere((e) => e.name == json['ageGroup']),
      gradeLevel: json['gradeLevel'] as int?,
      operationType: OperationType.values.firstWhere((e) => e.name == json['operationType']),
      difficulty: DifficultyLevel.values.firstWhere((e) => e.name == json['difficulty']),
      questions: (json['questions'] as List).map((q) => QuestionJson.fromJson(q as Map)).toList(),
      targetQuestionCount: json['targetQuestionCount'] as int,
      wordProblemsEnabled: json['wordProblemsEnabled'] as bool? ?? true,
      missingNumberEnabled: json['missingNumberEnabled'] as bool? ?? true,
      difficultyStepsByOperation: (json['difficultyStepsByOperation'] as Map?)?.map((k, v) => MapEntry(OperationType.values.firstWhere((e) => e.name == k), v as int)) ?? {},
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



