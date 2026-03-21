import 'package:audioplayers/audioplayers.dart';
import 'secure_storage_service.dart';

/// 사운드 효과 관리 서비스 (싱글톤)
class SoundService {
  static final SoundService _instance = SoundService._();
  factory SoundService() => _instance;
  SoundService._();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;

  final _player = AudioPlayer();

  /// 저장된 설정 로드
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final storage = SecureStorageService();
    _sfxEnabled = await storage.getSFXEnabled();
    _musicEnabled = await storage.getMusicEnabled();
  }

  /// 효과음 재생
  Future<void> playSE(String id) async {
    if (!_sfxEnabled) return;

    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$id.wav'));
    } catch (_) {
      // 사운드 파일 없거나 재생 실패 시 조용히 무시
    }
  }

  /// 효과음 토글
  Future<void> setSFXEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    await SecureStorageService().setSFXEnabled(enabled);
  }

  /// 음악 토글
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await SecureStorageService().setMusicEnabled(enabled);
  }
}
