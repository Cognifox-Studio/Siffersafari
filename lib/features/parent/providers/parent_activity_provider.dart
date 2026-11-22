import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/daily_activity_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/services/daily_activity_service.dart';
import 'package:siffersafari/domain/services/activity_summary.dart';

/// The last 90 days of play for one profile, shaped for the parent dashboard.
///
/// Reads the on-device counters (`DailyActivityService`) -- no events, no
/// network, nothing that outlives the phone. [userProvider] is watched only so
/// the summary refreshes after a session, when the counters change.
final parentActivityProvider =
    Provider.autoDispose.family<ActivitySummary, String>((ref, userId) {
  ref.watch(
    userProvider.select(
      (state) => (
        state.activeUser?.userId,
        state.activeUser?.totalQuizzesTaken,
      ),
    ),
  );

  final recent = ref.watch(dailyActivityProvider).recent(
        userId: userId,
        days: DailyActivityService.retentionDays,
      );

  return ActivitySummary.fromDailyCounts(
    recent.values.map((activity) => activity.sessions),
  );
});
