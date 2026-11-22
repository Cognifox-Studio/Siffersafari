import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/config/quiz_feature_settings.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] QuizFeatureSettings grade defaults (#68)', () {
    late InMemoryLocalStorageRepository repository;

    setUp(() async {
      repository = await setupWidgetTestDependencies();
      await repository.clearAllData();
    });

    test('Åk 1 defaults word problems and missing-number off', () async {
      await repository.saveUserProgress(
        const UserProgress(
          userId: 'u1',
          name: 'Mira',
          ageGroup: AgeGroup.young,
          gradeLevel: 1,
        ),
      );

      expect(
        QuizFeatureSettings.defaultWordProblemsEnabled(
          repository: repository,
          userId: 'u1',
        ),
        isFalse,
      );
      expect(
        QuizFeatureSettings.defaultMissingNumberEnabled(
          repository: repository,
          userId: 'u1',
        ),
        isFalse,
      );
      expect(
        QuizFeatureSettings.readMissingNumberEnabled(
          repository: repository,
          userId: 'u1',
        ),
        isFalse,
      );
    });

    // Uppläsning är inte en inställning för Åk 1–2, det är deras väg till
    // frågan: en sexåring som inte kan läsa textuppgiften har ingen nytta av en
    // brytare som ligger i föräldradashboarden och är av som standard.
    test('Uppläsning är på som standard för Åk 1–2', () async {
      await repository.saveUserProgress(
        const UserProgress(
          userId: 'u2',
          name: 'Loke',
          ageGroup: AgeGroup.young,
          gradeLevel: 2,
        ),
      );

      expect(
        QuizFeatureSettings.readTextToSpeechPreference(
          repository: repository,
          userId: 'u2',
        ),
        isNull,
        reason: 'Ingen har valt något än, och det måste gå att skilja från "av"',
      );
      expect(
        QuizFeatureSettings.readTextToSpeechEnabled(
          repository: repository,
          userId: 'u2',
        ),
        isTrue,
      );
    });

    test('Uppläsning är av som standard från Åk 3', () async {
      await repository.saveUserProgress(
        const UserProgress(
          userId: 'u3',
          name: 'Aya',
          ageGroup: AgeGroup.middle,
          gradeLevel: 5,
        ),
      );

      expect(
        QuizFeatureSettings.readTextToSpeechEnabled(
          repository: repository,
          userId: 'u3',
        ),
        isFalse,
      );
    });

    test('Ett uttryckligt nej från en förälder vinner över Åk 1–2', () async {
      await repository.saveUserProgress(
        const UserProgress(
          userId: 'u4',
          name: 'Signe',
          ageGroup: AgeGroup.young,
          gradeLevel: 1,
        ),
      );
      await repository.saveSetting(
        SettingsKeys.textToSpeechEnabled('u4'),
        false,
      );

      expect(
        QuizFeatureSettings.readTextToSpeechPreference(
          repository: repository,
          userId: 'u4',
        ),
        isFalse,
      );
      expect(
        QuizFeatureSettings.readTextToSpeechEnabled(
          repository: repository,
          userId: 'u4',
        ),
        isFalse,
      );
    });

    test('Ett uttryckligt ja gäller även för högre åk', () async {
      await repository.saveUserProgress(
        const UserProgress(
          userId: 'u5',
          name: 'Noa',
          ageGroup: AgeGroup.older,
          gradeLevel: 7,
        ),
      );
      await repository.saveSetting(
        SettingsKeys.textToSpeechEnabled('u5'),
        true,
      );

      expect(
        QuizFeatureSettings.readTextToSpeechEnabled(
          repository: repository,
          userId: 'u5',
        ),
        isTrue,
      );
    });
  });
}
