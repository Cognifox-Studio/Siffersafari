import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/gen/assets.g.dart';

part 'game_character_inventory_helpers.dart';

enum CharacterReaction {
  idle,
  enter,
  answerCorrect,
  answerWrong,
  celebrate,
  userTap,
  screenChange,
  run,
}

class GameCharacter extends StatefulWidget {
  const GameCharacter({
    super.key,
    this.reaction = CharacterReaction.idle,
    this.reactionNonce = 0,
    this.height = 96,
    this.fit = BoxFit.contain,
    this.characterId = CharacterId.loke,
    this.equippedItems,
    this.customItemOffsets,
    this.onItemOffsetUpdated,
    this.interactiveItems = false,
    this.persistentReaction = false,
    this.onTap,
  });

  final CharacterReaction reaction;
  final int reactionNonce;
  final double height;
  final BoxFit fit;

  /// Which character to display. Defaults to loke.
  final CharacterId characterId;

  /// Equipped inventory items (key: slot, value: item slug)
  final Map<String, String>? equippedItems;

  /// Custom offsets created by dragging. Key: item slug, Value: "dx,dy,scale,rotation" formatted string.
  final Map<String, String>? customItemOffsets;

  /// Callback when an item is dragged/scaled/rotated.
  final void Function(
    String itemSlug,
    double dx,
    double dy,
    double scale,
    double rotation,
  )? onItemOffsetUpdated;

  /// If true, items can be dragged to change their position.
  final bool interactiveItems;

  /// If true, does not fall back to CharacterReaction.idle after playing a reaction animation.
  final bool persistentReaction;

  /// Callback when the character is tapped.
  final VoidCallback? onTap;

  @override
  State<GameCharacter> createState() => _GameCharacterState();
}

