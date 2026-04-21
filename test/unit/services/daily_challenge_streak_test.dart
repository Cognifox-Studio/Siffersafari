import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/daily_challenge_service.dart';
import 'package:siffersafari/features/daily_challenge/providers/daily_challenge_provider.dart';

import '../../test_utils.dart';

void main() {
  const userId = 'u1';
  const service = DailyChallengeService();

  group('[Unit] DailyChallengeStreak', () {
    late InMemoryLocalStorageRepository repository;

    setUp(() {
      repository = InMemoryLocalStorageRepository();
    });

    DailyChallengeNotifier makeNotifier() => DailyChallengeNotifier(
          service: service,
          repository: repository,
          userId: userId,
        );

    test('streak startar på 0 utan lagrad data', () {
      final notifier = makeNotifier();
      expect(notifier.state.streakCount, 0);
    });

    test('streak blir 1 efter första markCompleted', () async {
      final notifier = makeNotifier();
      await notifier.markCompleted();
      expect(notifier.state.streakCount, 1);
      expect(notifier.state.isCompleted, true);
    });

    test('streak ökar inte vid dubbel markCompleted samma dag', () async {
      final notifier = makeNotifier();
      await notifier.markCompleted();
      await notifier.markCompleted();
      expect(notifier.state.streakCount, 1);
    });

    test('streak läses in korrekt från lagrad data', () async {
      final todayKey = service.todayKey();
      // Simulate a streak of 3 started yesterday.
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-'
          '${yesterday.day.toString().padLeft(2, '0')}';

      await repository.saveSetting(
        SettingsKeys.dailyChallengeStreak(userId),
        {'streak': 3, 'lastDate': yesterdayKey},
      );

      final notifier = makeNotifier();
      // Not yet completed today – streak loaded from storage.
      expect(notifier.state.streakCount, 3);
      expect(notifier.state.isCompleted, false);

      // Mark today complete – streak should become 4.
      await notifier.markCompleted();
      expect(notifier.state.streakCount, 4);

      // Verify stored value.
      final raw = repository.getSetting(
        SettingsKeys.dailyChallengeStreak(userId),
      ) as Map;
      expect(raw['streak'], 4);
      expect(raw['lastDate'], todayKey);
    });

    test('streak resettas till 1 vid gap på mer än en dag', () async {
      // Simulate old streak with lastDate 3 days ago.
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final oldKey =
          '${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-'
          '${twoDaysAgo.day.toString().padLeft(2, '0')}';
      await repository.saveSetting(
        SettingsKeys.dailyChallengeStreak(userId),
        {'streak': 10, 'lastDate': oldKey},
      );

      final notifier = makeNotifier();
      await notifier.markCompleted();
      expect(notifier.state.streakCount, 1);
    });

    test('isCompleted laddas in om idag är markerat klart', () async {
      final todayKey = service.todayKey();
      await repository.saveSetting(
        SettingsKeys.dailyChallengeCompletion(userId, todayKey),
        true,
      );
      await repository.saveSetting(
        SettingsKeys.dailyChallengeStreak(userId),
        {'streak': 2, 'lastDate': todayKey},
      );

      final notifier = makeNotifier();
      expect(notifier.state.isCompleted, true);
      expect(notifier.state.streakCount, 2);
    });
  });
}
