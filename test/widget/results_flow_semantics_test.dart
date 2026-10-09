import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/features/quiz/presentation/results_screen_semantics.dart';

void main() {
  group('[Widget] Results flow semantics labels', () {
    test('home CTA label is stable for screen readers', () {
      expect(ResultsScreenSemantics.homeButtonLabel, 'Tillbaka till hemmet');
    });
  });
}
