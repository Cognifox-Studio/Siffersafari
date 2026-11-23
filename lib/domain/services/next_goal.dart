import 'package:siffersafari/core/constants/achievement_catalog.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';

/// What there is to look forward to, shown while it is still out of reach.
///
/// A child who has played today has no reason to come back tomorrow unless the
/// app remembers to have one. Everything here is already in `UserProgress` or
/// `StoryProgress`: a locked badge, the next level, or the biome after the
/// episode. No new storage, no new counters -- the point is to *show* the
/// loops that already exist.
enum NextGoalKind { badge, level, story }

class NextGoal {
  const NextGoal({
    required this.kind,
    required this.title,
    required this.body,
    this.emoji = '⭐',
    this.assetPath,
  });

  final NextGoalKind kind;

  /// Kid-facing name of the thing that is one step away.
  final String title;

  /// Why it is close, in the app's own words.
  final String body;

  final String emoji;
  final String? assetPath;

  /// Read out by screen readers instead of the emoji.
  String get spokenLabel => '$title. $body';
}

/// The nearest locked goal, or null when there is no profile yet.
///
/// Badges come first because they are the only goals with a finite, visible
/// number left; a level is always reachable and a story biome is the long arc.
NextGoal? nextGoalFor({
  required UserProgress? user,
  StoryProgress? story,
}) {
  if (user == null) return null;

  return _lockedBadge(user) ?? _nextBiome(story) ?? _nextLevel(user);
}

NextGoal? _lockedBadge(UserProgress user) {
  final unlocked = user.achievements.toSet();
  for (final definition in AchievementCatalog.definitions) {
    if (unlocked.contains(definition.id)) continue;
    // Skip entries the catalog cannot describe; an empty hint is not a goal.
    if (definition.unlockHint.trim().isEmpty) continue;

    return NextGoal(
      kind: NextGoalKind.badge,
      title: definition.displayName,
      body: definition.unlockHint,
      emoji: definition.emoji,
      assetPath: definition.assetPath,
    );
  }
  return null;
}

NextGoal? _nextBiome(StoryProgress? story) {
  final biome = story?.nextBiome;
  if (story == null || !story.isEpisodeComplete || biome == null) {
    return null;
  }
  return NextGoal(
    kind: NextGoalKind.story,
    title: biome.previewTitle,
    body: biome.previewBody,
    emoji: '🗺️',
  );
}

NextGoal? _nextLevel(UserProgress user) {
  final toNext = user.pointsToNextLevel;
  if (toNext <= 0) return null;

  // Deliberately rough: "ungefär en runda" is honest for a 10-question round,
  // and a fake precision would be worse than a friendly estimate.
  final rounds = (toNext / 20).ceil().clamp(1, 99);
  return NextGoal(
    kind: NextGoalKind.level,
    title: 'Nivå ${user.level + 1}',
    body: rounds == 1
        ? 'Poäng kvar till nästa nivå: $toNext. Ungefär en runda.'
        : 'Poäng kvar till nästa nivå: $toNext. Ungefär $rounds rundor.',
    emoji: '🚀',
  );
}
