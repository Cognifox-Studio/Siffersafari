import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/streak_resolver.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18, 30);

  group('[Unit] StreakResolver', () {
    test('första sessionen någonsin ger dag 1', () {
      final outcome = resolveStreak(
        currentStreak: 0,
        lastSessionDate: null,
        now: now,
      );

      expect(outcome.streak, 1);
      expect(outcome.previousStreak, 0);
      expect(outcome.continued, isFalse);
      expect(outcome.broken, isFalse);
    });

    test('andra sessionen samma dag räknas inte upp', () {
      final outcome = resolveStreak(
        currentStreak: 4,
        lastSessionDate: DateTime(2026, 11, 22, 8),
        now: now,
      );

      expect(outcome.streak, 4);
      expect(outcome.continued, isFalse);
    });

    test('dagen efter fortsätter sviten', () {
      final outcome = resolveStreak(
        currentStreak: 4,
        lastSessionDate: DateTime(2026, 11, 21, 20),
        now: now,
      );

      expect(outcome.streak, 5);
      expect(outcome.continued, isTrue);
      expect(outcome.graceUsed, isFalse);
      expect(outcome.broken, isFalse);
    });

    test('en missad dag räddas av nåd-dagen', () {
      final outcome = resolveStreak(
        currentStreak: 6,
        lastSessionDate: DateTime(2026, 11, 20, 17),
        now: now,
        graceAvailable: true,
      );

      expect(outcome.streak, 7, reason: 'Dagen barnet är tillbaka på ska räknas');
      expect(outcome.graceUsed, isTrue);
      expect(outcome.continued, isTrue);
      expect(outcome.broken, isFalse);
    });

    test('utan nåd-dag nollställs sviten och förlusten rapporteras', () {
      final outcome = resolveStreak(
        currentStreak: 6,
        lastSessionDate: DateTime(2026, 11, 20, 17),
        now: now,
        graceAvailable: false,
      );

      expect(outcome.streak, 1);
      expect(outcome.continued, isFalse);
      expect(outcome.broken, isTrue);
      expect(outcome.previousStreak, 6);
    });

    test('nåd-dagen räddar bara en enstaka missad dag', () {
      final outcome = resolveStreak(
        currentStreak: 12,
        lastSessionDate: DateTime(2026, 11, 15),
        now: now,
        graceAvailable: true,
      );

      expect(outcome.streak, 1);
      expect(outcome.broken, isTrue);
      expect(outcome.graceUsed, isFalse);
    });

    test('en svit på en dag räknas inte som förlorad', () {
      final outcome = resolveStreak(
        currentStreak: 1,
        lastSessionDate: DateTime(2026, 11, 10),
        now: now,
        graceAvailable: false,
      );

      expect(outcome.streak, 1);
      expect(outcome.broken, isFalse, reason: 'Inget att sörja efter en dag');
    });
  });

  group('[Unit] StreakResolver – nåd-dagstillgång', () {
    test('första nåd-dagen är alltid tillgänglig', () {
      expect(isGraceAvailable(lastGraceUsedAt: null, now: now), isTrue);
    });

    test('använd nåd-dag spärrar i sju dagar', () {
      expect(
        isGraceAvailable(
          lastGraceUsedAt: DateTime(2026, 11, 20),
          now: now,
        ),
        isFalse,
      );
      expect(
        isGraceAvailable(
          lastGraceUsedAt: DateTime(2026, 11, 15),
          now: now,
        ),
        isTrue,
      );
    });
  });
}
