import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/settings/presentation/screens/settings_screen.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] SettingsScreen – radera profil väljer nästa användare och rensar data',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();
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

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(userProvider.notifier).loadUsers();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('delete_profile_button')),
      );
      await tester
          .ensureVisible(find.byKey(const Key('delete_profile_button')));
      await tester.tap(find.byKey(const Key('delete_profile_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_delete_profile_button')));
      await tester.pumpAndSettle();

      expect(repository.getUserProgress('u1'), isNull);
      expect(
        repository.getSetting(SettingsKeys.allowedOperations('u1')),
        isNull,
      );
      expect(repository.getQuizHistory('u1'), isEmpty);
      expect(repository.getActiveUserId(), 'u2');
      expect(container.read(userProvider).activeUser?.userId, 'u2');
    },
  );

  testWidgets(
    '[Widget] SettingsScreen – radera all data nollställer profiler och state',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();
      await repository.saveUserProgress(
        const UserProgress(
          userId: 'u1',
          name: 'Mira',
          ageGroup: AgeGroup.middle,
        ),
      );
      await repository.setActiveUserId('u1');
      await repository.saveSetting(SettingsKeys.onboardingDone('u1'), true);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(userProvider.notifier).loadUsers();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('clear_all_data_button')),
      );
      await tester
          .ensureVisible(find.byKey(const Key('clear_all_data_button')));
      await tester.tap(find.byKey(const Key('clear_all_data_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_clear_all_data_button')));
      await tester.pumpAndSettle();

      expect(repository.getAllUserProfiles(), isEmpty);
      expect(repository.getActiveUserId(), isNull);
      expect(container.read(userProvider).allUsers, isEmpty);
      expect(container.read(userProvider).activeUser, isNull);
    },
  );
}
