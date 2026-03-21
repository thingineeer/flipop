import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ─── 게임 이벤트 ────────────────────────────────────

  void logGameStart({required String mode, required int colors}) {
    _analytics.logEvent(name: 'game_start', parameters: {
      'mode': mode,
      'colors': colors,
    });
  }

  void logGameOver({
    required int score,
    required int comboMax,
    required String reason,
  }) {
    _analytics.logEvent(name: 'game_over', parameters: {
      'score': score,
      'combo_max': comboMax,
      'reason': reason,
    });
  }

  void logLineClear({required int combo, required int lines}) {
    _analytics.logEvent(name: 'line_clear', parameters: {
      'combo': combo,
      'lines': lines,
    });
  }

  void logTutorialComplete({required int step}) {
    _analytics.logEvent(name: 'tutorial_complete', parameters: {
      'step': step,
    });
  }

  void logAdWatched({required String type}) {
    _analytics.logEvent(name: 'ad_watched', parameters: {
      'type': type,
    });
  }

  void logIAPPurchase({required String productId}) {
    _analytics.logEvent(name: 'iap_purchase', parameters: {
      'product_id': productId,
    });
  }

  void logDailyBonusClaim({required int streak, required int coins}) {
    _analytics.logEvent(name: 'daily_bonus_claim', parameters: {
      'streak': streak,
      'coins': coins,
    });
  }

  void logChallengeComplete({required String type, required int score}) {
    _analytics.logEvent(name: 'challenge_complete', parameters: {
      'type': type,
      'score': score,
    });
  }

  void logShareScore({required int score}) {
    _analytics.logEvent(name: 'share_score', parameters: {
      'score': score,
    });
  }

  void logAppReviewShown({required String trigger}) {
    _analytics.logEvent(name: 'app_review_shown', parameters: {
      'trigger': trigger,
    });
  }

  // ─── 유저 프로퍼티 ──────────────────────────────────

  void setUserProperties({
    int? totalGames,
    int? bestScore,
    bool? isPremium,
  }) {
    if (totalGames != null) {
      _analytics.setUserProperty(
        name: 'total_games',
        value: totalGames.toString(),
      );
    }
    if (bestScore != null) {
      _analytics.setUserProperty(
        name: 'best_score',
        value: bestScore.toString(),
      );
    }
    if (isPremium != null) {
      _analytics.setUserProperty(
        name: 'is_premium',
        value: isPremium.toString(),
      );
    }
  }
}
