import '../../core/constants/settings_keys.dart';
import '../../data/repositories/local_storage_repository.dart';

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
}
