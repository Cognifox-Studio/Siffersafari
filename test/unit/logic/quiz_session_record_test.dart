import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/quiz_session_record.dart';

void main() {
  group('[Unit] QuizSessionRecord', () {
    test('tryParse accepts valid session map', () {
      final record = QuizSessionRecord.tryParse({
        'sessionId': 's1',
        'userId': 'u1',
        'isComplete': false,
        'operationType': 'addition',
        'difficulty': 'easy',
      });

      expect(record, isNotNull);
      expect(record!.sessionId, 's1');
      expect(record.operationType?.name, 'addition');
    });

    test('tryParse rejects missing sessionId', () {
      expect(
        QuizSessionRecord.tryParse({
          'userId': 'u1',
          'isComplete': false,
          'operationType': 'addition',
        }),
        isNull,
      );
    });
  });
}
