import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// iOS: Keychain, Android: EncryptedSharedPreferences 사용
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._();
  factory SecureStorageService() => _instance;
  SecureStorageService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyHasSeenWelcome = 'has_seen_welcome';
  static const _keyLastLoginProvider = 'last_login_provider';
  static const _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const _keyUnlockedAvatars = 'unlocked_avatars';
  static const _keyTotalGamesPlayed = 'total_games_played';
  static const _keyDailyBest = 'daily_best';
  static const _keyDailyBestDate = 'daily_best_date';
  static const _keyDailyBonusStreak = 'daily_bonus_streak';
  static const _keyDailyBonusLastDate = 'daily_bonus_last_date';
  static const _keyDailyBonusCoins = 'daily_bonus_coins';
  static const _keyIapAdsRemoved = 'iap_ads_removed';
  static const _keyIapAvatarPack = 'iap_avatar_pack';
  static const _keyDailyChallengeDate = 'daily_challenge_date';
  static const _keyDailyChallengeAttempts = 'daily_challenge_attempts';
  static const _keySFXEnabled = 'sound_sfx_enabled';
  static const _keyMusicEnabled = 'sound_music_enabled';
  static const _keyUiDarkMode = 'ui_dark_mode';
  static const _keySocialLastReviewDate = 'social_last_review_date';
  static const _keySocialReviewCount = 'social_review_count';

  Future<bool> hasSeenWelcome() async {
    final value = await _storage.read(key: _keyHasSeenWelcome);
    return value == 'true';
  }

  Future<void> setSeenWelcome() async {
    await _storage.write(key: _keyHasSeenWelcome, value: 'true');
  }

  Future<String?> getLastLoginProvider() async {
    return _storage.read(key: _keyLastLoginProvider);
  }

  Future<void> setLastLoginProvider(String provider) async {
    await _storage.write(key: _keyLastLoginProvider, value: provider);
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _keyHasSeenOnboarding);
    return value == 'true';
  }

  Future<void> setSeenOnboarding() async {
    await _storage.write(key: _keyHasSeenOnboarding, value: 'true');
  }

  // ── 플레이 횟수 & 일일 최고점 ──

  Future<int> getTotalGamesPlayed() async {
    final value = await _storage.read(key: _keyTotalGamesPlayed);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> incrementGamesPlayed() async {
    final current = await getTotalGamesPlayed();
    await _storage.write(
      key: _keyTotalGamesPlayed,
      value: '${current + 1}',
    );
  }

  Future<int> getDailyBest() async {
    final dateStr = await _storage.read(key: _keyDailyBestDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (dateStr != today) return 0; // 날짜가 다르면 리셋
    final value = await _storage.read(key: _keyDailyBest);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> updateDailyBest(int score) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dateStr = await _storage.read(key: _keyDailyBestDate);
    final currentBest = (dateStr == today)
        ? int.tryParse(await _storage.read(key: _keyDailyBest) ?? '') ?? 0
        : 0;
    if (score > currentBest) {
      await _storage.write(key: _keyDailyBest, value: '$score');
      await _storage.write(key: _keyDailyBestDate, value: today);
    }
  }

  // ── 아바타 해금 ──

  Future<Set<String>> getUnlockedAvatars() async {
    final value = await _storage.read(key: _keyUnlockedAvatars);
    if (value == null || value.isEmpty) return {};
    return value.split(',').toSet();
  }

  Future<void> unlockAvatar(String avatarId) async {
    final unlocked = await getUnlockedAvatars();
    unlocked.add(avatarId);
    await _storage.write(
      key: _keyUnlockedAvatars,
      value: unlocked.join(','),
    );
  }

  Future<bool> isAvatarUnlocked(String avatarId) async {
    final unlocked = await getUnlockedAvatars();
    return unlocked.contains(avatarId);
  }

  // ── 데일리 보너스 ──

  Future<int> getDailyBonusStreak() async {
    final value = await _storage.read(key: _keyDailyBonusStreak);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> setDailyBonusStreak(int streak) async {
    await _storage.write(key: _keyDailyBonusStreak, value: '$streak');
  }

  Future<String?> getDailyBonusLastDate() async {
    return _storage.read(key: _keyDailyBonusLastDate);
  }

  Future<void> setDailyBonusLastDate(String date) async {
    await _storage.write(key: _keyDailyBonusLastDate, value: date);
  }

  Future<int> getDailyBonusCoins() async {
    final value = await _storage.read(key: _keyDailyBonusCoins);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> setDailyBonusCoins(int coins) async {
    await _storage.write(key: _keyDailyBonusCoins, value: '$coins');
  }

  // ── IAP 구매 상태 ──

  Future<bool> getAdsRemoved() async {
    final value = await _storage.read(key: _keyIapAdsRemoved);
    return value == 'true';
  }

  Future<void> setAdsRemoved(bool value) async {
    await _storage.write(key: _keyIapAdsRemoved, value: value.toString());
  }

  Future<bool> getAvatarPack() async {
    final value = await _storage.read(key: _keyIapAvatarPack);
    return value == 'true';
  }

  Future<void> setAvatarPack(bool value) async {
    await _storage.write(key: _keyIapAvatarPack, value: value.toString());
  }

  // ── 데일리 챌린지 시도 횟수 ──

  Future<int> getDailyChallengeAttempts() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dateStr = await _storage.read(key: _keyDailyChallengeDate);
    if (dateStr != today) return 0; // 날짜가 다르면 리셋
    final value = await _storage.read(key: _keyDailyChallengeAttempts);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> incrementDailyChallengeAttempts() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dateStr = await _storage.read(key: _keyDailyChallengeDate);
    int current = 0;
    if (dateStr == today) {
      final value = await _storage.read(key: _keyDailyChallengeAttempts);
      current = int.tryParse(value ?? '') ?? 0;
    }
    await _storage.write(key: _keyDailyChallengeDate, value: today);
    await _storage.write(
      key: _keyDailyChallengeAttempts,
      value: '${current + 1}',
    );
  }

  Future<bool> canAttemptDailyChallenge() async {
    final attempts = await getDailyChallengeAttempts();
    return attempts < 3;
  }

  // ── 사운드 설정 ──

  Future<bool> getSFXEnabled() async {
    final value = await _storage.read(key: _keySFXEnabled);
    return value != 'false'; // 기본값 true
  }

  Future<void> setSFXEnabled(bool enabled) async {
    await _storage.write(key: _keySFXEnabled, value: enabled.toString());
  }

  Future<bool> getMusicEnabled() async {
    final value = await _storage.read(key: _keyMusicEnabled);
    return value != 'false'; // 기본값 true
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _storage.write(key: _keyMusicEnabled, value: enabled.toString());
  }

  // ── 다크 모드 설정 ──
  // 반환: null=시스템 설정, 'true'=다크, 'false'=라이트
  Future<String?> getDarkMode() async {
    return _storage.read(key: _keyUiDarkMode);
  }

  Future<void> setDarkMode(String? value) async {
    if (value == null) {
      await _storage.delete(key: _keyUiDarkMode);
    } else {
      await _storage.write(key: _keyUiDarkMode, value: value);
    }
  }

  // ── 리뷰 요청 ──

  Future<String?> getLastReviewDate() async {
    return _storage.read(key: _keySocialLastReviewDate);
  }

  Future<void> setLastReviewDate(String date) async {
    await _storage.write(key: _keySocialLastReviewDate, value: date);
  }

  Future<int> getReviewCount() async {
    final value = await _storage.read(key: _keySocialReviewCount);
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<void> incrementReviewCount() async {
    final current = await getReviewCount();
    await _storage.write(
      key: _keySocialReviewCount,
      value: '${current + 1}',
    );
  }

  // ── 범용 읽기/쓰기 (업적 등 확장 기능용) ──

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
