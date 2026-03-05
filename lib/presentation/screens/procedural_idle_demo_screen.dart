import 'package:flutter/material.dart';

import '../widgets/procedural_idle_animation.dart';

/// Demo screen for testing procedural idle animation without main app integration.
/// 
/// Usage: Run the app and navigate to this screen to see idle animation live.
class ProceduralIdleDemo extends StatefulWidget {
  const ProceduralIdleDemo({super.key});

  @override
  State<ProceduralIdleDemo> createState() => _ProceduralIdleDemoState();
}

class _ProceduralIdleDemoState extends State<ProceduralIdleDemo> {
  bool _enableAnimation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedural Idle Animation Demo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Enable Animation'),
                      value: _enableAnimation,
                      onChanged: (value) {
                        setState(() => _enableAnimation = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Animation Behavior:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Bullet('Sine-wave breathing (±4px sway)'),
                    const Bullet('Head nod with gentle rotation'),
                    const Bullet('Arm swing motions'),
                    const Bullet('Blink animation every ~3 seconds'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: _enableAnimation
                  ? const ProceduralIdleAnimation(
                      assetPath: 'assets/images/characters/character_v2/character_v2.png',
                      size: Size(200, 300),
                      breatheDuration: Duration(milliseconds: 2000),
                      headNodDuration: Duration(milliseconds: 1500),
                      armSwayDuration: Duration(milliseconds: 1800),
                    )
                  : Container(
                      width: 200,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Animation disabled'),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Real Implementation Notes:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Bullet(
                      'Uses CustomPaint to render sprite with transforms',
                      fontSize: 12,
                    ),
                    Bullet(
                      'Can mask/clip image for layered animation',
                      fontSize: 12,
                    ),
                    Bullet(
                      'Use BlendMode.clear + canvas.saveLayer for masking',
                      fontSize: 12,
                    ),
                    Bullet(
                      'Smooth curves via AnimationController + Listenable.merge',
                      fontSize: 12,
                    ),
                    Bullet(
                      'Can be integrated into InteractiveMascot when ready',
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Bullet extends StatelessWidget {
  const Bullet(
    this.text, {
    super.key,
    this.fontSize = 14,
  });

  final String text;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}
