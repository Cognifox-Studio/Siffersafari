import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:siffersafari/gen/assets.g.dart';

enum MascotReaction {
  idle,
  enter,
  answerCorrect,
  answerWrong,
  celebrate,
  userTap,
  screenChange,
}

class MascotCharacter extends StatefulWidget {
  const MascotCharacter({
    super.key,
    this.reaction = MascotReaction.idle,
    this.reactionNonce = 0,
    this.height = 96,
    this.fit = BoxFit.contain,
  });

  final MascotReaction reaction;
  final int reactionNonce;
  final double height;
  final BoxFit fit;

  @override
  State<MascotCharacter> createState() => _MascotCharacterState();
}

class _MascotCharacterState extends State<MascotCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reactionController;
  MascotReaction _fallbackReaction = MascotReaction.idle;
  int _reactionToken = 0;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      vsync: this,
      duration: _fallbackDurationFor(MascotReaction.idle),
    );
    _primeFallbackReaction();
  }

  @override
  void dispose() {
    _reactionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MascotCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reactionNonce != oldWidget.reactionNonce ||
        widget.reaction != oldWidget.reaction) {
      _playFallbackReaction(widget.reaction);
    }
  }

  void _primeFallbackReaction() {
    if (widget.reaction == MascotReaction.idle) return;
    _fallbackReaction = widget.reaction;
    _reactionController.duration = _fallbackDurationFor(widget.reaction);
    _reactionController.forward(from: 0);
  }

  void _playFallbackReaction(MascotReaction reaction) {
    _reactionToken++;
    final activeToken = _reactionToken;

    if (reaction == MascotReaction.idle) {
      if (mounted) {
        setState(() {
          _fallbackReaction = MascotReaction.idle;
        });
      } else {
        _fallbackReaction = MascotReaction.idle;
      }
      _reactionController.stop();
      _reactionController.value = 0;
      return;
    }

    if (mounted) {
      setState(() {
        _fallbackReaction = reaction;
      });
    } else {
      _fallbackReaction = reaction;
    }

    _reactionController.duration = _fallbackDurationFor(reaction);
    _reactionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      if (activeToken != _reactionToken) return;
      setState(() {
        _fallbackReaction = MascotReaction.idle;
      });
    });
  }

  Duration _fallbackDurationFor(MascotReaction reaction) {
    switch (reaction) {
      case MascotReaction.idle:
        return const Duration(milliseconds: 1);
      case MascotReaction.enter:
        return const Duration(milliseconds: 520);
      case MascotReaction.answerCorrect:
      case MascotReaction.celebrate:
        return const Duration(milliseconds: 820);
      case MascotReaction.answerWrong:
        return const Duration(milliseconds: 560);
      case MascotReaction.userTap:
        return const Duration(milliseconds: 360);
      case MascotReaction.screenChange:
        return const Duration(milliseconds: 420);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _fallback(context);
  }

  Widget _fallback(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTap: () => _playFallbackReaction(MascotReaction.userTap),
        child: AnimatedBuilder(
          animation: _reactionController,
          child: SvgPicture.asset(
            AssetPaths.characterCompositeSvg(CharacterId.mascot),
            fit: widget.fit,
            placeholderBuilder: (context) => _iconFallback(context),
          ),
          builder: (context, child) {
            final pose = _fallbackPoseFor(_reactionController.value);
            final offset = Offset(
              pose.dx * widget.height * 0.36,
              pose.dy * widget.height * 0.24,
            );

            return Opacity(
              opacity: pose.opacity,
              child: Transform.translate(
                offset: offset,
                child: Transform.rotate(
                  angle: pose.rotation,
                  child: Transform.scale(
                    scale: pose.scale,
                    alignment: Alignment.center,
                    child: child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _FallbackPose _fallbackPoseFor(double t) {
    final eased = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
    switch (_fallbackReaction) {
      case MascotReaction.idle:
        return const _FallbackPose();
      case MascotReaction.enter:
        return _FallbackPose(
          scale:
              0.92 + (0.08 * Curves.easeOutBack.transform(t.clamp(0.0, 1.0))),
          dx: 0.18 * (1 - eased),
          dy: 0.03 * (1 - eased),
          rotation: -0.06 * (1 - eased),
          opacity: Curves.easeOut.transform(t.clamp(0.0, 1.0)),
        );
      case MascotReaction.answerCorrect:
        final arc = math.sin(math.pi * eased);
        return _FallbackPose(
          scale: 1 + (0.09 * arc),
          dy: -0.12 * arc,
          rotation: 0.03 * math.sin(math.pi * 2 * eased),
        );
      case MascotReaction.celebrate:
        final arc = math.sin(math.pi * eased);
        return _FallbackPose(
          scale: 1 + (0.13 * arc),
          dy: -0.16 * arc,
          rotation: 0.05 * math.sin(math.pi * 2.4 * eased),
        );
      case MascotReaction.answerWrong:
        final shake = math.sin(math.pi * 5 * eased) * (1 - eased);
        return _FallbackPose(
          dx: 0.12 * shake,
          rotation: 0.04 * shake,
        );
      case MascotReaction.userTap:
        final pop = math.sin(math.pi * eased);
        return _FallbackPose(
          scale: 1 + (0.08 * pop),
          dy: -0.04 * pop,
        );
      case MascotReaction.screenChange:
        return _FallbackPose(
          scale: 1 - (0.08 * eased),
          dx: 0.22 * eased,
          rotation: -0.05 * eased,
          opacity: 1 - eased,
        );
    }
  }

  Widget _iconFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
      ),
    );
  }
}

class _FallbackPose {
  const _FallbackPose({
    this.scale = 1,
    this.rotation = 0,
    this.dx = 0,
    this.dy = 0,
    this.opacity = 1,
  });

  final double scale;
  final double rotation;
  final double dx;
  final double dy;
  final double opacity;
}
