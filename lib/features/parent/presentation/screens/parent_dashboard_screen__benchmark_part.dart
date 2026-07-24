part of 'parent_dashboard_screen.dart';

class _BenchmarkSection extends ConsumerWidget {
  const _BenchmarkSection({
    required this.userId,
    required this.gradeLevel,
    required this.allowedOperations,
    required this.storedSteps,
    required this.quizHistory,
  });

  final String userId;
  final int gradeLevel;
  final Set<OperationType> allowedOperations;
  final Map<String, int> storedSteps;
  final List<Map<String, dynamic>> quizHistory;

  ({double? rate, int answered}) _successRateFromLatestQuestions(
    OperationType op,
  ) {
    var correct = 0;
    var total = 0;

    for (final s in quizHistory) {
      if (s['operationType'] != op.name) continue;

      final cRaw = s['correctAnswers'];
      final tRaw = s['totalQuestions'];
      final c = cRaw is num ? cRaw.toInt() : int.tryParse('$cRaw');
      final t = tRaw is num ? tRaw.toInt() : int.tryParse('$tRaw');
      if (c == null || t == null || t <= 0) continue;

      correct += c;
      total += t;

      if (total >= DifficultyConfig.trainingRecommendationMinQuestions) {
        break;
      }
    }

    if (total <= 0) {
      return (rate: null, answered: 0);
    }
    return (rate: correct / total, answered: total);
  }

