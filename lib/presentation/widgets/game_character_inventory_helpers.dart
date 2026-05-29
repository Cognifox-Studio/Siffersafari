part of 'game_character.dart';

double _resolveInteractiveCanvasSize(
  _GameCharacterState state,
  BoxConstraints constraints,
) {
  final maxWidth = constraints.maxWidth.isFinite
      ? constraints.maxWidth
      : state.widget.height * 3.4;
  final maxHeight = constraints.maxHeight.isFinite
      ? constraints.maxHeight
      : state.widget.height * 3.4;
  final availableSide = math.min(maxWidth, maxHeight);

  return math.max(state.widget.height, availableSide);
}

Offset _getCharacterCanvasCenter(double canvasSize) {
  return Offset(
    canvasSize / 2,
    canvasSize / 2,
  );
}

String? _pickInteractiveItem(
  _GameCharacterState state,
  Offset localPosition,
  double canvasSize,
) {
  final itemIds = _layeredEquippedItemIds(state).toList(growable: false);
  String? bestItemId;
  double? bestScore;

  for (final itemId in itemIds.reversed) {
    final score = _getInteractiveItemHitScore(
      state,
      itemId,
      localPosition,
      canvasSize,
    );
    if (score == null) {
      continue;
    }

    if (bestScore == null || score < bestScore) {
      bestScore = score;
      bestItemId = itemId;
    }
  }

  return bestItemId;
}

double? _getInteractiveItemHitScore(
  _GameCharacterState state,
  String itemId,
  Offset localPosition,
  double canvasSize,
) {
  final itemConfig = _getItemConfig(itemId, '');
  final adjustments = _getCharacterAdjustments(
    state.widget.characterId,
    itemConfig.slot,
  );
  final layoutScale = itemConfig.renderScale * adjustments.scaleModifier;
  final saved = _getItemSaved(state, itemId);
  final currentScale =
      (saved['scale']! * (state._dragScales[itemId] ?? 1.0)).clamp(0.1, 10.0);
  final currentRotation = saved['rot']! + (state._dragRotations[itemId] ?? 0.0);
  final itemExtent = layoutScale * state.widget.height * currentScale;
  final hitShape = _getInteractiveHitShape(itemId, itemConfig.slot);

  final extraTouchPadding = math.max(
    state.widget.height * 0.02,
    itemExtent * hitShape.paddingFactor,
  );
  final hitHalfWidth =
      itemExtent * 0.5 * hitShape.widthFactor + extraTouchPadding;
  final hitHalfHeight =
      itemExtent * 0.5 * hitShape.heightFactor + extraTouchPadding;

  final canvasCenter = _getCharacterCanvasCenter(canvasSize);
  final pixelOffset = _getItemPixelOffset(state, itemId, canvasSize);
  final itemCenter = Offset(
    canvasCenter.dx + pixelOffset.dx,
    canvasCenter.dy + pixelOffset.dy,
  );

  final relative = localPosition - itemCenter;
  final sinAngle = math.sin(-currentRotation);
  final cosAngle = math.cos(-currentRotation);
  final unrotated = Offset(
    relative.dx * cosAngle - relative.dy * sinAngle,
    relative.dx * sinAngle + relative.dy * cosAngle,
  );

  final normalizedX = unrotated.dx.abs() / hitHalfWidth;
  final normalizedY = unrotated.dy.abs() / hitHalfHeight;
  final ellipseScore = normalizedX * normalizedX + normalizedY * normalizedY;

  if (ellipseScore > 1.0) {
    return null;
  }

  return ellipseScore;
}

