import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
    await repository.clearAllData();
  });

  testWidgets('[Widget] föräldern ser vad starten ställer in', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 1600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await repository.saveUserProgress(
      const UserProgress(
        userId: 'ny',
        name: 'Ny',
        ageGroup: AgeGroup.young,
      ),
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          child: MaterialApp(home: OnboardingScreen(userId: 'ny')),
        ),
      ),
    );
    // Inte pumpAndSettle: bakgrunden animerar oavbrutet.
    await pumpUntilFound(
      tester,
      find.text('Starta'),
      timeout: const Duration(seconds: 8),
    );

    // Inget val än: planen säger att vi börjar försiktigt, inte att vi vet.
    expect(
      find.text('Årskurs 1 – vi börjar försiktigt · plusraketer, '
          'minusgrottor'),
      findsOneWidget,
    );

    await tester.tap(find.text('Åk 3'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('Årskurs 3 · plusraketer, minusgrottor, gånger-djungeln, '
          'delat-isbanan'),
      findsOneWidget,
    );
    expect(find.textContaining('Allt kan ändras i Föräldraläge.'),
        findsOneWidget);
    // Knappen är kvar och heter fortfarande Starta.
    expect(find.text('Starta'), findsOneWidget);
  });
}
