import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/config/difficulty_config.dart';
import 'package:siffersafari/core/constants/app_constants.dart';
import 'package:siffersafari/core/providers/app_theme_provider.dart';
import 'package:siffersafari/core/providers/user_provider.dart';
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
  int? _selectedGrade;
  CharacterInfo _selectedCharacter = _characters.first;
  int _reactionNonce = 0;

  static const List<CharacterInfo> _characters = [
    CharacterInfo(
      id: 'loke',
      name: 'Loke',
      description: 'Apan som ser mönster i allt. Älskar ordning och pussel.',
      assetPath: 'assets/characters/loke/png/loke_base.png',
      emoji: '🐵',
    ),
    CharacterInfo(
      id: 'signe',
      name: 'Signe',
      description:
          'Djungelns snabbaste leopard. Ser banan som ett stort pussel.',
      assetPath: 'assets/characters/signe/png/signe_base.png',
      emoji: '🐆',
    ),
    CharacterInfo(
      id: 'astrid',
      name: 'Astrid',
      description: 'Minnesmästaren. En liten elefant som aldrig glömmer.',
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
    final cfg = ref.watch(appThemeConfigProvider);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);

    return AlertDialog(
      scrollable: true,
      backgroundColor: cfg.cardColor,
      title: Text('Skapa användare', style: TextStyle(color: onPrimary)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(color: onPrimary),
              decoration: InputDecoration(
                labelText: 'Namn',
                labelStyle: TextStyle(color: mutedOnPrimary),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),
            Text(
              'Vem vill du spela som?',
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

                  final handleTap = () {
                    setState(() {
                      _selectedCharacter = char;
                      _reactionNonce++;
                    });
                  };

                  return GestureDetector(
                    onTap: handleTap,
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cfg.primaryActionColor.withValues(alpha: 0.2)
                            : cfg.baseBackgroundColor,
                        border: Border.all(
                          color: isSelected
                              ? cfg.primaryActionColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      padding: const EdgeInsets.all(AppConstants.smallPadding),
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
                          const SizedBox(height: AppConstants.smallPadding),
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
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Årskurs',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: mutedOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                DropdownButton<int?>(
                  value: _selectedGrade,
                  dropdownColor: cfg.baseBackgroundColor,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: onPrimary),
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Ingen'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 1,
                      child: Text('Åk 1'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 2,
                      child: Text('Åk 2'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 3,
                      child: Text('Åk 3'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 4,
                      child: Text('Åk 4'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 5,
                      child: Text('Åk 5'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 6,
                      child: Text('Åk 6'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 7,
                      child: Text('Åk 7'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 8,
                      child: Text('Åk 8'),
                    ),
                    DropdownMenuItem<int?>(
                      value: 9,
                      child: Text('Åk 9'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _selectedGrade = value;
                  }),
                ),
              ],
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
            if (name.isEmpty) return;

            final ageGroup = DifficultyConfig.effectiveAgeGroup(
              fallback: AgeGroup.young,
              gradeLevel: _selectedGrade,
            );

            await ref.read(userProvider.notifier).createUser(
                  userId: const Uuid().v4(),
                  name: name,
                  ageGroup: ageGroup,
                  avatarEmoji: _selectedCharacter.emoji,
                  gradeLevel: _selectedGrade,
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
