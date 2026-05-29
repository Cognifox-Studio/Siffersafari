import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';

final parentRecentCompletedQuizHistoryProvider = Provider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, userId) {
  ref.watch(
    userProvider.select(
      (state) => (
        state.activeUser?.userId,
        state.activeUser?.totalQuizzesTaken,
        state.activeUser?.totalPoints,
      ),
    ),
  );

  return ref
      .watch(localStorageRepositoryProvider)
      .getQuizHistory(userId, limit: 50)
      .where((session) => session['isComplete'] != false)
      .take(5)
      .toList(growable: false);
});
