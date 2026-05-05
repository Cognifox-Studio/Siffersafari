import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _defaultOutputPath = 'site/project-map/graph-data.js';

const _columnLabels = <String, String>{
  'entry': 'Appstart',
  'features': 'Skärmar & UI',
  'state': 'Tillstånd & kopplingar',
  'services': 'Tjänster',
  'foundation': 'Modeller & lagring',
};

Future<void> main(List<String> args) async {
  final config = _CliConfig.parse(args);
  final repoRoot = _resolveRepoRoot();
  final generator = _ProjectMapGenerator(
    repoRoot: repoRoot,
    outputFile: File(_joinPaths(repoRoot.path, config.outputPath)),
  );

  await generator.generate();

  if (!config.watch) {
    return;
  }

  stdout.writeln('[project-map] Watching lib/ for changes...');
  await generator.watch();
}

Directory _resolveRepoRoot() {
  final scriptFile = File.fromUri(Platform.script);
  return scriptFile.parent.parent;
}

class _CliConfig {
  const _CliConfig({required this.watch, required this.outputPath});

  final bool watch;
  final String outputPath;

  static _CliConfig parse(List<String> args) {
    var watch = false;
    var outputPath = _defaultOutputPath;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];
      switch (arg) {
        case '--watch':
          watch = true;
        case '--output':
          if (index + 1 >= args.length) {
            throw ArgumentError('--output requires a file path');
          }
          outputPath = args[index + 1];
          index++;
        case '--help':
        case '-h':
          stdout.writeln(
            'Usage: dart run scripts/generate_project_map.dart [--watch] [--output path]',
          );
          exit(0);
      }
    }

    return _CliConfig(watch: watch, outputPath: outputPath);
  }
}

class _ProjectMapGenerator {
  _ProjectMapGenerator({required this.repoRoot, required this.outputFile});

  final Directory repoRoot;
  final File outputFile;

  Future<void> generate() async {
    final libDir = Directory(_joinPaths(repoRoot.path, 'lib'));
    if (!libDir.existsSync()) {
      throw StateError('Could not find lib/ under ${repoRoot.path}');
    }

    final dartFiles = await _collectDartFiles(libDir);
    final knownFiles = dartFiles.map((file) => file.relativePath).toSet();
    final modules = <String, _ModuleAccumulator>{};
    final fileToModule = <String, String>{};
    final edges = <String, _EdgeAccumulator>{};

    for (final sourceFile in dartFiles) {
      final moduleInfo = _classifyModule(sourceFile.relativePath);
      final module = modules.putIfAbsent(
        moduleInfo.id,
        () => _ModuleAccumulator(moduleInfo),
      );
      module.addFile(sourceFile.relativePath);
      fileToModule[sourceFile.relativePath] = moduleInfo.id;
    }

    for (final sourceFile in dartFiles) {
      final sourceModuleId = fileToModule[sourceFile.relativePath]!;
      final imports = _extractResolvedImports(
        sourceFile: sourceFile,
        knownFiles: knownFiles,
      );

      for (final targetPath in imports) {
        final targetModuleId = fileToModule[targetPath];
        if (targetModuleId == null || targetModuleId == sourceModuleId) {
          continue;
        }

        final edgeKey = '$sourceModuleId::$targetModuleId';
        final edge = edges.putIfAbsent(
          edgeKey,
          () => _EdgeAccumulator(sourceModuleId, targetModuleId),
        );
        edge.addExample(sourceFile.relativePath, targetPath);
      }
    }

    final sortedModules = modules.values.toList()
      ..sort((left, right) {
        final columnCompare = _columnOrder(left.info.column)
            .compareTo(_columnOrder(right.info.column));
        if (columnCompare != 0) {
          return columnCompare;
        }
        return left.info.label.compareTo(right.info.label);
      });

    final sortedEdges = edges.values.toList()
      ..sort((left, right) => right.weight.compareTo(left.weight));

    final data = <String, Object?>{
      'generatedAt': DateTime.now().toIso8601String(),
      'repoRoot': _normalizePath(repoRoot.path),
      'stats': <String, Object?>{
        'dartFiles': dartFiles.length,
        'modules': sortedModules.length,
        'edges': sortedEdges.length,
      },
      'columns': _columnLabels.entries
          .map(
            (entry) => <String, String>{
              'id': entry.key,
              'label': entry.value,
            },
          )
          .toList(growable: false),
      'modules': sortedModules.map((module) => module.toJson()).toList(),
      'edges': sortedEdges.map((edge) => edge.toJson()).toList(),
    };

    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsString(
      'window.__PROJECT_GRAPH__ = ${const JsonEncoder.withIndent('  ').convert(data)};\n',
    );

    stdout.writeln(
      '[project-map] Wrote ${_relativeToRoot(outputFile.path, repoRoot.path)} '
      '(${dartFiles.length} dart files, ${sortedModules.length} modules, ${sortedEdges.length} edges)',
    );
  }

