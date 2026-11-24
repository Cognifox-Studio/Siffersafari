import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/week_window.dart';
import 'package:siffersafari/domain/services/weekly_quest.dart';

Map<String, dynamic> _round({
  required String endedAt,
  String id = 'r1',
  bool complete = true,
}) {
  return <String, dynamic>{
    'sessionId': id,
    'isComplete': complete,
    'startTime': endedAt,
    'endTime': endedAt,
  };
}

void main() {
  group('[Unit] Veckofönster', () {
    test('veckan börjar på måndag morgon', () {
      // Söndag 22 nov 2026 hör till veckan som började 16 nov.
      final window = WeekWindow.containing(DateTime(2026, 11, 22, 18, 30));
      expect(window.start, DateTime(2026, 11, 16));
      expect(window.end, DateTime(2026, 11, 23));
    });

    test('midnatt på måndag hör till den nya veckan', () {
      final window = WeekWindow.containing(DateTime(2026, 11, 22, 23, 59));
      expect(window.contains(DateTime(2026, 11, 23)), isFalse);
      expect(
        WeekWindow.containing(DateTime(2026, 11, 23)).contains(
          DateTime(2026, 11, 23),
        ),
        isTrue,
      );
    });

    test('dagar kvar räknas i kalenderdagar', () {
      final window = WeekWindow.containing(DateTime(2026, 11, 16, 8));
      expect(window.daysLeft(DateTime(2026, 11, 16, 8)), 7);
      expect(window.daysLeft(DateTime(2026, 11, 22, 23)), 1);
    });

    test('veckonumret stämmer med ISO', () {
      expect(WeekWindow.containing(DateTime(2026, 11, 18)).label, 'Vecka 47');
      expect(WeekWindow.containing(DateTime(2026, 1, 1)).label, 'Vecka 1');
    });
  });

  group('[Unit] Veckoquest', () {
    test('bara rundor innevarande vecka räknas', () {
      final quest = weeklyQuestFor(
        history: [
          _round(endedAt: '2026-11-16T18:00:00', id: 'mån'),
          _round(endedAt: '2026-11-14T18:00:00', id: 'förra veckan'),
        ],
        now: DateTime(2026, 11, 18, 9),
        gradeLevel: 3,
      );

      expect(quest.done, 1);
      expect(quest.target, 4);
      expect(quest.isComplete, isFalse);
      expect(quest.progressLabel, '1 av 4 rundor');
    });

    test('avbrutna rundor tickar inte målet', () {
      final quest = weeklyQuestFor(
        history: [
          _round(endedAt: '2026-11-17T10:00:00', complete: false),
        ],
        now: DateTime(2026, 11, 18),
        gradeLevel: 3,
      );

      expect(quest.done, 0);
    });

    test('målet är klart och säger det', () {
      final quest = weeklyQuestFor(
        history: [
          for (var day = 16; day < 20; day++)
            _round(endedAt: '2026-11-${day}T10:00:00', id: 'd$day'),
        ],
        now: DateTime(2026, 11, 20),
        gradeLevel: 5,
      );

      expect(quest.isComplete, isTrue);
      expect(quest.progressLabel, 'Veckans mål klart');
      expect(quest.progress, 1.0);
    });

    test('de yngsta får tre rundor, de äldre fyra', () {
      expect(weeklyQuestTarget(gradeLevel: 2), 3);
      expect(weeklyQuestTarget(gradeLevel: null), 3);
      expect(weeklyQuestTarget(gradeLevel: 4), 4);
    });

    test('måndag nollställer veckan utan att något skrivs', () {
      final history = [
        _round(endedAt: '2026-11-20T10:00:00', id: 'förra'),
      ];

      final sunday = weeklyQuestFor(
        history: history,
        now: DateTime(2026, 11, 22, 20),
        gradeLevel: 4,
      );
      final monday = weeklyQuestFor(
        history: history,
        now: DateTime(2026, 11, 23, 7),
        gradeLevel: 4,
      );

      expect(sunday.done, 1);
      expect(monday.done, 0);
    });

    test('trasiga rader räknas som noll i stället för att krascha', () {
      final quest = weeklyQuestFor(
        history: [
          <String, dynamic>{'isComplete': true},
          _round(endedAt: 'inte ett datum'),
        ],
        now: DateTime(2026, 11, 18),
        gradeLevel: 3,
      );

      expect(quest.done, 0);
    });

    test('uppläsningen säger vecka och mål', () {
      final quest = weeklyQuestFor(
        history: const [],
        now: DateTime(2026, 11, 18),
        gradeLevel: 3,
      );

      expect(quest.spokenLabel, 'Vecka 47. Veckans mål: 0 av 4 rundor.');
    });
  });
}
