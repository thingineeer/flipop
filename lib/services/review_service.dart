import 'package:in_app_review/in_app_review.dart';
import 'secure_storage_service.dart';

/// 앱 리뷰 요청 서비스 (싱글톤)
class ReviewService {
  static final ReviewService _instance = ReviewService._();
  factory ReviewService() => _instance;
  ReviewService._();

  /// 조건에 따라 리뷰 요청
  /// - 5번째 게임
  /// - 최고점수 갱신
  /// - 3일 연속 접속 (streak)
  /// - 30일 재요청 금지
  Future<void> maybeRequestReview({
    required int gamesPlayed,
    required bool isNewBest,
    required int streak,
  }) async {
    final storage = SecureStorageService();

    // 30일 재요청 금지 체크
    final lastDateStr = await storage.getLastReviewDate();
    if (lastDateStr != null) {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null) {
        final diff = DateTime.now().difference(lastDate).inDays;
        if (diff < 30) return;
      }
    }

    // 조건 확인: 5번째 게임, 신기록, 3일 연속 접속
    final shouldRequest =
        gamesPlayed == 5 || isNewBest || streak >= 3;
    if (!shouldRequest) return;

    // 리뷰 요청
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();

      // 기록 저장
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await storage.setLastReviewDate(today);
      await storage.incrementReviewCount();
    }
  }
}
