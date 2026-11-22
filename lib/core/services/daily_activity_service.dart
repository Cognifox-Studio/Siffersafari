import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';

/// One day's local counters for a single profile.
class DailyActivity {
  const DailyActivity({this.appOpens = 0, this.sessions = 0});

  /// Number of times the app was opened (counted once per day).
  final int appOpens;

  /// Number of finished quiz sessions.
  final int sessions;

  bool get hasSession => sessions > 0;

  DailyActivity withOpen() =>
      DailyActivity(appOpens: appOpens + 1, sessions: sessions);

  DailyActivity withSession() =>
      DailyActivity(appOpens: appOpens, sessions: sessions + 1);

  Map<String, dynamic> toJson() => <String, dynamic>{'o': appOpens, 's': sessions};

  static DailyActivity fromJson(Object? raw) {
    if (raw is! Map) return const DailyActivity();

    int read(String key) {
      final value = raw[key];
      if (value is int) return value;
      return int.tryParse('${value ?? ''}') ?? 0;
    }

    return DailyActivity(appOpens: read('o'), sessions: read('s'));
  }
}

/// Per-day activity counters, stored on the device.
///
/// The event log (`AppAnalyticsService`) is a ring buffer of 500 entries, which
/// an active family fills within a few days — deleting exactly the history a
/// retention question depends on. These counters are tiny, bounded, and survive
/// that buffer. Nothing leaves the device: no trackers, no cloud.
class DailyActivityService {
  DailyActivityService(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// How many days of history to keep.
  static const int retentionDays = 90;

  final LocalStorageRepository _repository;
  final DateTime Function() _clock;

  /// `YYYY-MM-DD` in local time; deliberately sortable so pruning is cheap.
  static String dayKey(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  /// Records an app open. Returns true when it is the first one today.
  Future<bool> recordAppOpen({required String userId}) =>
      _increment(userId: userId, session: false);

  /// Records a finished session. Returns true when it is the first one today.
  Future<bool> recordSession({required String userId}) =>
      _increment(userId: userId, session: true);

  DailyActivity activityOn({required String userId, DateTime? day}) {
    final key = dayKey(day ?? _clock());
    return DailyActivity.fromJson(_read(userId)[key]);
  }

  bool hasSessionToday({required String userId}) =>
      activityOn(userId: userId).hasSession;

  /// The last [days] days, most recent last, including empty days.
  Map<String, DailyActivity> recent({
    required String userId,
    int days = 7,
  }) {
    final today = _day(_clock());
    final stored = _read(userId);
    final result = <String, DailyActivity>{};
    for (var offset = days - 1; offset >= 0; offset--) {
      final key = dayKey(today.subtract(Duration(days: offset)));
      result[key] = DailyActivity.fromJson(stored[key]);
    }
    return result;
  }

  /// How many of the last [days] days have at least one finished session.
  int activeDays({required String userId, int days = 7}) =>
      recent(userId: userId, days: days)
          .values
          .where((activity) => activity.hasSession)
          .length;

  Future<bool> _increment({
    required String userId,
    required bool session,
  }) async {
    final stored = _read(userId);
    final key = dayKey(_clock());
    final current = DailyActivity.fromJson(stored[key]);
    final updated = session ? current.withSession() : current.withOpen();

    stored[key] = updated.toJson();
    _prune(stored);

    await _repository.saveSetting(SettingsKeys.dailyActivity(userId), stored);

    return session ? !current.hasSession : current.appOpens == 0;
  }

  Map<String, dynamic> _read(String userId) {
    final raw = _repository.getSetting(
      SettingsKeys.dailyActivity(userId),
      defaultValue: const <String, dynamic>{},
    );
    if (raw is Map) {
      return raw.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  void _prune(Map<String, dynamic> stored) {
    final cutoff = _day(_clock()).subtract(const Duration(days: retentionDays));
    stored.removeWhere((key, _) => !_isOnOrAfter(key, cutoff));
  }

  bool _isOnOrAfter(String key, DateTime cutoff) {
    final parts = key.split('-');
    if (parts.length != 3) return false;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return false;
    return !DateTime(year, month, day).isBefore(cutoff);
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}
