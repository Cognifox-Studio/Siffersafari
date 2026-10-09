import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/config/curriculum_facit_loader.dart';

void main() {
  group('[Unit] CurriculumFacitLoader', () {
    test('parseJson reads schemaVersion and grade levels', () {
      final json = File('docs/curriculum_facit.json').readAsStringSync();
      final snapshot = CurriculumFacitLoader.parseJson(json);

      expect(snapshot.schemaVersion, greaterThan(0));
      expect(snapshot.gradeLevels, contains(1));
      expect(snapshot.gradeLevels, contains(9));
    });
  });
}
