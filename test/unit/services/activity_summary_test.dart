import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/activity_summary.dart';

void main() {
  group('[Unit] Aktivitetsöversikt', () {
    test('tom historik ger nollor', () {
      final summary = ActivitySummary.fromDailyCounts(const []);

      expect(summary.totalDays, 0);
      expect(summary.activeDays, 0);
      expect(summary.longestRun, 0);
      expect(summary.currentRun, 0);
      expect(summary.isEmpty, isTrue);
      expect(summary.busiestDay, 0);
    });

    test('räknar aktiva dagar och längsta följd', () {
      // oldest -> newest
      final summary = ActivitySummary.fromDailyCounts(const [0, 1, 1, 0, 1]);

      expect(summary.activeDays, 3);
      expect(summary.longestRun, 2);
      expect(
        summary.currentRun,
        1,
        reason: 'Sista dagen hade spel, så följden är en dag',
      );
    });

    test('följd som slutar med en tom dag ger currentRun 0', () {
      final summary = ActivitySummary.fromDailyCounts(const [1, 1, 1, 0]);

      expect(summary.longestRun, 3);
      expect(
        summary.currentRun,
        0,
        reason: 'Ingen ska känna sig tvingad -- siffran beskriver, den dömer inte',
      );
    });

    test('allt spelat ger hela perioden som följd', () {
      final summary = ActivitySummary.fromDailyCounts(List.filled(90, 2));

      expect(summary.totalDays, 90);
      expect(summary.activeDays, 90);
      expect(summary.longestRun, 90);
      expect(summary.currentRun, 90);
      expect(summary.busiestDay, 2);
    });

    test('negativa värden blir noll och blåser inte upp siffrorna', () {
      final summary = ActivitySummary.fromDailyCounts(const [-5, 1, -2]);

      expect(summary.sessionsPerDay, const [0, 1, 0]);
      expect(summary.activeDays, 1);
      expect(summary.longestRun, 1);
      expect(summary.currentRun, 0);
    });

    test('playedOn är falskt utanför historiken', () {
      final summary = ActivitySummary.fromDailyCounts(const [1, 0]);

      expect(summary.playedOn(0), isTrue);
      expect(summary.playedOn(1), isFalse);
      expect(summary.playedOn(-1), isFalse);
      expect(summary.playedOn(99), isFalse);
    });
  });
}
