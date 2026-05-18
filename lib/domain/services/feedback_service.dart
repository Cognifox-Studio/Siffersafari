import '../entities/question.dart';
import '../enums/age_group.dart';
import '../enums/operation_type.dart';

class FeedbackResult {
  const FeedbackResult({
    required this.isCorrect,
    required this.title,
    required this.message,
    this.comboMultiplier = 1.0,
    this.numberLine,
    this.groupModel,
  });

  final bool isCorrect;
  final String title;
  final String message;

  /// Combo multiplier applied to points for this answer (1.0 = no combo).
  final double comboMultiplier;

  final FeedbackNumberLine? numberLine;
  final FeedbackGroupModel? groupModel;
}

class FeedbackNumberLine {
  const FeedbackNumberLine({
    required this.start,
    required this.jump,
    required this.end,
    required this.operationType,
  });

  final int start;
  final int jump;
  final int end;
  final OperationType operationType;

  bool get isSubtraction => operationType == OperationType.subtraction;

  String get jumpLabel => isSubtraction ? '-$jump' : '+$jump';

  int get leftValue => start <= end ? start : end;

  int get rightValue => start <= end ? end : start;

  bool get startOnLeft => start <= end;
}

class FeedbackGroupModel {
  const FeedbackGroupModel({
    required this.operationType,
    required this.groupCount,
    required this.groupValue,
    required this.totalValue,
  });

  final OperationType operationType;
  final int groupCount;
  final int groupValue;
  final int totalValue;

  bool get isDivision => operationType == OperationType.division;

  String get summaryLabel => isDivision
      ? '$groupValue i varje grupp'
      : '$groupCount grupper med $groupValue';

  String get semanticsLabel => isDivision
      ? 'Bildstöd. $totalValue delat i $groupCount lika grupper. $groupValue i varje.'
      : 'Bildstöd. $groupCount grupper med $groupValue i varje. Tillsammans $totalValue.';
}

/// Generates contextual feedback messages for quiz answers.
///
/// Produces age-appropriate feedback including:
/// - Correct/incorrect title and explanation
/// - Points earned and bonus indicators
/// - Streak notifications
/// - Mathematical explanations (for incorrect answers)
class FeedbackService {
  static const Duration _slowResponseTipThreshold = Duration(seconds: 8);

  /// Builds a feedback result for a user's answer.
  ///
  /// Generates age-appropriate messages based on:
  /// - Whether the answer is correct
  /// - Points earned and speed bonus status
  /// - Current correct streak
  /// - Question explanation (if available)
  ///
  /// Returns a [FeedbackResult] with title, message, and correctness flag.
  FeedbackResult buildFeedback({
    required Question question,
    required int userAnswer,
    required AgeGroup ageGroup,
    int? pointsEarned,
    bool? gotSpeedBonus,
    int? correctStreak,
    Duration? responseTime,
    double comboMultiplier = 1.0,
  }) {
    final isCorrect = question.isCorrect(userAnswer);
    final correct = question.correctAnswer;
    final hint = question.explanation?.trim();

    final safePointsEarned = pointsEarned ?? 0;
    final safeGotSpeedBonus = gotSpeedBonus ?? false;
    final safeCorrectStreak = correctStreak ?? 0;
    final showPedagogicalTip = _shouldShowPedagogicalTip(
      question: question,
      isCorrect: isCorrect,
      responseTime: responseTime,
    );
    final numberLine = showPedagogicalTip ? _buildNumberLine(question) : null;
    final groupModel = showPedagogicalTip ? _buildGroupModel(question) : null;

    if (isCorrect) {
      final message = (hint != null && hint.isNotEmpty)
          ? 'Rätt svar: $correct\n✨ $hint'
          : 'Rätt svar: $correct';
      final pedagogicalTip =
          showPedagogicalTip ? _buildPedagogicalTip(question) : null;

      final metaLines = _buildMetaLines(
        pointsEarned: safePointsEarned,
        gotSpeedBonus: safeGotSpeedBonus,
        correctStreak: safeCorrectStreak,
        wasCorrect: true,
      );

      return FeedbackResult(
        isCorrect: true,
        title: _getPositiveTitle(
          ageGroup,
          seed: question.id,
          gotSpeedBonus: safeGotSpeedBonus,
          correctStreak: safeCorrectStreak,
        ),
        message: _joinLines([
          message,
          if (pedagogicalTip != null) '💡 $pedagogicalTip',
          ...metaLines,
        ]),
        comboMultiplier: comboMultiplier,
        numberLine: numberLine,
        groupModel: groupModel,
      );
    }

    final incorrectMessage = _buildIncorrectMessage(
      question: question,
      userAnswer: userAnswer,
      hint: hint,
      showPedagogicalTip: showPedagogicalTip,
    );

    final metaLines = _buildMetaLines(
      pointsEarned: safePointsEarned,
      gotSpeedBonus: safeGotSpeedBonus,
      correctStreak: safeCorrectStreak,
      wasCorrect: false,
    );

    return FeedbackResult(
      isCorrect: false,
      title: _getEncouragingTitle(ageGroup, seed: question.id),
      message: _joinLines([incorrectMessage, ...metaLines]),
      numberLine: numberLine,
      groupModel: groupModel,
    );
  }

