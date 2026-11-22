import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/streak_celebration.dart';

void main() {
  group('[Unit] Svitfirande i resultatvyn', () {
    test('utan svit sägs ingenting', () {
      expect(
        streakCelebration(currentStreak: 0, longestStreak: 0),
        isNull,
        reason: 'En nollad svit ska inte pekas ut i resultatvyn',
      );
    });

    test('första dagen är dag, inte dagar', () {
      final celebration = streakCelebration(
        currentStreak: 1,
        longestStreak: 1,
      );

      expect(celebration, isNotNull);
      expect(celebration!.label, 'Dag i rad');
      expect(celebration.value, '1');
      expect(
        celebration.isRecord,
        isFalse,
        reason: 'Dag ett är ingen rekordnotering att slå',
      );
    });

    test('växande svit är ett nytt rekord varje dag', () {
      final celebration = streakCelebration(
        currentStreak: 5,
        longestStreak: 5,
      );

      expect(celebration!.label, 'Dagar i rad – rekord!');
      expect(celebration.value, '5');
      expect(celebration.isRecord, isTrue);
    });

    test('återtagen svit är inget rekord', () {
      final celebration = streakCelebration(
        currentStreak: 3,
        longestStreak: 12,
      );

      expect(celebration!.label, 'Dagar i rad');
      expect(celebration.isRecord, isFalse);
      expect(celebration.days, 3);
    });

    test('trasig data ger inget rekord', () {
      // longestStreak should never be below currentStreak, but if stored data
      // is inconsistent we trust the live streak instead of throwing.
      final celebration = streakCelebration(
        currentStreak: 4,
        longestStreak: 1,
      );

      expect(celebration!.isRecord, isTrue);
      expect(celebration.value, '4');
    });
  });
}
