import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:siffersafari/gen/assets.g.dart';

enum CharacterReaction {
  idle,
  enter,
  answerCorrect,
  answerWrong,
  celebrate,
  userTap,
  screenChange,
}

class GameCharacter extends StatefulWidget {
  const GameCharacter({
    super.key,
    this.reaction = CharacterReaction.idle,
    this.reactionNonce = 0,
    this.height = 96,
    this.fit = BoxFit.contain,
    this.characterId = CharacterId.mascot,
  });

  final CharacterReaction reaction;
  final int reactionNonce;
  final double height;
  final BoxFit fit;

  /// Which character to display. Defaults to the original mascot.
  final CharacterId characterId;

  @override
  State<GameCharacter> createState() => _GameCharacterState();
}

class _GameCharacterState extends State<GameCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _reactionController;
  late final AnimationController _bobController;
  CharacterReaction _fallbackReaction = CharacterReaction.idle;
  int _reactionToken = 0;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      vsync: this,
      duration: _fallbackDurationFor(CharacterReaction.idle),
    );
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _primeFallbackReaction();
  }

  @override
  void dispose() {
    _reactionToken++;
    _reactionController.stop(canceled: true);
    _reactionController.dispose();
    _bobController.stop();
    _bobController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reactionNonce != oldWidget.reactionNonce ||
        widget.reaction != oldWidget.reaction) {
      _playFallbackReaction(widget.reaction);
    }
  }

  void _primeFallbackReaction() {
    if (widget.reaction == CharacterReaction.idle) return;
    _fallbackReaction = widget.reaction;
    _reactionController.duration = _fallbackDurationFor(widget.reaction);
    _bobController.stop();
    _reactionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _fallbackReaction = CharacterReaction.idle;
      });
      if (!_bobController.isAnimating) _bobController.repeat();
    });
  }

  void _playFallbackReaction(CharacterReaction reaction) {
    _reactionToken++;
    final activeToken = _reactionToken;

    if (reaction == CharacterReaction.idle) {
      if (mounted) {
        setState(() {
          _fallbackReaction = CharacterReaction.idle;
        });
      } else {
        _fallbackReaction = CharacterReaction.idle;
      }
      _reactionController.stop(canceled: true);
      _reactionController.value = 0;
      if (!_bobController.isAnimating) _bobController.repeat();
      return;
    }

    if (mounted) {
      setState(() {
        _fallbackReaction = reaction;
      });
    } else {
      _fallbackReaction = reaction;
    }

    _bobController.stop();
    _reactionController.duration = _fallbackDurationFor(reaction);
    _reactionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      if (activeToken != _reactionToken) return;
      setState(() {
        _fallbackReaction = CharacterReaction.idle;
      });
      if (!_bobController.isAnimating) _bobController.repeat();
    });
  }

  Duration _fallbackDurationFor(CharacterReaction reaction) {
    switch (reaction) {
      case CharacterReaction.idle:
        return const Duration(milliseconds: 1);
      case CharacterReaction.enter:
        return const Duration(milliseconds: 520);
      case CharacterReaction.answerCorrect:
        return const Duration(milliseconds: 820);
      case CharacterReaction.celebrate:
        return const Duration(milliseconds: 1100);
      case CharacterReaction.answerWrong:
        return const Duration(milliseconds: 560);
      case CharacterReaction.userTap:
        return const Duration(milliseconds: 360);
      case CharacterReaction.screenChange:
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
        onTap: () => _playFallbackReaction(CharacterReaction.userTap),
        child: AnimatedBuilder(
          animation: Listenable.merge([_reactionController, _bobController]),
          child: SvgPicture.asset(
            _currentSvgPath(),
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

  String _currentSvgPath() {
    if (_fallbackReaction == CharacterReaction.celebrate &&
        widget.characterId == CharacterId.mascot) {
      return 'assets/characters/mascot/svg/mascot_composite_celebrate.svg';
    }
    return AssetPaths.characterCompositeSvg(widget.characterId);
  }

  _FallbackPose _fallbackPoseFor(double t) {
    final eased = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
    switch (_fallbackReaction) {
      case CharacterReaction.idle:
        final bob = math.sin(_bobController.value * 2 * math.pi);
        return _FallbackPose(dy: -0.04 * bob);
      case CharacterReaction.enter:
        return _FallbackPose(
          scale:
              0.92 + (0.08 * Curves.easeOutBack.transform(t.clamp(0.0, 1.0))),
          dx: 0.18 * (1 - eased),
          dy: 0.03 * (1 - eased),
          rotation: -0.06 * (1 - eased),
          opacity: Curves.easeOut.transform(t.clamp(0.0, 1.0)),
        );
      case CharacterReaction.answerCorrect:
        final arc = math.sin(math.pi * eased);
        return _FallbackPose(
          scale: 1 + (0.09 * arc),
          dy: -0.12 * arc,
          rotation: 0.03 * math.sin(math.pi * 2 * eased),
        );
      case CharacterReaction.celebrate:
        // 5-phase jump: anticipation → spring up → float → land → settle
        final double jumpDy;
        final double jumpScale;
        final double jumpRotation;
        if (t < 0.12) {
          // anticipation squish
          final p = t / 0.12;
          jumpDy = 0.18 * p;
          jumpScale = 1.0 - 0.06 * p;
          jumpRotation = 0;
        } else if (t < 0.48) {
          // spring up
          final p = (t - 0.12) / 0.36;
          final spring = Curves.easeOut.transform(p);
          jumpDy = 0.18 - 1.28 * spring;
          jumpScale = 0.94 + 0.16 * spring;
          jumpRotation = 0.04 * math.sin(math.pi * p);
        } else if (t < 0.64) {
          // float at top
          final p = (t - 0.48) / 0.16;
          jumpDy = -1.10 + 0.08 * p;
          jumpScale = 1.10 - 0.03 * p;
          jumpRotation = 0.04;
        } else if (t < 0.86) {
          // fall + land
          final p = (t - 0.64) / 0.22;
          final fall = Curves.easeIn.transform(p);
          jumpDy = -1.02 + 1.20 * fall;
          jumpScale = 1.07 - 0.14 * fall;
          jumpRotation = 0.04 * (1 - p);
        } else {
          // settle bounce
          final p = (t - 0.86) / 0.14;
          final bounce = math.sin(math.pi * p);
          jumpDy = 0.18 - 0.22 * bounce;
          jumpScale = 0.93 + 0.07 * (1 - bounce * 0.4);
          jumpRotation = 0;
        }
        return _FallbackPose(
          scale: jumpScale,
          dy: jumpDy,
          rotation: jumpRotation,
        );
      case CharacterReaction.answerWrong:
        final shake = math.sin(math.pi * 5 * eased) * (1 - eased);
        return _FallbackPose(
          dx: 0.12 * shake,
          rotation: 0.04 * shake,
        );
      case CharacterReaction.userTap:
        final pop = math.sin(math.pi * eased);
        return _FallbackPose(
          scale: 1 + (0.08 * pop),
          dy: -0.04 * pop,
        );
      case CharacterReaction.screenChange:
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
