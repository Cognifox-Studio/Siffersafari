import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/achievement_catalog.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/services/next_goal.dart';

UserProgress _user({
  List<String> achievements = const [],
  int totalPoints = 0,
}) {
  return UserProgress(
    userId: 'u1',
    name: 'Sam',
    ageGroup: AgeGroup.young,
    achievements: achievements,
    totalPoints: totalPoints,
  );
}

/// All badge ids, so a profile can be "done" with badges in a test.
List<String> get _allBadges =>
    AchievementCatalog.definitions.map((d) => d.id).toList();

StoryProgress _story({bool complete = false, StoryBiomePreview? nextBiome}) {
  return StoryProgress(
    worldTitle: 'Djungeln',
    worldSubtitle: 'Första äventyret',
    chapterTitle: 'Kapitel 1',
    actIndex: 1,
    totalActs: 1,
    actTitle: 'Akt 1',
    actBody: 'Början',
    currentObjectiveTitle: 'Hitta floden',
    currentObjectiveDescription: 'Spela ett stopp.',
    progress: complete ? 1.0 : 0.5,
    completedNodes: 1,
    totalNodes: 2,
    currentNodeIndex: 1,
    nodes: const [],
    isEpisodeComplete: complete,
    endingTitle: 'Slutet',
    endingBody: 'Klart',
    nextBiome: nextBiome,
  );
}

void main() {
  group('[Unit] Nästa mål', () {
    test('utan profil finns inget mål', () {
      expect(nextGoalFor(user: null), isNull);
    });

    test('närmaste låsta märke visas med sin ledtråd', () {
      final goal = nextGoalFor(user: _user());

      expect(goal, isNotNull);
      expect(goal!.kind, NextGoalKind.badge);
      final first = AchievementCatalog.definitions.first;
      expect(goal.title, first.displayName);
      expect(goal.body, first.unlockHint);
      expect(goal.assetPath, first.assetPath);
    });

    test('ett upplåst märke hoppas över till nästa', () {
      final first = AchievementCatalog.definitions.first;
      final second = AchievementCatalog.definitions[1];

      final goal = nextGoalFor(user: _user(achievements: [first.id]));

      expect(goal!.title, second.displayName);
    });

    test('utan märken kvar pekar målet på nästa nivå', () {
      final goal = nextGoalFor(
        user: _user(achievements: _allBadges, totalPoints: 120),
      );

      expect(goal!.kind, NextGoalKind.level);
      expect(goal.title, 'Nivå 2');
      expect(goal.body, contains('80'));
      expect(goal.body, contains('rundor'));
    });

    test('en poäng kvar beskrivs som en runda, inte som en bråkdel', () {
      final goal = nextGoalFor(
        user: _user(achievements: _allBadges, totalPoints: 199),
      );

      expect(goal!.body, contains('Ungefär en runda.'));
    });

    test('ny biom teasas först när episoden är klar', () {
      final biome = const StoryBiomePreview(
        name: 'Nattskogen',
        tagline: 'Mörkare, men lugnare',
        previewPrefix: 'Snart',
        previewBody: 'En ny skog öppnar sig.',
      );

      final midEpisode = nextGoalFor(
        user: _user(),
        story: _story(complete: false, nextBiome: biome),
      );
      expect(midEpisode!.kind, NextGoalKind.badge);

      final completed = nextGoalFor(
        user: _user(achievements: _allBadges, totalPoints: 400),
        story: _story(complete: true, nextBiome: biome),
      );
      expect(completed!.kind, NextGoalKind.story);
      expect(completed.title, 'Nattskogen väntar.');
      expect(completed.body, 'En ny skog öppnar sig.');
    });

    test('uppläsningen läser titel och text, inte emojin', () {
      final goal = nextGoalFor(user: _user());

      expect(goal!.spokenLabel, '${goal.title}. ${goal.body}');
    });
  });
}
