import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/features/inventory/presentation/screens/wardrobe_screen.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] Wardrobe – barn kan välja upplåst item',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const userId = 'wardrobe-user';
      await repository.saveUserProgress(
        const UserProgress(
          userId: userId,
          name: 'Mira',
          ageGroup: AgeGroup.middle,
          unlockedItems: ['item_safari_hat'],
        ),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: ScreenUtilInit(
            designSize: Size(375, 812),
            child: MaterialApp(
              home: _WardrobeHarness(),
            ),
          ),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('wardrobe_item_item_safari_hat')),
      );

      expect(find.text('Tänker'), findsOneWidget);

      await tester.tap(find.byKey(const Key('wardrobe_item_item_safari_hat')));
      await tester.pumpAndSettle();

      expect(
        repository.getUserProgress(userId)?.equippedItems,
        containsPair('idle_item_safari_hat', 'item_safari_hat'),
      );
    },
  );
}

class _WardrobeHarness extends ConsumerStatefulWidget {
  const _WardrobeHarness();

  @override
  ConsumerState<_WardrobeHarness> createState() => _WardrobeHarnessState();
}

class _WardrobeHarnessState extends ConsumerState<_WardrobeHarness> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userProvider.notifier).loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return const WardrobeScreen();
  }
}
