import 'package:flutter_test/flutter_test.dart';
import 'package:flipop/game/daily_challenge.dart';
import 'package:flipop/game/game_state.dart';

void main() {
  group('DailyChallenge.todaySeed', () {
    test('날짜 기반 시드: YYYYMMDD 형식', () {
      final seed = DailyChallenge.todaySeed();
      final now = DateTime.now().toUtc();
      final expected = now.year * 10000 + now.month * 100 + now.day;
      expect(seed, expected);
    });

    test('시드는 8자리 양의 정수', () {
      final seed = DailyChallenge.todaySeed();
      expect(seed, greaterThan(20000000));
      expect(seed, lessThan(99999999));
    });
  });

  group('DailyChallenge.todayType', () {
    test('ChallengeType enum 값 중 하나를 반환', () {
      final type = DailyChallenge.todayType();
      expect(ChallengeType.values, contains(type));
    });
  });

  group('DailyChallenge.generateGrid', () {
    test('같은 시드 → 같은 그리드', () {
      const seed = 20260315;
      final grid1 = DailyChallenge.generateGrid(seed);
      final grid2 = DailyChallenge.generateGrid(seed);

      for (int r = 0; r < GameState.rows; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(grid1.colorAt(r, c), grid2.colorAt(r, c),
              reason: 'row=$r, col=$c 색상이 다름');
        }
      }
    });

    test('다른 시드 → 다른 그리드 (높은 확률)', () {
      final grid1 = DailyChallenge.generateGrid(20260315);
      final grid2 = DailyChallenge.generateGrid(20260316);

      var diffCount = 0;
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          if (grid1.colorAt(r, c) != grid2.colorAt(r, c)) {
            diffCount++;
          }
        }
      }
      expect(diffCount, greaterThan(0), reason: '다른 시드인데 그리드가 완전히 동일');
    });

    test('그리드 구조: 하단 3줄 채움, 나머지 비어있음', () {
      final state = DailyChallenge.generateGrid(12345);

      // row 0~2: 모든 칸 non-null
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(state.colorAt(r, c), isNotNull,
              reason: 'row=$r, col=$c 가 null');
        }
      }

      // row 3~6: 모든 칸 null
      for (int r = 3; r < GameState.rows; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(state.colorAt(r, c), isNull,
              reason: 'row=$r, col=$c 가 non-null');
        }
      }
    });

    test('블록 색상이 colorCount 범위 내', () {
      const colorCount = 3;
      final state = DailyChallenge.generateGrid(99999, colorCount: colorCount);
      final validColors = BlockColor.values.sublist(0, colorCount).toSet();

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(validColors, contains(state.colorAt(r, c)),
              reason: 'row=$r, col=$c 색상이 범위 밖');
        }
      }
    });

    test('colorCount=2일 때 2색만 사용', () {
      final state = DailyChallenge.generateGrid(77777, colorCount: 2);
      final validColors = {BlockColor.red, BlockColor.blue};

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(validColors, contains(state.colorAt(r, c)),
              reason: 'row=$r, col=$c 에 2색 외의 색상이 나옴');
        }
      }
    });

    test('생성된 GameState의 기본 필드 확인', () {
      final state = DailyChallenge.generateGrid(11111);
      expect(state.score, 0);
      expect(state.moves, 0);
      expect(state.isGameOver, false);
      expect(state.combo, 0);
    });

    test('같은 시드 반복 호출해도 결정론적', () {
      const seed = 42;
      final states = List.generate(5, (_) => DailyChallenge.generateGrid(seed));

      for (int i = 1; i < states.length; i++) {
        for (int r = 0; r < GameState.rows; r++) {
          for (int c = 0; c < GameState.cols; c++) {
            expect(states[i].colorAt(r, c), states[0].colorAt(r, c));
          }
        }
      }
    });
  });
}
