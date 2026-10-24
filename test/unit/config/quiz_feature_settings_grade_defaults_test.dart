import 'package:flutter_test/flutter_test.dart';
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
  });
}
