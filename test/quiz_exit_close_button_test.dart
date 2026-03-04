import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_game_app/core/constants/app_constants.dart';
import 'package:math_game_app/core/di/injection.dart';
import 'package:math_game_app/core/services/audio_service.dart';
import 'package:math_game_app/core/services/question_generator_service.dart';
import 'package:math_game_app/data/repositories/local_storage_repository.dart';
import 'package:math_game_app/domain/entities/question.dart';
import 'package:math_game_app/domain/entities/user_progress.dart';
import 'package:math_game_app/domain/enums/age_group.dart';
import 'package:math_game_app/domain/enums/difficulty_level.dart';
import 'package:math_game_app/domain/enums/operation_type.dart';
import 'package:math_game_app/main.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioService extends Mock implements AudioService {}

class _InMemoryLocalStorageRepository extends LocalStorageRepository {
  final Map<String, UserProgress> _users = {};
  final Map<String, dynamic> _settings = {};
  final Map<String, Map<String, dynamic>> _quizHistory = {};

  @override
  Future<void> saveUserProgress(UserProgress progress) async {
    _users[progress.userId] = progress;
  }

  @override
  UserProgress? getUserProgress(String userId) {
    return _users[userId];
  }

  @override
  List<UserProgress> getAllUserProfiles() {
    return _users.values.toList();
  }

  @override
  Future<void> deleteUserProgress(String userId) async {
    _users.remove(userId);
  }

  @override
  Future<void> saveQuizSession(Map<String, dynamic> session) async {
    final sessionId = session['sessionId'] as String;
    _quizHistory[sessionId] = session;
  }

  @override
  Future<void> deleteQuizSession(String sessionId) async {
    _quizHistory.remove(sessionId);
  }

  @override
  Future<void> purgeInProgressQuizSessions({
    required String userId,
    required String operationTypeName,
    String? exceptSessionId,
  }) async {
    final keys = _quizHistory.keys.toList(growable: false);
    for (final key in keys) {
      final session = _quizHistory[key];
      if (session == null) continue;

      if (exceptSessionId != null && session['sessionId'] == exceptSessionId) {
        continue;
      }

      if (session['userId'] != userId) continue;
      if (session['operationType'] != operationTypeName) continue;
      if (session['isComplete'] != false) continue;

      _quizHistory.remove(key);
    }
  }

  @override
  List<Map<String, dynamic>> getQuizHistory(String userId, {int? limit}) {
    final allSessions = _quizHistory.values
        .where((session) => session['userId'] == userId)
        .toList();

    allSessions.sort((a, b) {
      final dateA = DateTime.parse(a['startTime'] as String);
      final dateB = DateTime.parse(b['startTime'] as String);
      return dateB.compareTo(dateA);
    });

    return limit != null ? allSessions.take(limit).toList() : allSessions;
  }

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    _settings[key] = value;
  }

  @override
  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settings.containsKey(key) ? _settings[key] : defaultValue;
  }

  @override
  Future<void> deleteSetting(String key) async {
    _settings.remove(key);
  }

  @override
  Future<void> clearAllData() async {
    _users.clear();
    _settings.clear();
    _quizHistory.clear();
  }
}

class _FakeQuestionGeneratorService extends QuestionGeneratorService {
  static const Question question = Question(
    id: 'q1',
    operationType: OperationType.multiplication,
    difficulty: DifficultyLevel.easy,
    operand1: 6,
    operand2: 7,
    correctAnswer: 42,
    wrongAnswers: [41, 43, 40],
    explanation: '6 × 7 = 42',
  );

  @override
  List<Question> generateQuestions({
    required AgeGroup ageGroup,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    required int count,
    Map<OperationType, int>? difficultyStepsByOperation,
    int? difficultyStep,
    int? gradeLevel,
  }) {
    return const [question];
  }

