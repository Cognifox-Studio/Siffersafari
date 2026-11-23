import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// One line of "det här ställer vi in", written for the parent.
class SetupPlanLine {
  const SetupPlanLine({required this.label, required this.value});

  final String label;
  final String value;
}

/// What pressing "Starta" actually sets.
///
/// The onboarding flow used to end in a black box: a grade was picked, three
/// settings were written, and nothing said which. A setup the parent cannot see
/// is a setup the parent cannot fix -- and a child who lands on the wrong level
/// is the child who stops playing.
class SetupPlan {
  const SetupPlan({
    required this.gradeLevel,
    required this.operations,
    required this.readingHelp,
  });

  /// The grade the parent picked, or null for "Vet inte än".
  final int? gradeLevel;

  /// Operations the child will see first, in the app's order.
  final List<OperationType> operations;

  /// Whether text questions are on for this grade.
  final bool readingHelp;

  factory SetupPlan.forGrade(int? gradeLevel) {
    final grade = (gradeLevel ?? 1).clamp(1, 9);
    final visible = DifficultyConfig.visibleOperationsForGrade(grade);
    return SetupPlan(
      gradeLevel: gradeLevel,
      operations: OperationType.values
          .where(visible.contains)
          .toList(growable: false),
      // Mirrors `QuizFeatureSettings.defaultWordProblemsEnabled`: Åk 1 gets
      // numbers only, everyone else gets text questions from the start.
      readingHelp: grade > 1,
    );
  }

  /// True when the parent said "Vet inte än" and Åk 1 was assumed.
  bool get gradeWasGuessed => gradeLevel == null;

  int get grade => (gradeLevel ?? 1).clamp(1, 9);

  /// "Årskurs 3", or the gentler promise when nothing was chosen.
  String get gradeLabel => gradeWasGuessed
      ? 'Årskurs 1 – vi börjar försiktigt'
      : 'Årskurs $grade';

  /// "plus, minus, gånger, delat" -- names a child recognises.
  String get operationsLabel => operations
      .map((operation) => operation.displayName.toLowerCase())
      .join(', ');

  String get readingLabel =>
      readingHelp ? 'Läshjälp på' : 'Läshjälp av – bara siffror';

  List<SetupPlanLine> get lines => [
        SetupPlanLine(label: 'Årskurs', value: gradeLabel),
        SetupPlanLine(label: 'Räknesätt', value: operationsLabel),
        SetupPlanLine(label: 'Frågor', value: readingLabel),
      ];

  /// One sentence, in the app's own voice, for screen readers and for the
  /// parent who only skims.
  String get spokenSummary =>
      '$gradeLabel. Räknesätt: $operationsLabel. $readingLabel. '
      'Allt kan ändras i Föräldraläge.';
}
