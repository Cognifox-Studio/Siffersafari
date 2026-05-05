import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siffersafari/core/services/achievement_service.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/core/services/quest_progression_service.dart';
import 'package:siffersafari/core/services/question_generator_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/mastery_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/adaptive_difficulty_service.dart';
import 'package:siffersafari/domain/services/feedback_service.dart';
import 'package:siffersafari/domain/services/parent_pin_service.dart';

final getIt = GetIt.instance;

void _perf(String name, void Function() fn) {
  if (!kProfileMode) {
    fn();
    return;
  }

  final sw = Stopwatch()..start();
  try {
    fn();
  } finally {
    sw.stop();
    debugPrint('[PERF] $name: ${sw.elapsedMilliseconds}ms');
  }
}

Future<T> _perfAsync<T>(String name, Future<T> Function() fn) async {
  if (!kProfileMode) return fn();

  final sw = Stopwatch()..start();
  try {
    return await fn();
  } finally {
    sw.stop();
    debugPrint('[PERF] $name: ${sw.elapsedMilliseconds}ms');
  }
}

/// Generic helper to drastically reduce duplicate registration logic
void _registerLazy<T extends Object>(T Function() factoryFunc) {
  if (!getIt.isRegistered<T>()) {
    _perf('getIt.register($T)', () {
      getIt.registerLazySingleton<T>(factoryFunc);
    });
  }
}

/// Initialize all dependencies
Future<void> initializeDependencies({
  bool initializeHive = true,
  bool openQuizHistoryBox = true,
}) async {
  final total = kProfileMode ? (Stopwatch()..start()) : null;

  // Initialize Hive boxes
  if (initializeHive) {
    await _perfAsync(
      'initializeDependencies._initializeHive(openQuizHistoryBox: $openQuizHistoryBox)',
      () => _initializeHive(openQuizHistoryBox: openQuizHistoryBox),
    );
  }

  // Register repositories
  _registerLazy<LocalStorageRepository>(() => LocalStorageRepository());

  // Register services
  _registerLazy<QuestionGeneratorService>(() => QuestionGeneratorService());
  _registerLazy<AudioService>(() => AudioService());
  _registerLazy<AdaptiveDifficultyService>(() => AdaptiveDifficultyService());
  _registerLazy<QuestProgressionService>(() => const QuestProgressionService());
  _registerLazy<FeedbackService>(() => FeedbackService());
  _registerLazy<AchievementService>(() => AchievementService());
  _registerLazy<ParentPinService>(
      () => ParentPinService(getIt<LocalStorageRepository>()),);

  if (total != null) {
    total.stop();
    debugPrint(
      '[PERF] initializeDependencies total: ${total.elapsedMilliseconds}ms',
    );
  }
}

Future<void> _initializeHive({required bool openQuizHistoryBox}) async {
  // Register adapters
  // Register enum adapters first (used inside UserProgress)
  _perf('Hive.registerAdapter(enums + UserProgress)', () {
    _registerHiveAdapter(AgeGroupAdapter());
    _registerHiveAdapter(OperationTypeAdapter());
    _registerHiveAdapter(DifficultyLevelAdapter());
    _registerHiveAdapter(AppThemeAdapter());
    _registerHiveAdapter(MasteryLevelAdapter());
    _registerHiveAdapter(UserProgressAdapter());
  });

  // Open boxes concurrently
  final openFutures = <Future<void>>[
    _perfAsync(
        "Hive.openBox('user_progress')", () => Hive.openBox('user_progress'),),
    _perfAsync("Hive.openBox('settings')", () => Hive.openBox('settings')),
    if (openQuizHistoryBox)
      _perfAsync(
          "Hive.openBox('quiz_history')", () => Hive.openBox('quiz_history'),),
  ];

  await _perfAsync(
      'Hive.openBox(all required)', () => Future.wait(openFutures),);
}

void _registerHiveAdapter<T>(TypeAdapter<T> adapter) {
  if (Hive.isAdapterRegistered(adapter.typeId)) return;
  Hive.registerAdapter(adapter);
}
