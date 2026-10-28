import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/domain/entities/quiz_session.dart';
import 'package:siffersafari/domain/entities/quiz_session_json.dart';

/// Active or persisted in-progress quiz for the home resume CTA.
final homeResumeQuizSessionProvider =
    Provider.autoDispose.family<QuizSession?, String>((ref, userId) {
  final live = ref.watch(
    quizProvider.select(
      (state) => (
        userId: state.userId,
        session: state.session,
      ),
    ),
  );

  final liveSession = live.session;
  if (live.userId == userId &&
      liveSession != null &&
      !liveSession.isComplete &&
      liveSession.endTime == null) {
    return liveSession;
  }

  final sessionMap =
      ref.watch(localStorageRepositoryProvider).getQuizSession(userId);
  if (sessionMap == null) return null;

  try {
    final restored = QuizSessionJson.fromJson(sessionMap);
    if (restored.isComplete) return null;
    return restored;
  } catch (_) {
    return null;
  }
});

final homePersistedQuizSessionProvider =
    Provider.autoDispose.family<bool, String>((ref, userId) {
  return ref.watch(homeResumeQuizSessionProvider(userId)) != null;
});
