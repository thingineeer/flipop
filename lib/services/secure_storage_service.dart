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

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
