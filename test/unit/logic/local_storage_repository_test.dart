import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';

void main() {
  group('[Unit] LocalStorageRepository', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'siffersafari_local_storage_repo_',
      );
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'clearAllData öppnar quiz_history defensivt när boxen ännu inte är öppnad',
      () async {
        await Hive.openBox<dynamic>(AppConstants.userProgressBox);
        await Hive.openBox<dynamic>(AppConstants.settingsBox);
        expect(Hive.isBoxOpen(AppConstants.quizHistoryBox), isFalse);

        final repository = LocalStorageRepository();

        await expectLater(repository.clearAllData(), completes);

        expect(Hive.isBoxOpen(AppConstants.userProgressBox), isTrue);
        expect(Hive.isBoxOpen(AppConstants.settingsBox), isTrue);
        expect(Hive.isBoxOpen(AppConstants.quizHistoryBox), isTrue);
        expect(Hive.box<dynamic>(AppConstants.userProgressBox).isEmpty, isTrue);
        expect(Hive.box<dynamic>(AppConstants.settingsBox).isEmpty, isTrue);
        expect(Hive.box<dynamic>(AppConstants.quizHistoryBox).isEmpty, isTrue);
      },
    );
  });
}
