import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/providers/daily_challenge_provider.dart';
import 'package:siffersafari/core/services/daily_challenge_service.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/presentation/widgets/daily_challenge_card.dart';

import '../test_utils.dart';

void main() {
  const userId = 'u1';
  const user = UserProgress(
    userId: userId,
    name: 'Testaren',
    ageGroup: AgeGroup.middle,
  );
  final allowedOps = OperationType.values.toSet();

  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  Widget buildCard({VoidCallback? onStart}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: ProviderScope(
        overrides: [
          dailyChallengeProvider(userId).overrideWith(
            (ref) => DailyChallengeNotifier(
              service: const DailyChallengeService(),
              repository: repository,
              userId: userId,
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: DailyChallengeCard(
              user: user,
              userId: userId,
              allowedOps: allowedOps,
              onStart: (_) => onStart?.call(),
              onPrimary: Colors.white,
              mutedOnPrimary: Colors.white70,
              accentColor: Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    '[Widget] DailyChallengeCard – visar "Kör utmaningen" när ej klar',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildCard());
      await tester.pump();

      expect(find.text('Kör utmaningen'), findsOneWidget);
      expect(find.text('Dagens utmaning'), findsOneWidget);
      expect(find.textContaining('✅'), findsNothing);
    },
  );

  testWidgets(
    '[Widget] DailyChallengeCard – visar "✅ Klar!" när utmaningen är gjord',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Pre-populate storage: today is completed.
      final todayKey = const DailyChallengeService().todayKey();
      await repository.saveSetting(
        SettingsKeys.dailyChallengeCompletion(userId, todayKey),
        true,
      );

      await tester.pumpWidget(buildCard());
      await tester.pump();

      expect(find.textContaining('✅'), findsOneWidget);
      expect(find.text('Kör utmaningen'), findsNothing);
    },
  );

  testWidgets(
    '[Widget] DailyChallengeCard – visar streak-badge vid streak > 1',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final todayKey = const DailyChallengeService().todayKey();
      await repository.saveSetting(
        SettingsKeys.dailyChallengeCompletion(userId, todayKey),
        true,
      );
      await repository.saveSetting(
        SettingsKeys.dailyChallengeStreak(userId),
        {'streak': 4, 'lastDate': todayKey},
      );

      await tester.pumpWidget(buildCard());
      await tester.pump();

      expect(find.textContaining('4 dagar'), findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] DailyChallengeCard – döljer streak-badge vid streak = 1',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final todayKey = const DailyChallengeService().todayKey();
      await repository.saveSetting(
        SettingsKeys.dailyChallengeStreak(userId),
        {'streak': 1, 'lastDate': todayKey},
      );

      await tester.pumpWidget(buildCard());
      await tester.pump();

      expect(find.textContaining('dagar'), findsNothing);
    },
  );

  testWidgets(
    '[Widget] DailyChallengeCard – anropar onStart vid knapptryck',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var tapped = false;
      await tester.pumpWidget(buildCard(onStart: () => tapped = true));
      await tester.pump();

      await tester.tap(find.text('Kör utmaningen'));
      await tester.pump();

      expect(tapped, true);
    },
  );
}
