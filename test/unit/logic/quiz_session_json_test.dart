import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/quiz_session_json.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// Persisted sessions outlive refactors, so `fromJson` must degrade gracefully
/// instead of throwing `StateError` on data it does not recognise.
void main() {
  group('[Unit] QuizSessionJson – tolerant parsing', () {
    Map<String, dynamic> questionMap() => <String, dynamic>{
          'id': 'q1',
          'operationType': 'multiplication',
          'difficulty': 'easy',
          'operand1': 6,
          'operand2': 7,
          'correctAnswer': 42,
          'wrongAnswers': <int>[41, 43, 40],
          'explanation': '6 × 7 = 42',
        };

    Map<String, dynamic> sessionMap() => <String, dynamic>{
          'sessionId': 's1',
          'ageGroup': 'middle',
          'gradeLevel': 4,
          'operationType': 'multiplication',
          'difficulty': 'easy',
          'questions': <Map<String, dynamic>>[questionMap()],
          'targetQuestionCount': 10,
          'currentQuestionIndex': 2,
          'correctAnswers': 2,
          'wrongAnswers': 0,
          'totalPoints': 30,
          'startTime': DateTime(2026, 5, 12, 10).toIso8601String(),
          'answers': <String, int>{'q1': 42},
          'responseTimes': <String, int>{'q1': 1500},
          'difficultyStepsByOperation': <String, int>{'multiplication': 3},
        };

    test('round-trip bevarar fält', () {
      final parsed = QuizSessionJson.fromJson(sessionMap());

      expect(parsed.sessionId, 's1');
      expect(parsed.ageGroup, AgeGroup.middle);
      expect(parsed.gradeLevel, 4);
      expect(parsed.operationType, OperationType.multiplication);
      expect(parsed.difficulty, DifficultyLevel.easy);
      expect(parsed.targetQuestionCount, 10);
      expect(parsed.currentQuestionIndex, 2);
      expect(parsed.correctAnswers, 2);
      expect(parsed.totalPoints, 30);
      expect(
        parsed.difficultyStepsByOperation[OperationType.multiplication],
        3,
      );
      expect(parsed.responseTimes['q1'], const Duration(milliseconds: 1500));

      final again = QuizSessionJson.fromJson(parsed.toJson());
      expect(again.sessionId, parsed.sessionId);
      expect(again.currentQuestionIndex, parsed.currentQuestionIndex);
      expect(again.difficultyStepsByOperation, parsed.difficultyStepsByOperation);
    });

    test('okända enum-namn faller tillbaka istället för att kasta', () {
      final map = sessionMap()
        ..['ageGroup'] = 'toddler'
        ..['operationType'] = 'algebra'
        ..['difficulty'] = 'extreme'
        ..['difficultyStepsByOperation'] = <String, int>{'algebra': 5};

      // Throws => test fails with that exception, which is the point.
      final parsed = QuizSessionJson.fromJson(map);

      expect(parsed.ageGroup, AgeGroup.values.first);
      expect(parsed.operationType, OperationType.values.first);
      expect(parsed.difficulty, DifficultyLevel.values.first);
    });

    test('legacy-rad utan targetQuestionCount använder totalQuestions', () {
      final map = sessionMap()
        ..remove('targetQuestionCount')
        ..['totalQuestions'] = 7;

      expect(QuizSessionJson.fromJson(map).targetQuestionCount, 7);
    });

    test('rad utan något frågeantal faller tillbaka på antal frågor', () {
      final map = sessionMap()
        ..remove('targetQuestionCount')
        ..remove('totalQuestions');

      expect(QuizSessionJson.fromJson(map).targetQuestionCount, 1);
    });
  });
}