  String _getPositiveTitle(
    AgeGroup ageGroup, {
    required String seed,
    required bool gotSpeedBonus,
    required int correctStreak,
  }) {
    if (gotSpeedBonus) {
      final options = switch (ageGroup) {
        AgeGroup.young => const ['Blixt!', 'Snabbt!', 'ZOOOM!'],
        AgeGroup.middle => const ['Blixt!', 'Snabbt!', 'Raketfart!'],
        AgeGroup.older => const ['Snabbt!', 'Blixt!', 'Raketfart!'],
      };
      return _pick(seed, options);
    }

    if (correctStreak >= 3) {
      final options = switch (ageGroup) {
        AgeGroup.young => const ['I zonen!', 'Snygg svit!', 'Eldsvit!'],
        AgeGroup.middle => const ['I zonen!', 'Snygg svit!', 'Eldsvit!'],
        AgeGroup.older => const ['I zonen!', 'Snygg svit!', 'Stabil svit!'],
      };
      return _pick(seed, options);
    }

    final options = switch (ageGroup) {
      AgeGroup.young => const ['Bra!', 'Woho!', 'Snyggt!'],
      AgeGroup.middle => const ['Bra!', 'Snyggt!', 'Starkt!'],
      AgeGroup.older => const ['Bra!', 'Snyggt!', 'Stabilt!'],
    };
    return _pick(seed, options);
  }

  String _getEncouragingTitle(AgeGroup ageGroup, {required String seed}) {
    final options = switch (ageGroup) {
      AgeGroup.young => const ['Försök igen', 'Nära!', 'Igen!'],
      AgeGroup.middle => const ['Försök igen', 'Nära!', 'Bra försök!'],
      AgeGroup.older => const ['Försök igen', 'Nära!', 'Bra försök!'],
    };
    return _pick(seed, options);
  }

  String _buildIncorrectMessage({
    required Question question,
    required int userAnswer,
    required String? hint,
    required bool showPedagogicalTip,
  }) {
    final correct = question.correctAnswer;
    final hintLine = (hint != null && hint.isNotEmpty)
        ? '💡 $hint'
        : '💡 Titta lugnt en gång till nästa gång.';
    final pedagogicalTip =
        showPedagogicalTip ? _buildPedagogicalTip(question) : null;

    final lines = <String>[
      'Ditt svar: $userAnswer',
      'Rätt svar: $correct',
      hintLine,
    ];

    if (pedagogicalTip != null && pedagogicalTip.trim() != hint?.trim()) {
      lines.add('💡 $pedagogicalTip');
    }

    return _joinLines(lines);
  }

  bool _shouldShowPedagogicalTip({
    required Question question,
    required bool isCorrect,
    required Duration? responseTime,
  }) {
    if (question.operationType != OperationType.addition &&
        question.operationType != OperationType.subtraction &&
        question.operationType != OperationType.multiplication &&
        question.operationType != OperationType.division) {
      return false;
    }

    if (!isCorrect) {
      return true;
    }

    return responseTime != null && responseTime >= _slowResponseTipThreshold;
  }

