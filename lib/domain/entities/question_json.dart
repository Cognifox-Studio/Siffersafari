import 'question.dart';
import '../enums/difficulty_level.dart';
import '../enums/operation_type.dart';

extension QuestionJson on Question {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operationType': operationType.name,
      'difficulty': difficulty.name,
      'operand1': operand1,
      'operand2': operand2,
      'correctAnswer': correctAnswer,
      'promptText': promptText,
      'wrongAnswers': wrongAnswers,
      'explanation': explanation,
    };
  }

  static Question fromJson(Map<dynamic, dynamic> json) {
    return Question(
      id: json['id'] as String,
      operationType: OperationType.values.firstWhere((e) => e.name == json['operationType']),
      difficulty: DifficultyLevel.values.firstWhere((e) => e.name == json['difficulty']),
      operand1: json['operand1'] as int,
      operand2: json['operand2'] as int,
      correctAnswer: json['correctAnswer'] as int,
      promptText: json['promptText'] as String?,
      wrongAnswers: (json['wrongAnswers'] as List).cast<int>(),
      explanation: json['explanation'] as String?,
    );
  }
}
