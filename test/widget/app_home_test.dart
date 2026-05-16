import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/features/quiz/presentation/widgets/question_card.dart';
import 'package:siffersafari/main.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

import '../test_utils.dart';

void main() {
  late InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    repository = await setupWidgetTestDependencies();
  });

  testWidgets(
    '[Widget] App home – displays title',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.text('Skapa profil'),
        timeout: const Duration(seconds: 8),
      );

      final titleFinder = find.text(AppConstants.appName);
      if (titleFinder.evaluate().isEmpty) {
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? t.textSpan?.toPlainText())
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        fail(
          'Kunde inte hitta app-titeln "${AppConstants.appName}". '
          'Tillgängliga texter: ${texts.take(80).toList()}',
        );
      }

      expect(titleFinder, findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] App home – profile selector with multiple profiles',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const user1 = UserProgress(
        userId: 'u1',
        name: 'Alex',
        ageGroup: AgeGroup.middle,
        avatarEmoji: '🐯',
      );
      const user2 = UserProgress(
        userId: 'u2',
        name: 'Sam',
        ageGroup: AgeGroup.middle,
        avatarEmoji: '🦊',
      );
      await repository.saveUserProgress(user1);
      await repository.saveUserProgress(user2);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(tester, find.text('Välj spelare'));

      expect(find.text('Välj spelare'), findsOneWidget);
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Sam'), findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] App home – visar enklare hero för aktiv profil',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'review-user';
      const user = UserProgress(
        userId: userId,
        name: 'Nora',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('primary_play_button')),
      );

      expect(find.textContaining('Repetitioner redo:'), findsNothing);
      expect(find.text('Välj räknesätt'), findsOneWidget);
      expect(find.text('🎮 Mer spel'), findsNothing);
    },
  );

  testWidgets(
    '[Widget] App home – visar storystyrd primarknapp for aktiv profil',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'primary-play-user';
      const user = UserProgress(
        userId: userId,
        name: 'Milo',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('primary_play_button')),
      );

      expect(find.byKey(const Key('primary_play_button')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('primary_play_button')),
          matching: find.text('Spela nästa stopp'),
        ),
        findsOneWidget,
      );
      expect(find.text('Uppdrag: Hämta rep'), findsWidgets);
      expect(
        find.text('Lös talen så hittar vi rep till bron.'),
        findsWidgets,
      );
    },
  );

  testWidgets(
    '[Widget] App home – visar upplast camp-objekt for aktiv profil',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'camp-user';
      const user = UserProgress(
        userId: userId,
        name: 'Iris',
        ageGroup: AgeGroup.middle,
        unlockedItems: ['item_safari_hat'],
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('camp_scene_view')),
      );

      expect(find.byKey(const Key('camp_scene_cabin')), findsOneWidget);
      expect(find.byKey(const Key('camp_scene_campfire')), findsOneWidget);
      expect(
        find.byKey(const Key('camp_scene_pet_placeholder')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('camp_scene_prop_item_safari_hat')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('camp_scene_collection_badge')),
        findsOneWidget,
      );
      expect(find.text('1 sak'), findsOneWidget);
      expect(find.textContaining('Placeholder'), findsNothing);
    },
  );

  testWidgets(
    '[Widget] App home – visar enkelt badgealbum for aktiv profil',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'badge-user';
      const user = UserProgress(
        userId: userId,
        name: 'Svea',
        ageGroup: AgeGroup.middle,
        achievements: [AppConstants.firstQuizAchievement],
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('home_badge_album')),
      );

      expect(find.byKey(const Key('home_badge_album')), findsOneWidget);
      expect(find.text('Märken'), findsOneWidget);
      expect(find.text('1 av 5'), findsOneWidget);
      expect(
        find.byKey(
          const Key('home_badge_icon_${AppConstants.firstQuizAchievement}'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'home_badge_locked_${AppConstants.perfectScoreAchievement}',
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '[Widget] App home – visar upplast foljeslagare i campet',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'pet-user';
      const user = UserProgress(
        userId: userId,
        name: 'Tage',
        ageGroup: AgeGroup.middle,
        unlockedItems: ['item_pet_zebra_companion'],
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('camp_scene_pet_slot')),
      );

      expect(find.byKey(const Key('camp_scene_pet_slot')), findsOneWidget);
      expect(
        find.byKey(const Key('camp_scene_pet_item_pet_zebra_companion')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('camp_scene_pet_placeholder')), findsNothing);
    },
  );

  testWidgets(
    '[Widget] App home – visar fler camp-objekt utan att dubbla pet som prop',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'camp-polish-user';
      const user = UserProgress(
        userId: userId,
        name: 'Nils',
        ageGroup: AgeGroup.middle,
        unlockedItems: [
          'item_safari_hat',
          'item_hat_safari',
          'item_binoculars_safari',
          'item_pet_zebra_companion',
        ],
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('camp_scene_view')),
      );

      expect(
        find.byKey(const Key('camp_scene_prop_item_safari_hat')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('camp_scene_prop_item_hat_safari')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('camp_scene_prop_item_binoculars_safari')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('camp_scene_pet_item_pet_zebra_companion')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('camp_scene_prop_item_pet_zebra_companion')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('camp_scene_collection_badge')),
        findsOneWidget,
      );
      expect(find.text('4 saker'), findsOneWidget);
      expect(
        find.byKey(const Key('camp_scene_collection_hidden_count')),
        findsNothing,
      );
    },
  );

  testWidgets(
    '[Widget] App home – visar nar campet har fler saker an som syns',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'camp-overflow-user';
      const user = UserProgress(
        userId: userId,
        name: 'Alva',
        ageGroup: AgeGroup.middle,
        unlockedItems: [
          'item_safari_hat',
          'item_hat_safari',
          'item_binoculars_safari',
          'item_compass_safari',
          'item_map_safari',
        ],
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('camp_scene_collection_badge')),
      );

      expect(find.text('5 saker'), findsOneWidget);
      expect(find.text('+1 till'), findsOneWidget);
      expect(
        find.byKey(const Key('camp_scene_collection_hidden_count')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    '[Widget] App home – visar fortsätt när sparad quizsession finns',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'resume-user';
      const user = UserProgress(
        userId: userId,
        name: 'Mira',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);
      await repository.saveQuizSession({
        'sessionId': repository.inProgressQuizSessionId(
          userId: userId,
          operationTypeName: OperationType.addition.name,
        ),
        'userId': userId,
        'operationType': OperationType.addition.name,
        'difficulty': DifficultyLevel.easy.name,
        'questions': const [
          {
            'id': 'q_resume',
            'operationType': 'addition',
            'difficulty': 'easy',
            'operand1': 2,
            'operand2': 3,
            'correctAnswer': 5,
            'wrongAnswers': [4, 6, 7],
            'explanation': '2 + 3 = 5',
          },
        ],
        'targetQuestionCount': 1,
        'totalQuestions': 0,
        'wordProblemsEnabled': true,
        'missingNumberEnabled': true,
        'difficultyStepsByOperation': const {'addition': 4},
        'currentQuestionIndex': 0,
        'correctAnswers': 0,
        'wrongAnswers': 0,
        'totalPoints': 0,
        'successRate': 0.0,
        'startTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'endTime': DateTime(2026, 5, 12, 11).toIso8601String(),
        'answers': const <String, int>{},
        'responseTimes': const <String, int>{},
        'isComplete': false,
        'ageGroup': AgeGroup.middle.name,
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('primary_play_button')),
      );

      expect(find.text('Fortsätt'), findsOneWidget);

      await tester.tap(find.byKey(const Key('primary_play_button')));
      await tester.pump();
      await pumpUntilFound(tester, find.byType(QuestionCard));

      expect(find.byType(QuestionCard), findsOneWidget);
    },
  );

  testWidgets(
    '[Widget] App home – skickar custom item offsets till maskoten',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'offset-user';
      const savedOffsets = {
        'item_safari_hat_idle': 'n,0.0,-0.42,1.0,0.0',
      };
      const user = UserProgress(
        userId: userId,
        name: 'Lova',
        ageGroup: AgeGroup.middle,
        equippedItems: {
          'head': 'item_safari_hat',
        },
        customItemOffsets: savedOffsets,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(
        tester,
        find.byKey(const Key('primary_play_button')),
      );

      final mascot = tester.widget<GameCharacter>(find.byType(GameCharacter));

      expect(mascot.equippedItems, containsPair('head', 'item_safari_hat'));
      expect(
        mascot.customItemOffsets,
        containsPair('item_safari_hat_idle', 'n,0.0,-0.42,1.0,0.0'),
      );
    },
  );

  testWidgets(
    '[Widget] App home – can open story map',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'story-user';
      const user = UserProgress(
        userId: userId,
        name: 'Saga',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting(SettingsKeys.onboardingDone(userId), true);

      await tester.pumpWidget(
        const ProviderScope(
          child: SiffersafariApp(initError: null),
        ),
      );

      await pumpUntilFound(tester, find.text('Öppna kartan'));

      expect(find.text('Öppna kartan'), findsOneWidget);
      expect(
        find.byKey(const Key('home_story_next_biome_chip')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('home_story_next_biome_chip')),
          matching: find.text('Nattskogen'),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Öppna kartan'));
      await tester.tap(find.text('Öppna kartan'));
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.pageTransitionSlow + const Duration(milliseconds: 150),
      );

      expect(find.text('Djungelkartan'), findsAtLeastNWidgets(1));
      expect(find.text('Akt 1 av 3'), findsWidgets);
      expect(find.text('Resten av stigen'), findsOneWidget);
      expect(
        find.byKey(const Key('story_map_next_biome_chip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('story_map_locked_biome_teaser')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('story_map_locked_biome_teaser')),
          matching: find.text('Nattskogen'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('story_map_locked_biome_chip')),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Resten av stigen'));
      await tester.tap(find.text('Resten av stigen'));
      await tester.pump();

      expect(
        find.byKey(const Key('story_map_locked_biome_preview')),
        findsOneWidget,
      );
      expect(find.text('Efter djungeln'), findsOneWidget);

      await tester.ensureVisible(find.text('Spela nästa stopp'));
      await tester.tap(find.text('Spela nästa stopp'));
      await pumpUntilFound(tester, find.byType(QuestionCard));

      expect(find.byType(QuestionCard), findsOneWidget);
    },
  );
}