  Future<void> watch() async {
    final libDir = Directory(_joinPaths(repoRoot.path, 'lib'));
    Timer? debounceTimer;

    await for (final event in libDir.watch(recursive: true)) {
      if (!_isRelevantEvent(event)) {
        continue;
      }

      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 700), () async {
        try {
          await generate();
        } catch (error, stackTrace) {
          stderr.writeln('[project-map] Failed to regenerate: $error');
          stderr.writeln(stackTrace);
        }
      });
    }
  }
}

bool _isRelevantEvent(FileSystemEvent event) {
  if (event is FileSystemModifyEvent && event.contentChanged == false) {
    return false;
  }

  final normalizedPath = _normalizePath(event.path);
  return normalizedPath.endsWith('.dart');
}

Future<List<_SourceFile>> _collectDartFiles(Directory libDir) async {
  final files = <_SourceFile>[];

  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final relativePath = _relativeToRoot(entity.path, libDir.parent.path);
    final contents = await entity.readAsString();
    files.add(_SourceFile(relativePath: relativePath, contents: contents));
  }

  files.sort((left, right) => left.relativePath.compareTo(right.relativePath));
  return files;
}

Set<String> _extractResolvedImports({
  required _SourceFile sourceFile,
  required Set<String> knownFiles,
}) {
  final matches = RegExp(
    r'''^\s*(?:import|export)\s+['\"]([^'\"]+)['\"]''',
    multiLine: true,
  ).allMatches(sourceFile.contents);

  final resolved = <String>{};
  for (final match in matches) {
    final rawImport = match.group(1);
    if (rawImport == null) {
      continue;
    }

    final target = _resolveImport(sourceFile.relativePath, rawImport);
    if (target == null || !knownFiles.contains(target)) {
      continue;
    }
    resolved.add(target);
  }

  return resolved;
}

String? _resolveImport(String sourcePath, String rawImport) {
  if (rawImport.startsWith('dart:') ||
      rawImport.startsWith('package:flutter')) {
    return null;
  }

  if (rawImport.startsWith('package:siffersafari/')) {
    return 'lib/${rawImport.substring('package:siffersafari/'.length)}';
  }

  if (!rawImport.startsWith('.')) {
    return null;
  }

  final sourceSegments = sourcePath.split('/');
  final directorySegments = sourceSegments.take(sourceSegments.length - 1);
  final importSegments = rawImport.split('/');

  final resolved = <String>[];
  resolved.addAll(directorySegments);
  for (final segment in importSegments) {
    if (segment.isEmpty || segment == '.') {
      continue;
    }
    if (segment == '..') {
      if (resolved.isNotEmpty) {
        resolved.removeLast();
      }
      continue;
    }
    resolved.add(segment);
  }

  if (resolved.isEmpty || resolved.first != 'lib') {
    return null;
  }

  return resolved.join('/');
}