  String _percentLabel(double rate) {
    return '${(rate * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final mutedOnPrimary = onPrimary.withValues(alpha: AppOpacities.mutedText);
    final subtleOnPrimary =
        onPrimary.withValues(alpha: AppOpacities.subtleText);
    final user = ref.watch(userProvider).activeUser;

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

    final ops = <OperationType>[
      OperationType.addition,
      OperationType.subtraction,
      OperationType.multiplication,
      OperationType.division,
    ].where(allowedOperations.contains).toList(growable: false);

    Future<void> updateStep(OperationType op, int delta) async {
      final currentUser = user;
      if (currentUser == null || currentUser.userId != userId) return;

      final currentStoredSteps = currentUser.operationDifficultySteps;
      final currentStep = DifficultyConfig.clampDifficultyStep(
        currentStoredSteps[op.name] ?? DifficultyConfig.minDifficultyStep,
      );
      final nextStep =
          DifficultyConfig.clampDifficultyStep(currentStep + delta);
      if (nextStep == currentStep) return;

      final updatedSteps = {
        ...currentStoredSteps,
        op.name: nextStep,
      };

      await ref.read(userProvider.notifier).saveUser(
            currentUser.copyWith(operationDifficultySteps: updatedSteps),
          );
    }

    final cards = ops.map((op) {
      final stored = storedSteps[op.name];
      final currentStep = DifficultyConfig.clampDifficultyStep(
        stored ?? DifficultyConfig.minDifficultyStep,
      );
      final stats = _successRateFromLatestQuestions(op);
      final hasEnough =
          stats.answered >= DifficultyConfig.trainingRecommendationMinQuestions;

      final recommendedStep = !hasEnough
          ? null
          : DifficultyConfig.recommendedDifficultyStepForTraining(
              currentStep: currentStep,
              averageSuccessRate: stats.rate,
            );

      final indicatorStep = recommendedStep ?? currentStep;

      final benchmark = DifficultyConfig.compareDifficultyStepToGrade(
        gradeLevel: gradeLevel,
        operation: op,
        difficultyStep: indicatorStep,
      );

      final valueText = DifficultyConfig.benchmarkLevelLabel(benchmark.level);
      final recommendationText = DifficultyConfig.benchmarkRecommendationText(
        level: benchmark.level,
        operation: op,
      );

      final underlagText = stats.rate == null
          ? 'Underlag: 0/${DifficultyConfig.trainingRecommendationMinQuestions} frågor'
          : hasEnough
              ? 'Senaste ${DifficultyConfig.trainingRecommendationMinQuestions}: ${_percentLabel(stats.rate!)} rätt'
              : 'Underlag: ${stats.answered}/${DifficultyConfig.trainingRecommendationMinQuestions} (just nu: ${_percentLabel(stats.rate!)} rätt)';

      final stepText = recommendedStep == null
          ? 'Steg $currentStep'
          : 'Steg $currentStep → Förslag $recommendedStep';

      final detailsMessage = StringBuffer()
        ..writeln('Indikator: $valueText')
        ..writeln(underlagText)
        ..writeln(stepText)
        ..writeln()
        ..writeln('Obs: Quizet finjusterar steg försiktigt efter svaren.')
        ..writeln('Du kan också själv trycka Lättare eller Svårare.');

      if (recommendationText.isNotEmpty) {
        detailsMessage
          ..writeln()
          ..writeln(recommendationText);
      }

      return _BenchmarkOperationCard(
        operation: op,
        valueText: valueText,
        underlagText: underlagText,
        stepText: stepText,
        onPrimary: onPrimary,
        mutedOnPrimary: mutedOnPrimary,
        subtleOnPrimary: subtleOnPrimary,
        onShowDetails: () => showInfoDialog(
          title: '${op.displayName} – detaljer',
          message: detailsMessage.toString().trim(),
        ),
        onDecrease: (currentStep <= DifficultyConfig.minDifficultyStep)
            ? null
            : () => updateStep(op, -1),
        onIncrease: (currentStep >= DifficultyConfig.maxDifficultyStep)
            ? null
            : () => updateStep(op, 1),
      );
    }).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Skolverket-indikator (Åk $gradeLevel)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: mutedOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            IconButton(
              tooltip: 'Förklaring',
              visualDensity: VisualDensity.compact,
              onPressed: () => showInfoDialog(
                title: 'Skolverket-indikator',
                message:
                    'Detta är en enkel “Under / I linje / Över”-indikator baserad på appens nivå (steg 1–10) per räknesätt.\n\nFörslag bygger på de senaste ${DifficultyConfig.trainingRecommendationMinQuestions} frågorna (mål: 85% rätt).\n\nQuizet finjusterar steg försiktigt efter svaren. Du kan också själv trycka Lättare eller Svårare.',
              ),
              icon: Icon(Icons.help_outline, color: onPrimary),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Kort sagt: indikatorn speglar barnets senaste svar.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtleOnPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        LayoutBuilder(
          builder: (context, constraints) {
            final useGrid = constraints.maxWidth >= 520 && cards.length > 1;

            if (!useGrid) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: cards,
              );
            }

            final itemWidth =
                (constraints.maxWidth - AppConstants.smallPadding) / 2;
            return Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: itemWidth,
                      child: card,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _BenchmarkOperationCard extends StatelessWidget {
  const _BenchmarkOperationCard({
    required this.operation,
    required this.valueText,
    required this.underlagText,
    required this.stepText,
    required this.onPrimary,
    required this.mutedOnPrimary,
    required this.subtleOnPrimary,
    required this.onShowDetails,
    required this.onDecrease,
    required this.onIncrease,
  });

  final OperationType operation;
  final String valueText;
  final String underlagText;
  final String stepText;
  final Color onPrimary;
  final Color mutedOnPrimary;
  final Color subtleOnPrimary;
  final VoidCallback onShowDetails;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return _InsetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  operation.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: mutedOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Text(
                valueText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                tooltip: 'Förklaring',
                visualDensity: VisualDensity.compact,
                onPressed: onShowDetails,
                icon: Icon(Icons.help_outline, color: onPrimary),
              ),
            ],
          ),
          Text(
            underlagText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.microSpacing2),
          Text(
            stepText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtleOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecrease,
                  child: const Text('Lättare'),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: OutlinedButton(
                  onPressed: onIncrease,
                  child: const Text('Svårare'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
