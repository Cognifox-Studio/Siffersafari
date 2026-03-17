import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
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
    this.riveAssetPath,
    this.stateMachineName = 'MascotStateMachine',
  });

  final MascotReaction reaction;
  final int reactionNonce;
  final double height;
  final BoxFit fit;
  final String? riveAssetPath;
  final String stateMachineName;

  @override
  State<MascotCharacter> createState() => _MascotCharacterState();
}

class _MascotCharacterState extends State<MascotCharacter>
    with SingleTickerProviderStateMixin {
  Artboard? _artboard;
  SMITrigger? _answerCorrect;
  SMITrigger? _answerWrong;
  SMITrigger? _userTap;
  SMITrigger? _screenChange;
  SimpleAnimation? _legacyAnimationController;
  late final AnimationController _fallbackReactionController;

  bool _loadFailed = false;
  bool _hasMatchingStateMachine = false;
  bool _isUsingLegacyAnimation = false;
  MascotReaction _fallbackReaction = MascotReaction.idle;

  bool get _shouldSkipRiveLoading {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  @override
  void initState() {
    super.initState();
    _fallbackReactionController = AnimationController(
      vsync: this,
      duration: _fallbackDurationFor(MascotReaction.idle),
    );
    if (_shouldSkipRiveLoading || widget.riveAssetPath == null) {
      _loadFailed = true;
      _primeFallbackReaction();
      return;
    }
    _loadRive();
  }

  @override
  void dispose() {
    _fallbackReactionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MascotCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riveAssetPath != widget.riveAssetPath ||
        oldWidget.stateMachineName != widget.stateMachineName) {
      _artboard = null;
      _hasMatchingStateMachine = false;
      _isUsingLegacyAnimation = false;
      _loadFailed = false;
      if (_shouldSkipRiveLoading || widget.riveAssetPath == null) {
        _loadFailed = true;
        _primeFallbackReaction();
      } else {
        _loadRive();
      }
    }
    if (widget.reactionNonce != oldWidget.reactionNonce ||
        widget.reaction != oldWidget.reaction) {
      _fireReaction(widget.reaction);
    }
  }

  Future<void> _loadRive() async {
    try {
      final riveAssetPath = widget.riveAssetPath;
      if (riveAssetPath == null || riveAssetPath.isEmpty) {
        if (!mounted) return;
        _loadFailed = true;
        _hasMatchingStateMachine = false;
        _isUsingLegacyAnimation = false;
        _primeFallbackReaction();
        setState(() {
          // Trigger rebuild when runtime asset is unavailable.
        });
        return;
      }

      final data = await RiveFile.asset(riveAssetPath);
      final artboard = data.mainArtboard;
      var activeStateMachineName = widget.stateMachineName;
      debugPrint(
        'MascotCharacter: artboard=${artboard.name}, '
        'animations=${artboard.animations.map((a) => a.name).toList()}, '
        'stateMachines=${artboard.stateMachines.map((m) => m.name).toList()}',
      );
      var controller = StateMachineController.fromArtboard(
        artboard,
        widget.stateMachineName,
      );

      if (controller == null &&
          widget.stateMachineName == 'MascotStateMachine') {
        controller = StateMachineController.fromArtboard(
          artboard,
          'VilleStateMachine',
        );
        if (controller != null) {
          activeStateMachineName = 'VilleStateMachine';
          debugPrint(
            'MascotCharacter: using legacy state machine VilleStateMachine',
          );
        }
      }

      if (controller != null) {
        debugPrint(
          'MascotCharacter: using state machine $activeStateMachineName',
        );
        artboard.addController(controller);
        _answerCorrect =
            controller.findInput<bool>('answer_correct') as SMITrigger?;
        _answerWrong =
            controller.findInput<bool>('answer_wrong') as SMITrigger?;
        _userTap = controller.findInput<bool>('user_tap') as SMITrigger?;
        _screenChange =
            controller.findInput<bool>('screen_change') as SMITrigger?;
      } else {
        final legacyAnimationName = artboard.animations.isNotEmpty
            ? artboard.animations.first.name
            : null;

        if (legacyAnimationName != null) {
          final legacyAnimation = SimpleAnimation(legacyAnimationName);
          artboard.addController(legacyAnimation);
          _legacyAnimationController = legacyAnimation;
          debugPrint(
            'MascotCharacter: no matching state machine, using legacy animation '
            '$legacyAnimationName',
          );
        } else {
          // Files without a usable runtime controller are treated as preview-only.
          debugPrint(
            'MascotCharacter: no matching state machine or animation, using static SVG fallback',
          );
        }
      }

      final hasMatchingStateMachine = controller != null;
      final isUsingLegacyAnimation =
          controller == null && _legacyAnimationController != null;

      if (!mounted) return;
      _artboard = artboard;
      _loadFailed = false;
      _hasMatchingStateMachine = hasMatchingStateMachine;
      _isUsingLegacyAnimation = isUsingLegacyAnimation;
      setState(() {
        // Trigger rebuild after async Rive load completes.
      });

      if (widget.reaction != MascotReaction.idle) {
        _fireReaction(widget.reaction);
      }
    } catch (_) {
      debugPrint(
        'MascotCharacter: failed to load Rive asset ${widget.riveAssetPath}',
      );
      if (!mounted) return;
      _loadFailed = true;
      _hasMatchingStateMachine = false;
      _isUsingLegacyAnimation = false;
      _primeFallbackReaction();
      setState(() {
        // Trigger rebuild after async Rive load failure.
      });
    }
  }

  void _fireReaction(MascotReaction reaction) {
    debugPrint(
      'MascotCharacter: fire reaction $reaction '
      '(legacyAnimation=$_isUsingLegacyAnimation, '
      'hasStateMachine=$_hasMatchingStateMachine)',
    );

    if (_isUsingLegacyAnimation) {
      if (reaction != MascotReaction.idle) {
        _legacyAnimationController?.reset();
        _legacyAnimationController?.isActive = true;
      }
      return;
    }

    if (_loadFailed ||
        _artboard == null ||
        (!_hasMatchingStateMachine && !_isUsingLegacyAnimation)) {
      _playFallbackReaction(reaction);
      return;
    }

    switch (reaction) {
      case MascotReaction.idle:
        break;
      case MascotReaction.enter:
        _userTap?.fire();
      case MascotReaction.answerCorrect:
        _answerCorrect?.fire();
      case MascotReaction.answerWrong:
        _answerWrong?.fire();
      case MascotReaction.celebrate:
        _answerCorrect?.fire();
      case MascotReaction.userTap:
        _userTap?.fire();
      case MascotReaction.screenChange:
        _screenChange?.fire();
    }
  }

  void _primeFallbackReaction() {
    if (widget.reaction == MascotReaction.idle) return;
    _fallbackReaction = widget.reaction;
    _fallbackReactionController.duration =
        _fallbackDurationFor(widget.reaction);
    _fallbackReactionController.forward(from: 0);
  }

  void _playFallbackReaction(MascotReaction reaction) {
    if (reaction == MascotReaction.idle) {
      if (mounted) {
        setState(() {
          _fallbackReaction = MascotReaction.idle;
        });
      } else {
        _fallbackReaction = MascotReaction.idle;
      }
      _fallbackReactionController.stop();
      _fallbackReactionController.value = 0;
      return;
    }

    if (mounted) {
      setState(() {
        _fallbackReaction = reaction;
      });
    } else {
      _fallbackReaction = reaction;
    }

    _fallbackReactionController.duration = _fallbackDurationFor(reaction);
    _fallbackReactionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
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
    if (_loadFailed ||
        _artboard == null ||
        (!_hasMatchingStateMachine && !_isUsingLegacyAnimation)) {
      return _fallback(context);
    }

    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTap: () {
          if (_isUsingLegacyAnimation) {
            _legacyAnimationController?.reset();
            _legacyAnimationController?.isActive = true;
            return;
          }

          _userTap?.fire();
        },
        child: Rive(
          artboard: _artboard!,
          fit: widget.fit,
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GestureDetector(
        onTap: () => _playFallbackReaction(MascotReaction.userTap),
        child: AnimatedBuilder(
          animation: _fallbackReactionController,
          child: SvgPicture.asset(
            AssetPaths.characterCompositeSvg(CharacterId.mascot),
            fit: widget.fit,
            placeholderBuilder: (context) => _iconFallback(context),
          ),
          builder: (context, child) {
            final pose = _fallbackPoseFor(_fallbackReactionController.value);
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
