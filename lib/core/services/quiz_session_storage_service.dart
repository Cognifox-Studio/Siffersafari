import 'package:flutter/foundation.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/quiz_session_json.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

class QuizSessionStorageService {
  QuizSessionStorageService(this._repository);

  final LocalStorageRepository _repository;

  /// Serializes Hive writes so a late in-progress save cannot land after the
  /// row was cleared for a finished quiz.
  Future<void> _writes = Future<void>.value();

  void persistInProgressSession({
    required String userId,
    required QuizSession session,
    required List<String> pendingDueKeys,
    bool persistEvenWithoutAnswers = false,
  }) {
    debugPrint(
      '[QuizSessionStorageService] persistInProgressSession: '
      'userId=$userId, operationType=${session.operationType.name}',
    );
    final answered = session.correctAnswers + session.wrongAnswers;
    if (session.isComplete) {
      _enqueue(
        () => _clearInProgressSession(
          userId: userId,
          operationTypeName: session.operationType.name,
        ),
      );
      return;
    }
    if (answered <= 0 && !persistEvenWithoutAnswers) {
      debugPrint(
        '[QuizSessionStorageService] persistInProgressSession: no answers yet, skipping',
      );
      return;
    }

    final inProgressId = _repository.inProgressQuizSessionId(
      userId: userId,
      operationTypeName: session.operationType.name,
    );

    final sessionMap = session.toJson();
    sessionMap['sessionId'] = inProgressId;
    sessionMap['userId'] = userId;
    sessionMap['isComplete'] = false;
    sessionMap['pendingDueKeys'] = List<String>.from(pendingDueKeys);
    if (answered <= 0) {
      sessionMap['totalQuestions'] = 0;
      sessionMap['correctAnswers'] = 0;
      sessionMap['wrongAnswers'] = 0;
      sessionMap['successRate'] = 0.0;
      sessionMap['totalPoints'] = 0;
    }

    _enqueue(() async {
      await _repository.purgeInProgressQuizSessions(
        userId: userId,
        operationTypeName: session.operationType.name,
        exceptSessionId: inProgressId,
      );
      await _repository.saveQuizSession(sessionMap);
    });
  }

  void _enqueue(Future<void> Function() action) {
    _writes = _writes
        .then((_) => action())
        .catchError((Object error, StackTrace stack) {
      debugPrint('[QuizSessionStorageService] write failed: $error');
      debugPrintStack(stackTrace: stack);
    });
  }

  Future<void> _clearInProgressSession({
    required String userId,
    required String operationTypeName,
  }) {
    final inProgressId = _repository.inProgressQuizSessionId(
      userId: userId,
      operationTypeName: operationTypeName,
    );
    return _repository.deleteQuizSession(inProgressId);
  }

  void prepareInProgressStorage({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
  }) {
    _resetInProgressUnderlag(
      userId: userId,
      operationType: operationType,
      difficulty: difficulty,
    );
  }

  void _resetInProgressUnderlag({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
  }) {
    final now = DateTime.now();
    _writeSessionInfo(
      userId: userId,
      operationType: operationType,
      difficulty: difficulty,
      correctAnswers: 0,
      totalQuestions: 0,
      successRate: 0.0,
      points: 0,
      start: now,
      end: now,
    );
  }

  void _writeSessionInfo({
    required String userId,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required int correctAnswers,
    required int totalQuestions,
    required double successRate,
    required int points,
    required DateTime start,
    required DateTime end,
  }) {
    final inProgressId = _repository.inProgressQuizSessionId(
      userId: userId,
      operationTypeName: operationType.name,
    );

    _enqueue(() async {
      await _repository.purgeInProgressQuizSessions(
        userId: userId,
        operationTypeName: operationType.name,
        exceptSessionId: inProgressId,
      );
      await _repository.saveQuizSession({
        'sessionId': inProgressId,
        'userId': userId,
        'operationType': operationType.name,
        'difficulty': difficulty.name,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'successRate': successRate,
        'points': points,
        'bonusPoints': 0,
        'pointsWithBonus': points,
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'isComplete': false,
      });
    });
  }
}
