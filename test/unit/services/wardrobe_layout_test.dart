import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/wardrobe_layout.dart';

void main() {
  group('[Unit] WardrobeLayout', () {
    test('mitten av en kvadratisk bild på mitten ger noll förskjutning', () {
      final offset = anchoredItemOffset(
        layoutScale: 0.8,
        imageAspect: 1,
        anchorX: 0.5,
        anchorY: 0.5,
        targetX: 0,
        targetY: 0,
      );

      expect(offset.dx, closeTo(0, 1e-9));
      expect(offset.dy, closeTo(0, 1e-9));
    });

    test('målpunkten flyttar plagget lika mycket', () {
      final offset = anchoredItemOffset(
        layoutScale: 0.5,
        imageAspect: 1,
        anchorX: 0.5,
        anchorY: 0.5,
        targetX: 0.1,
        targetY: -0.25,
      );

      expect(offset.dx, closeTo(0.1, 1e-9));
      expect(offset.dy, closeTo(-0.25, 1e-9));
    });

    test('bred bild: ankaret i bildens nederkant lyfter plagget', () {
      // A 2:1 map is letterboxed inside the square box, so its bottom edge sits
      // a quarter of a box below the box centre.
      final offset = anchoredItemOffset(
        layoutScale: 0.6,
        imageAspect: 2,
        anchorX: 0.5,
        anchorY: 1,
        targetX: 0,
        targetY: 0,
      );

      expect(offset.dx, closeTo(0, 1e-9));
      expect(
        offset.dy,
        closeTo(-0.6 * 0.25, 1e-9),
        reason: 'Ankaret i nederkant ska dra plagget uppåt med en kvarts box',
      );
    });

    test('hög bild: ankaret i bildens nederkant lyfter mer', () {
      // A 1:2 tall image fills the box vertically, so its bottom edge is half a
      // box below the centre -- twice the wide case.
      final offset = anchoredItemOffset(
        layoutScale: 0.6,
        imageAspect: 0.5,
        anchorX: 0.5,
        anchorY: 1,
        targetX: 0,
        targetY: 0,
      );

      expect(offset.dy, closeTo(-0.6 * 0.5, 1e-9));
    });

    test('trasig bildbredd faller tillbaka på kvadrat', () {
      final offset = anchoredItemOffset(
        layoutScale: 0.5,
        imageAspect: 0,
        anchorX: 0.5,
        anchorY: 0.5,
        targetX: 0,
        targetY: 0,
      );

      expect(offset.dy, closeTo(0, 1e-9));
    });
  });
}
