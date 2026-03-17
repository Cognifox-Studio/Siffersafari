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

        final rivePath = AssetPaths.characterRive(id);
        if (rivePath != null) {
          expect(
            File(rivePath).existsSync(),
            isTrue,
            reason: 'Missing Rive runtime for $id',
          );
        }
      }
    });

    test('all UI effect asset paths exist on disk', () {
      for (final id in UiEffectId.values) {
        expect(
          File(AssetPaths.uiEffect(id)).existsSync(),
          isTrue,
          reason: 'Missing UI effect for $id',
        );
      }
    });
  });
}