({
  double widthFactor,
  double heightFactor,
  double paddingFactor,
}) _getInteractiveHitShape(String itemId, String slot) {
  switch (itemId) {
    case 'item_glasses_nerd':
      return (widthFactor: 0.68, heightFactor: 0.24, paddingFactor: 0.015);
    case 'item_safari_hat':
    case 'item_hat_safari':
    case 'item_hat_pirate':
      return (widthFactor: 0.9, heightFactor: 0.46, paddingFactor: 0.02);
    case 'item_binoculars_safari':
      return (widthFactor: 0.72, heightFactor: 0.42, paddingFactor: 0.02);
    case 'item_compass_safari':
      return (widthFactor: 0.6, heightFactor: 0.6, paddingFactor: 0.02);
    case 'item_map_safari':
      return (widthFactor: 0.84, heightFactor: 0.62, paddingFactor: 0.02);
    case 'item_camera_safari':
      return (widthFactor: 0.72, heightFactor: 0.58, paddingFactor: 0.02);
    case 'item_backpack_adventure':
      return (widthFactor: 0.72, heightFactor: 0.78, paddingFactor: 0.02);
    case 'item_shirt_explorer':
      return (widthFactor: 0.84, heightFactor: 0.92, paddingFactor: 0.02);
    case 'item_shoes_safari':
      return (widthFactor: 0.78, heightFactor: 0.4, paddingFactor: 0.02);
  }

  switch (slot) {
    case 'face':
      return (widthFactor: 0.7, heightFactor: 0.3, paddingFactor: 0.02);
    case 'head':
      return (widthFactor: 0.88, heightFactor: 0.48, paddingFactor: 0.02);
    case 'front':
    case 'accessory':
      return (widthFactor: 0.72, heightFactor: 0.62, paddingFactor: 0.02);
    default:
      return (widthFactor: 0.78, heightFactor: 0.78, paddingFactor: 0.02);
  }
}

Iterable<String> _layeredEquippedItemIds(_GameCharacterState state) sync* {
  final currentEquipped = state._currentPoseEquippedItems;
  if (currentEquipped.isEmpty) {
    return;
  }

  for (final slotLayer in _GameCharacterState._slotLayers) {
    for (final itemId in currentEquipped.values) {
      final itemConfig = _getItemConfig(itemId, slotLayer);
      if (itemConfig.slot == slotLayer) {
        yield itemId;
      }
    }
  }
}

Offset _getClampedItemOffset(
  _GameCharacterState state,
  String itemId,
  Offset rawOffset, {
  double? currentScale,
}) {
  final overflowAllowance =
      _getItemHitRadius(state, itemId, currentScale: currentScale) * 0.8;
  final halfCharacterExtent = state.widget.height / 2;
  final horizontalReach = halfCharacterExtent + overflowAllowance;
  final verticalReach = halfCharacterExtent + overflowAllowance;

  return Offset(
    rawOffset.dx.clamp(-horizontalReach, horizontalReach).toDouble(),
    rawOffset.dy.clamp(-verticalReach, verticalReach).toDouble(),
  );
}

double _getItemHitRadius(
  _GameCharacterState state,
  String itemId, {
  double? currentScale,
}) {
  final itemConfig = _getItemConfig(itemId, '');
  final adjustments = _getCharacterAdjustments(
    state.widget.characterId,
    itemConfig.slot,
  );
  final layoutScale = itemConfig.renderScale * adjustments.scaleModifier;
  final resolvedScale = currentScale ??
      (_getItemSavedScale(state, itemId) * (state._dragScales[itemId] ?? 1.0))
          .clamp(0.1, 10.0);
  final itemExtent = layoutScale * state.widget.height * resolvedScale;

  return math.max(itemExtent * 0.45, state.widget.height * 0.1);
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

InventoryItem _getItemConfig(String itemId, String slot) =>
    InventoryConfig.allItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => InventoryItem(
        id: itemId,
        slot: slot,
        assetPath: 'assets/images/items/$itemId.png',
        name: 'Unknown',
      ),
    );

