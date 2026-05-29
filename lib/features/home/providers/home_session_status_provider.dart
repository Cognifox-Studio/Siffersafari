import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';

final homePersistedQuizSessionProvider =
    Provider.autoDispose.family<bool, String>((ref, userId) {
  ref.watch(
    quizProvider.select(
      (state) => (
        state.userId,
        state.session?.sessionId,
        state.session?.endTime,
      ),
    ),
  );

  return ref.watch(localStorageRepositoryProvider).getQuizSession(userId) !=
      null;
});
