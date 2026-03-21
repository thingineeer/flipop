import 'package:flutter_test/flutter_test.dart';
import 'package:flipop/domain/entities/achievement.dart';
import 'package:flipop/services/achievement_service.dart';

void main() {
  group('업적 조건 테스트', () {
    AchievementContext makeCtx({
      int totalGames = 0,
      int bestScore = 0,
      int currentScore = 0,
      int maxCombo = 0,
      int linesCleared = 0,
      int streak = 0,
      int avatarsUnlocked = 0,
      bool tutorialDone = false,
    }) {
      return AchievementContext(
        totalGames: totalGames,
        bestScore: bestScore,
        currentScore: currentScore,
        maxCombo: maxCombo,
        linesCleared: linesCleared,
        streak: streak,
        avatarsUnlocked: avatarsUnlocked,
        tutorialDone: tutorialDone,
      );
    }

    Achievement findById(String id) {
      return AchievementService.allAchievements.firstWhere((a) => a.id == id);
    }

    test('전체 업적 20개 정의됨', () {
      expect(AchievementService.allAchievements.length, 20);
    });

    test('모든 업적 ID가 고유함', () {
      final ids = AchievementService.allAchievements.map((a) => a.id).toSet();
      expect(ids.length, 20);
    });

    test('모든 업적에 코인 보상이 있음', () {
      for (final a in AchievementService.allAchievements) {
        expect(a.coinReward, greaterThan(0), reason: '${a.id} 코인 보상 0');
      }
    });

    // 입문
    test('first_step: 1게임 이상', () {
      final a = findById('first_step');
      expect(a.condition(makeCtx(totalGames: 0)), false);
      expect(a.condition(makeCtx(totalGames: 1)), true);
    });

    test('trainee: 10게임 이상', () {
      final a = findById('trainee');
      expect(a.condition(makeCtx(totalGames: 9)), false);
      expect(a.condition(makeCtx(totalGames: 10)), true);
    });

    test('first_clear: 1줄 이상 클리어', () {
      final a = findById('first_clear');
      expect(a.condition(makeCtx(linesCleared: 0)), false);
      expect(a.condition(makeCtx(linesCleared: 1)), true);
    });

    test('combo_intro: 콤보 x2 이상', () {
      final a = findById('combo_intro');
      expect(a.condition(makeCtx(maxCombo: 1)), false);
      expect(a.condition(makeCtx(maxCombo: 2)), true);
    });

    test('tutorial: 튜토리얼 완료', () {
      final a = findById('tutorial');
      expect(a.condition(makeCtx(tutorialDone: false)), false);
      expect(a.condition(makeCtx(tutorialDone: true)), true);
    });

    // 숙련
    test('score_100: 100점 이상', () {
      final a = findById('score_100');
      expect(a.condition(makeCtx(bestScore: 99)), false);
      expect(a.condition(makeCtx(bestScore: 100)), true);
    });

    test('score_500: 500점 이상', () {
      final a = findById('score_500');
      expect(a.condition(makeCtx(bestScore: 499)), false);
      expect(a.condition(makeCtx(bestScore: 500)), true);
    });

    test('score_1000: 1000점 이상', () {
      final a = findById('score_1000');
      expect(a.condition(makeCtx(bestScore: 999)), false);
      expect(a.condition(makeCtx(bestScore: 1000)), true);
    });

    test('combo_master: 콤보 x5 이상', () {
      final a = findById('combo_master');
      expect(a.condition(makeCtx(maxCombo: 4)), false);
      expect(a.condition(makeCtx(maxCombo: 5)), true);
    });

    test('chain_reaction: 콤보 x3 이상', () {
      final a = findById('chain_reaction');
      expect(a.condition(makeCtx(maxCombo: 2)), false);
      expect(a.condition(makeCtx(maxCombo: 3)), true);
    });

    // 도전
    test('score_3000: 3000점 이상', () {
      final a = findById('score_3000');
      expect(a.condition(makeCtx(bestScore: 2999)), false);
      expect(a.condition(makeCtx(bestScore: 3000)), true);
    });

    test('combo_king: 콤보 x10 이상', () {
      final a = findById('combo_king');
      expect(a.condition(makeCtx(maxCombo: 9)), false);
      expect(a.condition(makeCtx(maxCombo: 10)), true);
    });

    test('perfect: 10줄 이상 클리어', () {
      final a = findById('perfect');
      expect(a.condition(makeCtx(linesCleared: 9)), false);
      expect(a.condition(makeCtx(linesCleared: 10)), true);
    });

    // 소셜
    test('challenger: 7일 연속 접속', () {
      final a = findById('challenger');
      expect(a.condition(makeCtx(streak: 6)), false);
      expect(a.condition(makeCtx(streak: 7)), true);
    });

    // 수집
    test('zoo: 아바타 8종 해금', () {
      final a = findById('zoo');
      expect(a.condition(makeCtx(avatarsUnlocked: 7)), false);
      expect(a.condition(makeCtx(avatarsUnlocked: 8)), true);
    });

    test('full_collection: 아바타 12종 해금', () {
      final a = findById('full_collection');
      expect(a.condition(makeCtx(avatarsUnlocked: 11)), false);
      expect(a.condition(makeCtx(avatarsUnlocked: 12)), true);
    });

    // 경계값: 빈 컨텍스트에서 달성되는 업적 없음
    test('빈 컨텍스트에서 달성 업적 0개', () {
      final ctx = makeCtx();
      final achieved = AchievementService.allAchievements
          .where((a) => a.condition(ctx))
          .toList();
      expect(achieved, isEmpty);
    });

    // 모든 조건 최대치에서 전부 달성
    test('최대 컨텍스트에서 전부 달성', () {
      final ctx = makeCtx(
        totalGames: 1000,
        bestScore: 10000,
        currentScore: 5000,
        maxCombo: 20,
        linesCleared: 50,
        streak: 30,
        avatarsUnlocked: 12,
        tutorialDone: true,
      );
      final achieved = AchievementService.allAchievements
          .where((a) => a.condition(ctx))
          .toList();
      expect(achieved.length, 20);
    });
  });
}
