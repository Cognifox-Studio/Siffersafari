import 'package:siffersafari/core/config/app_features.dart';
import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';

final class QuizFeatureSettings {
  const QuizFeatureSettings._();

  static bool defaultWordProblemsEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    try {
      final user = repository.getUserProgress(userId);
      if (user?.gradeLevel == 1) return false;
    } catch (_) {
      return AppFeatures.wordProblemsEnabled;
    }
    return AppFeatures.wordProblemsEnabled;
  }

  static bool hasStoredWordProblemsEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    try {
      return repository.getSetting(SettingsKeys.wordProblemsEnabled(userId))
          is bool;
    } catch (_) {
      return false;
    }
  }

  static bool readWordProblemsEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    final fallback = defaultWordProblemsEnabled(
      repository: repository,
      userId: userId,
    );
    try {
      final raw = repository.getSetting(
        SettingsKeys.wordProblemsEnabled(userId),
        defaultValue: fallback,
      );
      return raw is bool ? raw : fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<void> saveWordProblemsEnabled({
    required LocalStorageRepository repository,
    required String userId,
    required bool enabled,
  }) {
    return repository.saveSetting(
      SettingsKeys.wordProblemsEnabled(userId),
      enabled,
    );
  }

  static bool defaultMissingNumberEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    try {
      final grade = repository.getUserProgress(userId)?.gradeLevel;
      // Saknat tal is harder early; keep off for Åk 1–2 unless parent opts in.
      if (grade != null && grade <= 2) return false;
    } catch (_) {
      return AppFeatures.missingNumberEnabled;
    }
    return AppFeatures.missingNumberEnabled;
  }

  static bool hasStoredMissingNumberEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    try {
      return repository.getSetting(SettingsKeys.missingNumberEnabled(userId))
          is bool;
    } catch (_) {
      return false;
    }
  }

  static bool readMissingNumberEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    final fallback = defaultMissingNumberEnabled(
      repository: repository,
      userId: userId,
    );
    try {
      final raw = repository.getSetting(
        SettingsKeys.missingNumberEnabled(userId),
        defaultValue: fallback,
      );
      return raw is bool ? raw : fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<void> saveMissingNumberEnabled({
    required LocalStorageRepository repository,
    required String userId,
    required bool enabled,
  }) {
    return repository.saveSetting(
      SettingsKeys.missingNumberEnabled(userId),
      enabled,
    );
  }

  static bool readSpacedRepetitionEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    try {
      final raw = repository.getSetting(
        SettingsKeys.spacedRepetitionEnabled(userId),
        defaultValue: AppFeatures.spacedRepetitionEnabled,
      );
      return raw is bool ? raw : AppFeatures.spacedRepetitionEnabled;
    } catch (_) {
      return AppFeatures.spacedRepetitionEnabled;
    }
  }

  static Future<void> saveSpacedRepetitionEnabled({
    required LocalStorageRepository repository,
    required String userId,
    required bool enabled,
  }) {
    return repository.saveSetting(
      SettingsKeys.spacedRepetitionEnabled(userId),
      enabled,
    );
  }

  /// The parent's explicit choice, or null when nobody has ever chosen.
  ///
  /// Keeping "never set" apart from "set to off" is what makes the default
  /// grade-aware possible; the old getter collapsed both into false, which is
  /// why a 6-year-old never heard the question unless an adult went looking for
  /// the switch in the parent dashboard.
  static bool? readTextToSpeechPreference({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    try {
      final raw = repository.getSetting(SettingsKeys.textToSpeechEnabled(userId));
      return raw is bool ? raw : null;
    } catch (_) {
      return null;
    }
  }

  /// Åk 1–2 cannot read a word problem yet, so read-aloud is the access path
  /// rather than an enhancement: it defaults to ON there and stays off for the
  /// older grades, where reading the question is part of the exercise.
  /// An explicit choice from the parent dashboard always wins.
  static bool readTextToSpeechEnabled({
    required LocalStorageRepository repository,
    required String userId,
  }) {
    final stored = readTextToSpeechPreference(
      repository: repository,
      userId: userId,
    );
    if (stored != null) return stored;
    try {
      final grade = repository.getUserProgress(userId)?.gradeLevel;
      if (grade != null && grade <= 2) return true;
    } catch (_) {
      return AppFeatures.textToSpeechEnabled;
    }
    return AppFeatures.textToSpeechEnabled;
  }

  static Future<void> saveTextToSpeechEnabled({
    required LocalStorageRepository repository,
    required String userId,
    required bool enabled,
  }) {
    return repository.saveSetting(
      SettingsKeys.textToSpeechEnabled(userId),
      enabled,
    );
  }
}
