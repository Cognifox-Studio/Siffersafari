part of 'parent_dashboard_screen.dart';

class _DashboardBody extends ConsumerStatefulWidget {
  const _DashboardBody({required this.userId});

  static const _gradeItems = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

  final String userId;

  @override
  ConsumerState<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends ConsumerState<_DashboardBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appAnalyticsProvider).logEvent(name: 'parent_mode_opened');
    });
  }

  @override
  Widget build(BuildContext context) {
    const sectionSpacing = SizedBox(height: AppConstants.defaultPadding);

    void showInfoDialog({required String title, required String message}) {
      showDialog(
        context: context,
        builder: (ctx) {
          final onPrimary = Theme.of(ctx).colorScheme.onPrimary;
          return AlertDialog(
            title: Text(
              title,
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            content: Text(
              message,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: onPrimary),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    Widget infoButton({required String title, required String message}) {
      final onPrimary = Theme.of(context).colorScheme.onPrimary;
      return IconButton(
        tooltip: 'Förklaring',
        visualDensity: VisualDensity.compact,
        onPressed: () => showInfoDialog(title: title, message: message),
        icon: Icon(Icons.help_outline, color: onPrimary),
      );
    }

    final accentColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final userId = widget.userId;
    final user = ref.watch(userProvider).activeUser!;
    final repo = ref.read(localStorageRepositoryProvider);
    final recentHistory = repo.getQuizHistory(userId, limit: 50);
    final history = recentHistory
        .where((s) => s['isComplete'] != false)
        .take(5)
        .toList(growable: false);
    final visibleHistory = history.take(2).toList(growable: false);
    final remainingHistory = history.skip(2).toList(growable: false);
    final parentSummary = history.isEmpty
        ? 'Barnet har inte spelat klart något quiz ännu.'
        : user.successRate >= 0.85
            ? 'Det flyter på bra just nu. Fortsätt i samma lugna takt.'
            : user.successRate >= 0.65
                ? 'Lagom nivå just nu. Lite mer träning bygger säkerhet.'
                : 'Det är lite kämpigt just nu. Kortare pass kan hjälpa.';
    final weakestAreas = _computeWeakestAreas(user.masteryLevels);

    final settingsNotifier = ref.read(parentSettingsProvider(userId).notifier);
    final allowedOps = ref.watch(parentSettingsProvider(userId));

    final wordProblemsEnabled = ref.watch(wordProblemsEnabledProvider(userId));
    final wordProblemsNotifier =
        ref.read(wordProblemsEnabledProvider(userId).notifier);

    final missingNumberEnabled =
        ref.watch(missingNumberEnabledProvider(userId));
    final missingNumberNotifier =
        ref.read(missingNumberEnabledProvider(userId).notifier);

    final spacedRepetitionEnabled =
        ref.watch(spacedRepetitionEnabledProvider(userId));
    final spacedRepetitionNotifier =
        ref.read(spacedRepetitionEnabledProvider(userId).notifier);

    final ttsEnabled = ref.watch(ttsEnabledProvider(userId));
    final ttsNotifier = ref.read(ttsEnabledProvider(userId).notifier);
    final themedMenuSurface = Color.alphaBlend(
      Theme.of(context).cardTheme.color ?? Colors.transparent,
      Theme.of(context).scaffoldBackgroundColor,
    );

    final overviewBadges = [
      _StatusBadge(
        label: user.gradeLevel == null ? 'Ingen Åk' : 'Åk ${user.gradeLevel}',
        icon: Icons.school_rounded,
        toneColor: primaryColor,
      ),
      _StatusBadge(
        label: ttsEnabled ? 'Uppläsning på' : 'Uppläsning av',
        icon: ttsEnabled
            ? Icons.record_voice_over_rounded
            : Icons.volume_off_rounded,
        toneColor: accentColor,
      ),
    ];

    final gradePicker = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppConstants.smallPadding,
          runSpacing: AppConstants.smallPadding,
          children: [
            _StatusBadge(
              label: user.gradeLevel == null
                  ? 'Ingen nivå vald'
                  : 'Nu: Åk ${user.gradeLevel}',
              icon: Icons.flag_rounded,
              toneColor: accentColor,
            ),
            _StatusBadge(
              label: 'Ändra när som helst',
              icon: Icons.tune_rounded,
              toneColor: primaryColor,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        DropdownButtonFormField<int?>(
          initialValue: user.gradeLevel,
          isExpanded: true,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          dropdownColor: themedMenuSurface,
          iconEnabledColor: onPrimary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
              ),
          decoration: InputDecoration(
            labelText: 'Årskurs',
            helperText: 'Ger tydligare nivåhjälp i analysen',
            prefixIcon: Icon(Icons.school_rounded, color: accentColor),
            filled: true,
            fillColor: onPrimary.withValues(alpha: 0.12),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Ingen'),
            ),
            ..._DashboardBody._gradeItems.map(
              (g) => DropdownMenuItem<int?>(
                value: g,
                child: Text('Åk $g'),
              ),
            ),
          ],
          onChanged: (value) async {
            await ref
                .read(userProvider.notifier)
                .saveUser(user.copyWith(gradeLevel: value));
          },
        ),
      ],
    );

    final operationChips = LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 280 ? 2 : 1;
        final itemWidth = columns == 2
            ? (constraints.maxWidth - AppConstants.smallPadding) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppConstants.smallPadding,
          runSpacing: AppConstants.smallPadding,
          children: _baseOps().map((op) {
            final isOn = allowedOps.contains(op);
            final canTurnOff = allowedOps.length > 1;
            final toneColor = switch (op) {
              OperationType.addition => primaryColor,
              OperationType.subtraction => accentColor,
              OperationType.multiplication =>
                primaryColor.withValues(alpha: 0.92),
              OperationType.division => accentColor.withValues(alpha: 0.92),
              OperationType.mixed => primaryColor.withValues(alpha: 0.82),
            };

            return SizedBox(
              width: itemWidth,
              child: _OperationToggleTile(
                operation: op,
                selected: isOn,
                enabled: !isOn || canTurnOff,
                toneColor: toneColor,
                onTap: (!isOn || canTurnOff)
                    ? () {
                        settingsNotifier.setOperationAllowed(op, !isOn);
                      }
                    : null,
              ),
            );
          }).toList(growable: false),
        );
      },
    );

    final overviewCard = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Översikt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            'Det viktigaste först för ${user.name}.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: overviewBadges,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          LayoutBuilder(
            builder: (context, constraints) {
              final tiles = [
                _OverviewMetricTile(
                  label: 'Nivå',
                  value: '${user.level}',
                  icon: Icons.auto_awesome_rounded,
                  toneColor: accentColor,
                ),
                _OverviewMetricTile(
                  label: 'Rätt',
                  value: '${(user.successRate * 100).toStringAsFixed(0)}%',
                  icon: Icons.check_circle_outline_rounded,
                  toneColor: primaryColor,
                ),
                _OverviewMetricTile(
                  label: 'Quiz',
                  value: '${user.totalQuizzesTaken}',
                  icon: Icons.quiz_outlined,
                  toneColor: accentColor.withValues(alpha: 0.88),
                ),
              ];

              if (constraints.maxWidth < 280) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final tile in tiles) ...[
                      tile,
                      if (tile != tiles.last)
                        const SizedBox(height: AppConstants.smallPadding),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var index = 0; index < tiles.length; index++) ...[
                    Expanded(child: tiles[index]),
                    if (index != tiles.length - 1)
                      const SizedBox(width: AppConstants.smallPadding),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: onPrimary.withValues(alpha: AppOpacities.subtleFill),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: onPrimary.withValues(alpha: AppOpacities.borderSubtle),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Läget idag',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  parentSummary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (visibleHistory.isNotEmpty || weakestAreas.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            LayoutBuilder(
              builder: (context, constraints) {
                final latestQuizPanel = visibleHistory.isEmpty
                    ? null
                    : _InsetPanel(
                        child:
                            _LatestQuizSnapshot(history: visibleHistory.first),
                      );
                final nextFocusPanel = weakestAreas.isEmpty
                    ? null
                    : _InsetPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Börja här',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.microSpacing4),
                            Text(
                              'Om du vill styra nästa övning, börja i de här områdena.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: subtleOnPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: AppConstants.smallPadding),
                            ...weakestAreas.map(
                              (area) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppConstants.microSpacing4,
                                ),
                                child: _RecommendationRow(area: area),
                              ),
                            ),
                          ],
                        ),
                      );

                final useTwoColumns = constraints.maxWidth >= 520 &&
                    latestQuizPanel != null &&
                    nextFocusPanel != null;

                if (useTwoColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: latestQuizPanel),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(child: nextFocusPanel),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (latestQuizPanel != null) latestQuizPanel,
                    if (latestQuizPanel != null && nextFocusPanel != null)
                      const SizedBox(height: AppConstants.defaultPadding),
                    if (nextFocusPanel != null) nextFocusPanel,
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );

    final adaptationsCard = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Snabba ändringar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              infoButton(
                title: 'Snabba ändringar',
                message:
                    'Det här är de val som oftast räcker för att styra upplevelsen.\n\nBörja med Årskurs, Stöd i quiz och Räknesätt. Fler val ligger längre ner.',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Vanligast först. Fler val ligger längre ner.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _InsetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ParentSectionHeader(
                  title: 'Nivå och mål',
                  subtitle: 'Välj årskurs när du vill få enklare nivåhjälp.',
                ),
                const SizedBox(height: AppConstants.smallPadding),
                gradePicker,
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _InsetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ParentSectionHeader(
                  title: 'Stöd i quiz',
                  subtitle:
                      'Bra när barnet behöver mer guidning i själva rundan.',
                ),
                const SizedBox(height: AppConstants.smallPadding),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Uppläsning',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: mutedOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    'Fråga och kort feedback i quiz',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtleOnPrimary,
                        ),
                  ),
                  value: ttsEnabled,
                  activeThumbColor: accentColor,
                  activeTrackColor: accentColor.withValues(
                    alpha: AppOpacities.highlightStrong,
                  ),
                  onChanged: (value) {
                    ttsNotifier.setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Repetition över tid',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: mutedOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    'Planerad repetition över tid',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtleOnPrimary,
                        ),
                  ),
                  value: spacedRepetitionEnabled,
                  activeThumbColor: accentColor,
                  activeTrackColor: accentColor.withValues(
                    alpha: AppOpacities.highlightStrong,
                  ),
                  onChanged: (value) async {
                    await spacedRepetitionNotifier.setEnabled(value);
                    if (!mounted) return;
                    ref
                        .read(quizProvider.notifier)
                        .hydrateReviewSummaryForUser(userId);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _InsetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ParentSectionHeader(
                  title: 'Räknesätt',
                  subtitle: 'Välj vad som får dyka upp i quiz.',
                ),
                const SizedBox(height: AppConstants.smallPadding),
                operationChips,
              ],
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _DashboardExpansionSection(
            title: 'Fler quizval',
            subtitle: 'Textuppgifter, saknat tal och figur',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Textuppgifter',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: mutedOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    'Kort berättelse i stället för bara siffror',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtleOnPrimary,
                        ),
                  ),
                  value: wordProblemsEnabled,
                  activeThumbColor: accentColor,
                  activeTrackColor: accentColor.withValues(
                    alpha: AppOpacities.highlightStrong,
                  ),
                  onChanged: (value) {
                    wordProblemsNotifier.setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Saknat tal',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: mutedOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    'Till exempel 7 + ? = 10',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtleOnPrimary,
                        ),
                  ),
                  value: missingNumberEnabled,
                  activeThumbColor: accentColor,
                  activeTrackColor: accentColor.withValues(
                    alpha: AppOpacities.highlightStrong,
                  ),
                  onChanged: (value) {
                    missingNumberNotifier.setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                _CharacterPickerTile(userId: userId),
              ],
            ),
          ),
        ],
      ),
    );

    final benchmarkSectionContent = user.gradeLevel == null
        ? Text(
            'Sätt Årskurs (Åk) för att få Under/I linje/Över-indikator.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          )
        : _BenchmarkSection(
            userId: user.userId,
            gradeLevel: user.gradeLevel!,
            allowedOperations: allowedOps,
            storedSteps: user.operationDifficultySteps,
            quizHistory: recentHistory,
          );

    final recommendationSectionContent = weakestAreas.isEmpty
        ? _ParentEmptyStatePanel(
            title: 'Fler quiz behövs',
            message: 'Spela några rundor så kommer nästa fokus hit.',
            icon: Icons.insights_rounded,
            toneColor: primaryColor,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Börja här',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppConstants.microSpacing4),
              Text(
                'De här områdena ser just nu svagast ut.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtleOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              ...weakestAreas.map(
                (a) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.microSpacing6,
                  ),
                  child: _RecommendationRow(area: a),
                ),
              ),
            ],
          );

    final analysisCard = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Analys',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              infoButton(
                title: 'Hur räknas statistiken?',
                message:
                    'Korrekt % (alla frågor) = alla svar sedan start.\n\nFörslag (steg) räknas per räknesätt på de senaste ${DifficultyConfig.trainingRecommendationMinQuestions} frågorna (mål: 85% rätt).\n\nRekommenderad övning visar snitt per kategori (t.ex. Plus • Lätt) från quiz-resultat. Det ändrar inte steg automatiskt.',
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Här ligger fördjupningen. Börja med rekommendationen och öppna nivådetaljer när du vill gräva djupare.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _InsetPanel(
            child: recommendationSectionContent,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _DashboardExpansionSection(
            title: user.gradeLevel == null
                ? 'Lägg till Årskurs för nivåindikator'
                : 'Se nivå per räknesätt',
            subtitle: user.gradeLevel == null
                ? 'Välj Åk först för att få Under / I linje / Över.'
                : 'Under / I linje / Över och stegförslag',
            child: benchmarkSectionContent,
          ),
        ],
      ),
    );

    final historyCard = _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Senaste quiz',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing4),
          Text(
            'Det senaste först. Öppna fler rundor vid behov.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          if (history.isEmpty)
            _ParentEmptyStatePanel(
              title: 'Ingen historik än',
              message: 'När första quizet är klart syns rundorna här.',
              icon: Icons.history_rounded,
              toneColor: accentColor,
            )
          else
            LayoutBuilder(
              builder: (context, historyConstraints) {
                final useHistoryGrid = historyConstraints.maxWidth >= 520 &&
                    visibleHistory.length > 1;

                if (!useHistoryGrid) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: visibleHistory
                        .map((h) => _HistoryRow(history: h))
                        .toList(growable: false),
                  );
                }

                final itemWidth = (historyConstraints.maxWidth -
                        AppConstants.defaultPadding) /
                    2;

                return Wrap(
                  spacing: AppConstants.defaultPadding,
                  runSpacing: AppConstants.defaultPadding,
                  children: visibleHistory
                      .map(
                        (h) => SizedBox(
                          width: itemWidth,
                          child: _HistoryTile(history: h),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          if (remainingHistory.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            _DashboardExpansionSection(
              title: 'Visa fler quiz',
              subtitle: '${remainingHistory.length} äldre rundor',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: remainingHistory
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.microSpacing6,
                        ),
                        child: _HistoryRow(history: h),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = AdaptiveLayoutInfo.fromConstraints(constraints);

        if (!layout.isExpandedWidth) {
          return ListView(
            children: [
              overviewCard,
              sectionSpacing,
              adaptationsCard,
              sectionSpacing,
              historyCard,
              sectionSpacing,
              analysisCard,
            ],
          );
        }

        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    overviewCard,
                    sectionSpacing,
                    historyCard,
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    adaptationsCard,
                    sectionSpacing,
                    analysisCard,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_WeakArea> _computeWeakestAreas(Map<String, double> masteryLevels) {
    if (masteryLevels.isEmpty) return const [];

    final entries = masteryLevels.entries
        .where((e) => e.value.isFinite)
        .map(
          (e) => _WeakArea(
            key: e.key,
            rate: e.value.clamp(0.0, 1.0),
            label: _prettyMasteryKey(e.key),
          ),
        )
        .toList();

    entries.sort((a, b) => a.rate.compareTo(b.rate));
    return entries.take(3).toList();
  }

  String _prettyMasteryKey(String key) {
    final parts = key.split('_');
    if (parts.length < 2) return key;
    final operation = parts[0];
    final difficulty = parts[1];

    return '${_prettyEnumLabel(operation)} • ${_prettyEnumLabel(difficulty)}';
  }

  List<OperationType> _baseOps() {
    return const [
      OperationType.addition,
      OperationType.subtraction,
      OperationType.multiplication,
      OperationType.division,
    ];
  }
}
