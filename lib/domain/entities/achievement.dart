/// 업적 달성 조건 평가를 위한 컨텍스트
class AchievementContext {
  final int totalGames;
  final int bestScore;
  final int currentScore;
  final int maxCombo;
  final int linesCleared;
  final int streak;
  final int avatarsUnlocked;
  final bool tutorialDone;

  const AchievementContext({
    this.totalGames = 0,
    this.bestScore = 0,
    this.currentScore = 0,
    this.maxCombo = 0,
    this.linesCleared = 0,
    this.streak = 0,
    this.avatarsUnlocked = 0,
    this.tutorialDone = false,
  });
}

/// 업적 정의
class Achievement {
  final String id;
  final String titleKey; // l10n 키
  final String descKey; // l10n 키
  final int coinReward;
  final bool Function(AchievementContext) condition;

  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.coinReward,
    required this.condition,
  });
}
