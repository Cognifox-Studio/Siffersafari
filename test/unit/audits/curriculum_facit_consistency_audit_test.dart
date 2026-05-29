import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';

Map<String, dynamic> _loadCurriculumFacit() {
  final file = File('docs/curriculum_facit.json');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'docs/curriculum_facit.json must exist for curriculum audits.',
  );

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  return List<Map<String, dynamic>>.from(value as List);
}

Set<String> _asStringSet(dynamic value) {
  return Set<String>.from((value as List).cast<String>());
}

OperationType _operationFromName(String name) {
  return OperationType.values.firstWhere((operation) => operation.name == name);
}

void main() {
  group('[Unit] Curriculum facit – synced with runtime config', () {
    late Map<String, dynamic> facit;

    setUpAll(() {
      facit = _loadCurriculumFacit();
    });

    test('grade mappings cover all grades 1-9 exactly once', () {
      final gradeMappings = _asMapList(facit['gradeMappings']);
      final grades = gradeMappings
          .map((mapping) => mapping['grade'] as int)
          .toList()
        ..sort();

      expect(grades, equals(List<int>.generate(9, (index) => index + 1)));
    });

    test('source hierarchy ranks are sequential', () {
      final sourceHierarchy = _asMapList(facit['sourceHierarchy']);
      final ranks =
          sourceHierarchy.map((entry) => entry['rank'] as int).toList()..sort();

      expect(
        ranks,
        equals(
          List<int>.generate(
            sourceHierarchy.length,
            (index) => index + 1,
          ),
        ),
      );
    });

    test(
        'visible operations, expected steps and step-10 caps match DifficultyConfig',
        () {
      final gradeMappings = _asMapList(facit['gradeMappings']);

      for (final mapping in gradeMappings) {
        final grade = mapping['grade'] as int;

        final visibleOperationsFromFacit = _asStringSet(
          mapping['visibleOperations'],
        );
        final visibleOperationsFromConfig =
            DifficultyConfig.visibleOperationsForGrade(grade)
                .map((operation) => operation.name)
                .toSet();

        expect(
          visibleOperationsFromFacit,
          equals(visibleOperationsFromConfig),
          reason: 'Visible operations drift for grade $grade.',
        );

        final expectedSteps =
            Map<String, dynamic>.from(mapping['expectedSteps'] as Map);
        for (final operation in OperationType.values.where(
          (value) => value != OperationType.mixed,
        )) {
          final expectedStepFromFacit = expectedSteps[operation.name] as int;
          final expectedStepFromConfig =
              DifficultyConfig.expectedDifficultyStepForGrade(
            gradeLevel: grade,
            operation: operation,
          );

          expect(
            expectedStepFromFacit,
            expectedStepFromConfig,
            reason: 'Expected step drift for grade $grade ${operation.name}.',
          );
        }

        final step10Caps =
            Map<String, dynamic>.from(mapping['step10Caps'] as Map);
        for (final entry in step10Caps.entries) {
          final operation = _operationFromName(entry.key);
          final range = DifficultyConfig.curriculumNumberRangeForStep(
            gradeLevel: grade,
            operationType: operation,
            difficultyStep: DifficultyConfig.maxDifficultyStep,
          );

          expect(
            entry.value,
            range.max,
            reason: 'Step-10 cap drift for grade $grade ${operation.name}.',
          );
        }
      }
    });

    test('addition/subtraction step tables match DifficultyConfig', () {
      final gradeMappings = _asMapList(facit['gradeMappings']);

      for (final mapping in gradeMappings) {
        if (!mapping.containsKey('additionSubtractionStepCaps')) {
          continue;
        }

        final grade = mapping['grade'] as int;
        final stepCaps =
            List<int>.from((mapping['additionSubtractionStepCaps'] as List));

        expect(stepCaps.length, DifficultyConfig.maxDifficultyStep);

        final expectedAddCaps = List<int>.generate(
          DifficultyConfig.maxDifficultyStep,
          (index) => DifficultyConfig.curriculumNumberRangeForStep(
            gradeLevel: grade,
            operationType: OperationType.addition,
            difficultyStep: index + 1,
          ).max,
        );

        final expectedSubCaps = List<int>.generate(
          DifficultyConfig.maxDifficultyStep,
          (index) => DifficultyConfig.curriculumNumberRangeForStep(
            gradeLevel: grade,
            operationType: OperationType.subtraction,
            difficultyStep: index + 1,
          ).max,
        );

        expect(
          stepCaps,
          equals(expectedAddCaps),
          reason: 'Addition step table drift for grade $grade.',
        );
        expect(
          stepCaps,
          equals(expectedSubCaps),
          reason: 'Subtraction step table drift for grade $grade.',
        );
      }
    });

    test('question type policies declare rollout metadata', () {
      final stageIds = _asMapList(
        facit['stages'],
      ).map((entry) => entry['id'] as String).toSet();
      final knowledgeAreaIds = _asMapList(
        facit['knowledgeAreas'],
      ).map((entry) => entry['id'] as String).toSet();
      final questionTypePolicies = _asMapList(facit['questionTypePolicies']);

      for (final policy in questionTypePolicies) {
        final id = policy['id'] as String;

        expect(id, isNotEmpty, reason: 'Question type policy must have id.');
        expect(
          knowledgeAreaIds.contains(policy['skolverketAreaId']),
          isTrue,
          reason: '$id must reference an existing knowledge area.',
        );
        expect(
          stageIds.contains(policy['stage']),
          isTrue,
          reason: '$id must reference an existing stage.',
        );
        expect(
          policy['appStatus'],
          anyOf('NU', 'SEN', 'SAKNAS'),
          reason: '$id must declare appStatus.',
        );
        expect(
          (policy['gate'] as String).trim(),
          isNotEmpty,
          reason: '$id must declare a rollout gate.',
        );

        final minAuditTests =
            List<String>.from((policy['minAuditTests'] as List).cast<String>());
        expect(
          minAuditTests,
          isNotEmpty,
          reason: '$id must declare at least one audit/test dependency.',
        );
      }
    });
  });
}
