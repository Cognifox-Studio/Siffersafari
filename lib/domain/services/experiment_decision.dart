/// What to do with an experiment, decided before the data arrives.
enum ExperimentVerdict {
  /// Not enough profiles yet; keep collecting and change nothing.
  collectMore,

  /// Keep the variant: it moved retention by the margin we promised to care
  /// about.
  keep,

  /// Drop it: the variant did not earn its place, and a variant is a
  /// maintenance cost forever.
  drop,
}

/// The rule, in one place, written down before the numbers exist.
///
/// Retro-fitting a threshold to a result is how a test turns into a story. This
/// is deliberately blunt: at least 30 profiles on each side, at least three
/// percentage points on day 7. Below that, the honest answer is "we don't know",
/// not "it looks good".
class ExperimentDecision {
  const ExperimentDecision._();

  static const int minimumProfilesPerArm = 30;
  static const double minimumLiftPercentagePoints = 3.0;

  static ExperimentVerdict decide({
    required int controlProfiles,
    required int variantProfiles,
    required double controlRate,
    required double variantRate,
  }) {
    if (controlProfiles < minimumProfilesPerArm ||
        variantProfiles < minimumProfilesPerArm) {
      return ExperimentVerdict.collectMore;
    }
    if (controlRate < 0 || variantRate < 0) {
      return ExperimentVerdict.collectMore;
    }

    final lift = (variantRate - controlRate) * 100;
    return lift >= minimumLiftPercentagePoints
        ? ExperimentVerdict.keep
        : ExperimentVerdict.drop;
  }

  /// Plain-text summary for the monthly review, so nobody has to re-derive it.
  static String explain({
    required int controlProfiles,
    required int variantProfiles,
    required double controlRate,
    required double variantRate,
  }) {
    final verdict = decide(
      controlProfiles: controlProfiles,
      variantProfiles: variantProfiles,
      controlRate: controlRate,
      variantRate: variantRate,
    );
    final lift = (variantRate - controlRate) * 100;
    final liftText = '${lift >= 0 ? '+' : ''}${lift.toStringAsFixed(1)} pp';

    return switch (verdict) {
      ExperimentVerdict.collectMore =>
        'Samla mer data: $controlProfiles kontroll och $variantProfiles variant '
            '(minst $minimumProfilesPerArm per arm). Skillnad så långt: '
            '$liftText.',
      ExperimentVerdict.keep =>
        'Behåll: $liftText bättre D7 vid $variantProfiles profiler i varianten '
            '(regeln kräver +${minimumLiftPercentagePoints.toStringAsFixed(0)} '
            'pp vid minst $minimumProfilesPerArm per arm).',
      ExperimentVerdict.drop =>
        'Ta bort: $liftText räcker inte (regeln kräver '
            '+${minimumLiftPercentagePoints.toStringAsFixed(0)} pp vid minst '
            '$minimumProfilesPerArm per arm).',
    };
  }
}