Map<String, double> _getItemSaved(_GameCharacterState state, String itemId) {
  final config = _getItemConfig(itemId, '');
  final adjustments = _getCharacterAdjustments(
    state.widget.characterId,
    config.slot,
  );
  final characterHeight = state.widget.height;
  final layoutScale = config.renderScale * adjustments.scaleModifier;
  final alignmentFactor = (characterHeight * (1.0 - layoutScale)) * 0.5;

  var dx = (config.offset.x + adjustments.dx) * alignmentFactor;
  var dy = (config.offset.y + adjustments.dy) * alignmentFactor;
  var scale = 1.0;
  var rot = 0.0;
  final idleKey = '${itemId}_idle';

  String lookupKey = itemId;
  for (final poseName in state._currentPoseLookupNames) {
    final poseKey = '${itemId}_$poseName';
    if (state.widget.customItemOffsets?.containsKey(poseKey) == true ||
        state._optimisticOffsets.containsKey(poseKey)) {
      lookupKey = poseKey;
      break;
    }
  }

  if (lookupKey == itemId &&
      (state.widget.customItemOffsets?.containsKey(idleKey) == true ||
          state._optimisticOffsets.containsKey(idleKey))) {
    lookupKey = idleKey;
  }

  final stored = state._optimisticOffsets[lookupKey] ??
      state.widget.customItemOffsets?[lookupKey];
  if (stored != null) {
    if (stored.startsWith('n,')) {
      final parts = stored.substring(2).split(',');
      if (parts.length >= 2) {
        final nx = double.tryParse(parts[0]);
        final ny = double.tryParse(parts[1]);
        if (nx != null) dx = nx * state.widget.height;
        if (ny != null) dy = ny * state.widget.height;
      }
      if (parts.length >= 4) {
        scale = double.tryParse(parts[2]) ?? scale;
        rot = double.tryParse(parts[3]) ?? rot;
      }
    } else if (stored.startsWith('p,')) {
      final parts = stored.substring(2).split(',');
      if (parts.length >= 2) {
        final px = double.tryParse(parts[0]);
        final py = double.tryParse(parts[1]);
        if (px != null) dx = (px / 200.0) * state.widget.height;
        if (py != null) dy = (py / 200.0) * state.widget.height;
      }
      if (parts.length >= 4) {
        scale = double.tryParse(parts[2]) ?? scale;
        rot = double.tryParse(parts[3]) ?? rot;
      }
    } else {
      final parts = stored.split(',');
      if (parts.length >= 4) {
        scale = double.tryParse(parts[2]) ?? scale;
        rot = double.tryParse(parts[3]) ?? rot;
      }
    }
  }
  return {'dx': dx, 'dy': dy, 'scale': scale, 'rot': rot};
}

double _getItemSavedDx(_GameCharacterState state, String id) =>
    _getItemSaved(state, id)['dx']!;

double _getItemSavedDy(_GameCharacterState state, String id) =>
    _getItemSaved(state, id)['dy']!;

double _getItemSavedScale(_GameCharacterState state, String id) =>
    _getItemSaved(state, id)['scale']!;

double _getItemSavedRot(_GameCharacterState state, String id) =>
    _getItemSaved(state, id)['rot']!;

Offset _getItemPixelOffset(
  _GameCharacterState state,
  String itemId,
  double canvasSize,
) {
  final saved = _getItemSaved(state, itemId);
  final drag = state._dragOffsets[itemId] ?? Offset.zero;
  final currentScale =
      (saved['scale']! * (state._dragScales[itemId] ?? 1.0)).clamp(0.1, 10.0);

  return _getClampedItemOffset(
    state,
    itemId,
    Offset(saved['dx']! + drag.dx, saved['dy']! + drag.dy),
    currentScale: currentScale,
  );
}

List<Widget> _buildEquippedItem(
  _GameCharacterState state,
  BuildContext context,
  String slotLayer,
  double canvasSize,
) {
  final currentEquipped = state._currentPoseEquippedItems;
  if (currentEquipped.isEmpty) {
    return [];
  }

  final widgets = <Widget>[];

  for (final itemId in currentEquipped.values) {
    final itemConfig = _getItemConfig(itemId, slotLayer);
    if (itemConfig.slot != slotLayer) continue;

    final adjustments = _getCharacterAdjustments(
      state.widget.characterId,
      slotLayer,
    );
    final layoutScale = itemConfig.renderScale * adjustments.scaleModifier;
    final saved = _getItemSaved(state, itemId);

    final ds = state._dragScales[itemId] ?? 1.0;
    final dr = state._dragRotations[itemId] ?? 0.0;

    final currentScale = (saved['scale']! * ds).clamp(0.1, 10.0);
    final currentRot = saved['rot']! + dr;
    final currentOffset = _getItemPixelOffset(state, itemId, canvasSize);
    final currentDx = currentOffset.dx;
    final currentDy = currentOffset.dy;

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheHeight = (state.widget.height *
            pixelRatio *
            itemConfig.renderScale *
            adjustments.scaleModifier)
        .toInt()
        .clamp(20, 1000);

    Widget itemWidget = Image.asset(
      itemConfig.assetPath,
      fit: BoxFit.contain,
      cacheHeight: cacheHeight,
    );
    itemWidget = Transform.scale(
      scale: currentScale,
      child: Transform.rotate(angle: currentRot, child: itemWidget),
    );

    widgets.add(
      Positioned.fill(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(currentDx, currentDy),
              child: SizedBox(
                width: layoutScale * state.widget.height,
                height: layoutScale * state.widget.height,
                child: itemWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }

  return widgets;
}
