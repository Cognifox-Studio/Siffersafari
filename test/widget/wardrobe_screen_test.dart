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

      expect(find.text('Fel'), findsOneWidget);
      expect(find.text('Vila'), findsOneWidget);
      expect(find.text('Rätt'), findsOneWidget);

      await tester.tap(find.byKey(const Key('wardrobe_item_item_safari_hat')));
      await tester.pumpAndSettle();

      expect(
        repository.getUserProgress(userId)?.equippedItems,
        containsPair('idle_item_safari_hat', 'item_safari_hat'),
      );
    },
  );

  testWidgets(
    '[Widget] Wardrobe – pose är förhandsvisning, plagget sparas globalt',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const userId = 'wardrobe-pose-user';
      await repository.saveUserProgress(
        const UserProgress(
          userId: userId,
          name: 'Mira',
          ageGroup: AgeGroup.middle,
          unlockedItems: ['item_safari_hat'],
        ),
      );
      await repository.setActiveUserId(userId);

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

      // Barnet förhandsvisar "Rätt" och klär på sig där.
      await tester.tap(find.text('Rätt'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wardrobe_item_item_safari_hat')));
      await tester.pumpAndSettle();

      final equipped = repository.getUserProgress(userId)!.equippedItems;
      expect(
        equipped,
        containsPair('idle_item_safari_hat', 'item_safari_hat'),
        reason: 'Plagget ska hamna i basoutfiten, inte i posen',
      );
      expect(
        equipped.keys.where((key) => key.startsWith('answerCorrect_')),
        isEmpty,
        reason: 'En pose ska aldrig äga ett plagg',
      );
    },
  );

  testWidgets(
    '[Widget] Wardrobe – ett plagg per slot',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const userId = 'wardrobe-slot-user';
      await repository.saveUserProgress(
        const UserProgress(
          userId: userId,
          name: 'Mira',
          ageGroup: AgeGroup.middle,
          unlockedItems: ['item_safari_hat', 'item_hat_pirate'],
        ),
      );
      await repository.setActiveUserId(userId);

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

      await tester.tap(find.byKey(const Key('wardrobe_item_item_safari_hat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wardrobe_item_item_hat_pirate')));
      await tester.pumpAndSettle();

      final equipped = repository.getUserProgress(userId)!.equippedItems;
      expect(
        equipped,
        containsPair('idle_item_hat_pirate', 'item_hat_pirate'),
        reason: 'Den nya hatten ska ta över huvudet',
      );
      expect(
        equipped.containsValue('item_safari_hat'),
        isFalse,
        reason: 'Två hattar får aldrig sitta på samtidigt',
      );
    },
  );

  testWidgets(
    '[Widget] Wardrobe – att trycka på ett plagg tar av det',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const userId = 'wardrobe-remove-user';
      await repository.saveUserProgress(
        const UserProgress(
          userId: userId,
          name: 'Mira',
          ageGroup: AgeGroup.middle,
          unlockedItems: ['item_safari_hat'],
        ),
      );
      await repository.setActiveUserId(userId);

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

      await tester.tap(find.byKey(const Key('wardrobe_item_item_safari_hat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('wardrobe_item_item_safari_hat')));
      await tester.pumpAndSettle();

      expect(
        repository.getUserProgress(userId)!.equippedItems,
        isEmpty,
        reason: 'Av betyder av, oavsett pose',
      );
    },
  );
  testWidgets(
    '[Widget] Wardrobe – Slumpa klär på barnet med ett tryck',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const userId = 'wardrobe-shuffle-user';
      const unlocked = ['item_safari_hat', 'item_hat_pirate', 'item_glasses_nerd'];
      await repository.saveUserProgress(
        const UserProgress(
          userId: userId,
          name: 'Mira',
          ageGroup: AgeGroup.middle,
          unlockedItems: unlocked,
        ),
      );
      await repository.setActiveUserId(userId);

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
        find.byKey(const Key('wardrobe_randomize')),
      );

      await tester.tap(find.byKey(const Key('wardrobe_randomize')));
      await tester.pumpAndSettle();

      final equipped = repository.getUserProgress(userId)!.equippedItems;
      expect(equipped, isNotEmpty);
      expect(
        equipped.keys.every((key) => key.startsWith('idle_')),
        isTrue,
        reason: 'Slumpade plagg ska hamna i basoutfiten',
      );
      // OBS: garderoben släpper igenom allt i debug-bygget (kDebugMode), så
      // testet kan inte kräva att bara upplåsta plagg valts. Regeln testas i
      // stället i outfit_shuffler_test.dart. Här kontrolleras att knappen
      // verkligen ger en komplett outfit utan dubbletter i samma slot.
      expect(
        equipped.values.toSet().length,
        equipped.length,
        reason: 'Inga dubbletter',
      );
      expect(
        equipped.values.where((id) => id.contains('hat')).length,
        1,
        reason: 'Högst en hatt',
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
