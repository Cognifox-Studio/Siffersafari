import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/daily_goal.dart';

void main() {
  group('[Unit] Dagsmål', () {
    test('Åk 1–2 har en runda som mål', () {
      expect(dailyGoalSessions(gradeLevel: 1), 1);
      expect(dailyGoalSessions(gradeLevel: 2), 1);
    });

    test('från Åk 3 är målet två rundor', () {
      expect(dailyGoalSessions(gradeLevel: 3), 2);
      expect(dailyGoalSessions(gradeLevel: 9), 2);
    });

    test('okänt åk får det snälla målet', () {
      expect(
        dailyGoalSessions(gradeLevel: null),
        1,
        reason: 'Att gissa högt straffar barnet för en inställning som saknas',
      );
    });

    test('målet är uppnått vid target, inte innan', () {
      expect(
        dailyGoalProgress(sessionsToday: 0, gradeLevel: 1).achieved,
        isFalse,
      );
      expect(
        dailyGoalProgress(sessionsToday: 1, gradeLevel: 1).achieved,
        isTrue,
      );
      expect(
        dailyGoalProgress(sessionsToday: 1, gradeLevel: 4).achieved,
        isFalse,
      );
      expect(
        dailyGoalProgress(sessionsToday: 2, gradeLevel: 4).achieved,
        isTrue,
      );
    });

    test('negativa värden blir noll', () {
      final progress = dailyGoalProgress(sessionsToday: -3, gradeLevel: 4);

      expect(progress.done, 0);
    });
  });

  group('[Unit] Dagsmål – text', () {
    test('en runda kvar', () {
      expect(dailyGoalLabel(done: 0, target: 1), 'Dagens mål: en runda');
    });

    test('räknar upp för äldre barn', () {
      expect(dailyGoalLabel(done: 0, target: 2), 'Dagens mål: 0 av 2 rundor');
      expect(dailyGoalLabel(done: 1, target: 2), 'Dagens mål: 1 av 2 rundor');
    });

    test('klart slår igenom', () {
      expect(dailyGoalLabel(done: 2, target: 2), 'Dagens mål klart');
      expect(
        dailyGoalLabel(done: 5, target: 2),
        'Dagens mål klart',
        reason: 'Fler rundor än målet ska inte se ut som ett fel',
      );
    });
  });
}
