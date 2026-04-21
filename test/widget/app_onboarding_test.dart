import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/features/home/presentation/screens/home_screen.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] Onboarding – shown once and does not repeat',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
        gradeLevel: 3,
      );
      await repository.saveUserProgress(user);
      await repository.setActiveUserId(userId);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(userProvider.notifier).loadUsers();
      expect(container.read(userProvider).activeUser?.userId, userId);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ScreenUtilInit(
            designSize: Size(375, 812),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Let HomeScreen's post-frame onboarding push run.
      await tester.pump();

      final onboardingTitle = find.text('Nu kör vi!');
      final steps = (const Duration(seconds: 2).inMilliseconds / 50).ceil();
      for (var i = 0; i < steps; i++) {
        if (onboardingTitle.evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(onboardingTitle, findsOneWidget);
      expect(find.text('Välj årskurs'), findsOneWidget);
      expect(find.text('Tryck på en ruta.'), findsOneWidget);
      expect(find.text('Kan barnet läsa?'), findsNothing);
      expect(find.text('Vad vill du räkna först?'), findsNothing);

      await tester.tap(find.text('Starta'));
      await pumpUntilFound(tester, find.text(AppConstants.appName));
      await pumpFor(tester, const Duration(milliseconds: 600));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ScreenUtilInit(
            designSize: Size(375, 812),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      await pumpFor(tester, const Duration(milliseconds: 600));

      // Onboarding should not appear again after finishing.
      expect(find.text('Nu kör vi!'), findsNothing);
    },
  );

  testWidgets(
    '[Widget] Onboarding – start completes setup in one step',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.setActiveUserId(userId);

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(userProvider.notifier).loadUsers();
      expect(container.read(userProvider).activeUser?.userId, userId);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ScreenUtilInit(
            designSize: Size(375, 812),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      // Let HomeScreen's post-frame onboarding push run.
      await tester.pump();

      final onboardingTitle = find.text('Nu kör vi!');
      final steps = (const Duration(seconds: 2).inMilliseconds / 50).ceil();
      for (var i = 0; i < steps; i++) {
        if (onboardingTitle.evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(onboardingTitle, findsOneWidget);
      expect(find.text('Välj årskurs'), findsOneWidget);
      expect(find.text('Årskurs'), findsOneWidget);
      expect(find.text('Kan barnet läsa?'), findsNothing);
      expect(find.text('Vad vill du räkna först?'), findsNothing);

      expect(find.text('Åk 3'), findsOneWidget);
      await tester.tap(find.text('Åk 3'));
      await pumpFor(tester, const Duration(milliseconds: 200));

      await tester.tap(find.text('Starta'));

      final homeTitle = find.text(AppConstants.appName);
      final finishSteps =
          (const Duration(seconds: 4).inMilliseconds / 50).ceil();
      for (var i = 0; i < finishSteps; i++) {
        if (homeTitle.evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 50));
      }

      await pumpFor(tester, const Duration(milliseconds: 600));

      expect(homeTitle, findsOneWidget);
      expect(onboardingTitle, findsNothing);
      expect(repository.getAllowedOperationNames(userId), contains('addition'));
      expect(
        repository.getAllowedOperationNames(userId),
        contains('division'),
      );
      expect(
        repository.getSetting('word_problems_enabled_$userId'),
        isA<bool>(),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ScreenUtilInit(
            designSize: Size(375, 812),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await pumpFor(tester, const Duration(milliseconds: 800));
      expect(find.text('Nu kör vi!'), findsNothing);
    },
  );
}
