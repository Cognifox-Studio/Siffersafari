part of 'question_generator_service.dart';

mixin _QuestionGeneratorServiceHelpers {
  Random get _random;

  int _randomInRange(DifficultyNumberRange range) {
    return range.min + _random.nextInt(range.max - range.min + 1);
  }

  int _randomSignedValue(int maxAbs, {int minAbs = 0}) {
    final safeMaxAbs = max(1, maxAbs);
    final safeMinAbs = max(0, min(minAbs, safeMaxAbs));
    final value = safeMinAbs + _random.nextInt(safeMaxAbs - safeMinAbs + 1);
    return _random.nextBool() ? value : -value;
  }

  int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x == 0 ? 1 : x;
  }

  bool _hasCarry(int a, int b) {
    var x = a;
    var y = b;
    while (x > 0 || y > 0) {
      if ((x % 10) + (y % 10) >= 10) return true;
      x ~/= 10;
      y ~/= 10;
    }
    return false;
  }

  bool _hasBorrow(int a, int b) {
    var x = a;
    var y = b;
    var borrow = 0;

    while (x > 0 || y > 0) {
      final da = (x % 10) - borrow;
      final db = y % 10;
      if (da < db) return true;
      borrow = da < db ? 1 : 0;
      x ~/= 10;
      y ~/= 10;
    }

    return false;
  }

  List<int> _sortedCopy(List<int> values) {
    final copy = List<int>.from(values);
    copy.sort();
    return copy;
  }

  List<int> _generateWrongPercentAnswers(int correctPercent, int count) {
    final wrong = <int>{};
    final correct = correctPercent.clamp(0, 100);

    final deltas = <int>[
      -50,
      -40,
      -30,
      -25,
      -20,
      -15,
      -10,
      -5,
      5,
      10,
      15,
      20,
      25,
      30,
      40,
      50,
    ];

    for (var i = 0; i < 200 && wrong.length < count; i++) {
      final delta = deltas[_random.nextInt(deltas.length)];
      final candidate = (correct + delta).clamp(0, 100);
      if (candidate == correct) continue;
      wrong.add(candidate);
    }

    var cursor = 0;
    while (wrong.length < count) {
      final candidate = (cursor * 10).clamp(0, 100);
      cursor++;
      if (candidate == correct) continue;
      wrong.add(candidate);
    }

    return wrong.take(count).toList();
  }
}
