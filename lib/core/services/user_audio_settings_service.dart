import 'package:siffersafari/core/constants/settings_keys.dart';
import 'package:siffersafari/core/services/audio_service.dart';
import 'package:siffersafari/data/repositories/local_storage_repository.dart';
import 'package:siffersafari/domain/entities/user_progress.dart';

class UserAudioSettingsService {
  const UserAudioSettingsService(this._repository, this._audioService);

  final LocalStorageRepository _repository;
  final AudioService _audioService;

  double readAudioLevelSetting(String key) {
    final raw = _repository.getSetting(key);
    if (raw is! num) return AppAudioLevel.high.factor;

    final volume = raw.toDouble().clamp(0.0, 1.0);
    if (volume <= 0.01) return AppAudioLevel.high.factor;
    return volume;
  }

  void syncAudioSettings(UserProgress user) {
    _audioService.setSoundVolume(
      readAudioLevelSetting(SettingsKeys.soundVolume(user.userId)),
    );
    _audioService.setMusicVolume(
      readAudioLevelSetting(SettingsKeys.musicVolume(user.userId)),
    );
    _audioService.setSoundEnabled(user.soundEnabled);
    _audioService.setMusicEnabled(user.musicEnabled);
  }
}
