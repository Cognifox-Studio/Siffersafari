import 'package:equatable/equatable.dart';

/// Event emitted when a user crosses a level threshold after a quiz.
///
/// Used by the results screen to surface a celebration overlay highlighting
/// the new level and title.
class LevelUpEvent extends Equatable {
  const LevelUpEvent({
    required this.oldLevel,
    required this.newLevel,
    required this.newTitle,
  });

  final int oldLevel;
  final int newLevel;
  final String newTitle;

  @override
  List<Object?> get props => [oldLevel, newLevel, newTitle];
}