_ModuleInfo _classifyModule(String relativePath) {
  final segments = relativePath.split('/');
  if (relativePath == 'lib/main.dart') {
    return const _ModuleInfo(
      id: 'main',
      label: 'Appens startfil',
      technicalLabel: 'main.dart',
      description: 'Första filen som startar Flutter-appen.',
      path: 'lib/main.dart',
      column: 'entry',
      kind: 'entrypoint',
      kindLabel: 'start',
    );
  }

  if (segments.length >= 3 && segments[1] == 'features') {
    final featureName = segments[2];
    return _ModuleInfo(
      id: 'feature:$featureName',
      label: _friendlyFeatureLabel(featureName),
      technicalLabel: 'features/$featureName',
      description:
          'Skärmar, dialoger och widgets för ${_friendlyFeatureLabel(featureName).toLowerCase()}.',
      path: 'lib/features/$featureName',
      column: 'features',
      kind: 'feature',
      kindLabel: 'feature',
    );
  }

  if (segments.length >= 3 && segments[1] == 'presentation') {
    return _ModuleInfo(
      id: 'presentation/${segments[2]}',
      label: 'Delad UI',
      technicalLabel: 'presentation/${segments[2]}',
      description: 'UI-komponenter som delas mellan flera delar av appen.',
      path: 'lib/presentation/${segments[2]}',
      column: 'features',
      kind: 'shared-ui',
      kindLabel: 'delad UI',
    );
  }

  if (segments.length >= 3 && segments[1] == 'app') {
    final bucket = segments[2];
    return _ModuleInfo(
      id: 'app/$bucket',
      label: bucket == 'bootstrap' ? 'Appstart' : _humanizeLabel(bucket),
      technicalLabel: 'app/$bucket',
      description: bucket == 'bootstrap'
          ? 'Bestämmer hur appen startar och vart användaren skickas först.'
          : 'Grundläggande appflöde och uppstart.',
      path: 'lib/app/$bucket',
      column: 'entry',
      kind: 'app',
      kindLabel: 'appflöde',
    );
  }

  if (segments.length >= 3 && segments[1] == 'core') {
    final bucket = segments[2];
    return _ModuleInfo(
      id: 'core/$bucket',
      label: _friendlyCoreLabel(bucket),
      technicalLabel: 'core/$bucket',
      description: _friendlyCoreDescription(bucket),
      path: 'lib/core/$bucket',
      column: _columnForCoreBucket(bucket),
      kind: 'core',
      kindLabel: 'grundsystem',
    );
  }

  if (segments.length >= 3 && segments[1] == 'domain') {
    final bucket = segments[2];
    return _ModuleInfo(
      id: 'domain/$bucket',
      label: _friendlyDomainLabel(bucket),
      technicalLabel: 'domain/$bucket',
      description: _friendlyDomainDescription(bucket),
      path: 'lib/domain/$bucket',
      column: bucket == 'services' ? 'services' : 'foundation',
      kind: 'domain',
      kindLabel: 'affärsregler',
    );
  }

  if (segments.length >= 3 && segments[1] == 'data') {
    final bucket = segments[2];
    return _ModuleInfo(
      id: 'data/$bucket',
      label: _friendlyDataLabel(bucket),
      technicalLabel: 'data/$bucket',
      description: _friendlyDataDescription(bucket),
      path: 'lib/data/$bucket',
      column: 'foundation',
      kind: 'data',
      kindLabel: 'lagring',
    );
  }

  if (segments.length >= 2 && segments[1] == 'shared') {
    return const _ModuleInfo(
      id: 'shared',
      label: 'Delat',
      technicalLabel: 'shared',
      description: 'Kod som delas brett i projektet.',
      path: 'lib/shared',
      column: 'features',
      kind: 'shared',
      kindLabel: 'delat',
    );
  }

  if (segments.length >= 2 && segments[1] == 'gen') {
    return const _ModuleInfo(
      id: 'gen',
      label: 'Genererad kod',
      technicalLabel: 'gen',
      description:
          'Kod som genereras automatiskt och normalt inte skrivs för hand.',
      path: 'lib/gen',
      column: 'foundation',
      kind: 'generated',
      kindLabel: 'genererat',
    );
  }

  return _ModuleInfo(
    id: relativePath,
    label: _humanizeLabel(relativePath.replaceFirst('lib/', '')),
    technicalLabel: relativePath.replaceFirst('lib/', ''),
    description: 'Övrig kod som inte grupperats i en tydligare modul ännu.',
    path: relativePath,
    column: 'foundation',
    kind: 'other',
    kindLabel: 'övrigt',
  );
}

