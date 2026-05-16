import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
import 'package:siffersafari/core/theme/app_theme_colors.dart';
import 'package:siffersafari/domain/enums/age_group.dart';
import 'package:siffersafari/gen/assets.g.dart';
import 'package:siffersafari/presentation/widgets/game_character.dart';
import 'package:uuid/uuid.dart';

Future<void> showCreateUserDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return const _CreateUserDialog();
    },
  );
}

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog();

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class CharacterInfo {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final String emoji;

  const CharacterInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.emoji,
  });
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
  final _nameController = TextEditingController();
  String? _nameErrorText;
  CharacterInfo _selectedCharacter = _characters.first;
  int _reactionNonce = 0;

  static const List<CharacterInfo> _characters = [
    CharacterInfo(
      id: 'loke',
      name: 'Loke',
      description: 'Ser mönster snabbt.',
      assetPath: 'assets/characters/loke/png/loke_base.png',
      emoji: '🐵',
    ),
    CharacterInfo(
      id: 'signe',
      name: 'Signe',
      description: 'Springer snabbt.',
      assetPath: 'assets/characters/signe/png/signe_base.png',
      emoji: '🐆',
    ),
    CharacterInfo(
      id: 'astrid',
      name: 'Astrid',
      description: 'Minns allt.',
      assetPath: 'assets/characters/astrid/png/astrid_base.png',
      emoji: '🐘',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.appThemeColors;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

    return AlertDialog(
      scrollable: true,
      backgroundColor: themeColors.cardColor,
      title: Text('Skapa profil', style: TextStyle(color: onPrimary)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_nameErrorText == null) return;
                setState(() {
                  _nameErrorText = null;
                });
              },
              style: TextStyle(color: onPrimary),
              decoration: InputDecoration(
                labelText: 'Namn',
                hintText: 'Skriv namn',
                labelStyle: TextStyle(color: mutedOnPrimary),
                errorText: _nameErrorText,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),
            Text(
              'Välj figur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _characters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppConstants.defaultPadding),
                itemBuilder: (context, index) {
                  final char = _characters[index];
                  final isSelected = char.id == _selectedCharacter.id;

                  void handleTap() {
                    setState(() {
                      _selectedCharacter = char;
                      _reactionNonce++;
                    });
                  }

                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: 'Välj ${char.name}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        onTap: handleTap,
                        child: Container(
                          width: 140,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeColors.primaryActionColor.withValues(
                                    alpha: 0.2,
                                  )
                                : themeColors.baseBackgroundColor,
                            border: Border.all(
                              color: isSelected
                                  ? themeColors.primaryActionColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                          padding: const EdgeInsets.all(
                            AppConstants.smallPadding,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: GameCharacter(
                                  onTap: handleTap,
                                  characterId: CharacterId.values.firstWhere(
                                    (e) => e.name == char.id,
                                    orElse: () => CharacterId.loke,
                                  ),
                                  reaction: isSelected
                                      ? CharacterReaction.celebrate
                                      : CharacterReaction.idle,
                                  reactionNonce: isSelected ? _reactionNonce : 0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(
                                height: AppConstants.smallPadding,
                              ),
                              Text(
                                char.name,
                                style: TextStyle(
                                  color: onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                char.description,
                                style: TextStyle(
                                  color: mutedOnPrimary,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Avbryt'),
        ),
        TextButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              setState(() {
                _nameErrorText = 'Skriv ett namn.';
              });
              return;
            }

            await ref.read(userProvider.notifier).createUser(
                  userId: const Uuid().v4(),
                  name: name,
                  ageGroup: AgeGroup.young,
                  avatarEmoji: _selectedCharacter.emoji,
                  selectedCharacterId: _selectedCharacter.id,
                );

            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Skapa'),
        ),
      ],
    );
  }
}
