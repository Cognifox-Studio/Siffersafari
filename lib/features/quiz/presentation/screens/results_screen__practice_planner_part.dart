part of 'results_screen.dart';

class _ResultsPracticePlanner {
  const _ResultsPracticePlanner._();

  static const int slowAnswerThresholdSeconds = 8;

  static List<_HardestQuestion> hardestQuestions(QuizSession session) {
    final items = <_HardestQuestion>[];

    for (final question in session.questions) {
      final answer = session.answers[question.id];
      final time = session.responseTimes[question.id];
      if (answer == null && time == null) continue;

      final wasCorrect = answer != null ? question.isCorrect(answer) : true;
      final isSlow = (time?.inSeconds ?? 0) >= slowAnswerThresholdSeconds;
      if (wasCorrect && !isSlow) continue;

      items.add(
        _HardestQuestion(
          question: question,
          answer: answer,
          wasCorrect: wasCorrect,
          time: time,
        ),
      );
    }

    items.sort((a, b) {
      if (a.wasCorrect != b.wasCorrect) {
        return a.wasCorrect ? 1 : -1;
      }
      final answerTime = a.time?.inMilliseconds ?? 0;
      final otherTime = b.time?.inMilliseconds ?? 0;
      return otherTime.compareTo(answerTime);
    });

    return items.length <= 3 ? items : items.take(3).toList(growable: false);
  }

  static List<Question> focusedMiniPassQuestions(
    QuizSession session,
    List<_HardestQuestion> hardest,
    int count,
  ) {
    if (count <= 0) return const [];
    if (session.questions.isEmpty) return const [];

    final weakQuestions =
        hardest.map((hardQuestion) => hardQuestion.question).toList(
              growable: false,
            );

    final correctFast = <Question>[];
    final timed = <({Question question, int milliseconds})>[];

    for (final question in session.questions) {
      final answer = session.answers[question.id];
      if (answer == null) continue;
      if (!question.isCorrect(answer)) continue;

      final milliseconds = session.responseTimes[question.id]?.inMilliseconds;
      if (milliseconds == null) {
        correctFast.add(question);
      } else {
        timed.add((question: question, milliseconds: milliseconds));
      }
    }

    timed.sort((a, b) => a.milliseconds.compareTo(b.milliseconds));
    correctFast
      ..addAll(timed.map((entry) => entry.question))
      ..removeWhere((question) => weakQuestions.contains(question));

    final weakCount = ((count * 0.8).round()).clamp(1, count);
    final easyCount = (count - weakCount).clamp(0, count);
    final result = <Question>[];

    if (weakQuestions.isEmpty) {
      final fallback = correctFast.isNotEmpty ? correctFast : session.questions;
      for (var index = 0; index < count; index++) {
        final question = fallback[index % fallback.length];
        result.add(question.copyWith(id: '${question.id}__focus_$index'));
      }
      return result;
    }

    for (var index = 0; index < weakCount; index++) {
      final question = weakQuestions[index % weakQuestions.length];
      result.add(question.copyWith(id: '${question.id}__weak_$index'));
    }

    final filler = correctFast.isNotEmpty
        ? correctFast
        : session.questions
            .where((question) => !weakQuestions.contains(question))
            .toList();
    for (var index = 0; index < easyCount; index++) {
      final question = filler.isNotEmpty
          ? filler[index % filler.length]
          : weakQuestions[index % weakQuestions.length];
      result.add(question.copyWith(id: '${question.id}__easy_$index'));
    }

    return result;
  }
}
