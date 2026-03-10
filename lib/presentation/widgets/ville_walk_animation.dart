import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Example widget showing how to use Ville walk animation.
/// 
/// Usage:
/// ```dart
/// VilleWalkAnimation(
///   size: 120,
///   repeat: true,
/// )
/// ```
class VilleWalkAnimation extends StatelessWidget {
  const VilleWalkAnimation({
    super.key,
    this.size = 100,
    this.repeat = true,
    this.onComplete,
  });

  final double size;
  final bool repeat;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/ui/lottie/ville_walk.json',
        repeat: repeat,
        onLoaded: (composition) {
          if (onComplete != null && !repeat) {
            Future.delayed(composition.duration, onComplete);
          }
        },
      ),
    );
  }
}
