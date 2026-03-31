import 'dart:io';
import 'package:flutter/foundation.dart' show VoidCallback, kReleaseMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'analytics_service.dart';
import 'iap_service.dart';

class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;
  bool _isAppOpenReady = false;

  bool get isInterstitialReady => _isInterstitialReady;
  bool get isRewardedReady => _isRewardedReady;

  // 인터스티셜 빈도 제어: N판마다 1회
  int _gameOverCount = 0;
  static const int _interstitialFrequency = 3;

  String get _interstitialAdUnitId {
    if (!kReleaseMode) {
      // 테스트 광고 ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-5283496525222246/8178333600'
        : 'ca-app-pub-5283496525222246/8410413686';
  }

  String get _rewardedAdUnitId {
    if (!kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-5283496525222246/4422921429'
        : 'ca-app-pub-5283496525222246/2307535181';
  }

  String get _appOpenAdUnitId {
    if (!kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/5575463023';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-5283496525222246/2823584084'
        : 'ca-app-pub-5283496525222246/9841751134';
  }

  String get bannerAdUnitId {
    if (!kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2435281174';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-5283496525222246/6524355051'
        : 'ca-app-pub-5283496525222246/6556144644';
  }

  /// AdMob SDK 초기화
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRewardedAd();
    loadAppOpenAd();
  }

  // ─── 인터스티셜 광고 (게임 오버 후 1회) ─────────────────

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialReady = false;
              loadInterstitialAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  /// 인터스티셜 광고 표시 (게임 오버 후 호출, N판마다 1회)
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (IAPService().adsRemoved) {
      onAdDismissed?.call();
      return;
    }

    _gameOverCount++;

    // 첫 3게임은 광고 없음 (온보딩 보호)
    if (_gameOverCount <= 3 ||
        _gameOverCount % _interstitialFrequency != 0 ||
        !_isInterstitialReady ||
        _interstitialAd == null) {
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialReady = false;
        loadInterstitialAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialReady = false;
        loadInterstitialAd();
        onAdDismissed?.call();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
    AnalyticsService().logAdWatched(type: 'interstitial');
  }

  // ─── 보상형 광고 (이어하기) ────────────────────────────

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
        },
      ),
    );
  }

  /// 보상형 광고 표시 (이어하기 기능)
  /// [onRewarded] 광고 시청 완료 시 콜백
  /// [onAdDismissed] 광고 닫힘 시 콜백 (보상 여부 무관)
  void showRewardedAd({
    required void Function() onRewarded,
    VoidCallback? onAdDismissed,
  }) {
    if (!_isRewardedReady || _rewardedAd == null) {
      onAdDismissed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedReady = false;
        loadRewardedAd(); // 다음 광고 미리 로드
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedReady = false;
        loadRewardedAd();
        onAdDismissed?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
        AnalyticsService().logAdWatched(type: 'rewarded');
      },
    );
    _rewardedAd = null;
  }

  // ─── 앱 오프닝 광고 (포그라운드 복귀 시) ──────────────

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenReady = true;
        },
        onAdFailedToLoad: (error) {
          _isAppOpenReady = false;
        },
      ),
    );
  }

  /// 앱 오프닝 광고 표시 (앱이 포그라운드로 돌아올 때)
  void showAppOpenAd() {
    if (IAPService().adsRemoved) return;
    if (!_isAppOpenReady || _appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAppOpenReady = false;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAppOpenReady = false;
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
    _appOpenAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
