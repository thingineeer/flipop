import 'dart:math';

import 'game_state.dart';

/// 요일별 챌린지 유형
enum ChallengeType {
  timeAttack,   // 60초
  limitedMoves, // 20터치
  comboMaster,  // 콤보x3 이상만 점수
  speedRun,     // 500점 최단시간
  normal,       // 일반
}

/// 시드 기반 데일리 챌린지 엔진
///
/// 모든 플레이어가 동일한 날짜에 동일한 그리드를 받도록 보장한다.
/// Domain 레이어 — Flutter/Firebase 의존성 없음.
class DailyChallenge {
  DailyChallenge._();

  /// 오늘 날짜(UTC) 기반 시드 생성
  static int todaySeed() {
    final now = DateTime.now().toUtc();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  /// 요일별 챌린지 타입
  static ChallengeType todayType() {
    final weekday = DateTime.now().toUtc().weekday; // 1=Mon
    return switch (weekday) {
      1 => ChallengeType.timeAttack,
      2 => ChallengeType.limitedMoves,
      3 => ChallengeType.comboMaster,
      4 => ChallengeType.normal,
      5 => ChallengeType.normal,
      6 => ChallengeType.speedRun,
      7 => ChallengeType.normal,
      _ => ChallengeType.normal,
    };
  }

  /// 시드 기반 GameState 생성
  ///
  /// [GameState.newGame]과 동일한 그리드 구조(하단 3줄 채움)를 사용하되
  /// [Random(seed)]로 결정론적 생성.
  static GameState generateGrid(int seed, {int colorCount = 3}) {
    final random = Random(seed);
    final colors = BlockColor.values.sublist(0, colorCount);
    var id = 0;

    final grid = List.generate(GameState.rows, (row) {
      if (row == 0) {
        // 하단 첫 줄: 4/5칸 같은 색 (1탭 클리어 가능)
        final mainColor = colors[random.nextInt(colorCount)];
        final oddCol = random.nextInt(GameState.cols);
        return List<Cell?>.generate(GameState.cols, (col) {
          if (col == oddCol) {
            BlockColor otherColor;
            do {
              otherColor = colors[random.nextInt(colorCount)];
            } while (otherColor == mainColor && colorCount > 1);
            return Cell(color: otherColor, id: id++);
          }
          return Cell(color: mainColor, id: id++);
        });
      } else if (row < 3) {
        // 2~3번째 줄: 랜덤 배치
        return List<Cell?>.generate(GameState.cols, (col) {
          return Cell(color: colors[random.nextInt(colorCount)], id: id++);
        });
      }
      return List<Cell?>.filled(GameState.cols, null);
    });

    return GameState(
      grid: grid,
      colorCount: colorCount,
      nextId: id,
    );
  }
}
