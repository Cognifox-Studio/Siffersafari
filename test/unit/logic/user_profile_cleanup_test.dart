import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] User profile cleanup', () {
    late InMemoryLocalStorageRepository repository;
    late MockAudioService audioService;
    late UserNotifier notifier;

    setUp(() {
      repository = InMemoryLocalStorageRepository();
      audioService = MockAudioService();
      when(() => audioService.setSoundEnabled(any())).thenReturn(null);
      when(() => audioService.setMusicEnabled(any())).thenReturn(null);

      notifier = UserNotifier(
        repository,
        AchievementService(),
        audioService,
        const QuestProgressionService(),
      );
    });

    test(
      'rensar användarscopade settings och quiz utan att påverka andra profiler',
      () async {
        await repository.saveUserProgress(
          const UserProgress(
            userId: 'u1',
            name: 'Mira',
            ageGroup: AgeGroup.middle,
          ),
        );
        await repository.saveUserProgress(
          const UserProgress(
            userId: 'u2',
            name: 'Leo',
            ageGroup: AgeGroup.middle,
          ),
        );

        await repository.setActiveUserId('u1');
        await repository
            .saveSetting(SettingsKeys.allowedOperations('u1'), ['addition']);
        await repository.saveSetting(
          SettingsKeys.wordProblemsEnabled('u1'),
          false,
        );
        await repository.saveSetting(
          SettingsKeys.dailyChallengeCompletion('u1', '2026-05-12'),
          true,
        );
        await repository.saveSetting(SettingsKeys.dailyChallengeStreak('u1'), {
          'streak': 2,
          'lastDate': '2026-05-12',
        });
        await repository
            .saveSetting(SettingsKeys.allowedOperations('u2'), ['division']);

        await repository.saveQuizSession({
          'sessionId': 'inprogress_u1_addition',
          'userId': 'u1',
          'operationType': OperationType.addition.name,
          'difficulty': 'easy',
          'questions': const [],
          'targetQuestionCount': 1,
          'currentQuestionIndex': 0,
          'correctAnswers': 0,
          'wrongAnswers': 0,
          'totalPoints': 0,
          'successRate': 0.0,
          'startTime': DateTime(2026, 5, 12).toIso8601String(),
          'endTime': DateTime(2026, 5, 12).toIso8601String(),
          'answers': const <String, int>{},
          'responseTimes': const <String, int>{},
          'isComplete': false,
        });
        await repository.saveQuizSession({
          'sessionId': 'complete_u2',
          'userId': 'u2',
          'operationType': OperationType.division.name,
          'difficulty': 'easy',
          'correctAnswers': 4,
          'totalQuestions': 5,
          'successRate': 0.8,
          'points': 20,
          'startTime': DateTime(2026, 5, 12).toIso8601String(),
          'endTime': DateTime(2026, 5, 12).toIso8601String(),
          'isComplete': true,
        });

        await repository.deleteUserData('u1');

        expect(repository.getUserProgress('u1'), isNull);
        expect(repository.getUserProgress('u2'), isNotNull);
        expect(repository.getQuizHistory('u1'), isEmpty);
        expect(repository.getQuizHistory('u2'), isNotEmpty);
        expect(
          repository.getSetting(SettingsKeys.allowedOperations('u1')),
          isNull,
        );
        expect(
          repository.getSetting(SettingsKeys.wordProblemsEnabled('u1')),
          isNull,
        );
        expect(
          repository.getSetting(
            SettingsKeys.dailyChallengeCompletion('u1', '2026-05-12'),
          ),
          isNull,
        );
        expect(
          repository.getSetting(SettingsKeys.dailyChallengeStreak('u1')),
          isNull,
        );
        expect(
          repository.getSetting(SettingsKeys.allowedOperations('u2')),
          ['division'],
        );
        expect(repository.getActiveUserId(), isNull);
      },
    );

    test('deleteUser väljer nästa profil och rensar borttagen profils data',
        () async {
      await notifier.createUser(
        userId: 'u1',
        name: 'Mira',
        ageGroup: AgeGroup.middle,
      );
      await notifier.createUser(
        userId: 'u2',
        name: 'Leo',
        ageGroup: AgeGroup.middle,
      );
      await notifier.selectUser('u1');

      await repository
          .saveSetting(SettingsKeys.allowedOperations('u1'), ['addition']);
      await repository.saveQuizSession({
        'sessionId': repository.inProgressQuizSessionId(
          userId: 'u1',
          operationTypeName: OperationType.addition.name,
        ),
        'userId': 'u1',
        'operationType': OperationType.addition.name,
        'difficulty': 'easy',
        'questions': const [],
        'targetQuestionCount': 1,
        'currentQuestionIndex': 0,
        'correctAnswers': 0,
        'wrongAnswers': 0,
        'totalPoints': 0,
        'successRate': 0.0,
        'startTime': DateTime(2026, 5, 12).toIso8601String(),
        'endTime': DateTime(2026, 5, 12).toIso8601String(),
        'answers': const <String, int>{},
        'responseTimes': const <String, int>{},
        'isComplete': false,
      });

      await notifier.deleteUser('u1');

      expect(notifier.state.activeUser?.userId, 'u2');
      expect(notifier.state.allUsers.map((u) => u.userId), ['u2']);
      expect(repository.getActiveUserId(), 'u2');
      expect(repository.getUserProgress('u1'), isNull);
      expect(repository.getQuizHistory('u1'), isEmpty);
      expect(
        repository.getSetting(SettingsKeys.allowedOperations('u1')),
        isNull,
      );
    });

    test('clearAllData nollställer användarstate helt', () async {
      await notifier.createUser(
        userId: 'u1',
        name: 'Mira',
        ageGroup: AgeGroup.middle,
      );

      await notifier.clearAllData();

      expect(notifier.state.allUsers, isEmpty);
      expect(notifier.state.activeUser, isNull);
      expect(notifier.state.questStatus, isNull);
      expect(repository.getAllUserProfiles(), isEmpty);
      expect(repository.getActiveUserId(), isNull);
    });
  });
}
