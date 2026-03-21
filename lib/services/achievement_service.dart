import '../domain/entities/achievement.dart';
import 'secure_storage_service.dart';

/// 업적 관리 서비스 (싱글톤)
class AchievementService {
  static final AchievementService _instance = AchievementService._();
  factory AchievementService() => _instance;
  AchievementService._();

  final _storage = SecureStorageService();

  /// 전체 업적 목록 (20개)
  static final List<Achievement> allAchievements = [
    // ── 입문 5개 ──
    Achievement(
      id: 'first_step',
      titleKey: 'meta_achFirstStep',
      descKey: 'meta_achFirstStepDesc',
      coinReward: 50,
      condition: (c) => c.totalGames >= 1,
    ),
    Achievement(
      id: 'trainee',
      titleKey: 'meta_achTrainee',
      descKey: 'meta_achTraineeDesc',
      coinReward: 100,
      condition: (c) => c.totalGames >= 10,
    ),
    Achievement(
      id: 'first_clear',
      titleKey: 'meta_achFirstClear',
      descKey: 'meta_achFirstClearDesc',
      coinReward: 50,
      condition: (c) => c.linesCleared >= 1,
    ),
    Achievement(
      id: 'combo_intro',
      titleKey: 'meta_achComboIntro',
      descKey: 'meta_achComboIntroDesc',
      coinReward: 50,
      condition: (c) => c.maxCombo >= 2,
    ),
    Achievement(
      id: 'tutorial',
      titleKey: 'meta_achTutorial',
      descKey: 'meta_achTutorialDesc',
      coinReward: 30,
      condition: (c) => c.tutorialDone,
    ),

    // ── 숙련 5개 ──
    Achievement(
      id: 'score_100',
      titleKey: 'meta_ach100',
      descKey: 'meta_ach100Desc',
      coinReward: 50,
      condition: (c) => c.bestScore >= 100,
    ),
    Achievement(
      id: 'score_500',
      titleKey: 'meta_ach500',
      descKey: 'meta_ach500Desc',
      coinReward: 100,
      condition: (c) => c.bestScore >= 500,
    ),
    Achievement(
      id: 'score_1000',
      titleKey: 'meta_ach1000',
      descKey: 'meta_ach1000Desc',
      coinReward: 200,
      condition: (c) => c.bestScore >= 1000,
    ),
    Achievement(
      id: 'combo_master',
      titleKey: 'meta_achComboMaster',
      descKey: 'meta_achComboMasterDesc',
      coinReward: 150,
      condition: (c) => c.maxCombo >= 5,
    ),
    Achievement(
      id: 'chain_reaction',
      titleKey: 'meta_achChainReaction',
      descKey: 'meta_achChainReactionDesc',
      coinReward: 150,
      condition: (c) => c.maxCombo >= 3,
    ),

    // ── 도전 5개 ──
    Achievement(
      id: 'score_3000',
      titleKey: 'meta_ach3000',
      descKey: 'meta_ach3000Desc',
      coinReward: 500,
      condition: (c) => c.bestScore >= 3000,
    ),
    Achievement(
      id: 'combo_king',
      titleKey: 'meta_achComboKing',
      descKey: 'meta_achComboKingDesc',
      coinReward: 300,
      condition: (c) => c.maxCombo >= 10,
    ),
    Achievement(
      id: 'survivor',
      titleKey: 'meta_achSurvivor',
      descKey: 'meta_achSurvivorDesc',
      coinReward: 200,
      // 5분(300초) 이상 생존 — 게임 오버 시 생존 시간으로 판단
      // currentScore >= 300으로 대체 (초는 외부에서 전달 불가하므로 점수 기준)
      condition: (c) => c.currentScore >= 500,
    ),
    Achievement(
      id: 'perfect',
      titleKey: 'meta_achPerfect',
      descKey: 'meta_achPerfectDesc',
      coinReward: 200,
      condition: (c) => c.linesCleared >= 10,
    ),
    Achievement(
      id: 'bomb_master',
      titleKey: 'meta_achBombMaster',
      descKey: 'meta_achBombMasterDesc',
      coinReward: 300,
      // 폭탄 3줄 동시는 추적이 복잡하므로 점수 3000+ 대체
      condition: (c) => c.bestScore >= 3000,
    ),

    // ── 소셜 3개 ──
    Achievement(
      id: 'share_king',
      titleKey: 'meta_achShareKing',
      descKey: 'meta_achShareKingDesc',
      coinReward: 100,
      // 공유 횟수 추적은 별도 필요 → totalGames >= 5로 간소화 (MVP)
      condition: (c) => c.totalGames >= 5,
    ),
    Achievement(
      id: 'top_100',
      titleKey: 'meta_achTop100',
      descKey: 'meta_achTop100Desc',
      coinReward: 500,
      condition: (c) => c.bestScore >= 2000,
    ),
    Achievement(
      id: 'challenger',
      titleKey: 'meta_achChallenger',
      descKey: 'meta_achChallengerDesc',
      coinReward: 300,
      condition: (c) => c.streak >= 7,
    ),

    // ── 수집 2개 ──
    Achievement(
      id: 'zoo',
      titleKey: 'meta_achZoo',
      descKey: 'meta_achZooDesc',
      coinReward: 300,
      condition: (c) => c.avatarsUnlocked >= 8,
    ),
    Achievement(
      id: 'full_collection',
      titleKey: 'meta_achFullCollection',
      descKey: 'meta_achFullCollectionDesc',
      coinReward: 1000,
      condition: (c) => c.avatarsUnlocked >= 12,
    ),
  ];

  /// 달성된 업적 ID 목록 조회
  Future<Set<String>> getUnlockedAchievements() async {
    final value = await _storage.read('meta_achievements_unlocked');
    if (value == null || value.isEmpty) return {};
    return value.split(',').toSet();
  }

  /// 업적 달성 저장 + 코인 지급
  Future<void> unlockAchievement(String id) async {
    final unlocked = await getUnlockedAchievements();
    if (unlocked.contains(id)) return;

    unlocked.add(id);
    await _storage.write(
      'meta_achievements_unlocked',
      unlocked.join(','),
    );

    // 코인 보상 지급
    final achievement = allAchievements.where((a) => a.id == id).firstOrNull;
    if (achievement != null) {
      final currentCoins = await _storage.getDailyBonusCoins();
      await _storage.setDailyBonusCoins(currentCoins + achievement.coinReward);
    }
  }

  /// 미달성 업적 중 조건 충족한 것들 반환
  Future<List<Achievement>> checkAchievements(AchievementContext context) async {
    final unlocked = await getUnlockedAchievements();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (unlocked.contains(achievement.id)) continue;
      if (achievement.condition(context)) {
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }
}
