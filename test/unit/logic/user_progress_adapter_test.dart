import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/app_theme.dart';

void main() {
  group('[Unit] UserProgressAdapter', () {
    test('läser legacy-profiler utan nyare fält med defaultvärden', () {
      final adapter = UserProgressAdapter();
      final reader = _FakeBinaryReader(
        byteValues: [3, 0, 1, 2],
        values: ['legacy-user', 'Lisa', AgeGroup.middle],
      );

      final progress = adapter.read(reader);

      expect(progress.userId, 'legacy-user');
      expect(progress.name, 'Lisa');
      expect(progress.ageGroup, AgeGroup.middle);
      expect(progress.avatarEmoji, '🧒');
      expect(progress.gradeLevel, isNull);
      expect(progress.totalQuizzesTaken, 0);
      expect(progress.totalQuestionsAnswered, 0);
      expect(progress.totalCorrectAnswers, 0);
      expect(progress.currentStreak, 0);
      expect(progress.longestStreak, 0);
      expect(progress.totalPoints, 0);
      expect(progress.selectedTheme, AppTheme.jungle);
      expect(progress.soundEnabled, isTrue);
      expect(progress.musicEnabled, isTrue);
      expect(progress.timerEnabled, isFalse);
      expect(progress.lastSessionDate, isNull);
      expect(progress.unlockedThemes, const [AppTheme.jungle]);
      expect(progress.achievements, isEmpty);
      expect(progress.masteryLevels, isEmpty);
      expect(progress.operationDifficultySteps, isEmpty);
      expect(progress.selectedCharacterId, 'mascot');
    });
  });
}

class _FakeBinaryReader implements BinaryReader {
  _FakeBinaryReader({
    required List<int> byteValues,
    required List<Object?> values,
  })  : _byteValues = Queue<int>.from(byteValues),
        _values = Queue<Object?>.from(values);

  final Queue<int> _byteValues;
  final Queue<Object?> _values;

  @override
  dynamic read([int? byteCount]) => _values.removeFirst();

  @override
  int readByte() => _byteValues.removeFirst();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
