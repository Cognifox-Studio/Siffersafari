import 'dart:convert';

/// Loads curriculum metadata from [docs/curriculum_facit.json] (tests / tooling).
class CurriculumFacitLoader {
  const CurriculumFacitLoader._();

  static CurriculumFacitSnapshot parseJson(String jsonSource) {
    final decoded = jsonDecode(jsonSource);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('curriculum_facit root must be an object');
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! int) {
      throw FormatException('curriculum_facit.schemaVersion must be int');
    }

    final stages = decoded['stages'];
    if (stages is! List) {
      throw FormatException('curriculum_facit.stages must be a list');
    }

    final gradeLevels = <int>{};
    for (final stage in stages) {
      if (stage is! Map<String, dynamic>) continue;
      final grades = stage['grades'];
      if (grades is! List) continue;
      for (final g in grades) {
        if (g is int) gradeLevels.add(g);
      }
    }

    return CurriculumFacitSnapshot(
      schemaVersion: schemaVersion,
      gradeLevels: gradeLevels.toList()..sort(),
    );
  }
}

class CurriculumFacitSnapshot {
  const CurriculumFacitSnapshot({
    required this.schemaVersion,
    required this.gradeLevels,
  });

  final int schemaVersion;
  final List<int> gradeLevels;
}
