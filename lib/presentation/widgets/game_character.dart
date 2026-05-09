import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/gen/assets.g.dart';

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
          String itemSlug, double dx, double dy, double scale, double rotation)?
      onItemOffsetUpdated;

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
  late final AnimationController _reactionController;
  late final AnimationController _bobController;
  CharacterReaction _fallbackReaction = CharacterReaction.idle;
  int _reactionToken = 0;
  final Map<String, Offset> _dragOffsets = {};
  final Map<String, double> _dragScales = {};
  final Map<String, double> _dragRotations = {};

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

    if (_fallbackReaction == CharacterReaction.run) {
      _reactionController.repeat();
      return;
    }

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

    if (reaction == CharacterReaction.run) {
      _reactionController.repeat();
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
      case CharacterReaction.run:
        return const Duration(milliseconds: 600); // 8 x 75ms = 600ms
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
        onTap: () {
          _playFallbackReaction(CharacterReaction.userTap);
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_reactionController, _bobController]),
          builder: (context, child) {
            final currentAsset = _currentAsset(context);

            final pose = _fallbackPoseFor(_reactionController.value);
            // Using standard scale
            final adjustedScale = pose.scale * 1.0;

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
                    scale: adjustedScale,
                    alignment: Alignment.center,
                    child: currentAsset,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _currentAsset(BuildContext context) {
    final assetPath = _currentPngPath();
    final characterAsset = Image.asset(
      assetPath,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => _iconFallback(context),
    );

    if (widget.equippedItems == null || widget.equippedItems!.isEmpty) {
      return characterAsset;
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        ..._buildEquippedItem('back'),
        characterAsset,
        ..._buildEquippedItem('body'),
        ..._buildEquippedItem('face'),
        ..._buildEquippedItem('head'),
        ..._buildEquippedItem('accessory'),
        ..._buildEquippedItem(
          'front',
        ), // Nytt fack som alltid ritas lÃ¤ngst fram (Ã¶ver accessory)
      ],
    );
  }

  ({double dx, double dy, double scaleModifier}) _getCharacterAdjustments(
    CharacterId characterId,
    String slot,
  ) {
    if (characterId == CharacterId.signe) {
      if (slot == 'head' || slot == 'face') {
        return (dx: 0.0, dy: 0.35, scaleModifier: 0.95);
      }
    } else if (characterId == CharacterId.astrid) {
      if (slot == 'head' || slot == 'face') {
        return (dx: 0.15, dy: 0.15, scaleModifier: 1.05);
      }
    }
    return (dx: 0.0, dy: 0.0, scaleModifier: 1.0);
  }

  List<Widget> _buildEquippedItem(String slotLayer) {
    if (widget.equippedItems == null || widget.equippedItems!.isEmpty) {
      return [];
    }

    final widgets = <Widget>[];

    for (final itemId in widget.equippedItems!.values) {
      final itemConfig = InventoryConfig.allItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => InventoryItem(
          id: itemId,
          slot: slotLayer,
          assetPath: 'assets/images/items/$itemId.png',
          name: 'Unknown',
        ),
      );

      if (itemConfig.slot == slotLayer) {
        final adjustments =
            _getCharacterAdjustments(widget.characterId, slotLayer);

        var baseDx = itemConfig.offset.x + adjustments.dx;
        var baseDy = itemConfig.offset.y + adjustments.dy;
        var baseScale = 1.0;
        var baseRot = 0.0;

        final currentReactionName = _fallbackReaction.name;
        final poseSpecificKey = '${itemId}_$currentReactionName';
        final lookupKey = (widget.customItemOffsets != null &&
                widget.customItemOffsets!.containsKey(poseSpecificKey))
            ? poseSpecificKey
            : itemId;

        if (widget.customItemOffsets != null &&
            widget.customItemOffsets!.containsKey(lookupKey)) {
          final parts = widget.customItemOffsets![lookupKey]!.split(',');
          if (parts.length >= 2) {
            baseDx = double.tryParse(parts[0]) ?? baseDx;
            baseDy = double.tryParse(parts[1]) ?? baseDy;
          }
          if (parts.length >= 4) {
            baseScale = double.tryParse(parts[2]) ?? baseScale;
            baseRot = double.tryParse(parts[3]) ?? baseRot;
          }
        }

        final dragOffset = _dragOffsets[itemId] ?? Offset.zero;
        final dragScale = _dragScales[itemId] ?? 1.0;
        final dragRot = _dragRotations[itemId] ?? 0.0;

        // Clamp the local drag position to avoid losing items completely outside viewport (-5.0 to 5.0 alignment is a wide safe boundary)
        final currentDx = (baseDx + dragOffset.dx).clamp(-5.0, 5.0);
        final currentDy = (baseDy + dragOffset.dy).clamp(-5.0, 5.0);
        final currentScale = (baseScale * dragScale).clamp(0.2, 3.0);
        final currentRot = baseRot + dragRot;

        final adjustedAlignment = Alignment(currentDx, currentDy);
        final finalScale =
            itemConfig.renderScale * adjustments.scaleModifier * currentScale;

        Widget itemWidget = Transform.rotate(
          angle: currentRot,
          child: Image.asset(
            itemConfig.assetPath,
            fit: BoxFit.contain,
          ),
        );

        if (widget.interactiveItems) {
          itemWidget = GestureDetector(
            onScaleUpdate: (details) {
              final containerSize =
                  context.size ?? Size(widget.height, widget.height);
              setState(() {
                final currentOffset = _dragOffsets[itemId] ?? Offset.zero;
                // details.focalPointDelta ger rÃ¶relse sen gÃ¥ende frame
                final dx = currentOffset.dx +
                    (details.focalPointDelta.dx / (containerSize.width / 2));
                final dy = currentOffset.dy +
                    (details.focalPointDelta.dy / (containerSize.height / 2));
                _dragOffsets[itemId] = Offset(dx, dy);

                if (details.scale != 1.0) {
                  _dragScales[itemId] = details.scale;
                }
                if (details.rotation != 0.0) {
                  _dragRotations[itemId] = details.rotation;
                }
              });
            },
            onScaleEnd: (details) {
              if (_dragOffsets.containsKey(itemId) ||
                  _dragScales.containsKey(itemId) ||
                  _dragRotations.containsKey(itemId)) {
                final saveKey = '${itemId}_${_fallbackReaction.name}';
                widget.onItemOffsetUpdated?.call(
                    saveKey, currentDx, currentDy, currentScale, currentRot);
                setState(() {
                  _dragOffsets.remove(itemId);
                  _dragScales.remove(itemId);
                  _dragRotations.remove(itemId);
                });
              }
            },
            child: itemWidget,
          );
        }

        widgets.add(
          Positioned.fill(
            child: Align(
              alignment: adjustedAlignment,
              child: FractionallySizedBox(
                widthFactor: finalScale,
                child: itemWidget,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
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
        // 5-phase jump: anticipation Ã¢â€ â€™ spring up Ã¢â€ â€™ float Ã¢â€ â€™ land Ã¢â€ â€™ settle
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
