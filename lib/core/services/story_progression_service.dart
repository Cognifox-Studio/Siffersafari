import 'package:siffersafari/domain/entities/quest.dart';
import 'package:siffersafari/domain/entities/story_progress.dart';
import 'package:siffersafari/domain/enums/difficulty_level.dart';

class StoryProgressionService {
  const StoryProgressionService();

  static const _upcomingBiomes = <DifficultyLevel, StoryBiomePreview>{
    DifficultyLevel.easy: StoryBiomePreview(
      name: 'Nattskogen',
      tagline: 'Spela fler stopp först.',
      previewPrefix: 'Efter djungeln',
      previewBody: 'Fler stopp först.',
    ),
    DifficultyLevel.medium: StoryBiomePreview(
      name: 'Stjärnöknen',
      tagline: 'Fortsätt genom skymningen först.',
      previewPrefix: 'Efter natten',
      previewBody: 'Fler stopp först.',
    ),
  };

  static const _landmarks = <_LandmarkData>[
    _LandmarkData(
      'Startlägret',
      'Maskoten packar verktygen inför uppdraget.',
      'baslager',
    ),
    _LandmarkData(
      'Fruktgläntan',
      'Samla sifferfrukter till bron.',
      'frukt',
    ),
    _LandmarkData(
      'Skuggstigen',
      'Följ ledtrådarna som visar var plankorna ligger.',
      'skugga',
    ),
    _LandmarkData(
      'Djungelbron',
      'Bron är trasig. Vi måste laga den tillsammans.',
      'bro',
    ),
    _LandmarkData(
      'Kartlägret',
      'En ny kartbit visar vägen till nästa delmål.',
      'karta',
    ),
    _LandmarkData(
      'Forsgläntan',
      'Vattnet dånar och siffrorna måste fångas i farten.',
      'fors',
    ),
    _LandmarkData(
      'Tempelporten',
      'Stora stenar markerar vägen till något större.',
      'tempel',
    ),
    _LandmarkData(
      'Soltemplet',
      'Det gyllene templet väntar längst in i djungeln.',
      'soltempel',
    ),
    _LandmarkData(
      'Ormbunksängen',
      'Höga ormbunkar döljer nya spår i marken.',
      'skog',
    ),
    _LandmarkData(
      'Trumgläntan',
      'Djupa rytmer ekar mellan träden.',
      'trumma',
    ),
    _LandmarkData(
      'Månporten',
      'En stenbåge markerar vägen vidare i skymningen.',
      'port',
    ),
    _LandmarkData(
      'Safirfallet',
      'Kallt vatten glittrar mellan klipporna.',
      'fors',
    ),
    _LandmarkData(
      'Kartutkiken',
      'Härifrån syns flera stigar samtidigt.',
      'karta',
    ),
    _LandmarkData(
      'Skattkammaren',
      'Gamla kistor och symboler täcker marken.',
      'skatt',
    ),
    _LandmarkData(
      'Väktartrappan',
      'Stegen uppåt kräver mod och skärpa.',
      'tempel',
    ),
    _LandmarkData(
      'Solterrassen',
      'Ljusstrålar visar den sista delen av stigen.',
      'soltempel',
    ),
    _LandmarkData(
      'Trädkojan',
      'Expeditionen samlar kraft inför nästa etapp.',
      'koja',
    ),
    _LandmarkData(
      'Mangolunden',
      'Färska frukter markerar en trygg rastplats.',
      'frukt',
    ),
    _LandmarkData(
      'Skymningsstigen',
      'Solen sjunker men ledtrådarna lyser upp vägen.',
      'skugga',
    ),
    _LandmarkData(
      'Guldbron',
      'Den sista bron leder rakt mot målet.',
      'bro',
    ),
  ];

