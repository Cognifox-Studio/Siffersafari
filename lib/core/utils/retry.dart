/// Small helper for retrying transient async failures.
///
/// Intended usage in this codebase:
/// - ONLY for write/clear/delete operations (not reads) to avoid masking real
///   corruption problems.
Future<T> retryAsync<T>({
  required String label,
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 50),
  Duration maxDelay = const Duration(milliseconds: 500),
  void Function(String message)? log,
  bool Function(Object error)? shouldRetry,
}) async {
  if (maxAttempts <= 0) {
    throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be > 0');
  }

  Duration scaledDelay(Duration base, int factor) {
    final micros = base.inMicroseconds * factor;
    return Duration(microseconds: micros);
  }

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e) {
      final Object error = e;

      final retryable = shouldRetry == null ? true : shouldRetry(error);
      final isLastAttempt = attempt >= maxAttempts;

      if (!retryable || isLastAttempt) rethrow;

      log?.call(
        '[$label] misslyckades (försök $attempt/$maxAttempts): $error — försöker igen…',
      );

      final backoffFactor = 1 << (attempt - 1); // 1,2,4...
      var delay = scaledDelay(initialDelay, backoffFactor);
      if (delay > maxDelay) delay = maxDelay;
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
    }
  }

  // Should be unreachable because we either return or rethrow.
  throw StateError('retryAsync reached unreachable code: $label');
}
