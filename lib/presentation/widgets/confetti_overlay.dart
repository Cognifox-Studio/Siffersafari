import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiParticle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool animate;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.animate = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<ConfettiParticle> _particles = [];
  final Random _random = Random();
  bool _playing = false;

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )
      ..addListener(() {
        _updateParticles();
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _playing = false;
          });
        }
      });

    if (widget.animate) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _initParticles();
    setState(() {
      _playing = true;
    });
    _controller.forward(from: 0.0);
  }

  void _initParticles() {
    _particles = List.generate(100, (index) {
      return ConfettiParticle(
        x: 0.5, // Start at center horizontal
        y: 0.3, // Start slightly above center vertical
        velocityX: (_random.nextDouble() - 0.5) * 4,
        velocityY: (_random.nextDouble() - 1.0) * 4 - 2, // Upward bias
        color: _colors[_random.nextInt(_colors.length)],
        size: _random.nextDouble() * 8 + 4,
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.4,
      );
    });
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.velocityX * 0.01;
      particle.y += particle.velocityY * 0.01;
      particle.velocityY += 0.05; // Gravity
      particle.rotation += particle.rotationSpeed;
    }
    setState(() {}); // Trigger repaint
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_playing)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.save();
      // Assume coordinates are proportional to screen size (0.0 to 1.0 roughly, plus overflow)
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;
      if (dx >= 0 && dx <= size.width && dy >= 0 && dy <= size.height) {
        canvas.translate(dx, dy);
        canvas.rotate(particle.rotation);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.8,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
