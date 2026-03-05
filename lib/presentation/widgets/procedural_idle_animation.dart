import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Procedural idle animation using CustomPaint.
/// 
/// Renders a character image with separate animated "parts":
/// - Body (slight sway)
/// - Head (gentle nod + rotation)
/// - Arms (gentle swing)
/// - Eyes (blink + look around)
/// 
/// This is a proof-of-concept for animating a static sprite without frame sheets.
class ProceduralIdleAnimation extends StatefulWidget {
  const ProceduralIdleAnimation({
    super.key,
    required this.assetPath,
    this.size = const Size(200, 300),
    this.breatheDuration = const Duration(milliseconds: 2000),
    this.headNodDuration = const Duration(milliseconds: 1500),
    this.armSwayDuration = const Duration(milliseconds: 1800),
  });

  final String assetPath;
  final Size size;
  final Duration breatheDuration;
  final Duration headNodDuration;
  final Duration armSwayDuration;

  @override
  State<ProceduralIdleAnimation> createState() =>
      _ProceduralIdleAnimationState();
}

class _ProceduralIdleAnimationState extends State<ProceduralIdleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _headNodController;
  late AnimationController _armSwayController;
  late AnimationController _blinkController;

  ui.Image? _image;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadImage();
  }

  void _initControllers() {
    _breatheController = AnimationController(
      vsync: this,
      duration: widget.breatheDuration,
    )..repeat(reverse: true);

    _headNodController = AnimationController(
      vsync: this,
      duration: widget.headNodDuration,
    )..repeat(reverse: true);

    _armSwayController = AnimationController(
      vsync: this,
      duration: widget.armSwayDuration,
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _blinkController.repeat(
      min: 0,
      max: 1,
      period: const Duration(seconds: 3),
    );
  }

  Future<void> _loadImage() async {
    try {
      final data = await DefaultAssetBundle.of(context)
          .load(widget.assetPath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      setState(() {
        _image = frame.image;
        _imageLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _headNodController.dispose();
    _armSwayController.dispose();
    _blinkController.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_imageLoaded || _image == null) {
      return SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _breatheController,
        _headNodController,
        _armSwayController,
        _blinkController,
      ]),
      builder: (context, _) {
        return CustomPaint(
          painter: _IdleCharacterPainter(
            image: _image!,
            breatheValue: _breatheController.value,
            headNodValue: _headNodController.value,
            armSwayValue: _armSwayController.value,
            blinkValue: _blinkController.value,
          ),
          size: widget.size,
        );
      },
    );
  }
}

class _IdleCharacterPainter extends CustomPainter {
  _IdleCharacterPainter({
    required this.image,
    required this.breatheValue,
    required this.headNodValue,
    required this.armSwayValue,
    required this.blinkValue,
  });

  final ui.Image image;
  final double breatheValue;
  final double headNodValue;
  final double armSwayValue;
  final double blinkValue;

  @override
  void paint(Canvas canvas, Size size) {

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Convert animation values to actual movements
    // breatheValue: 0 -> 1 -> 0 (sway left/right with body)
    final breatheOffset = (breatheValue - 0.5) * 8; // ±4 pixels

    // headNodValue: 0 -> 1 -> 0 (nod up/down, slight rotation)
    final headNodOffset = (headNodValue - 0.5) * 6; // ±3 pixels
    final headRotation = (headNodValue - 0.5) * 0.05; // ±0.025 radians

    // armSwayValue: 0 -> 1 -> 0 (swing arms)
    final armSwayRotation = (armSwayValue - 0.5) * 0.1; // ±0.05 radians

    // blinkValue: 0 -> 1 -> 0 (eye closure)
    final blinkOpacity = 1 - (blinkValue > 0.5 ? (blinkValue - 0.5) * 4 : 0);

    // Draw full body with breathe offset
    canvas.save();
    canvas.translate(breatheOffset, 0);
    _drawBody(canvas, size);
    canvas.restore();

    // Draw head with nod and rotation
    canvas.save();
    canvas.translate(centerX, centerY - 50 + headNodOffset);
    canvas.rotate(headRotation);
    canvas.translate(-centerX, -(centerY - 50));
    _drawHead(canvas, size);
    canvas.restore();

    // Draw arms with sway
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(armSwayRotation);
    canvas.translate(-centerX, -centerY);
    _drawArms(canvas, size);
    canvas.restore();

    // Draw eyes with blink
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withValues(alpha: 1.0 - blinkOpacity),
    );
    _drawEyes(canvas, size);
    canvas.restore();
  }

  void _drawBody(Canvas canvas, Size size) {
    // Draw the full image (simplified - in real implementation, mask different parts)
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    final src = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final dst = Rect.fromLTWH(
      size.width / 2 - 50,
      size.height / 2 - 80,
      100,
      160,
    );
    canvas.drawImageRect(image, src, dst, Paint());
  }

  void _drawHead(Canvas canvas, Size size) {
    // In a real implementation, this would draw a masked portion of the image
    // For now, we'll draw a circle to represent the head
    final headRadius = 25.0;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 - 50),
      headRadius,
      Paint()..color = Colors.amber.withValues(alpha: 0.3),
    );
  }

  void _drawArms(Canvas canvas, Size size) {
    // Draw simplified arms as lines
    final leftArmStart = Offset(size.width / 2 - 40, size.height / 2 - 20);
    final leftArmEnd = Offset(size.width / 2 - 70, size.height / 2 + 20);
    final rightArmStart = Offset(size.width / 2 + 40, size.height / 2 - 20);
    final rightArmEnd = Offset(size.width / 2 + 70, size.height / 2 + 20);

    final paint = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(leftArmStart, leftArmEnd, paint);
    canvas.drawLine(rightArmStart, rightArmEnd, paint);
  }

  void _drawEyes(Canvas canvas, Size size) {
    // Draw simplified eyes
    const eyeRadius = 5.0;
    final leftEyePos = Offset(size.width / 2 - 15, size.height / 2 - 60);
    final rightEyePos = Offset(size.width / 2 + 15, size.height / 2 - 60);

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(leftEyePos, eyeRadius, eyePaint);
    canvas.drawCircle(rightEyePos, eyeRadius, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _IdleCharacterPainter oldDelegate) {
    return breatheValue != oldDelegate.breatheValue ||
        headNodValue != oldDelegate.headNodValue ||
        armSwayValue != oldDelegate.armSwayValue ||
        blinkValue != oldDelegate.blinkValue;
  }
}
