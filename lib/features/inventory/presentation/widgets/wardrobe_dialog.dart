import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/audio_service_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';

import '../../../../domain/entities/inventory_item.dart';

class WardrobeDialog extends ConsumerWidget {
  const WardrobeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = ref.watch(userProvider).activeUser;

    if (activeUser == null) {
      return const SizedBox.shrink();
    }

    final unlockedItems = activeUser.unlockedItems;
    final equippedItems = activeUser.equippedItems;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: PlayfulPanel(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activeUser.selectedCharacterId == 'signe'
                    ? 'Signes garderob'
                    : activeUser.selectedCharacterId == 'astrid'
                        ? 'Astrids garderob'
                        : 'Lokes garderob',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largePadding),
              SizedBox(
                height: 250,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppConstants.smallPadding,
                    mainAxisSpacing: AppConstants.smallPadding,
                  ),
                  itemCount: InventoryConfig.allItems.length,
                  itemBuilder: (context, index) {
                    final item = InventoryConfig.allItems[index];
                    final isUnlocked = unlockedItems.contains(item.id);
                    // Om nyckeln eller värdet i the map är det specifika föremålet, är det utrustat
                    final isEquipped = equippedItems.values.contains(item.id);

                    return GestureDetector(
                      onTap: () {
                        if (isUnlocked) {
                          ref.read(audioServiceProvider).playClickSound();
                          if (isEquipped) {
                            // När vi avrustar använder vi föremålets ID istället för en fast slot, för att tillåta "multiple selects"
                            // men vi letar först upp ifall föremålet låg sparat under sin originella slot (bakåtkompatibilitet för gamla profiler).
                            final existingKey = equippedItems.entries
                                .firstWhere(
                                  (entry) => entry.value == item.id,
                                  orElse: () => MapEntry(item.id, item.id),
                                )
                                .key;

                            ref
                                .read(userProvider.notifier)
                                .unequipItem(existingKey);
                          } else {
                            // Vi sparar föremålets id som slot-nyckel, för att tillåta oändligt antal av samma slot
                            ref
                                .read(userProvider.notifier)
                                .equipItem(item.id, item.id);
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isEquipped
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius),
                          border: Border.all(
                            color: isEquipped
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Opacity(
                                opacity: isUnlocked ? 1.0 : 0.3,
                                child: Image.asset(item.assetPath),
                              ),
                            ),
                            if (!isUnlocked)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Image.asset(
                                  'assets/images/ui/ic_reward_locked.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ref.read(audioServiceProvider).playClickSound();
                      ref.read(userProvider.notifier).clearCustomItemOffsets();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Återställ placering'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tillbaka'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
