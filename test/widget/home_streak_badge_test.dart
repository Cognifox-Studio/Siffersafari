import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_streak_badge.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18);

  Widget harness(Widget child, {double textScale = 1.0}) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [child]),
          ),
        ),
      ),
    );
  }

  group('[Widget] HomeStreakBadge', () {
    testWidgets('visar sviten och påminner om dagen', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 5,
            longestStreak: 9,
            lastSessionDate: DateTime(2026, 11, 21),
            now: now,
          ),
        ),
      );

      expect(find.byKey(HomeStreakBadge.badgeKey), findsOneWidget);
      expect(find.byKey(HomeStreakBadge.textKey), findsOneWidget);
      expect(find.text('5 dagar i rad'), findsOneWidget);
      expect(
        find.byKey(HomeStreakBadge.dayDoneKey),
        findsNothing,
        reason: 'Dagen är inte gjord förrän barnet spelat',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('markerar att dagen är gjord efter en session', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 6,
            longestStreak: 9,
            lastSessionDate: DateTime(2026, 11, 22, 7),
            now: now,
          ),
        ),
      );

      expect(find.byKey(HomeStreakBadge.dayDoneKey), findsOneWidget);
      expect(find.text('6 dagar i rad'), findsOneWidget);
      expect(find.textContaining('vi ses imorgon'), findsOneWidget);
    });

    testWidgets('hälsar välkommen tillbaka i stället för att skälla',
        (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 1,
            longestStreak: 12,
            lastSessionDate: DateTime(2026, 11, 16),
            brokenStreak: 12,
            now: now,
          ),
        ),
      );

      expect(find.byKey(HomeStreakBadge.comebackKey), findsOneWidget);
      expect(find.text('Välkommen tillbaka!'), findsOneWidget);
      expect(find.textContaining('12 dagar'), findsOneWidget);
    });

    testWidgets('startläget lovar inget som inte finns', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 0,
            longestStreak: 0,
            lastSessionDate: null,
            now: now,
          ),
        ),
      );

      expect(find.text('Starta en svit idag'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('visar dagens mål och räknar upp', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 4,
            longestStreak: 4,
            lastSessionDate: DateTime(2026, 11, 21),
            now: now,
            sessionsToday: 1,
            gradeLevel: 4,
          ),
        ),
      );

      expect(find.byKey(HomeStreakBadge.goalKey), findsOneWidget);
      expect(find.text('Dagens mål: 1 av 2 rundor'), findsOneWidget);
    });

    testWidgets('säger att målet är klart när det är klart', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 2,
            longestStreak: 2,
            lastSessionDate: DateTime(2026, 11, 22, 8),
            now: now,
            sessionsToday: 1,
            gradeLevel: 2,
          ),
        ),
      );

      expect(find.text('Dagens mål klart'), findsOneWidget);
    });

    testWidgets('utan sessionsdata visas ingen mållinje', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 3,
            longestStreak: 3,
            lastSessionDate: DateTime(2026, 11, 21),
            now: now,
          ),
        ),
      );

      expect(find.byKey(HomeStreakBadge.goalKey), findsNothing);
    });

    testWidgets('klarar 200 % textskala utan att klippa', (tester) async {
      await tester.pumpWidget(
        harness(
          HomeStreakBadge(
            streak: 14,
            longestStreak: 30,
            lastSessionDate: DateTime(2026, 11, 22, 7),
            now: now,
          ),
          textScale: 2.0,
        ),
      );

      expect(find.byKey(HomeStreakBadge.badgeKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
