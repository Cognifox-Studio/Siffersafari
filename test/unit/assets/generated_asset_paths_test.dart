import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/gen/assets.g.dart';

void main() {
  group('[Unit] Generated asset paths', () {
    test('all character asset paths exist on disk', () {
      for (final id in CharacterId.values) {
        expect(
          File(AssetPaths.characterCompositeSvg(id)).existsSync(),
          isTrue,
          reason: 'Missing composite SVG for $id',
        );
      }
    });
  });
}
