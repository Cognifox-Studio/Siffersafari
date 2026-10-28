import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/quiz_session_storage_service.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import '../../test_utils.dart';

void main() {
  test('pågående runda kan hämtas', () async {
    final repo = InMemoryLocalStorageRepository();
    final service = QuizSessionStorageService(repo);

    service.persistInProgressSession(
      userId: 'u1',
      session: _session(index: 3),
      pendingDueKeys: const [],
    );
    await pumpEventQueue();

    expect(repo.getQuizSession('u1'), isNotNull);
  });

  test('avslutad runda tar bort pågående rad', () async {
    final repo = InMemoryLocalStorageRepository();
    final service = QuizSessionStorageService(repo);
    final open = _session(index: 7);
    final done = open.copyWith(
      currentQuestionIndex: open.targetQuestionCount,
      endTime: DateTime(2026, 10, 28),
    );

    service.persistInProgressSession(
      userId: 'u1',
      session: open,
      pendingDueKeys: const [],
    );
    service.persistInProgressSession(
      userId: 'u1',
      session: done,
      pendingDueKeys: const [],
    );
    await pumpEventQueue();

    expect(done.isComplete, isTrue);
    expect(repo.getQuizSession('u1'), isNull);
  });
}

QuizSession _session({required int index}) {
  return QuizSession(
    sessionId: 's1',
    ageGroup: AgeGroup.middle,
    operationType: OperationType.addition,
    difficulty: DifficultyLevel.easy,
    questions: const [],
    targetQuestionCount: 8,
    currentQuestionIndex: index,
    correctAnswers: index,
    answers: {
      for (var i = 0; i < index; i++) 'q$i': i,
    },
  );
}
