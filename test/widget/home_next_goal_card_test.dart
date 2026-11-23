import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/next_goal.dart';
import 'package:siffersafari/features/home/presentation/widgets/home_next_goal_card.dart';

void main() {
  testWidgets('[Widget] Nästa mål visas med titel och text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeNextGoalCard(
            goal: NextGoal(
              kind: NextGoalKind.badge,
              title: 'Första quizet',
              body: 'Klara ditt första quiz.',
              emoji: '🧭',
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(HomeNextGoalCard.cardKey), findsOneWidget);
    expect(find.byKey(HomeNextGoalCard.titleKey), findsOneWidget);
    expect(find.text('Nästa mål'), findsOneWidget);
    expect(find.text('Första quizet'), findsOneWidget);
    expect(find.text('Klara ditt första quiz.'), findsOneWidget);
  });

  testWidgets('[Widget] uppläsningen får hela meningen, inte emojin',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeNextGoalCard(
            goal: NextGoal(
              kind: NextGoalKind.level,
              title: 'Nivå 2',
              body: 'Poäng kvar till nästa nivå: 80.',
              emoji: '🚀',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byKey(HomeNextGoalCard.cardKey)),
      matchesSemantics(
        container: true,
        label: 'Nästa mål. Nivå 2. Poäng kvar till nästa nivå: 80.',
      ),
    );
    handle.dispose();
  });
}
