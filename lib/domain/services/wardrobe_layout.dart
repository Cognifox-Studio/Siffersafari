/// Where an item's box goes, derived from where its art actually is.
///
/// The old model was `Alignment(0.0, -2.8)` multiplied by
/// `height * (1 - renderScale) / 2` at draw time. Both numbers are unreachable
/// by reading: -2.8 is a position divided by a scale, and adding a hat meant
/// trial and error with a device in hand.
///
/// This is the replacement, and it is pure on purpose: given the art's opaque
/// centre (from the generated manifest) and the point on the character it
/// should land on, the offset falls out of the geometry. Every number is a
/// fraction of the character's height, so it does not matter how large the
/// character is drawn.
library;

/// The distance from the character's centre to the item's box centre, as
/// fractions of the character's height.
///
/// [layoutScale] is the item box's side as a fraction of the character's height
/// (the renderer draws items in a square box and fits the art inside it).
/// [imageAspect] is the art's width divided by its height -- a wide map and a
/// tall hat fill their box differently, which is exactly the thing the old
/// offset could not express.
/// [anchorX]/[anchorY] is the point *in the art* that should land on
/// [targetX]/[targetY]; both pairs use 0.5 as their centre.
({double dx, double dy}) anchoredItemOffset({
  required double layoutScale,
  required double imageAspect,
  required double anchorX,
  required double anchorY,
  required double targetX,
  required double targetY,
}) {
  final box = layoutScale;
  final aspect = imageAspect <= 0 ? 1.0 : imageAspect;

  // BoxFit.contain: the art fills the box along its longer side and is centred
  // along the other, so the anchor point moves with the aspect ratio.
  final double drawWidth;
  final double drawHeight;
  if (aspect >= 1) {
    drawWidth = box;
    drawHeight = box / aspect;
  } else {
    drawWidth = box * aspect;
    drawHeight = box;
  }

  final offsetX = (box - drawWidth) / 2;
  final offsetY = (box - drawHeight) / 2;

  // Distance from the box centre to the anchor point, in the same units.
  final anchorFromBoxX = offsetX + anchorX * drawWidth - box / 2;
  final anchorFromBoxY = offsetY + anchorY * drawHeight - box / 2;

  return (
    dx: targetX - anchorFromBoxX,
    dy: targetY - anchorFromBoxY,
  );
}
