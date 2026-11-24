import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/domain/services/experiment_decision.dart';

void main() {
  group('[Unit] Experimentbeslut', () {
    test('under trettio profiler per arm gissar vi inte', () {
      expect(
        ExperimentDecision.decide(
          controlProfiles: 12,
          variantProfiles: 40,
          controlRate: 0.10,
          variantRate: 0.40,
        ),
        ExperimentVerdict.collectMore,
      );
    });

    test('tre procentenheter räcker för att behålla', () {
      expect(
        ExperimentDecision.decide(
          controlProfiles: 60,
          variantProfiles: 60,
          controlRate: 0.20,
          variantRate: 0.23,
        ),
        ExperimentVerdict.keep,
      );
    });

    test('två och en halv procentenhet räcker inte', () {
      expect(
        ExperimentDecision.decide(
          controlProfiles: 60,
          variantProfiles: 60,
          controlRate: 0.20,
          variantRate: 0.225,
        ),
        ExperimentVerdict.drop,
      );
    });

    test('sämre variant tas bort, inte behålls', () {
      expect(
        ExperimentDecision.decide(
          controlProfiles: 80,
          variantProfiles: 80,
          controlRate: 0.30,
          variantRate: 0.18,
        ),
        ExperimentVerdict.drop,
      );
    });

    test('regeln är skriven i klartext åt månadsgenomgången', () {
      expect(
        ExperimentDecision.explain(
          controlProfiles: 10,
          variantProfiles: 10,
          controlRate: 0.2,
          variantRate: 0.2,
        ),
        contains('Samla mer data'),
      );
      expect(
        ExperimentDecision.explain(
          controlProfiles: 50,
          variantProfiles: 50,
          controlRate: 0.2,
          variantRate: 0.1,
        ),
        contains('Ta bort'),
      );
    });
  });
}
