import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/utils/page_transitions.dart';
import 'package:siffersafari/features/home/presentation/screens/home_screen.dart';
import 'package:siffersafari/presentation/widgets/playful_panel.dart';
import 'package:siffersafari/presentation/widgets/themed_background_scaffold.dart';

class ProfileSelectionScreen extends ConsumerWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final users = userState.allUsers;
    final scheme = Theme.of(context).colorScheme;

    return ThemedBackgroundScaffold(
      appBar: AppBar(title: const Text('Välj spelare')),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 820
              ? 3
              : constraints.maxWidth >= 480
                  ? 2
                  : 1;
          final childAspectRatio = crossAxisCount == 1 ? 2.25 : 1.0;

          if (users.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: PlayfulPanel(
                  hero: true,
                  highlightColor: scheme.secondary,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🦁', style: TextStyle(fontSize: 48)),
                      SizedBox(height: AppConstants.defaultPadding),
                      PlayfulSectionHeading(
                        title: 'Inga spelare ännu',
                        subtitle: 'Be en vuxen skapa en profil.',
                        center: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PlayfulSectionHeading(
                title: 'Vem vill spela?',
                center: true,
              ),
              const SizedBox(height: AppConstants.largePadding),
              Expanded(
                child: GridView.builder(
                  itemCount: users.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppConstants.defaultPadding,
                    mainAxisSpacing: AppConstants.defaultPadding,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return _ProfileTile(
                      name: u.name,
                      avatarEmoji: u.avatarEmoji,
                      onTap: () async {
                        await ref.read(userProvider.notifier).selectUser(
                              u.userId,
                            );
                        if (!context.mounted) return;
                        await context.pushReplacementSmooth(const HomeScreen());
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTile extends ConsumerWidget {
  const _ProfileTile({
    required this.name,
    required this.avatarEmoji,
    required this.onTap,
  });

  final String name;
  final String avatarEmoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeCfg = ref.watch(appThemeConfigProvider);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return PlayfulPanel(
      onTap: onTap,
      hero: true,
      highlightColor: themeCfg.primaryActionColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 220 || constraints.maxHeight < 170;

          if (compact) {
            return Row(
              children: [
                _ProfileAvatar(
                  avatarEmoji: avatarEmoji,
                  color: themeCfg.accentColor,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _ProfileTileText(name: name)),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: onPrimary,
                  size: 28,
                ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ProfileAvatar(
                avatarEmoji: avatarEmoji,
                color: themeCfg.accentColor,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _ProfileTileText(
                name: name,
                center: true,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Icon(
                Icons.play_circle_fill_rounded,
                color: onPrimary,
                size: 28,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarEmoji,
    required this.color,
  });

  final String avatarEmoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.34),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        avatarEmoji,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}

class _ProfileTileText extends StatelessWidget {
  const _ProfileTileText({
    required this.name,
    this.center = false,
  });

  final String name;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
