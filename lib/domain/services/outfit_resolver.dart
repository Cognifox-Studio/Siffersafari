/// Resolves which item is actually worn in each slot, for one pose.
///
/// Equipment is stored as `key -> itemId`, where the key is one of three
/// generations that all exist in real profiles:
///
///  * `<pose>_<itemId>` — picked in the wardrobe while a pose was selected,
///  * `idle_<itemId>` — the same thing, dressed while idle,
///  * a bare slot name (`head`, `face`) — the original slot-based model.
///
/// A child dresses the character once and expects it to stay dressed. So a
/// pose-specific entry should only *override* the base outfit for its slot;
/// everything not overridden is still worn.
///
/// Before this resolver, only keys matching the current pose were drawn, which
/// meant a hat equipped while idle disappeared the moment the character reacted
/// (`answerCorrect`, `celebrate`, `run`, …). Equipping something and having it
/// vanish is a broken promise, and the character reacts during every quiz.
class OutfitResolver {
  OutfitResolver._();

  /// Base keys are the ones that are not tied to a single pose.
  static bool isBaseKey(String key) =>
      !key.contains('_') || key.startsWith('idle_');

  /// The pose a key belongs to, or null for a base key.
  static String? poseOf(String key) {
    if (isBaseKey(key)) return null;
    final separator = key.indexOf('_');
    if (separator <= 0) return null;
    return key.substring(0, separator);
  }

  /// Returns the keys and values that should be drawn for [poseNames].
  ///
  /// [poseNames] is a priority list (e.g. `['celebrate', 'answerCorrect']`):
  /// earlier entries win when the same slot is dressed more than once.
  /// [slotOf] maps an item id to its slot and decides what "the same slot"
  /// means — two hats must not be drawn at once.
  static Map<String, String> resolve({
    required Map<String, String> equipped,
    required List<String> poseNames,
    required String Function(String itemId) slotOf,
  }) {
    if (equipped.isEmpty) return const <String, String>{};

    final bySlot = <String, MapEntry<String, String>>{};

    // Everything the child wore without choosing a pose.
    for (final entry in equipped.entries) {
      if (isBaseKey(entry.key)) {
        bySlot[slotOf(entry.value)] = entry;
      }
    }

    // Pose-specific entries override the base outfit, highest priority last so
    // it wins the slot.
    for (final poseName in poseNames.reversed) {
      final prefix = '${poseName}_';
      for (final entry in equipped.entries) {
        if (entry.key.startsWith(prefix)) {
          bySlot[slotOf(entry.value)] = entry;
        }
      }
    }

    return <String, String>{
      for (final entry in bySlot.values) entry.key: entry.value,
    };
  }
}