  StoryProgress createStoryProgress({
    required List<QuestDefinition> path,
    required QuestStatus currentStatus,
    required Set<String> completedQuestIds,
    String? notice,
  }) {
    final effectivePath =
        path.isNotEmpty ? path : <QuestDefinition>[currentStatus.quest];

    var currentNodeIndex = 0;
    for (var i = 0; i < effectivePath.length; i++) {
      if (effectivePath[i].id == currentStatus.quest.id) {
        currentNodeIndex = i;
        break;
      }
    }

    final completedNodes = effectivePath
        .where((quest) => completedQuestIds.contains(quest.id))
        .length;

    final nodes = List<StoryNode>.generate(effectivePath.length, (index) {
      final quest = effectivePath[index];
      final landmark = _landmarks[index % _landmarks.length];
      final state = completedQuestIds.contains(quest.id)
          ? StoryNodeState.completed
          : index == currentNodeIndex
              ? StoryNodeState.current
              : StoryNodeState.upcoming;

      return StoryNode(
        id: quest.id,
        title: quest.title,
        operation: quest.operation,
        difficulty: quest.difficulty,
        state: state,
        landmark: landmark.name,
        landmarkHint: landmark.hint,
        sceneTag: landmark.sceneTag,
        stepIndex: index,
      );
    });

    final chapterOne = currentStatus.quest.difficulty == DifficultyLevel.easy;
    final objectiveBeat = _objectiveBeatFor(
      index: currentNodeIndex,
      chapterOne: chapterOne,
    );

    return StoryProgress(
      worldTitle: 'Maskoten i djungeln',
      worldSubtitle: chapterOne
          ? 'Kapitel 1: Hjälp maskoten att laga den trasiga bron.'
          : 'Följ stigen genom djungeln och lås upp nya platser.',
      chapterTitle: _chapterTitleFor(currentStatus.quest.difficulty),
      currentObjectiveTitle:
          chapterOne ? objectiveBeat.title : currentStatus.quest.title,
      currentObjectiveDescription:
          chapterOne ? objectiveBeat.body : currentStatus.quest.description,
      progress: currentStatus.progress.clamp(0.0, 1.0),
      completedNodes: completedNodes,
      totalNodes: effectivePath.length,
      currentNodeIndex: currentNodeIndex,
      nodes: nodes,
      nextBiome: _nextBiomeFor(
        difficulty: currentStatus.quest.difficulty,
        isFinalNode: currentNodeIndex >= effectivePath.length - 1,
      ),
      notice: notice,
    );
  }

  StoryBiomePreview? _nextBiomeFor({
    required DifficultyLevel difficulty,
    required bool isFinalNode,
  }) {
    if (isFinalNode) {
      return null;
    }

    return _upcomingBiomes[difficulty];
  }

  String _chapterTitleFor(DifficultyLevel difficulty) {
    switch (difficulty.name) {
      case 'easy':
        return 'Kapitel 1: Den trasiga bron';
      case 'medium':
        return 'Kapitel 2: Djupare in i jungeln';
      case 'hard':
        return 'Kapitel 3: Templet i dimman';
    }

    return 'Junglexpediton';
  }

  _StoryBeat _objectiveBeatFor({
    required int index,
    required bool chapterOne,
  }) {
    if (!chapterOne) {
      return const _StoryBeat(
        title: 'Nästa uppdrag',
        body: 'Lös uppdraget för att gå vidare på stigen.',
      );
    }

    final beats = <_StoryBeat>[
      const _StoryBeat(
        title: 'Uppdrag: Hämta rep',
        body: 'Lös talen så hittar vi rep till bron.',
      ),
      const _StoryBeat(
        title: 'Uppdrag: Samla plankor',
        body: 'Räkna rätt och samla plankor i gläntan.',
      ),
      const _StoryBeat(
        title: 'Uppdrag: Hitta verktyg',
        body: 'Vi behöver verktyg för att laga bron.',
      ),
      const _StoryBeat(
        title: 'Uppdrag: Laga bron',
        body: 'Några rätt till och bron blir stabil.',
      ),
      const _StoryBeat(
        title: 'Uppdrag: Testa bron',
        body: 'Bra jobbat! Nu testar vi om bron håller.',
      ),
      const _StoryBeat(
        title: 'Uppdrag: Vidare mot templet',
        body: 'Bron håller. Nu går vi mot nästa delmål.',
      ),
    ];

    final safeIndex = index.clamp(0, beats.length - 1);
    return beats[safeIndex];
  }
}

class _StoryBeat {
  const _StoryBeat({required this.title, required this.body});

  final String title;
  final String body;
}

class _LandmarkData {
  const _LandmarkData(this.name, this.hint, this.sceneTag);

  final String name;
  final String hint;
  final String sceneTag;
}
