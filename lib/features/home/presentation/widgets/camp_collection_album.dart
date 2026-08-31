import 'package:flutter/material.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/utils/image_cache_size.dart';
import 'package:siffersafari/domain/entities/inventory_item.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';

Future<void> showCampCollectionAlbum(
  BuildContext context, {
  required List<String> unlockedItemIds,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return CampCollectionAlbumDialog(
        unlockedItemIds: unlockedItemIds,
      );
    },
  );
}

class CampCollectionAlbumDialog extends StatelessWidget {
  const CampCollectionAlbumDialog({
    required this.unlockedItemIds,
    super.key,
  });

  final List<String> unlockedItemIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final souvenirs = InventoryConfig.campSouvenirItems;
    final unlockedIds = unlockedItemIds.toSet();
    final unlockedCount =
        InventoryConfig.unlockedCampSouvenirCount(unlockedIds);
    final countLabel = '$unlockedCount av ${souvenirs.length}';
    final helperText = unlockedCount == 0
        ? 'Spela och samla.'
        : unlockedCount == souvenirs.length
            ? 'Alla camp-saker klara!'
            : 'Fler väntar.';

    return Dialog(
      key: const Key('camp_collection_album'),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: PlayfulPanel(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Campet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.smallPadding,
                        vertical: AppConstants.microSpacing6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        countLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.microSpacing6),
                Text(
                  helperText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Wrap(
                  spacing: AppConstants.smallPadding,
                  runSpacing: AppConstants.smallPadding,
                  children: [
                    for (final item in souvenirs)
                      _CampSouvenirTile(
                        item: item,
                        unlocked: unlockedIds.contains(item.id),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('camp_collection_album_close'),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Stäng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampSouvenirTile extends StatelessWidget {
  const _CampSouvenirTile({
    required this.item,
    required this.unlocked,
  });

  final InventoryItem item;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageCacheSize = imageCacheExtent(context, 56);
    final lockedCacheSize = imageCacheExtent(context, 28);
    final labelColor = unlocked
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.64);

    return Semantics(
      label: unlocked ? '${item.name}, upplåst' : '${item.name}, låst',
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: Key('camp_collection_album_tile_${item.id}'),
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: unlocked
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked
                      ? theme.colorScheme.primary.withValues(alpha: 0.35)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                ),
              ),
              child: unlocked
                  ? Image.asset(
                      item.assetPath,
                      key: Key('camp_collection_album_unlocked_${item.id}'),
                      fit: BoxFit.contain,
                      cacheWidth: imageCacheSize,
                      cacheHeight: imageCacheSize,
                    )
                  : Image.asset(
                      'assets/images/ui/ic_reward_locked_nobg.png',
                      key: Key('camp_collection_album_locked_${item.id}'),
                      fit: BoxFit.contain,
                      cacheWidth: lockedCacheSize,
                      cacheHeight: lockedCacheSize,
                    ),
            ),
            const SizedBox(height: AppConstants.microSpacing6),
            Text(
              unlocked ? item.name : 'Låst',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
