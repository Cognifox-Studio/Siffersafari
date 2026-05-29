import 'package:siffersafari/domain/enums/operation_type.dart';

class QuestionMixPolicy {
  const QuestionMixPolicy({
    required this.requestedOperation,
    required this.selectedOperation,
    required this.gradeLevel,
    required this.clampedStep,
    required this.roll,
    required this.wordProblemsEnabled,
    required this.wordProblemsChance,
  });

  final OperationType requestedOperation;
  final OperationType selectedOperation;
  final int? gradeLevel;
  final int clampedStep;
  final double roll;
  final bool wordProblemsEnabled;
  final double wordProblemsChance;

  bool get isLowGradeMix =>
      requestedOperation == OperationType.mixed &&
      gradeLevel != null &&
      gradeLevel! >= 2 &&
      gradeLevel! <= 3;

  bool get isM4Mix =>
      requestedOperation == OperationType.mixed &&
      gradeLevel != null &&
      gradeLevel! >= 4 &&
      gradeLevel! <= 6;

  bool get isM5Mix =>
      requestedOperation == OperationType.mixed &&
      gradeLevel != null &&
      gradeLevel! >= 7 &&
      gradeLevel! <= 9;

  double get m4StatsChance => m4StatsChanceForStep(clampedStep);
  double get m4ProbabilityChance => m4ProbabilityChanceForStep(clampedStep);
  double get lowGradeStatsChance => lowGradeStatsChanceFor(
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get lowGradeChanceChance => lowGradeChanceChanceFor(
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get m4PercentChance => m4PercentChanceFor(
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get m4NegativeChance => m4NegativeChanceFor(
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get m5aPercentChance => m5aPercentChanceFor(
        isM5Mix: isM5Mix,
        clampedStep: clampedStep,
      );
  double get m5aPowerChance => m5aPowerChanceFor(
        isM5Mix: isM5Mix,
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get m5aProportionalityChance => m5aProportionalityChanceFor(
        isM5Mix: isM5Mix,
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get m5aEquationChance => m5aEquationChanceFor(
        isM5Mix: isM5Mix,
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );
  double get m5aPrecedenceChance => m5aPrecedenceChanceFor(
        isM5Mix: isM5Mix,
        clampedStep: clampedStep,
      );
  double get m5bLinearChance => m5bLinearChanceFor(
        isM5Mix: isM5Mix,
        clampedStep: clampedStep,
      );
  double get m5bGeometricChance => m5bGeometricChanceFor(
        isM5Mix: isM5Mix,
        clampedStep: clampedStep,
      );
  double get m5bAdvancedStatsChance => m5bAdvancedStatsChanceFor(
        isM5Mix: isM5Mix,
        clampedStep: clampedStep,
      );
  double get m4TimeChance => m4TimeChanceFor(
        gradeLevel: gradeLevel,
        clampedStep: clampedStep,
      );

  double get _m4LateStart => m4StatsChance + m4ProbabilityChance;
  double get _m5bLinearStart =>
      m5aPercentChance +
      m5aPowerChance +
      m5aProportionalityChance +
      m5aEquationChance +
      m5aPrecedenceChance;
  double get _m5bGeometricStart => _m5bLinearStart + m5bLinearChance;
  double get _m5bAdvancedStatsStart => _m5bGeometricStart + m5bGeometricChance;

  bool get shouldTryM4Statistics => isM4Mix && roll < m4StatsChance;

  bool get shouldTryM4Probability =>
      isM4Mix &&
      roll >= m4StatsChance &&
      roll < (m4StatsChance + m4ProbabilityChance);

  bool get shouldTryLowGradeStatistics =>
      isLowGradeMix &&
      lowGradeStatsChance > 0 &&
      roll >= 0.88 &&
      roll < (0.88 + lowGradeStatsChance);

  bool get shouldTryLowGradeChance =>
      isLowGradeMix &&
      lowGradeChanceChance > 0 &&
      roll >= 0.94 &&
      roll < (0.94 + lowGradeChanceChance);

  bool get shouldTryM4Percent =>
      isM4Mix &&
      m4PercentChance > 0 &&
      roll >= _m4LateStart &&
      roll < (_m4LateStart + m4PercentChance);

  bool get shouldTryM4NegativeNumbers =>
      isM4Mix &&
      m4NegativeChance > 0 &&
      roll >= (_m4LateStart + m4PercentChance) &&
      roll < (_m4LateStart + m4PercentChance + m4NegativeChance);

  bool get shouldTryM5aPercent => isM5Mix && roll < m5aPercentChance;

  bool get shouldTryM5aPower =>
      isM5Mix &&
      gradeLevel != null &&
      gradeLevel! >= 8 &&
      clampedStep >= 7 &&
      roll >= m5aPercentChance &&
      roll < (m5aPercentChance + m5aPowerChance);

    bool get shouldTryM5aProportionality =>
      isM5Mix &&
      m5aProportionalityChance > 0 &&
      roll >= (m5aPercentChance + m5aPowerChance) &&
      roll <
        (m5aPercentChance +
          m5aPowerChance +
          m5aProportionalityChance);

  bool get shouldTryM5aEquation =>
      isM5Mix &&
      m5aEquationChance > 0 &&
      roll >= (m5aPercentChance + m5aPowerChance + m5aProportionalityChance) &&
      roll <
        (m5aPercentChance +
          m5aPowerChance +
          m5aProportionalityChance +
          m5aEquationChance);

  bool get shouldTryM5aPrecedence =>
      isM5Mix &&
      clampedStep >= 6 &&
      roll >=
        (m5aPercentChance +
          m5aPowerChance +
          m5aProportionalityChance +
          m5aEquationChance) &&
      roll <
          (m5aPercentChance +
              m5aPowerChance +
          m5aProportionalityChance +
              m5aEquationChance +
              m5aPrecedenceChance);

  bool get shouldTryM5bLinearFunction =>
      isM5Mix &&
      clampedStep >= 8 &&
      roll >= _m5bLinearStart &&
      roll < _m5bGeometricStart;

  bool get shouldTryM5bGeometricTransformation =>
      isM5Mix &&
      clampedStep >= 8 &&
      roll >= _m5bGeometricStart &&
      roll < _m5bAdvancedStatsStart;

  bool get shouldTryM5bAdvancedStatistics =>
      isM5Mix &&
      clampedStep >= 8 &&
      roll >= _m5bAdvancedStatsStart &&
      roll < (_m5bAdvancedStatsStart + m5bAdvancedStatsChance);

  bool get shouldTryM4Time =>
      requestedOperation == OperationType.mixed &&
      gradeLevel != null &&
      m4TimeChance > 0 &&
      roll >= (0.85 - m4TimeChance) &&
      roll < 0.85;

  bool get shouldTryWordProblemAddSub =>
      wordProblemsEnabled &&
      gradeLevel != null &&
      gradeLevel! >= 1 &&
      gradeLevel! <= 3 &&
      roll < wordProblemsChance &&
      (selectedOperation == OperationType.addition ||
          selectedOperation == OperationType.subtraction);

  bool get shouldTryWordProblemMulDiv =>
      wordProblemsEnabled &&
      gradeLevel == 3 &&
      (requestedOperation != OperationType.mixed || clampedStep >= 7) &&
      roll < wordProblemsChance &&
      (selectedOperation == OperationType.multiplication ||
          selectedOperation == OperationType.division);

  static double m4StatsChanceForStep(int step) {
    if (step <= 3) return 0.09;
    if (step <= 6) return 0.11;
    if (step <= 8) return 0.10;
    return 0.09;
  }

  static double m4ProbabilityChanceForStep(int step) {
    if (step <= 3) return 0.09;
    if (step <= 6) return 0.10;
    if (step <= 8) return 0.08;
    return 0.07;
  }

  static double lowGradeStatsChanceFor({
    required int? gradeLevel,
    required int clampedStep,
  }) {
    return switch (gradeLevel) {
      2 => clampedStep <= 4
          ? 0.0
          : clampedStep <= 6
              ? 0.03
              : clampedStep <= 8
                  ? 0.04
                  : 0.05,
      3 => clampedStep <= 4
          ? 0.0
          : clampedStep <= 6
              ? 0.04
              : clampedStep <= 8
                  ? 0.05
                  : 0.06,
      _ => 0.0,
    };
  }

  static double lowGradeChanceChanceFor({
    required int? gradeLevel,
    required int clampedStep,
  }) {
    return switch (gradeLevel) {
      2 => clampedStep <= 5
          ? 0.0
          : clampedStep <= 7
              ? 0.02
              : clampedStep <= 9
                  ? 0.03
                  : 0.04,
      3 => clampedStep <= 5
          ? 0.0
          : clampedStep <= 7
              ? 0.03
              : clampedStep <= 9
                  ? 0.04
                  : 0.05,
      _ => 0.0,
    };
  }

  static double m4PercentChanceFor({
    required int? gradeLevel,
    required int clampedStep,
  }) {
    if (gradeLevel == 4) {
      if (clampedStep == 8) return 0.03;
      if (clampedStep == 9) return 0.04;
      if (clampedStep == 10) return 0.05;
      return 0.0;
    }

    if (gradeLevel != null && gradeLevel >= 5 && gradeLevel <= 6) {
      if (clampedStep < 6) return 0.0;
      if (clampedStep == 6) return 0.03;
      if (clampedStep <= 8) return 0.04;
      if (clampedStep <= 10) return 0.05;
    }

    return 0.0;
  }

  static double m4NegativeChanceFor({
    required int? gradeLevel,
    required int clampedStep,
  }) {
    if (gradeLevel == 4) {
      if (clampedStep == 9) return 0.02;
      if (clampedStep == 10) return 0.03;
      return 0.0;
    }

    if (gradeLevel != null && gradeLevel >= 5 && gradeLevel <= 6) {
      if (clampedStep <= 6) return 0.0;
      if (clampedStep <= 8) return 0.03;
      return 0.04;
    }

    return 0.0;
  }

  static double m5aPercentChanceFor({
    required bool isM5Mix,
    required int clampedStep,
  }) {
    if (!isM5Mix || clampedStep < 4) return 0.0;
    if (clampedStep <= 5) return 0.16;
    if (clampedStep <= 7) return 0.15;
    return 0.12;
  }

  static double m5aPowerChanceFor({
    required bool isM5Mix,
    required int? gradeLevel,
    required int clampedStep,
  }) {
    if (!isM5Mix || gradeLevel == null || gradeLevel < 8 || clampedStep < 7) {
      return 0.0;
    }
    return clampedStep == 7 ? 0.06 : 0.10;
  }

  static double m5aEquationChanceFor({
    required bool isM5Mix,
    required int? gradeLevel,
    required int clampedStep,
  }) {
    if (!isM5Mix || gradeLevel == null) {
      return 0.0;
    }

    if (gradeLevel == 7) {
      if (clampedStep < 6) return 0.0;
      if (clampedStep <= 7) return 0.10;
      return 0.08;
    }

    if (gradeLevel == 9) {
      if (clampedStep < 7) return 0.0;
      if (clampedStep <= 8) return 0.08;
      return 0.10;
    }

    return 0.0;
  }

  static double m5aProportionalityChanceFor({
    required bool isM5Mix,
    required int? gradeLevel,
    required int clampedStep,
  }) {
    if (!isM5Mix || gradeLevel != 8 || clampedStep < 8) {
      return 0.0;
    }

    if (clampedStep == 8) return 0.08;
    return 0.10;
  }

  static double m5aPrecedenceChanceFor({
    required bool isM5Mix,
    required int clampedStep,
  }) {
    if (!isM5Mix || clampedStep < 6) return 0.0;
    if (clampedStep <= 7) return 0.10;
    return 0.08;
  }

  static double m5bLinearChanceFor({
    required bool isM5Mix,
    required int clampedStep,
  }) {
    if (!isM5Mix || clampedStep < 8) return 0.0;
    if (clampedStep == 8) return 0.10;
    if (clampedStep == 9) return 0.12;
    return 0.13;
  }

  static double m5bGeometricChanceFor({
    required bool isM5Mix,
    required int clampedStep,
  }) {
    if (!isM5Mix || clampedStep < 8) return 0.0;
    if (clampedStep == 8) return 0.08;
    return 0.10;
  }

  static double m5bAdvancedStatsChanceFor({
    required bool isM5Mix,
    required int clampedStep,
  }) {
    if (!isM5Mix || clampedStep < 8) return 0.0;
    if (clampedStep == 8) return 0.08;
    return 0.10;
  }

  static double m4TimeChanceFor({
    required int? gradeLevel,
    required int clampedStep,
  }) {
    return switch (gradeLevel) {
      2 => clampedStep <= 3
          ? 0.0
          : clampedStep <= 4
              ? 0.02
              : clampedStep <= 6
                  ? 0.03
                  : clampedStep <= 8
                      ? 0.04
                      : 0.05,
      3 => clampedStep <= 3
          ? 0.0
          : clampedStep <= 5
              ? 0.02
              : clampedStep <= 7
                  ? 0.03
                  : 0.04,
      _ => 0.0,
    };
  }
}
