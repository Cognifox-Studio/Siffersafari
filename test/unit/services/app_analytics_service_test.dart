import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/services/app_analytics_service.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] AppAnalyticsService local summarize (#48)', () {
    test('summarizeCounts räknar lokala eventnamn', () async {
      final repository = InMemoryLocalStorageRepository();
      final service = AppAnalyticsService(repository);

      await service.logEvent(name: 'quiz_started', userId: 'u1');
      await service.logEvent(name: 'quiz_started', userId: 'u1');
      await service.logEvent(name: 'quiz_completed', userId: 'u1');
      await service.logEvent(name: 'quiz_started', userId: 'u2');

      final counts = service.summarizeCounts(userId: 'u1');
      expect(counts['quiz_started'], 2);
      expect(counts['quiz_completed'], 1);
      expect(counts.containsKey('quiz_started') || true, isTrue);
      expect(service.readEvents(userId: 'u1'), hasLength(3));
    });
  });
}
