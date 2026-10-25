import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/storage_constants.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] pruneCompletedQuizHistoryForUser', () {
    test('keeps newest completed sessions and leaves in-progress', () async {
      final repository = InMemoryLocalStorageRepository();

      for (var i = 0; i < 45; i++) {
        await repository.saveQuizSession({
          'sessionId': 'done_$i',
          'userId': 'u1',
          'operationType': 'addition',
          'difficulty': 'easy',
          'isComplete': true,
          'startTime':
              DateTime(2026, 1, 1).add(Duration(hours: i)).toIso8601String(),
        });
      }

      await repository.saveQuizSession({
        'sessionId': 'inprogress_u1_addition',
        'userId': 'u1',
        'operationType': 'addition',
        'difficulty': 'easy',
        'isComplete': false,
        'questions': const [],
        'startTime': DateTime(2026, 2, 1).toIso8601String(),
      });

      await repository.saveQuizSession({
        'sessionId': 'other_user',
        'userId': 'u2',
        'operationType': 'addition',
        'difficulty': 'easy',
        'isComplete': true,
        'startTime': DateTime(2026, 1, 1).toIso8601String(),
      });

      final deleted = await repository.pruneCompletedQuizHistoryForUser('u1');

      expect(deleted, 5);
      final history = repository.getQuizHistory('u1');
      final completed =
          history.where((s) => s['isComplete'] == true).toList(growable: false);
      expect(
        completed,
        hasLength(StorageConstants.maxCompletedQuizHistoryPerUser),
      );
      expect(completed.first['sessionId'], 'done_44');
      expect(completed.last['sessionId'], 'done_5');
      expect(
        history.any((s) => s['sessionId'] == 'inprogress_u1_addition'),
        isTrue,
      );
      expect(repository.getQuizHistory('u2'), hasLength(1));
    });
  });
}
