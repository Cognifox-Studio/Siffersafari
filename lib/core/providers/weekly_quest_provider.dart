import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/quiz_provider.dart';
import 'package:siffersafari/domain/services/weekly_quest.dart';

/// This week's small goal for one profile, derived from the history that is
/// already stored.
///
/// Watches [quizProvider]'s session count so a finished round moves the bar
/// without a restart: the quest is a view of the week, not a counter of its own.
final weeklyQuestProvider =
    Provider.autoDispose.family<WeeklyQuest, String>((ref, userId) {
  ref.watch(_quizHistoryTicksProvider);

  final repository = ref.watch(localStorageRepositoryProvider);
  return weeklyQuestFor(
    history: repository.getQuizHistory(userId),
    now: DateTime.now(),
    gradeLevel: repository.getUserProgress(userId)?.gradeLevel,
  );
});

/// A cheap thing to watch so the quest is recomputed after a round lands.
///
/// `quizProvider`'s completed-session stamp changes when a session is applied,
/// which is exactly when the history grew.
final _quizHistoryTicksProvider = Provider.autoDispose<Object?>((ref) {
  return ref.watch(
    quizProvider.select((state) => state.session?.endTime),
  );
});
