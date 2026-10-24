import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';

class AppAnalyticsEvent {
  const AppAnalyticsEvent({
    required this.name,
    required this.timestamp,
    this.userId,
    this.properties = const <String, Object?>{},
  });

  final String name;
  final DateTime timestamp;
  final String? userId;
  final Map<String, Object?> properties;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'properties': properties,
    };
  }
}

/// Lightweight local analytics used for funnel visibility without cloud SDKs.
class AppAnalyticsService {
  AppAnalyticsService(this._repository);

  static const int _maxStoredEvents = 500;

  final LocalStorageRepository _repository;

  Future<void> logEvent({
    required String name,
    String? userId,
    Map<String, Object?> properties = const <String, Object?>{},
  }) async {
    final current = _repository.getSetting(
      SettingsKeys.analyticsEvents,
      defaultValue: const <dynamic>[],
    );

    final events = current is List ? List<dynamic>.from(current) : <dynamic>[];

    events.add(
      AppAnalyticsEvent(
        name: name,
        timestamp: DateTime.now(),
        userId: userId,
        properties: properties,
      ).toMap(),
    );

    if (events.length > _maxStoredEvents) {
      events.removeRange(0, events.length - _maxStoredEvents);
    }

    await _repository.saveSetting(SettingsKeys.analyticsEvents, events);
  }

  /// Offline-only event maps newest-first (COPPA: never leaves the device).
  List<Map<String, dynamic>> readEvents({String? userId}) {
    final current = _repository.getSetting(
      SettingsKeys.analyticsEvents,
      defaultValue: const <dynamic>[],
    );
    if (current is! List) return const [];

    final parsed = <Map<String, dynamic>>[];
    for (final raw in current.reversed) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      if (userId != null && map['userId'] != null && map['userId'] != userId) {
        continue;
      }
      parsed.add(map);
    }
    return parsed;
  }

  /// Friendly counts for parent dashboard insight (ROI #48).
  Map<String, int> summarizeCounts({
    String? userId,
    int lookback = 200,
  }) {
    final events = readEvents(userId: userId).take(lookback);
    final counts = <String, int>{};
    for (final event in events) {
      final name = event['name'] as String? ?? '';
      if (name.isEmpty) continue;
      counts.update(name, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }
}
