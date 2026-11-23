import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siffersafari/core/providers/local_storage_repository_provider.dart';
import 'package:siffersafari/domain/enums/operation_type.dart';
import 'package:siffersafari/domain/services/personal_best.dart';

/// Which history to read: one profile, and optionally one round to leave out.
typedef PersonalBestQuery = ({String userId, String? excludeSessionId});

/// Best round per operation for one profile.
///
/// Derived here rather than in the results screen: presentation reads
/// provider state, it does not talk to storage (see the boundary audit).
///
/// `excludeSessionId` matters because a round is written to history before the
/// results screen paints -- without it the round would be compared with itself
/// and never look like a record.
final personalBestsProvider = Provider.autoDispose
    .family<Map<OperationType, PersonalBest>, PersonalBestQuery>(
  (ref, query) {
    return personalBestsFrom(
      ref.watch(localStorageRepositoryProvider).getQuizHistory(query.userId),
      excludeSessionId: query.excludeSessionId,
    );
  },
);
