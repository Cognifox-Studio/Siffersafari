import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// Input to the question generation pipeline (MixPolicy → dispatch → Question).
class QuestionRequest {
  const QuestionRequest({
    required this.ageGroup,
    required this.operationType,
    required this.difficulty,
    this.difficultyStepsByOperation,
    this.difficultyStep,
    this.gradeLevel,
    this.wordProblemsEnabledOverride,
    this.wordProblemsChanceOverride,
    this.missingNumberEnabledOverride,
    this.missingNumberChanceOverride,
  });

  final AgeGroup ageGroup;
  final OperationType operationType;
  final DifficultyLevel difficulty;
  final Map<OperationType, int>? difficultyStepsByOperation;
  final int? difficultyStep;
  final int? gradeLevel;
  final bool? wordProblemsEnabledOverride;
  final double? wordProblemsChanceOverride;
  final bool? missingNumberEnabledOverride;
  final double? missingNumberChanceOverride;
}
