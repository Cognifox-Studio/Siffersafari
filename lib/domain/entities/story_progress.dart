import 'package:equatable/equatable.dart';

import '../enums/difficulty_level.dart';
import '../enums/operation_type.dart';

enum StoryNodeState {
  completed,
  current,
  upcoming,
}

class StoryNode extends Equatable {
  const StoryNode({
    required this.id,
    required this.title,
    required this.operation,
    required this.difficulty,
    required this.state,
    required this.landmark,
    required this.landmarkHint,
    required this.sceneTag,
    required this.stepIndex,
  });

  final String id;
  final String title;
  final OperationType operation;
  final DifficultyLevel difficulty;
  final StoryNodeState state;
  final String landmark;
  final String landmarkHint;
  final String sceneTag;
  final int stepIndex;

  @override
  List<Object?> get props => [
        id,
        title,
        operation,
        difficulty,
        state,
        landmark,
        landmarkHint,
        sceneTag,
        stepIndex,
      ];
}

class StoryBiomePreview extends Equatable {
  const StoryBiomePreview({
    required this.name,
    required this.tagline,
    required this.previewPrefix,
    required this.previewBody,
  });

  final String name;
  final String tagline;
  final String previewPrefix;
  final String previewBody;

  String get previewTitle => '$name väntar.';

  @override
  List<Object?> get props => [
        name,
        tagline,
        previewPrefix,
        previewBody,
      ];
}

class StoryProgress extends Equatable {
  const StoryProgress({
    required this.worldTitle,
    required this.worldSubtitle,
    required this.chapterTitle,
    required this.actIndex,
    required this.totalActs,
    required this.actTitle,
    required this.actBody,
    required this.currentObjectiveTitle,
    required this.currentObjectiveDescription,
    required this.progress,
    required this.completedNodes,
    required this.totalNodes,
    required this.currentNodeIndex,
    required this.nodes,
    required this.isEpisodeComplete,
    required this.endingTitle,
    required this.endingBody,
    this.nextBiome,
    this.notice,
  });

  final String worldTitle;
  final String worldSubtitle;
  final String chapterTitle;
  final int actIndex;
  final int totalActs;
  final String actTitle;
  final String actBody;
  final String currentObjectiveTitle;
  final String currentObjectiveDescription;
  final double progress;
  final int completedNodes;
  final int totalNodes;
  final int currentNodeIndex;
  final List<StoryNode> nodes;
  final bool isEpisodeComplete;
  final String endingTitle;
  final String endingBody;
  final StoryBiomePreview? nextBiome;
  final String? notice;

  String get actLabel => 'Akt $actIndex av $totalActs';

  StoryNode? get currentNode {
    for (final node in nodes) {
      if (node.state == StoryNodeState.current) return node;
    }
    return nodes.isEmpty ? null : nodes.last;
  }

  @override
  List<Object?> get props => [
        worldTitle,
        worldSubtitle,
        chapterTitle,
        actIndex,
        totalActs,
        actTitle,
        actBody,
        currentObjectiveTitle,
        currentObjectiveDescription,
        progress,
        completedNodes,
        totalNodes,
        currentNodeIndex,
        nodes,
        isEpisodeComplete,
        endingTitle,
        endingBody,
        nextBiome,
        notice,
      ];
}