  String? _buildPedagogicalTip(Question question) {
    switch (question.operationType) {
      case OperationType.addition:
        final larger = question.operand1 >= question.operand2
            ? question.operand1
            : question.operand2;
        final smaller = question.operand1 >= question.operand2
            ? question.operand2
            : question.operand1;

        if (smaller <= 0) {
          return null;
        }

        return 'Börja på $larger och räkna $smaller steg till.';
      case OperationType.subtraction:
        final jump = question.operand2.abs();
        if (jump <= 0) {
          return null;
        }

        return 'Börja på ${question.operand1} och räkna $jump steg tillbaka.';
      case OperationType.multiplication:
        final groupModel = _buildGroupModel(question);
        if (groupModel == null) {
          return null;
        }

        return 'Se det som ${groupModel.groupCount} grupper med ${groupModel.groupValue} i varje.';
      case OperationType.division:
        final groupModel = _buildGroupModel(question);
        if (groupModel == null) {
          return null;
        }

        return 'Dela ${groupModel.totalValue} i ${groupModel.groupCount} lika grupper.';
      default:
        return null;
    }
  }

  FeedbackNumberLine? _buildNumberLine(Question question) {
    switch (question.operationType) {
      case OperationType.addition:
        final start = question.operand1 >= question.operand2
            ? question.operand1
            : question.operand2;
        final jump = question.operand1 >= question.operand2
            ? question.operand2
            : question.operand1;

        if (jump <= 0) {
          return null;
        }

        return FeedbackNumberLine(
          start: start,
          jump: jump,
          end: start + jump,
          operationType: OperationType.addition,
        );
      case OperationType.subtraction:
        final jump = question.operand2.abs();
        if (jump <= 0) {
          return null;
        }

        return FeedbackNumberLine(
          start: question.operand1,
          jump: jump,
          end: question.correctAnswer,
          operationType: OperationType.subtraction,
        );
      default:
        return null;
    }
  }

  FeedbackGroupModel? _buildGroupModel(Question question) {
    switch (question.operationType) {
      case OperationType.multiplication:
        final factorA = question.operand1.abs();
        final factorB = question.operand2.abs();
        if (factorA <= 0 || factorB <= 0) {
          return null;
        }

        final groupCount = factorA <= factorB ? factorA : factorB;
        final groupValue = factorA <= factorB ? factorB : factorA;

        return FeedbackGroupModel(
          operationType: OperationType.multiplication,
          groupCount: groupCount,
          groupValue: groupValue,
          totalValue: question.correctAnswer.abs(),
        );
      case OperationType.division:
        final groupCount = question.operand2.abs();
        final groupValue = question.correctAnswer.abs();
        final totalValue = question.operand1.abs();

        if (groupCount <= 0 || groupValue <= 0 || totalValue <= 0) {
          return null;
        }

        return FeedbackGroupModel(
          operationType: OperationType.division,
          groupCount: groupCount,
          groupValue: groupValue,
          totalValue: totalValue,
        );
      default:
        return null;
    }
  }

  List<String> _buildMetaLines({
    required int pointsEarned,
    required bool gotSpeedBonus,
    required int correctStreak,
    required bool wasCorrect,
  }) {
    final lines = <String>[];

    if (pointsEarned > 0) {
      lines.add('🪙 +$pointsEarned poäng');
    }

    if (gotSpeedBonus) {
      lines.add('⚡ Snabbbonus!');
    }

    if (wasCorrect) {
      if (correctStreak >= 2) {
        lines.add('🔥 Sviten: $correctStreak');
      }
    } else {
      if (correctStreak >= 2) {
        lines.add('🔥 Svit (nyss): $correctStreak');
      }
    }

    return lines;
  }

  String _pick(String seed, List<String> options) {
    if (options.isEmpty) return '';
    final index = _stableHash(seed) % options.length;
    return options[index];
  }

  int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }

  String _joinLines(List<String> parts) {
    final cleaned = parts
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    return cleaned.join('\n');
  }
}
