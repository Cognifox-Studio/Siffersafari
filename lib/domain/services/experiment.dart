/// The experiments that exist, and nothing else.
///
/// A variant may never touch the core loop -- it changes a line of copy or
/// whether a card is shown. If an idea needs more than that, it is a product
/// decision, not an experiment.
class Experiments {
  Experiments._();

  /// Is the weekly goal visible on home (step 12)?
  static const String weeklyQuest = 'weekly_quest_visible';

  /// Is the streak shown on home at all (step 4)?
  static const String streakBadge = 'streak_badge_visible';

  /// Every experiment and the variants it can land in.
  static const Map<String, List<String>> all = {
    weeklyQuest: ['on', 'off'],
    streakBadge: ['on', 'off'],
  };
}

/// Stable variant for one child and one experiment.
///
/// No server, no randomness at launch: the same child always lands in the same
/// variant, because the hash is over the user id. That also means a variant
/// cannot change under a child mid-week, which would make the data useless and
/// the app unpredictable.
String experimentVariant({
  required String userId,
  required String experiment,
  List<String> variants = const ['a', 'b'],
}) {
  if (variants.isEmpty) return 'a';
  final bucket = _fnv1a('$experiment:$userId');
  return variants[bucket % variants.length];
}

/// True when [userId] is in the first variant of [experiment].
///
/// Call sites read like an argument: `if (variantIsOn(userId: id, ...))`.
bool variantIsOn({
  required String userId,
  required String experiment,
}) {
  final variants = Experiments.all[experiment] ?? const ['off', 'on'];
  return experimentVariant(
        userId: userId,
        experiment: experiment,
        variants: variants,
      ) ==
      'on';
}

/// FNV-1a, 32 bit. Small, deterministic and dependency-free -- the point is
/// reproducibility across devices, not cryptographic quality.
int _fnv1a(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  // Avalanche before bucketing. Without it two experiments whose names differ
  // in one character land in the same bucket for the same child, and the two
  // results can never be read apart.
  hash ^= hash >> 13;
  hash = (hash * 0x5bd1e995) & 0xffffffff;
  hash ^= hash >> 15;
  return hash;
}
