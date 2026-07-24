part of 'story_map_screen.dart';

class _StoryMapReadModel {
  const _StoryMapReadModel({
    required this.story,
    required this.currentNode,
    required this.nextNode,
  });

  final StoryProgress story;
  final StoryNode? currentNode;
  final StoryNode? nextNode;

  String get headingSubtitle => story.isEpisodeComplete
      ? story.endingBody
      : '${story.actLabel}: ${story.actTitle}';

  bool get hasNextBiomePreview => story.nextBiome != null;

  factory _StoryMapReadModel.from(StoryProgress story) {
    final nextIndex = story.currentNodeIndex + 1;
    final nextNode = nextIndex >= 0 && nextIndex < story.nodes.length
        ? story.nodes[nextIndex]
        : null;

    return _StoryMapReadModel(
      story: story,
      currentNode: story.currentNode,
      nextNode: nextNode,
    );
  }
}
