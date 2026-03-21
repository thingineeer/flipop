import 'secure_storage_service.dart';

class DailyBonusService {
  static final DailyBonusService _instance = DailyBonusService._();
  factory DailyBonusService() => _instance;
  DailyBonusService._();

  final _storage = SecureStorageService();

  /// 연속 출석일 조회
  Future<int> getStreak() async {
    return _storage.getDailyBonusStreak();
  }

  /// 코인 조회
  Future<int> getCoins() async {
    return _storage.getDailyBonusCoins();
  }

  /// 오늘 보너스 수령 가능 여부
  Future<bool> canClaimToday() async {
    final lastDate = await _storage.getDailyBonusLastDate();
    if (lastDate == null) return true;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastDate != today;
  }

  /// 보너스 수령 (리워드 광고 시청 후 호출)
  /// Day 1: 50코인, Day 2: 75, Day 3: 100, Day 7: 200,
  /// 그 외: 50 + (streak * 10, max 150)
  Future<int> claimBonus() async {
    final canClaim = await canClaimToday();
    if (!canClaim) return 0;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = await _storage.getDailyBonusLastDate();
    int streak = await _storage.getDailyBonusStreak();

    // 연속 출석 체크: 어제 날짜와 비교
    if (lastDate != null) {
      final lastDay = DateTime.parse(lastDate);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDay).inDays;
      if (diff == 1) {
        streak += 1;
      } else {
        // 연속이 아니면 리셋
        streak = 1;
      }
    } else {
      streak = 1;
    }

    // 보상 계산
    final reward = _calculateReward(streak);

    // 코인 적립
    final currentCoins = await _storage.getDailyBonusCoins();
    await _storage.setDailyBonusCoins(currentCoins + reward);
    await _storage.setDailyBonusStreak(streak);
    await _storage.setDailyBonusLastDate(today);

    return reward;
  }

  int _calculateReward(int streak) {
    switch (streak) {
      case 1:
        return 50;
      case 2:
        return 75;
      case 3:
        return 100;
      case 7:
        return 200;
      default:
        final bonus = streak * 10;
        return 50 + (bonus > 150 ? 150 : bonus);
    }
  }

  /// 코인 추가 (리워드 광고 등)
  Future<void> addCoins(int amount) async {
    final current = await _storage.getDailyBonusCoins();
    await _storage.setDailyBonusCoins(current + amount);
  }

  /// 코인 사용
  Future<bool> spendCoins(int amount) async {
    final current = await _storage.getDailyBonusCoins();
    if (current < amount) return false;
    await _storage.setDailyBonusCoins(current - amount);
    return true;
  }
}
