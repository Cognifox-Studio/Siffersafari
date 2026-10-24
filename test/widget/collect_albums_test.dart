import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/achievement_service_provider.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/features/home/presentation/widgets/camp_collection_album.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_badge_album.dart';

void main() {
  Future<void> pumpAlbum(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          achievementServiceProvider.overrideWithValue(AchievementService()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            home: Scaffold(body: child),
          ),
        ),
      ),
    );
  }

  testWidgets('HomeBadgeAlbum shows count and locked tip (#98)', (tester) async {
    final total = AchievementService().albumEntries.length;
    await pumpAlbum(
      tester,
      HomeBadgeAlbum(
        achievementIds: const [AppConstants.firstQuizAchievement],
      ),
    );

    expect(find.byKey(const Key('home_badge_album')), findsOneWidget);
    expect(find.text('1 av $total'), findsOneWidget);
    expect(find.text('Tryck på låsta för tips.'), findsOneWidget);
    expect(
      find.byKey(
        const Key('home_badge_icon_${AppConstants.firstQuizAchievement}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('CampCollectionAlbumDialog shows souvenir progress (#98)',
      (tester) async {
    final total = InventoryConfig.campSouvenirItems.length;
    await pumpAlbum(
      tester,
      CampCollectionAlbumDialog(
        unlockedItemIds: const ['item_camp_fruit_glade'],
      ),
    );

    expect(find.byKey(const Key('camp_collection_album')), findsOneWidget);
    expect(find.text('Campet'), findsOneWidget);
    expect(find.text('1 av $total'), findsOneWidget);
    expect(find.text('Fler väntar.'), findsOneWidget);
  });
}
