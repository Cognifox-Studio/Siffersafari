import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/features/inventory/presentation/widgets/wardrobe_dialog.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';

/// A view representing the user's "Camp" where the mascot lives.
/// Currently a placeholder structure for v1.6.0.
class CampSceneView extends ConsumerWidget {
  const CampSceneView({
    required this.mascotReaction,
    required this.mascotReactionNonce,
    this.isWideScreen = false,
    super.key,
  });

  final CharacterReaction mascotReaction;
  final int mascotReactionNonce;
  final bool isWideScreen;

  void _openWardrobe(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider).activeUser;
    if (user != null) {
      showDialog(
        context: context,
        builder: (context) => const WardrobeDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).activeUser;
    final characterId = user?.selectedCharacterId == 'signe'
        ? CharacterId.signe
        : user?.selectedCharacterId == 'astrid'
            ? CharacterId.astrid
            : CharacterId.loke;

    final theme = Theme.of(context);
    
    // The height of the camp scene.
    final height = isWideScreen ? 280.0 : 250.0;
    
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.6),
          width: 4,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background placeholder for camp scene illustration (v1.6.0)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Text(
                    'Camp Scene Placeholder\n(Väntar på assets)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.green.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Data-driven layer for placeable items (placeholder for future furniture)
          const Positioned(
            bottom: 20,
            left: 30,
            child: _CampItemPlaceholder(icon: Icons.fireplace, label: 'Lägereld'),
          ),
          const Positioned(
            bottom: 20,
            right: 30,
            child: _CampItemPlaceholder(icon: Icons.chair, label: 'Stubbe'),
          ),

          // Character
          Positioned(
            bottom: 10,
            child: SizedBox(
              height: height * 0.75, // Scale mascot slightly within camp
              child: GameCharacter(
                characterId: characterId,
                reaction: mascotReaction,
                reactionNonce: mascotReactionNonce,
                height: height * 0.75,
                equippedItems: user?.equippedItems ?? const {},
                onTap: () => _openWardrobe(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampItemPlaceholder extends StatelessWidget {
  const _CampItemPlaceholder({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fireplace, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
