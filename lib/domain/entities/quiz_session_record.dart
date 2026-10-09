import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

/// Typed view of in-progress or historical quiz session maps in Hive.
class QuizSessionRecord {
  const QuizSessionRecord({
    required this.sessionId,
    required this.userId,
    required this.isComplete,
    required this.operationTypeName,
    this.raw = const {},
  });

  final String sessionId;
  final String userId;
  final bool isComplete;
  final String operationTypeName;
  final Map<String, dynamic> raw;

  OperationType? get operationType =>
      OperationType.values.asNameMap()[operationTypeName];

  DifficultyLevel? get difficulty {
    final name = raw['difficulty']?.toString();
    if (name == null) return null;
    return DifficultyLevel.values.asNameMap()[name];
  }

  static QuizSessionRecord? tryParse(Map<String, dynamic>? map) {
    if (map == null) return null;

    final sessionId = map['sessionId'];
    final userId = map['userId'];
    final isComplete = map['isComplete'];
    final operationType = map['operationType'];

    if (sessionId is! String || sessionId.isEmpty) return null;
    if (userId is! String || userId.isEmpty) return null;
    if (isComplete is! bool) return null;
    if (operationType is! String || operationType.isEmpty) return null;

    return QuizSessionRecord(
      sessionId: sessionId,
      userId: userId,
      isComplete: isComplete,
      operationTypeName: operationType,
      raw: map,
    );
  }
}
