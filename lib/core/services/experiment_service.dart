import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/services/experiment.dart';

/// Hands out and remembers experiment variants.
///
/// The variant is decided once, from the user id, and then stored. Recomputing
/// it every launch would be cheaper but wrong: a child who flips between "on"
/// and "off" makes every comparison meaningless -- and confusing for her.
class ExperimentService {
  const ExperimentService(this._repository);

  final LocalStorageRepository _repository;

  /// The variant [userId] has for [experiment], assigning it on first use.
  ({String variant, bool isNew}) variantFor({
    required String userId,
    required String experiment,
  }) {
    final key = SettingsKeys.experiment(userId, experiment);
    final stored = _repository.getSetting(key);
    if (stored is String && stored.isNotEmpty) {
      return (variant: stored, isNew: false);
    }

    final variants = Experiments.all[experiment] ?? const ['off', 'on'];
    final variant = experimentVariant(
      userId: userId,
      experiment: experiment,
      variants: variants,
    );
    // Fire and forget: a failed write must not stop the screen it feeds.
    // The next launch will simply assign the same variant again.
    _repository.saveSetting(key, variant);
    return (variant: variant, isNew: true);
  }

  /// Every experiment's variant for one child, assigning missing ones.
  Map<String, String> assignmentsFor(String userId) {
    return {
      for (final experiment in Experiments.all.keys)
        experiment: variantFor(userId: userId, experiment: experiment).variant,
    };
  }
}
