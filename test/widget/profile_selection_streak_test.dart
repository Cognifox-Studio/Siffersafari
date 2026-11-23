import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/features/profiles/presentation/screens/profile_selection_screen.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
    await repository.clearAllData();
  });

  testWidgets('[Widget] varje barn ser sin egen svit på profilvalet',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 1600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await repository.saveUserProgress(
      const UserProgress(
        userId: 'signe',
        name: 'Signe',
        ageGroup: AgeGroup.middle,
        currentStreak: 5,
        longestStreak: 5,
      ),
    );
    await repository.saveUserProgress(
      const UserProgress(
        userId: 'astrid',
        name: 'Astrid',
        ageGroup: AgeGroup.young,
      ),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(userProvider.notifier).loadUsers();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ScreenUtilInit(
          designSize: Size(375, 812),
          child: MaterialApp(home: ProfileSelectionScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_streak_signe')), findsOneWidget);
    expect(find.text('🔥 5 dagar i rad'), findsOneWidget);

    // Astrid har ingen svit -- hon ska inte låna sin systers.
    expect(find.byKey(const Key('profile_streak_astrid')), findsNothing);
  });
}
