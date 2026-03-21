import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._();

  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  /// Remote Config 초기화 (main.dart에서 호출)
  Future<void> initialize() async {
    try {
      await _rc.setDefaults({
        'game_initial_timer_seconds': 90,
        'maintenance_mode': false,
        'force_update_version': '0.0.0',
        'event_banner_enabled': false,
        'event_banner_text': '',
        'ad_interstitial_frequency': 3,
      });

      await _rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 5)
            : const Duration(hours: 12),
      ));

      await _rc.fetchAndActivate();
    } catch (e) {
      // Remote Config 실패해도 앱 실행 가능 (기본값 사용)
      debugPrint('RemoteConfig initialize failed: $e');
    }
  }

  // ─── Getters ─────────────────────────────────────────

  int get initialTimerSeconds => _rc.getInt('game_initial_timer_seconds');

  bool get maintenanceMode => _rc.getBool('maintenance_mode');

  String get forceUpdateVersion => _rc.getString('force_update_version');

  bool get eventBannerEnabled => _rc.getBool('event_banner_enabled');

  String get eventBannerText => _rc.getString('event_banner_text');

  int get adInterstitialFrequency => _rc.getInt('ad_interstitial_frequency');
}