String _friendlyFeatureLabel(String featureName) {
  switch (featureName) {
    case 'daily_challenge':
      return 'Daglig utmaning';
    case 'home':
      return 'Hem';
    case 'onboarding':
      return 'Första gången';
    case 'parent':
      return 'Föräldraläge';
    case 'profiles':
      return 'Profiler';
    case 'quiz':
      return 'Quiz';
    case 'settings':
      return 'Inställningar';
    case 'story':
      return 'Storykarta';
    default:
      return _humanizeLabel(featureName);
  }
}

String _friendlyCoreLabel(String bucket) {
  switch (bucket) {
    case 'config':
      return 'Konfiguration';
    case 'constants':
      return 'Konstanter';
    case 'di':
      return 'Tjänstkoppling';
    case 'providers':
      return 'Tillstånd';
    case 'services':
      return 'Apptjänster';
    case 'theme':
      return 'Tema';
    case 'utils':
      return 'Hjälpfunktioner';
    default:
      return _humanizeLabel(bucket);
  }
}

String _friendlyCoreDescription(String bucket) {
  switch (bucket) {
    case 'config':
      return 'Samlad konfiguration och funktionsflaggor för appen.';
    case 'constants':
      return 'Fasta värden och nycklar som används på flera ställen.';
    case 'di':
      return 'Registrerar vilka tjänster appen kan hämta globalt via GetIt.';
    case 'providers':
      return 'Riverpod-state som UI:t läser och uppdaterar.';
    case 'services':
      return 'Återanvändbar appnära logik som ljud, frågor och progression.';
    case 'theme':
      return 'Färger, typografi och andra visuella teman.';
    case 'utils':
      return 'Små hjälpfunktioner och stödlogik.';
    default:
      return 'Grundläggande systemkod för appen.';
  }
}

String _friendlyDomainLabel(String bucket) {
  switch (bucket) {
    case 'constants':
      return 'Domänkonstanter';
    case 'entities':
      return 'Datamodeller';
    case 'enums':
      return 'Typer & val';
    case 'services':
      return 'Domänregler';
    default:
      return _humanizeLabel(bucket);
  }
}

String _friendlyDomainDescription(String bucket) {
  switch (bucket) {
    case 'constants':
      return 'Fasta regler och standardvärden för matte- och inlärningsdomänen.';
    case 'entities':
      return 'Grundläggande datamodeller som frågor, profiler och progression.';
    case 'enums':
      return 'Valbara typer och nivåer som används i affärslogiken.';
    case 'services':
      return 'Ren affärslogik utan UI, till exempel svårighetsgrad och PIN-regler.';
    default:
      return 'Domänkod som beskriver hur appen fungerar på affärsnivå.';
  }
}

String _friendlyDataLabel(String bucket) {
  switch (bucket) {
    case 'repositories':
      return 'Lagring';
    default:
      return _humanizeLabel(bucket);
  }
}

String _friendlyDataDescription(String bucket) {
  switch (bucket) {
    case 'repositories':
      return 'Läser och sparar lokal data, främst via Hive.';
    default:
      return 'Kod för att läsa och skriva data.';
  }
}

String _humanizeLabel(String value) {
  final pieces = value
      .split(RegExp(r'[/_-]'))
      .where((piece) => piece.isNotEmpty)
      .map((piece) => '${piece[0].toUpperCase()}${piece.substring(1)}');
  return pieces.join(' ');
}

String _columnForCoreBucket(String bucket) {
  switch (bucket) {
    case 'providers':
    case 'di':
      return 'state';
    case 'services':
      return 'services';
    default:
      return 'foundation';
  }
}

