import 'package:flutter_test/flutter_test.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/daily_activity_service.dart';

import '../../test_utils.dart';

void main() {
  group('[Unit] DailyActivityService', () {
    late InMemoryLocalStorageRepository repository;
    late DateTime now;
    late DailyActivityService service;

    setUp(() {
      repository = InMemoryLocalStorageRepository();
      now = DateTime(2026, 11, 22, 9);
      service = DailyActivityService(repository, clock: () => now);
    });

    test('dagsnyckel är sorterbar och nollstoppad', () {
      expect(DailyActivityService.dayKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(DailyActivityService.dayKey(DateTime(2026, 11, 22)), '2026-11-22');
    });

    test('första appöppningen på dagen rapporteras en gång', () async {
      expect(await service.recordAppOpen(userId: 'u1'), isTrue);
      expect(await service.recordAppOpen(userId: 'u1'), isFalse);

      expect(service.activityOn(userId: 'u1').appOpens, 2);
    });

    test('första sessionen på dagen rapporteras en gång', () async {
      expect(await service.recordSession(userId: 'u1'), isTrue);
      expect(await service.recordSession(userId: 'u1'), isFalse);

      expect(service.hasSessionToday(userId: 'u1'), isTrue);
      expect(service.activityOn(userId: 'u1').sessions, 2);
    });

    test('dagar utan session räknas inte som aktiva', () async {
      await service.recordSession(userId: 'u1');
      now = now.add(const Duration(days: 1));
      await service.recordAppOpen(userId: 'u1');

      expect(service.activeDays(userId: 'u1', days: 7), 1);
      expect(service.recent(userId: 'u1', days: 7).length, 7);
    });

    test('profiler hålls åtskilda', () async {
      await service.recordSession(userId: 'u1');

      expect(service.hasSessionToday(userId: 'u1'), isTrue);
      expect(service.hasSessionToday(userId: 'u2'), isFalse);
    });

    test('historik äldre än 90 dagar kastas, resten sparas', () async {
      await service.recordSession(userId: 'u1');
      final firstDay = DailyActivityService.dayKey(now);

      now = now.add(const Duration(days: DailyActivityService.retentionDays + 5));
      await service.recordSession(userId: 'u1');

      final stored = repository.getSetting(SettingsKeys.dailyActivity('u1'));
      expect(stored, isA<Map>());
      expect((stored as Map).containsKey(firstDay), isFalse);
      expect((stored).length, 1);
    });
  });
}
