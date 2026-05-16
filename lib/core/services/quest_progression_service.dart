import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';
import 'package:siffersafari/domain/enums/mastery_level.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

typedef QuestPath = List<QuestDefinition>;

/// Manages the quest progression system and adaptive quest selection.
///
/// Tracks user progress through quests based on:
/// - Grade level and age group
/// - Mastery levels per operation/difficulty
/// - Completed quests and current position
///
/// Routes are dynamically generated based on user profile. Quests auto-advance
/// when mastery threshold is reached.
class QuestProgressionService {
  const QuestProgressionService();

  static const List<QuestDefinition> defaultQuests = [
    QuestDefinition(
      id: 'q_plus_easy',
      title: 'Samla sifferfrukter',
      description: 'Bli skicklig på plus (lätt).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_easy',
      title: 'Hitta borttappade siffror',
      description: 'Bli skicklig på minus (lätt).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_easy',
      title: 'Bygg ditt basläger',
      description: 'Bli skicklig på gånger (lätt).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_easy',
      title: 'Dela upp skattkistan',
      description: 'Bli skicklig på delat (lätt).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_plus_easy_2',
      title: 'Tänd lägerelden',
      description: 'Bli ännu tryggare på plus (lätt).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_easy_2',
      title: 'Räkna hem stegen',
      description: 'Bli ännu tryggare på minus (lätt).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_easy_2',
      title: 'Bygg repstegen',
      description: 'Bli ännu tryggare på gånger (lätt).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_easy_2',
      title: 'Dela matsäcken',
      description: 'Bli ännu tryggare på delat (lätt).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_plus_easy_3',
      title: 'Fyll vattenflaskorna',
      description: 'Bemästra plus på djungelstigen (lätt).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_easy_3',
      title: 'Hitta rätt stig',
      description: 'Bemästra minus på djungelstigen (lätt).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_easy_3',
      title: 'Res tältduken',
      description: 'Bemästra gånger på djungelstigen (lätt).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_easy_3',
      title: 'Sortera fynden',
      description: 'Bemästra delat på djungelstigen (lätt).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.easy,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_plus_medium',
      title: 'Kartlägg nya stigar',
      description: 'Bli skicklig på plus (medel).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_medium',
      title: 'Undvik snubbelstenar',
      description: 'Bli skicklig på minus (medel).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_medium',
      title: 'Tämj djungelbron',
      description: 'Bli skicklig på gånger (medel).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_medium',
      title: 'Räkna ut ransoner',
      description: 'Bli skicklig på delat (medel).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_plus_medium_2',
      title: 'Följ lianernas mönster',
      description: 'Bli ännu tryggare på plus (medel).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_medium_2',
      title: 'Rensa stenstigen',
      description: 'Bli ännu tryggare på minus (medel).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_medium_2',
      title: 'Res tältplatsen',
      description: 'Bli ännu tryggare på gånger (medel).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_medium_2',
      title: 'Dela expeditionens fynd',
      description: 'Bli ännu tryggare på delat (medel).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_plus_medium_3',
      title: 'Tänd lägereldarna',
      description: 'Fördjupa plusstrategier (medel).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_medium_3',
      title: 'Hitta rätt fotspår',
      description: 'Fördjupa minusstrategier (medel).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_medium_3',
      title: 'Bygg vakttornet',
      description: 'Fördjupa gångerstrategier (medel).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_medium_3',
      title: 'Packa proviantpåsar',
      description: 'Fördjupa delatstrategier (medel).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_plus_medium_4',
      title: 'Räkna tempellyktorna',
      description: 'Bemästra plus i djupare terräng (medel).',
      operation: OperationType.addition,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_minus_medium_4',
      title: 'Lås upp stenporten',
      description: 'Bemästra minus i djupare terräng (medel).',
      operation: OperationType.subtraction,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_times_medium_4',
      title: 'Stärk repbron',
      description: 'Bemästra gånger i djupare terräng (medel).',
      operation: OperationType.multiplication,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
    QuestDefinition(
      id: 'q_div_medium_4',
      title: 'Dela solskatterna',
      description: 'Bemästra delat i djupare terräng (medel).',
      operation: OperationType.division,
      difficulty: DifficultyLevel.medium,
      requiredMastery: MasteryLevel.proficient,
    ),
  ];

  QuestPath questsForUser(
    UserProgress user, {
    Set<OperationType>? allowedOperations,
  }) {
    final grade = user.gradeLevel;

    // Grade-based paths (recommended guidance). Keep it simple and predictable.
    // - Åk 1-2 & Age.young: only Easy
    // - Åk 3-4, 5+ & Age.middle, Age.older: Easy + Medium (Hard quests can be added later)
    final includeMedium = (grade != null && grade > 2) ||
        (grade == null && user.ageGroup != AgeGroup.young);

    final basePath = defaultQuests.where((q) {
      if (q.difficulty == DifficultyLevel.easy) return true;
      if (includeMedium && q.difficulty == DifficultyLevel.medium) return true;
      return false; // Ignorera hard tills det lanseras
    }).toList(growable: false);

    final filteredPath = _applyAllowedOperations(
      basePath: basePath,
      allowedOperations: allowedOperations,
    );

    return _normalizePathLength(
      basePath: filteredPath,
      targetLength: _targetStopCountFor(includeMedium: includeMedium),
    );
  }

  int _targetStopCountFor({required bool includeMedium}) {
    return includeMedium ? 30 : 10;
  }

  QuestPath _normalizePathLength({
    required QuestPath basePath,
    required int targetLength,
  }) {
    if (basePath.isEmpty) return basePath;

    if (basePath.length == targetLength) {
      return basePath;
    }

    if (basePath.length > targetLength) {
      return basePath.sublist(0, targetLength);
    }

    final expanded = <QuestDefinition>[...basePath];
    final occurrenceByQuestId = <String, int>{
      for (final quest in basePath) quest.id: 1,
    };
    var remaining = targetLength - basePath.length;

    while (remaining > 0) {
      final chunkSize =
          remaining < basePath.length ? remaining : basePath.length;
      final chunkStart = basePath.length - chunkSize;
      final chunk = basePath.sublist(chunkStart);

      for (final template in chunk) {
        final nextOccurrence = (occurrenceByQuestId[template.id] ?? 1) + 1;
        occurrenceByQuestId[template.id] = nextOccurrence;
        expanded.add(
          QuestDefinition(
            id: '${template.id}__del_$nextOccurrence',
            title: '${template.title} del $nextOccurrence',
            description: template.description,
            operation: template.operation,
            difficulty: template.difficulty,
            requiredMastery: template.requiredMastery,
          ),
        );
      }

      remaining -= chunkSize;
    }

    return expanded;
  }

  QuestPath _applyAllowedOperations({
    required QuestPath basePath,
    required Set<OperationType>? allowedOperations,
  }) {
    final allowed = allowedOperations;
    if (allowed == null) return basePath;

    final filtered = basePath
        .where((q) => allowed.contains(q.operation))
        .toList(growable: false);

    // If filtering would remove everything (should be rare), keep base path.
    return filtered.isEmpty ? basePath : filtered;
  }

  QuestDefinition? questById({required QuestPath path, required String id}) {
    for (final q in path) {
      if (q.id == id) return q;
    }
    return null;
  }

  String firstQuestId(
    UserProgress user, {
    Set<OperationType>? allowedOperations,
  }) {
    final path = questsForUser(user, allowedOperations: allowedOperations);
    return (path.isNotEmpty ? path.first : defaultQuests.first).id;
  }

  QuestStatus getCurrentStatus({
    required UserProgress user,
    required String? currentQuestId,
    required Set<String> completedQuestIds,
    Set<OperationType>? allowedOperations,
  }) {
    final path = questsForUser(user, allowedOperations: allowedOperations);
    final effectivePath = path.isNotEmpty ? path : defaultQuests;

    QuestDefinition quest;

    final byId = currentQuestId == null
        ? null
        : questById(path: effectivePath, id: currentQuestId);
    if (byId != null && !completedQuestIds.contains(byId.id)) {
      quest = byId;
    } else {
      quest = effectivePath.firstWhere(
        (q) => !completedQuestIds.contains(q.id),
        orElse: () => effectivePath.last,
      );
    }

    final masteryKey = '${quest.operation.name}_${quest.difficulty.name}';
    final rate = (user.masteryLevels[masteryKey] ?? 0.0).clamp(0.0, 1.0);
    final threshold = quest.threshold;

    final progress = threshold <= 0 ? 0.0 : (rate / threshold).clamp(0.0, 1.0);

    return QuestStatus(
      quest: quest,
      masteryRate: rate,
      progress: progress,
      isCompleted: rate >= threshold,
    );
  }

  String? nextQuestId({
    required UserProgress user,
    required String currentQuestId,
    Set<OperationType>? allowedOperations,
  }) {
    final path = questsForUser(user, allowedOperations: allowedOperations);
    final effectivePath = path.isNotEmpty ? path : defaultQuests;

    for (var i = 0; i < effectivePath.length; i++) {
      if (effectivePath[i].id == currentQuestId) {
        final nextIndex = i + 1;
        if (nextIndex >= effectivePath.length) return null;
        return effectivePath[nextIndex].id;
      }
    }
    return null;
  }
}
