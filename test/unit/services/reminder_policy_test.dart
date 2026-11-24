import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/reminder_policy.dart';

void main() {
  group('[Unit] Påminnelsepolicy', () {
    test('av som default -- ingen notis utan att en förälder slagit på', () {
      const policy = ReminderPolicy(enabled: false);

      expect(
        policy.nextFireTime(
          now: DateTime(2026, 11, 23, 8),
          alreadySentToday: false,
        ),
        isNull,
      );
    });

    test('högst en per dag: skickad idag ger imorgon, inte en till ikväll', () {
      const policy = ReminderPolicy(enabled: true, hour: 19);

      expect(
        policy.nextFireTime(
          now: DateTime(2026, 11, 23, 18),
          alreadySentToday: true,
        ),
        isNull,
      );
    });

    test('ikväll om tiden inte passerat, annars imorgon', () {
      const policy = ReminderPolicy(enabled: true, hour: 19);

      expect(
        policy.nextFireTime(
          now: DateTime(2026, 11, 23, 18),
          alreadySentToday: false,
        ),
        DateTime(2026, 11, 23, 19),
      );
      expect(
        policy.nextFireTime(
          now: DateTime(2026, 11, 23, 20),
          alreadySentToday: false,
        ),
        DateTime(2026, 11, 24, 19),
      );
    });

    test('tysta timmar flyttar notisen, den stryks inte', () {
      const policy = ReminderPolicy(enabled: true, hour: 21);

      expect(policy.isQuietHours, isTrue);
      expect(policy.effectiveHour, 7);
      expect(
        policy.nextFireTime(
          now: DateTime(2026, 11, 23, 6),
          alreadySentToday: false,
        ),
        DateTime(2026, 11, 23, 7),
      );
    });

    test('tysta timmar över midnatt räknas både före och efter', () {
      const before = ReminderPolicy(enabled: true, hour: 3);
      const after = ReminderPolicy(enabled: true, hour: 22);
      const daytime = ReminderPolicy(enabled: true, hour: 12);

      expect(before.isQuietHours, isTrue);
      expect(after.isQuietHours, isTrue);
      expect(daytime.isQuietHours, isFalse);
    });
  });
}