class _GameCharacterState extends State<GameCharacter>
    with TickerProviderStateMixin {
  static const List<String> _slotLayers = <String>[
    'back',
    'body',
    'face',
    'head',
    'accessory',
    'front',
  ];

  late final AnimationController _reactionController;
  late final AnimationController _bobController;
  late final bool _isTestBinding;
  CharacterReaction _fallbackReaction = CharacterReaction.idle;
  int _reactionToken = 0;
  // Under aktiv gest: vilket item dras just nu
  String? _activeItemId;
  // Sparar position/skala/rotation per item under aktiv gest (delta från sparad)
  final Map<String, Offset> _dragOffsets = {};
  final Map<String, double> _dragScales = {};
  final Map<String, double> _dragRotations = {};
  final Map<String, String> _optimisticOffsets = {};

  @override
  void initState() {
    super.initState();
    _isTestBinding = _detectTestBinding();
    _reactionController = AnimationController(
      vsync: this,
      duration: _fallbackDurationFor(CharacterReaction.idle),
    );
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!_isTestBinding) {
      _bobController.repeat();
    }
    _primeFallbackReaction();
  }

  @override
  void dispose() {
    _reactionToken++;
    _reactionController.stop(canceled: true);
    _reactionController.dispose();
    _bobController.stop(canceled: true);
    _bobController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rensa vår lokala optimistiska cache så fort Riverpod uppdaterar förälderns dict
    if (widget.customItemOffsets != oldWidget.customItemOffsets) {
      _optimisticOffsets.clear();
    }

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

    if (_fallbackReaction == CharacterReaction.run) {
      if (!_isTestBinding) {
        _reactionController.repeat();
      }
      return;
    }

    _reactionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      setState(() {
        _fallbackReaction = CharacterReaction.idle;
      });
      if (!_isTestBinding && !_bobController.isAnimating) {
        _bobController.repeat();
      }
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
      if (!_isTestBinding && !_bobController.isAnimating) {
        _bobController.repeat();
      }
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

    if (reaction == CharacterReaction.run) {
      if (!_isTestBinding) {
        _reactionController.repeat();
      }
      return;
    }

    _reactionController.forward(from: 0).whenCompleteOrCancel(() {
      if (!mounted) return;
      if (activeToken != _reactionToken) return;

      if (widget.persistentReaction) {
        return;
      }

      setState(() {
        _fallbackReaction = CharacterReaction.idle;
      });
      if (!_isTestBinding && !_bobController.isAnimating) {
        _bobController.repeat();
      }
    });
  }

  bool _detectTestBinding() {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgets') ||
        bindingType.contains('AutomatedTestWidgets') ||
        bindingType.contains('LiveTestWidgets') ||
        bindingType.contains('IntegrationTestWidgets');
  }

  Duration _fallbackDurationFor(CharacterReaction reaction) {
    switch (reaction) {
      case CharacterReaction.idle:
        return const Duration(milliseconds: 1);
      case CharacterReaction.enter:
        return const Duration(milliseconds: 440);
      case CharacterReaction.answerCorrect:
        return const Duration(milliseconds: 620);
      case CharacterReaction.celebrate:
        return const Duration(milliseconds: 900);
      case CharacterReaction.answerWrong:
        return const Duration(milliseconds: 420);
      case CharacterReaction.userTap:
        return const Duration(milliseconds: 260);
      case CharacterReaction.screenChange:
        return const Duration(milliseconds: 320);
      case CharacterReaction.run:
        return const Duration(milliseconds: 600); // 8 x 75ms = 600ms
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    if (!widget.interactiveItems) {
      return SizedBox(
        height: widget.height,
        width: widget.height,
        child: _buildAnimatedCharacterSurface(widget.height),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = _resolveInteractiveCanvasSize(this, constraints);
        return SizedBox.square(
          dimension: canvasSize,
          child: _buildAnimatedCharacterSurface(canvasSize),
        );
      },
    );
  }

  Widget _buildAnimatedCharacterSurface(double canvasSize) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap == null
          ? null
          : () {
              _playFallbackReaction(CharacterReaction.userTap);
              widget.onTap?.call();
            },
      onScaleStart: !widget.interactiveItems
          ? null
          : (details) {
              setState(() {
                _activeItemId = _pickInteractiveItem(
                  this,
                  details.localFocalPoint,
                  canvasSize,
                );
              });
            },
      onScaleUpdate: !widget.interactiveItems
          ? null
          : (details) {
              final id = _activeItemId;
              if (id == null) return;
              setState(() {
                final prev = _dragOffsets[id] ?? Offset.zero;
                final savedDx = _getItemSavedDx(this, id);
                final savedDy = _getItemSavedDy(this, id);
                final savedScale = _getItemSavedScale(this, id);
                final rawOffset = Offset(
                  savedDx + prev.dx + details.focalPointDelta.dx,
                  savedDy + prev.dy + details.focalPointDelta.dy,
                );

                if (details.pointerCount > 1) {
                  _dragScales[id] = details.scale;
                  _dragRotations[id] = details.rotation;
                }
                final dragScale = _dragScales[id] ?? 1.0;

                final clampedOffset = _getClampedItemOffset(
                  this,
                  id,
                  rawOffset,
                  currentScale: (savedScale * dragScale).clamp(0.1, 10.0),
                );
                _dragOffsets[id] = Offset(
                  clampedOffset.dx - savedDx,
                  clampedOffset.dy - savedDy,
                );
              });
            },
      onScaleEnd: !widget.interactiveItems
          ? null
          : (details) {
              final id = _activeItemId;
              if (id == null) return;
              final savedDx = _getItemSavedDx(this, id);
              final savedDy = _getItemSavedDy(this, id);
              final savedScale = _getItemSavedScale(this, id);
              final savedRot = _getItemSavedRot(this, id);
              final drag = _dragOffsets[id] ?? Offset.zero;
              final ds = _dragScales[id] ?? 1.0;
              final dr = _dragRotations[id] ?? 0.0;
              final finalScale = (savedScale * ds).clamp(0.1, 10.0);
              final finalRot = savedRot + dr;
              final clampedOffset = _getClampedItemOffset(
                this,
                id,
                Offset(savedDx + drag.dx, savedDy + drag.dy),
                currentScale: finalScale,
              );
              final finalDx = clampedOffset.dx;
              final finalDy = clampedOffset.dy;

              final normDx = finalDx / widget.height;
              final normDy = finalDy / widget.height;

              final saveKey = '${id}_${_fallbackReaction.name}';
              widget.onItemOffsetUpdated
                  ?.call(saveKey, normDx, normDy, finalScale, finalRot);
              setState(() {
                _activeItemId = null;
                _optimisticOffsets[saveKey] =
                    'n,$normDx,$normDy,$finalScale,$finalRot';
                _dragOffsets.remove(id);
                _dragScales.remove(id);
                _dragRotations.remove(id);
              });
            },
      child: AnimatedBuilder(
        animation: Listenable.merge([_reactionController, _bobController]),
        builder: (context, child) {
          final currentAsset = _currentAsset(context, canvasSize);

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
                  child: currentAsset,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, String> get _currentPoseEquippedItems {
    if (widget.equippedItems == null || widget.equippedItems!.isEmpty) {
      return {};
    }

    final poseNames = _currentPoseLookupNames;
    final Map<String, String> items = {};

    for (final entry in widget.equippedItems!.entries) {
      final key = entry.key;
      final val = entry.value;

      if (poseNames.any((poseName) => key.startsWith('${poseName}_'))) {
        items[key] = val;
      } else if (!key.contains('_')) {
        if (poseNames.contains('idle')) {
          items[key] = val;
        }
      }
    }
    return items;
  }

  List<String> get _currentPoseLookupNames {
    switch (_fallbackReaction) {
      case CharacterReaction.answerCorrect:
        return const ['answerCorrect', 'celebrate'];
      case CharacterReaction.celebrate:
        return const ['celebrate', 'answerCorrect'];
      default:
        return [_fallbackReaction.name];
    }
  }

  Widget _currentAsset(BuildContext context, double canvasSize) {
    final assetPath = _currentPngPath();

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheHeight = (widget.height * pixelRatio).toInt();

    final characterAsset = SizedBox.square(
      dimension: widget.height,
      child: Image.asset(
        assetPath,
        fit: widget.fit,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) => _iconFallback(context),
      ),
    );

    final currentEquipped = _currentPoseEquippedItems;

    if (currentEquipped.isEmpty) {
      if (!widget.interactiveItems) {
        return characterAsset;
      }
      return SizedBox.square(
        dimension: canvasSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [characterAsset],
        ),
      );
    }

    final stack = SizedBox.square(
      dimension: widget.interactiveItems ? canvasSize : widget.height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ..._buildEquippedItem(this, context, 'back', canvasSize),
          characterAsset,
          ..._buildEquippedItem(this, context, 'body', canvasSize),
          ..._buildEquippedItem(this, context, 'face', canvasSize),
          ..._buildEquippedItem(this, context, 'head', canvasSize),
          ..._buildEquippedItem(this, context, 'accessory', canvasSize),
          ..._buildEquippedItem(this, context, 'front', canvasSize),
        ],
      ),
    );

    return stack;
  }

  String _currentPngPath() {
    if (widget.characterId == CharacterId.signe) {
      if (_fallbackReaction == CharacterReaction.celebrate ||
          _fallbackReaction == CharacterReaction.answerCorrect) {
        return 'assets/characters/signe/png/signe_cheer.png';
      } else if (_fallbackReaction == CharacterReaction.answerWrong) {
        return 'assets/characters/signe/png/signe_thinking.png';
      }
      return 'assets/characters/signe/png/signe_base.png';
    }

    if (widget.characterId == CharacterId.astrid) {
      if (_fallbackReaction == CharacterReaction.celebrate ||
          _fallbackReaction == CharacterReaction.answerCorrect) {
        return 'assets/characters/astrid/png/astrid_cheer.png';
      } else if (_fallbackReaction == CharacterReaction.answerWrong) {
        return 'assets/characters/astrid/png/astrid_thinking.png';
      }
      return 'assets/characters/astrid/png/astrid_base.png';
    }

    // Default to Loke
    if (_fallbackReaction == CharacterReaction.celebrate ||
        _fallbackReaction == CharacterReaction.answerCorrect) {
      return 'assets/characters/loke/png/loke_cheer_streak.png';
    } else if (_fallbackReaction == CharacterReaction.answerWrong) {
      return 'assets/characters/loke/png/loke_think_struggle.png';
    }
    return 'assets/characters/loke/png/loke_base.png';
  }

  _FallbackPose _fallbackPoseFor(double t) {
    final eased = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
    switch (_fallbackReaction) {
      case CharacterReaction.idle:
        final time = _bobController.value * 2 * math.pi;
        final bob = math.sin(time);
        final scaleBob = math.cos(time);
        return _FallbackPose(
          dy: -0.04 * bob,
          scale: 1.0 + 0.04 * scaleBob,
          rotation: 0.02 * bob,
        );
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
        // 5-phase jump: anticipation -> spring up -> float -> land -> settle
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
      case CharacterReaction.run:
        return const _FallbackPose();
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