int _columnOrder(String column) {
  switch (column) {
    case 'entry':
      return 0;
    case 'features':
      return 1;
    case 'state':
      return 2;
    case 'services':
      return 3;
    default:
      return 4;
  }
}

String _detectRole(String relativePath) {
  final fileName = relativePath.split('/').last;
  if (fileName == 'main.dart') {
    return 'entrypoint';
  }
  if (fileName.endsWith('_screen.dart')) {
    return 'screen';
  }
  if (fileName.endsWith('_dialog.dart')) {
    return 'dialog';
  }
  if (fileName.endsWith('_widget.dart')) {
    return 'widget';
  }
  if (fileName.endsWith('_provider.dart')) {
    return 'provider';
  }
  if (fileName.endsWith('_notifier.dart')) {
    return 'notifier';
  }
  if (fileName.endsWith('_service.dart')) {
    return 'service';
  }
  if (fileName.endsWith('_repository.dart')) {
    return 'repository';
  }
  if (relativePath.contains('/entities/')) {
    return 'entity';
  }
  if (relativePath.contains('/enums/')) {
    return 'enum';
  }
  if (relativePath.contains('/config/')) {
    return 'config';
  }
  if (relativePath.contains('/constants/')) {
    return 'constant';
  }
  return 'dart';
}

String _joinPaths(String left, String right) {
  return _normalizePath('$left${Platform.pathSeparator}$right');
}

String _relativeToRoot(String path, String rootPath) {
  final normalizedPath = _normalizePath(path);
  final normalizedRoot = _normalizePath(rootPath);
  if (normalizedPath.startsWith('$normalizedRoot/')) {
    return normalizedPath.substring(normalizedRoot.length + 1);
  }
  return normalizedPath;
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

class _SourceFile {
  const _SourceFile({required this.relativePath, required this.contents});

  final String relativePath;
  final String contents;
}

class _ModuleInfo {
  const _ModuleInfo({
    required this.id,
    required this.label,
    required this.technicalLabel,
    required this.description,
    required this.path,
    required this.column,
    required this.kind,
    required this.kindLabel,
  });

  final String id;
  final String label;
  final String technicalLabel;
  final String description;
  final String path;
  final String column;
  final String kind;
  final String kindLabel;
}

class _ModuleAccumulator {
  _ModuleAccumulator(this.info);

  final _ModuleInfo info;
  final Set<String> _files = <String>{};
  final Map<String, int> _roleCounts = <String, int>{};

  void addFile(String relativePath) {
    _files.add(relativePath);
    final role = _detectRole(relativePath);
    _roleCounts.update(role, (value) => value + 1, ifAbsent: () => 1);
  }

  Map<String, Object?> toJson() {
    final files = _files.toList()..sort();
    final roleCounts = Map<String, int>.fromEntries(
      _roleCounts.entries.toList()
        ..sort((left, right) => left.key.compareTo(right.key)),
    );

    return <String, Object?>{
      'id': info.id,
      'label': info.label,
      'technicalLabel': info.technicalLabel,
      'description': info.description,
      'path': info.path,
      'column': info.column,
      'kind': info.kind,
      'kindLabel': info.kindLabel,
      'fileCount': files.length,
      'roleCounts': roleCounts,
      'files': files,
    };
  }
}

class _EdgeAccumulator {
  _EdgeAccumulator(this.source, this.target);

  final String source;
  final String target;
  final Set<String> _examples = <String>{};
  int weight = 0;

  void addExample(String from, String to) {
    weight++;
    if (_examples.length >= 5) {
      return;
    }
    _examples.add('$from->$to');
  }

  Map<String, Object?> toJson() {
    final examples = _examples.toList()..sort();
    return <String, Object?>{
      'source': source,
      'target': target,
      'weight': weight,
      'examples': examples.map((pair) {
        final parts = pair.split('->');
        return <String, String>{
          'from': parts.first,
          'to': parts.last,
        };
      }).toList(growable: false),
    };
  }
}