  @override
  Question generateQuestion({
    required AgeGroup ageGroup,
    required OperationType operationType,
    required DifficultyLevel difficulty,
    Map<OperationType, int>? difficultyStepsByOperation,
    int? difficultyStep,
    int? gradeLevel,
    bool? wordProblemsEnabledOverride,
    double? wordProblemsChanceOverride,
    bool? missingNumberEnabledOverride,
    double? missingNumberChanceOverride,
  }) {
    return question;
  }
}

void main() {
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    final steps = (duration.inMilliseconds / 50).ceil().clamp(1, 200);
    for (var i = 0; i < steps; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final steps = (timeout.inMilliseconds / 50).ceil().clamp(1, 400);
    for (var i = 0; i < steps; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  late _InMemoryLocalStorageRepository repository;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    await getIt.reset();

    repository = _InMemoryLocalStorageRepository();
    getIt.registerSingleton<LocalStorageRepository>(repository);

    final audio = _MockAudioService();
    when(() => audio.playCorrectSound()).thenAnswer((_) async {});
    when(() => audio.playWrongSound()).thenAnswer((_) async {});
    when(() => audio.playCelebrationSound()).thenAnswer((_) async {});
    when(() => audio.playClickSound()).thenAnswer((_) async {});
    when(() => audio.playMusic()).thenAnswer((_) async {});
    when(() => audio.stopMusic()).thenAnswer((_) async {});
    getIt.registerSingleton<AudioService>(audio);

    getIt.registerSingleton<QuestionGeneratorService>(
      _FakeQuestionGeneratorService(),
    );

    await initializeDependencies(initializeHive: false);
  });

  testWidgets(
    'Widget (Quiz): X-knappen kan stänga quiz utan crash',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting('onboarding_done_$userId', true);

      await tester.pumpWidget(
        ProviderScope(
          child: MathGameApp(initFuture: Future.value(null)),
        ),
      );

      final multiplication =
          find.byKey(const Key('operation_card_multiplication'));
      await pumpUntilFound(tester, multiplication);
      expect(multiplication, findsOneWidget);

      await tester.ensureVisible(multiplication);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tester.tap(multiplication);
      await pumpUntilFound(tester, find.textContaining('Fråga'));
      expect(find.textContaining('Fråga'), findsOneWidget);

      // Exit immediately.
      final closeInAppBar = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.close),
      );
      expect(closeInAppBar, findsOneWidget);
      await tester.tap(closeInAppBar);
      await pumpFor(tester, const Duration(milliseconds: 400));

      // Should be back on Home.
      await pumpUntilFound(tester, find.text(AppConstants.appName));
      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Widget (Quiz): svar + X snabbt ger ingen exception',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await repository.clearAllData();

      const userId = 'test-user';
      const user = UserProgress(
        userId: userId,
        name: 'Test',
        ageGroup: AgeGroup.middle,
      );
      await repository.saveUserProgress(user);
      await repository.saveSetting('onboarding_done_$userId', true);

      await tester.pumpWidget(
        ProviderScope(
          child: MathGameApp(initFuture: Future.value(null)),
        ),
      );

      final multiplication =
          find.byKey(const Key('operation_card_multiplication'));
      await pumpUntilFound(tester, multiplication);

      await tester.ensureVisible(multiplication);
      await tester.pump();
      await pumpFor(
        tester,
        AppConstants.mediumAnimationDuration +
            const Duration(milliseconds: 150),
      );
      await tester.tap(multiplication);
      await pumpUntilFound(tester, find.textContaining('Fråga'));

      // Tap an answer and immediately tap X.
      await tester.tap(find.text('42'));
      final closeInAppBar = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.close),
      );
      expect(closeInAppBar, findsOneWidget);
      await tester.tap(closeInAppBar);
      await pumpFor(tester, const Duration(milliseconds: 500));

      await pumpUntilFound(tester, find.text(AppConstants.appName));
      expect(tester.takeException(), isNull);
    },
  );
}
