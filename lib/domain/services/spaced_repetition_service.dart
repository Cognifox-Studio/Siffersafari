import '../constants/learning_constants.dart';

/// Represents a scheduled review for a question
class ReviewSchedule {
  const ReviewSchedule({
    required this.questionId,
    required this.nextReviewDate,
    required this.intervalDays,
    required this.consecutiveCorrect,
  });

  final String questionId;
  final DateTime nextReviewDate;
  final int intervalDays;
  final int consecutiveCorrect;

  ReviewSchedule copyWith({
    String? questionId,
    DateTime? nextReviewDate,
    int? intervalDays,
    int? consecutiveCorrect,
  }) {
    return ReviewSchedule(
      questionId: questionId ?? this.questionId,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      intervalDays: intervalDays ?? this.intervalDays,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
    );
  }
}

/// Manages spaced repetition schedules to optimize long-term retention.
///
/// Uses intervals defined in [LearningConstants]:
/// - First review: [firstReviewInterval] days
/// - Second review: [secondReviewInterval] days
/// - Third review: [thirdReviewInterval] days
///
/// Incorrect answers reset the schedule to the first interval.
/// Consecutive correct answers progress through intervals.
class SpacedRepetitionService {
  /// Calculates the next review date for a question.
  ///
  /// If [wasCorrect] is false, resets to the first interval regardless
  /// of prior schedule. If true, advances to the next interval based on
  /// [consecutiveCorrect] count.
  ///
  /// [now] defaults to [DateTime.now] for testing purposes.
  ReviewSchedule scheduleNextReview({
    required String questionId,
    required bool wasCorrect,
    ReviewSchedule? previous,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final newConsecutiveCorrect =
        wasCorrect ? (previous?.consecutiveCorrect ?? 0) + 1 : 0;
    final intervalDays = _getNextInterval(newConsecutiveCorrect);

    if (previous == null) {
      return ReviewSchedule(
        questionId: questionId,
        nextReviewDate: currentTime.add(Duration(days: intervalDays)),
        intervalDays: intervalDays,
        consecutiveCorrect: newConsecutiveCorrect,
      );
    }

    return previous.copyWith(
      nextReviewDate: currentTime.add(Duration(days: intervalDays)),
      intervalDays: intervalDays,
      consecutiveCorrect: newConsecutiveCorrect,
    );
  }

  /// Returns the next interval based on consecutive correct answers
  int _getNextInterval(int consecutiveCorrect) {
    if (consecutiveCorrect >= 3) return LearningConstants.thirdReviewInterval;
    if (consecutiveCorrect == 2) return LearningConstants.secondReviewInterval;
    return LearningConstants.firstReviewInterval;
  }

  /// Get question IDs that are due for review
  List<String> getDueQuestionIds(
    List<ReviewSchedule> schedules,
    DateTime now,
  ) {
    return [
      for (final schedule in schedules)
        if (!schedule.nextReviewDate.isAfter(now)) schedule.questionId,
    ];
  }
}
