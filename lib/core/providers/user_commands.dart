/// User state command boundaries.
///
/// - **Profile / settings:** [UserNotifier.loadUsers], `selectUser`, `saveUser`,
///   equip/unequip, audio levels.
/// - **Quiz merge (sole write path):** [UserNotifier.applyQuizResult] →
///   [ApplyQuizResultUseCase].
///
/// UI should not call repository directly for progress merges.

library;

export 'user_provider.dart' show UserNotifier, UserState, userProvider;
