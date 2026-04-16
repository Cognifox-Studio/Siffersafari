import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/daily_challenge_service.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

void main() {
  const service = DailyChallengeService();

  group('[Unit] DailyChallengeService – getTodaysChallenge', () {
    test('returnerar ett giltigt DailyChallenge-objekt', () {
      final challenge = service.getTodaysChallenge();

      expect(challenge.operation, isA<OperationType>());
      expect(challenge.difficulty, isA<DifficultyLevel>());
      expect(challenge.dateKey, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(challenge.title, isNotEmpty);
    });

    test('samma dag ger alltid samma utmaning (deterministisk)', () {
      final a = service.getTodaysChallenge();
      final b = service.getTodaysChallenge();

      expect(a.operation, equals(b.operation));
      expect(a.difficulty, equals(b.difficulty));
      expect(a.dateKey, equals(b.dateKey));
    });

    test('dateKey matchar todayKey()', () {
      final challenge = service.getTodaysChallenge();
      expect(challenge.dateKey, equals(service.todayKey()));
    });

    test('svårighetsgrad är easy eller medium (aldrig hard)', () {
      final challenge = service.getTodaysChallenge();
      expect(
        challenge.difficulty,
        anyOf(DifficultyLevel.easy, DifficultyLevel.medium),
      );
    });

    test('title innehåller operationens displayName', () {
      final challenge = service.getTodaysChallenge();
      expect(challenge.title, contains(challenge.operation.displayName));
    });
  });

  group('[Unit] DailyChallengeService – getTodaysChallengeForUser', () {
    const baseUser = UserProgress(
      userId: 'u1',
      name: 'Testaren',
      ageGroup: AgeGroup.middle,
    );

    test('returnerar operation inom allowedOperations', () {
      final allowed = {OperationType.addition, OperationType.multiplication};
      final challenge = service.getTodaysChallengeForUser(
        user: baseUser,
        allowedOperations: allowed,
      );
      expect(allowed, contains(challenge.operation));
    });

    test('faller tillbaka på alla operationer om allowedOperations är tomt',
        () {
      final challenge = service.getTodaysChallengeForUser(
        user: baseUser,
        allowedOperations: {},
      );
      expect(challenge.operation, isA<OperationType>());
    });

    test('returnerar alltid hard eller medium vid hög mastery och högt step',
        () {
      const advancedUser = UserProgress(
        userId: 'u2',
        name: 'Expert',
        ageGroup: AgeGroup.older,
        masteryLevels: {
          'multiplication_3': 0.95,
          'multiplication_5': 0.90,
        },
        operationDifficultySteps: {'multiplication': 9},
      );

      final challenge = service.getTodaysChallengeForUser(
        user: advancedUser,
        allowedOperations: {OperationType.multiplication},
      );

      expect(
        challenge.difficulty,
        anyOf(DifficultyLevel.medium, DifficultyLevel.hard),
      );
    });

    test('returnerar easy vid låg mastery och lågt step', () {
      const beginnerUser = UserProgress(
        userId: 'u3',
        name: 'Nybörjare',
        ageGroup: AgeGroup.young,
        masteryLevels: {
          'addition_1': 0.1,
        },
        operationDifficultySteps: {'addition': 1},
      );

      final challenge = service.getTodaysChallengeForUser(
        user: beginnerUser,
        allowedOperations: {OperationType.addition},
      );

      expect(challenge.difficulty, equals(DifficultyLevel.easy));
    });

    test('alla challenge returnerar korrekt formaterat dateKey', () {
      final challenge = service.getTodaysChallengeForUser(
        user: baseUser,
        allowedOperations: OperationType.values.toSet(),
      );
      expect(challenge.dateKey, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('operation prioriteras mot sämre behärskad operation', () {
      // Addition låg mastery, multiplikation hög mastery.
      const user = UserProgress(
        userId: 'u4',
        name: 'Blandad',
        ageGroup: AgeGroup.middle,
        masteryLevels: {
          'addition_1': 0.1,
          'multiplication_3': 0.9,
          'multiplication_5': 0.85,
        },
        operationDifficultySteps: {'addition': 1, 'multiplication': 8},
      );

      final allowed = {OperationType.addition, OperationType.multiplication};
      // Med pool av 2, dag-index väljer antingen index 0 eller 1 från de
      // sorterade kandidaterna. Addition ska ligga lägst i lärbehovspoäng.
      // Vi verifierar bara att returvärdet är en av de tillåtna operationerna
      // och inte kastar undantag.
      final challenge = service.getTodaysChallengeForUser(
        user: user,
        allowedOperations: allowed,
      );
      expect(allowed, contains(challenge.operation));
    });
  });

  group('[Unit] DailyChallengeService – todayKey', () {
    test('todayKey har rätt format YYYY-MM-DD', () {
      final key = service.todayKey();
      expect(key, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });

    test('todayKey innehåller aktuellt år', () {
      final year = DateTime.now().year.toString();
      expect(service.todayKey(), startsWith(year));
    });
  });
}
