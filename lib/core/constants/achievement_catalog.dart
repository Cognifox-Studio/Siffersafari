import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/services/achievement_service.dart';

/// Declarative achievement metadata (display). Unlock rules stay in
/// [AchievementService].
abstract final class AchievementCatalog {
  static const List<AchievementDefinition> definitions = [
    AchievementDefinition(
      id: AppConstants.firstQuizAchievement,
      displayName: 'Första quizet',
      albumLabel: 'Första',
      emoji: '🧭',
      unlockHint: 'Klara ditt första quiz.',
    ),
    AchievementDefinition(
      id: AppConstants.firstAdditionAchievement,
      displayName: 'Första plusrundan',
      albumLabel: 'Plus',
      emoji: '➕',
      unlockHint: 'Spela en plus-runda.',
    ),
    AchievementDefinition(
      id: AppConstants.firstSubtractionAchievement,
      displayName: 'Första minusrundan',
      albumLabel: 'Minus',
      emoji: '➖',
      unlockHint: 'Spela en minus-runda.',
    ),
    AchievementDefinition(
      id: AppConstants.firstMultiplicationAchievement,
      displayName: 'Första gångerrundan',
      albumLabel: 'Gånger',
      emoji: '✖️',
      unlockHint: 'Spela en gånger-runda.',
    ),
    AchievementDefinition(
      id: AppConstants.firstDivisionAchievement,
      displayName: 'Första delatrundan',
      albumLabel: 'Delat',
      emoji: '➗',
      unlockHint: 'Spela en delat-runda.',
    ),
    AchievementDefinition(
      id: AppConstants.perfectScoreAchievement,
      displayName: 'Perfekt resultat',
      albumLabel: 'Perfekt',
      emoji: '⭐',
      unlockHint: 'Svara rätt på alla frågor i ett quiz.',
    ),
    AchievementDefinition(
      id: AppConstants.hardQuizAchievement,
      displayName: 'Klarade svår nivå',
      albumLabel: 'Svår',
      emoji: '🧗',
      unlockHint: 'Klara ett quiz på svår nivå.',
    ),
    AchievementDefinition(
      id: AppConstants.quiz10Achievement,
      displayName: '10 quiz spelade',
      albumLabel: '10 quiz',
      emoji: '🎒',
      unlockHint: 'Spela 10 quiz.',
    ),
    AchievementDefinition(
      id: AppConstants.points500Achievement,
      displayName: '500 poäng',
      albumLabel: '500 p',
      emoji: '🪙',
      unlockHint: 'Samla 500 poäng.',
    ),
    AchievementDefinition(
      id: AppConstants.points1000Achievement,
      displayName: '1000 poäng',
      albumLabel: '1000 p',
      emoji: '🏅',
      unlockHint: 'Samla 1000 poäng.',
    ),
    AchievementDefinition(
      id: AppConstants.points2000Achievement,
      displayName: '2000 poäng',
      albumLabel: '2000 p',
      emoji: '🏆',
      unlockHint: 'Samla 2000 poäng.',
    ),
    AchievementDefinition(
      id: AppConstants.questions500Achievement,
      displayName: '500 frågor',
      albumLabel: '500 frågor',
      emoji: '🧠',
      unlockHint: 'Svara på 500 frågor.',
    ),
    AchievementDefinition(
      id: AppConstants.questions1000Achievement,
      displayName: '1000 frågor',
      albumLabel: '1000 frågor',
      emoji: '🚀',
      unlockHint: 'Svara på 1000 frågor.',
    ),
    AchievementDefinition(
      id: AppConstants.collectAllSouvenirsAchievement,
      displayName: 'Alla souvenirer',
      albumLabel: 'Souvenirer',
      emoji: '🗺️',
      unlockHint: 'Samla alla souvenirer i campet.',
    ),
    AchievementDefinition(
      id: AppConstants.master100Achievement,
      displayName: 'Mästare 100',
      albumLabel: '100 rätt',
      emoji: '💯',
      unlockHint: 'Svara rätt 100 gånger.',
    ),
    AchievementDefinition(
      id: AppConstants.streak7Achievement,
      displayName: '7-dagars streak',
      albumLabel: '7 dagar',
      emoji: '🔥',
      unlockHint: 'Spela 7 dagar i rad.',
    ),
    AchievementDefinition(
      id: AppConstants.streak30Achievement,
      displayName: '30-dagars streak',
      albumLabel: '30 dagar',
      emoji: '👑',
      unlockHint: 'Spela 30 dagar i rad.',
    ),
  ];
}
