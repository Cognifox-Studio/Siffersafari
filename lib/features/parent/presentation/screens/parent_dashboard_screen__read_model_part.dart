part of 'parent_dashboard_screen.dart';

class _ParentDashboardReadModel {
  const _ParentDashboardReadModel({
    required this.visibleHistory,
    required this.remainingHistory,
    required this.parentSummary,
    required this.weakestAreas,
  });

  final List<Map<String, dynamic>> visibleHistory;
  final List<Map<String, dynamic>> remainingHistory;
  final String parentSummary;
  final List<_WeakArea> weakestAreas;

  factory _ParentDashboardReadModel.from({
    required UserProgress user,
    required List<Map<String, dynamic>> history,
  }) {
    return _ParentDashboardReadModel(
      visibleHistory: history.take(2).toList(growable: false),
      remainingHistory: history.skip(2).toList(growable: false),
      parentSummary: _summaryFor(user: user, history: history),
      weakestAreas: _weakestAreas(user.masteryLevels),
    );
  }

  static String _summaryFor({
    required UserProgress user,
    required List<Map<String, dynamic>> history,
  }) {
    if (history.isEmpty) return 'Barnet har inte spelat klart något quiz ännu.';
    if (user.successRate >= 0.85) {
      return 'Det flyter på bra just nu. Fortsätt i samma lugna takt.';
    }
    if (user.successRate >= 0.65) {
      return 'Lagom nivå just nu. Lite mer träning bygger säkerhet.';
    }
    return 'Det är lite kämpigt just nu. Kortare pass kan hjälpa.';
  }

  static List<_WeakArea> _weakestAreas(Map<String, double> masteryLevels) {
    if (masteryLevels.isEmpty) return const [];

    final entries = masteryLevels.entries
        .where((entry) => entry.value.isFinite)
        .map(
          (entry) => _WeakArea(
            key: entry.key,
            rate: entry.value.clamp(0.0, 1.0),
            label: _prettyMasteryKey(entry.key),
          ),
        )
        .toList();

    entries.sort((a, b) => a.rate.compareTo(b.rate));
    return entries.take(3).toList();
  }

  static String _prettyMasteryKey(String key) {
    final parts = key.split('_');
    if (parts.length < 2) return key;
    return '${_prettyEnumLabel(parts[0])} • ${_prettyEnumLabel(parts[1])}';
  }
}
