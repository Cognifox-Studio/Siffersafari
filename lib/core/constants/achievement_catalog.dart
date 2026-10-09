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
    ),
    AchievementDefinition(
      id: AppConstants.firstAdditionAchievement,
      displayName: 'Första plusrundan',
      albumLabel: 'Plus',
      emoji: '➕',
    ),
    AchievementDefinition(
      id: AppConstants.firstSubtractionAchievement,
      displayName: 'Första minusrundan',
      albumLabel: 'Minus',
      emoji: '➖',
    ),
    AchievementDefinition(
      id: AppConstants.firstMultiplicationAchievement,
      displayName: 'Första gångerrundan',
      albumLabel: 'Gånger',
      emoji: '✖️',
    ),
    AchievementDefinition(
      id: AppConstants.firstDivisionAchievement,
      displayName: 'Första delatrundan',
      albumLabel: 'Delat',
      emoji: '➗',
    ),
    AchievementDefinition(
      id: AppConstants.perfectScoreAchievement,
      displayName: 'Perfekt resultat',
      albumLabel: 'Perfekt',
      emoji: '⭐',
    ),
    AchievementDefinition(
      id: AppConstants.hardQuizAchievement,
      displayName: 'Klarade svår nivå',
      albumLabel: 'Svår',
      emoji: '🧗',
    ),
    AchievementDefinition(
      id: AppConstants.quiz10Achievement,
      displayName: '10 quiz spelade',
      albumLabel: '10 quiz',
      emoji: '🎒',
    ),
    AchievementDefinition(
      id: AppConstants.points500Achievement,
      displayName: '500 poäng',
      albumLabel: '500 p',
      emoji: '🪙',
    ),
    AchievementDefinition(
      id: AppConstants.points1000Achievement,
      displayName: '1000 poäng',
      albumLabel: '1000 p',
      emoji: '🏅',
    ),
    AchievementDefinition(
      id: AppConstants.points2000Achievement,
      displayName: '2000 poäng',
      albumLabel: '2000 p',
      emoji: '🏆',
    ),
    AchievementDefinition(
      id: AppConstants.questions500Achievement,
      displayName: '500 frågor',
      albumLabel: '500 frågor',
      emoji: '🧠',
    ),
    AchievementDefinition(
      id: AppConstants.questions1000Achievement,
      displayName: '1000 frågor',
      albumLabel: '1000 frågor',
      emoji: '🚀',
    ),
    AchievementDefinition(
      id: AppConstants.collectAllSouvenirsAchievement,
      displayName: 'Alla souvenirer',
      albumLabel: 'Souvenirer',
      emoji: '🗺️',
    ),
    AchievementDefinition(
      id: AppConstants.master100Achievement,
      displayName: 'Mästare 100',
      albumLabel: '100 rätt',
      emoji: '💯',
    ),
    AchievementDefinition(
      id: AppConstants.streak7Achievement,
      displayName: '7-dagars streak',
      albumLabel: '7 dagar',
      emoji: '🔥',
    ),
    AchievementDefinition(
      id: AppConstants.streak30Achievement,
      displayName: '30-dagars streak',
      albumLabel: '30 dagar',
      emoji: '👑',
    ),
  ];
}
