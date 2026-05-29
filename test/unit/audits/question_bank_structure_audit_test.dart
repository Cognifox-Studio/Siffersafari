import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _loadQuestionBank(int grade) {
  final file = File('docs/grade_${grade}_question_bank.json');
  expect(
    file.existsSync(),
    isTrue,
    reason: 'docs/grade_${grade}_question_bank.json must exist.',
  );

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  return List<Map<String, dynamic>>.from(value as List);
}

void main() {
  group('[Unit] Question banks – structure', () {
    const declaredQuestionCounts = <int, int>{
      1: 100,
      2: 110,
      3: 120,
      4: 120,
      5: 140,
      6: 130,
      7: 140,
      8: 140,
      9: 150,
    };

    for (final entry in declaredQuestionCounts.entries) {
      final grade = entry.key;
      final declaredQuestionCount = entry.value;

      test('grade $grade bank has valid counts and unique question ids', () {
        final bank = _loadQuestionBank(grade);

        expect(bank['schemaVersion'], 1);
        expect(bank['grade'], grade);
        expect(bank['notCanonicalFacit'], isTrue);

        final coverage = Map<String, dynamic>.from(bank['coverage'] as Map);
        final countsBySection = Map<String, dynamic>.from(
          coverage['countsBySection'] as Map,
        );
        final declaredCountsBySection = Map<String, dynamic>.from(
          coverage['declaredCountsBySection'] as Map,
        );
        final sections = _asMapList(bank['sections']);
        final seenIds = <String>{};

        var actualQuestionCount = 0;
        var actualDeclaredQuestionCount = 0;

        for (final section in sections) {
          final sectionId = section['id'] as String;
          final questions = _asMapList(section['questions']);
          final sectionQuestionCount = section['questionCount'] as int;
          final sectionDeclaredQuestionCount =
              section['declaredQuestionCount'] as int;

          expect(
            sectionQuestionCount,
            questions.length,
            reason: 'Section $sectionId in grade $grade has stale count.',
          );
          expect(countsBySection[sectionId], sectionQuestionCount);
          expect(
            declaredCountsBySection[sectionId],
            sectionDeclaredQuestionCount,
          );

          actualQuestionCount += sectionQuestionCount;
          actualDeclaredQuestionCount += sectionDeclaredQuestionCount;

          for (final question in questions) {
            final id = question['id'] as String;
            expect(id, isNotEmpty);
            expect(seenIds.add(id), isTrue, reason: 'Duplicate id $id.');
            expect((question['prompt'] as String).trim(), isNotEmpty);
            expect((question['responseType'] as String).trim(), isNotEmpty);
          }
        }

        expect(coverage['questionCount'], actualQuestionCount);
        expect(coverage['declaredQuestionCount'], actualDeclaredQuestionCount);
        expect(actualDeclaredQuestionCount, declaredQuestionCount);

        final qualityNotes = List<String>.from(
          (bank['qualityNotes'] as List).cast<String>(),
        ).join('\n');

        if (actualQuestionCount != actualDeclaredQuestionCount) {
          expect(
            qualityNotes,
            contains('declares'),
            reason: 'Count mismatch in grade $grade must be documented.',
          );
        }

        final headlineQuestionCount = coverage['headlineQuestionCount'] as int?;
        if (headlineQuestionCount != null &&
            headlineQuestionCount != actualDeclaredQuestionCount) {
          expect(
            qualityNotes,
            contains('Grade headline declares'),
            reason: 'Headline mismatch in grade $grade must be documented.',
          );
        }
      });
    }
  });
}
