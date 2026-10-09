import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/app_analytics_provider.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';

/// Commits quiz results and side effects (analytics, celebration audio).
class ResultsFlowService {
  ResultsFlowService(this._ref);

  final Ref _ref;

  Future<bool> commitSessionResults(QuizSession session) async {
    _ref.read(userProvider.notifier).applyQuizResult(session);

    final reward = _ref.read(userProvider).lastReward;
    final shouldCelebrate = session.successRate >= 0.8 ||
        (reward?.unlockedIds.isNotEmpty ?? false);
    if (shouldCelebrate) {
      _ref.read(audioServiceProvider).playCelebrationSound();
    }

    final userId = _ref.read(userProvider).activeUser?.userId;
    if (userId != null && userId.isNotEmpty) {
      unawaited(
        _ref.read(appAnalyticsProvider).logEvent(
          name: 'quiz_completed',
          userId: userId,
          properties: {
            'operation': session.operationType.name,
            'difficulty': session.difficulty.name,
            'successRate': session.successRate,
            'correctAnswers': session.correctAnswers,
            'wrongAnswers': session.wrongAnswers,
          },
        ),
      );
    }

    final levelUp = _ref.read(userProvider).lastLevelUp;
    if (levelUp != null && userId != null && userId.isNotEmpty) {
      unawaited(
        _ref.read(appAnalyticsProvider).logEvent(
          name: 'level_up',
          userId: userId,
          properties: {
            'old_level': levelUp.oldLevel,
            'new_level': levelUp.newLevel,
            'title': levelUp.newTitle,
          },
        ),
      );
    }

    return shouldCelebrate;
  }
}

final resultsFlowProvider = Provider.autoDispose<ResultsFlowService>((ref) {
  return ResultsFlowService(ref);
});
