import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:siffersafari/core/constants/app_constants.dart';

class StarRating extends StatefulWidget {
  const StarRating({
    required this.stars,
    super.key,
  });

  final int stars;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _scales;
  late final List<Animation<double>> _opacities;

  // Keep the reveal short so results feel rewarding without dragging.
  // Star 0: 0.0–0.62 | Star 1: 0.19–0.81 | Star 2: 0.38–1.0
  static const _totalDuration = Duration(milliseconds: 480);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..forward();
    _scales = List.generate(3, (i) {
      final start = i * 0.19;
      final end = (start + 0.62).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    _opacities = List.generate(3, (i) {
      final start = i * 0.19;
      final end = (start + 0.48).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clamped = widget.stars.clamp(0, 3);
    final starColor = Theme.of(context).colorScheme.secondary;
    return Semantics(
      label: 'Stjärnor: $clamped av 3',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isFilled = index < clamped;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.microSpacing8.w,
                  ),
                  child: Opacity(
                    opacity: _opacities[index].value,
                    child: Transform.scale(
                      scale: _scales[index].value,
                      child: Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        color: starColor,
                        size: 64.sp,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
