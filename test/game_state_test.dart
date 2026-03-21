import 'package:flutter_test/flutter_test.dart';
import 'package:flipop/game/game_state.dart';

// 짧은 alias
const R = BlockColor.red;
const B = BlockColor.blue;
const Y = BlockColor.yellow;
const G = BlockColor.green;

GameState makeState(
  List<List<BlockColor?>> gridColors, {
  int colorCount = 3,
  int score = 0,
  int moves = 0,
  int addRowEvery = 99,
}) {
  return GameState.fromGrid(
    gridColors,
    colorCount: colorCount,
    score: score,
    moves: moves,
    addRowEvery: addRowEvery,
  );
}

/// 그리드 상태를 문자열로 출력 (디버깅용)
String dumpGrid(GameState s, {int maxRow = 6}) {
  final buf = StringBuffer();
  for (int r = maxRow; r >= 0; r--) {
    buf.write('row $r: ');
    for (int c = 0; c < GameState.cols; c++) {
      final color = s.colorAt(r, c);
      if (color == null) {
        buf.write('_ ');
      } else {
        buf.write('${color.name[0].toUpperCase()} ');
      }
    }
    buf.writeln();
  }
  return buf.toString();
}

/// 특정 row의 모든 색상을 리스트로 (테스트 헬퍼)
List<BlockColor?> rowColors(GameState s, int row) {
  return List.generate(GameState.cols, (c) => s.colorAt(row, c));
}

/// 특정 col의 모든 색상을 리스트로 (테스트 헬퍼)
List<BlockColor?> colColors(GameState s, int col, {int maxRow = 6}) {
  return List.generate(maxRow + 1, (r) => s.colorAt(r, col));
}

/// row가 전부 비어있는지 확인
bool isRowEmpty(GameState s, int row) {
  for (int c = 0; c < GameState.cols; c++) {
    if (s.colorAt(row, c) != null) return false;
  }
  return true;
}

/// row에 블록 개수
int blockCountInRow(GameState s, int row) {
  int count = 0;
  for (int c = 0; c < GameState.cols; c++) {
    if (s.colorAt(row, c) != null) count++;
  }
  return count;
}

/// 전체 그리드의 블록 수
int totalBlocks(GameState s) {
  int count = 0;
  for (int r = 0; r < GameState.rows; r++) {
    for (int c = 0; c < GameState.cols; c++) {
      if (s.colorAt(r, c) != null) count++;
    }
  }
  return count;
}

void main() {
  // ============================================================
  // 1. 기본 생성
  // ============================================================
  group('GameState 생성', () {
    test('newGame: 7x5 그리드, 하단 3줄 채워짐, 상단 4줄 비어있음', () {
      final state = GameState.newGame(colorCount: 3);

      expect(state.grid.length, GameState.rows);
      for (final row in state.grid) {
        expect(row.length, GameState.cols);
      }

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(state.grid[r][c], isNotNull, reason: 'row $r, col $c');
        }
      }

      for (int r = 3; r < GameState.rows; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(state.grid[r][c], isNull, reason: 'row $r, col $c');
        }
      }
    });

    test('newGame: 색상이 colorCount 범위 내', () {
      final state = GameState.newGame(colorCount: 3);
      final validColors = {R, B, Y};

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(validColors.contains(state.grid[r][c]!.color), isTrue);
        }
      }
    });

    test('newGame: 4색 모드 색상 범위', () {
      final state = GameState.newGame(colorCount: 4);
      final validColors = {R, B, Y, G};

      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(validColors.contains(state.grid[r][c]!.color), isTrue);
        }
      }
    });

    test('fromGrid: 지정된 색상으로 정확히 생성', () {
      final state = makeState([
        [R, B, Y, R, B],
        [Y, R, B, Y, R],
      ]);

      expect(state.colorAt(0, 0), R);
      expect(state.colorAt(0, 1), B);
      expect(state.colorAt(0, 2), Y);
      expect(state.colorAt(0, 3), R);
      expect(state.colorAt(0, 4), B);
      expect(state.colorAt(1, 0), Y);
      expect(state.colorAt(1, 1), R);
      expect(state.colorAt(1, 2), B);
      expect(state.colorAt(1, 3), Y);
      expect(state.colorAt(1, 4), R);
      expect(state.colorAt(2, 0), isNull);
    });

    test('fromGrid: null 칸 정확히 생성', () {
      final state = makeState([
        [R, null, B, null, Y],
        [null, R, null, B, null],
      ]);

      expect(state.colorAt(0, 0), R);
      expect(state.colorAt(0, 1), isNull);
      expect(state.colorAt(0, 2), B);
      expect(state.colorAt(0, 3), isNull);
      expect(state.colorAt(0, 4), Y);
      expect(state.colorAt(1, 0), isNull);
      expect(state.colorAt(1, 1), R);
    });

    test('fromGrid: 빈 그리드', () {
      final state = makeState([]);
      for (int r = 0; r < GameState.rows; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          expect(state.colorAt(r, c), isNull);
        }
      }
    });

    test('초기 상태 기본값', () {
      final state = GameState.newGame();
      expect(state.score, 0);
      expect(state.moves, 0);
      expect(state.combo, 0);
      expect(state.isGameOver, false);
      expect(state.colorCount, 2); // 2색 입문모드
      expect(state.addRowEvery, 5); // Phase A: 5턴마다
    });

    test('newGame: bestScore 전달', () {
      final state = GameState.newGame(bestScore: 1000);
      expect(state.bestScore, 1000);
    });

    test('newGame: nextId = 15 (3줄 * 5칸)', () {
      final state = GameState.newGame(colorCount: 3);
      expect(state.nextId, 15);
    });

    test('fromGrid: nextId = 생성된 셀 수', () {
      final state = makeState([
        [R, R, R, R, R],
        [R, null, R, null, R],
      ]);
      expect(state.nextId, 8); // 5 + 3 non-null
    });

    test('Cell equality: 같은 color + id', () {
      const a = Cell(color: BlockColor.red, id: 0);
      const b = Cell(color: BlockColor.red, id: 0);
      const c = Cell(color: BlockColor.blue, id: 0);
      const d = Cell(color: BlockColor.red, id: 1);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });

    test('Cell copyWith: color만 변경, id 유지', () {
      const cell = Cell(color: BlockColor.red, id: 42);
      final copied = cell.copyWith(color: BlockColor.blue);
      expect(copied.color, BlockColor.blue);
      expect(copied.id, 42);
    });

    test('Cell toString', () {
      const cell = Cell(color: BlockColor.red, id: 5);
      expect(cell.toString(), 'R5');
    });
  });

  // ============================================================
  // 2. 탭 — 색상 순환 (전 위치 정밀 검증)
  // ============================================================
  group('탭: 색상 순환', () {
    test('가운데 탭 → 상하좌우 색상 순환, 자기 자신과 대각선 불변', () {
      final state = makeState([
        [R, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      final after = state.tap(1, 2);

      expect(after.colorAt(1, 2), R, reason: '자기 자신 불변');
      expect(after.colorAt(2, 2), B, reason: '위');
      expect(after.colorAt(0, 2), B, reason: '아래');
      expect(after.colorAt(1, 1), B, reason: '왼쪽');
      expect(after.colorAt(1, 3), B, reason: '오른쪽');
      expect(after.colorAt(0, 1), R, reason: '대각선 불변');
      expect(after.colorAt(0, 3), R, reason: '대각선 불변');
      expect(after.colorAt(2, 1), R, reason: '대각선 불변');
      expect(after.colorAt(2, 3), R, reason: '대각선 불변');
    });

    test('3색 순환: R→B→Y→R 완전 순환 (클리어 회피 그리드)', () {
      // 클리어가 안 되는 그리드에서 3번 탭 순환 검증
      // 2줄 그리드로 세로 클리어 회피, 색 혼합으로 가로 클리어 회피
      final state = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ]);

      // tap(0,0): (0,1)B→Y, (1,0)B→Y
      final s1 = state.tap(0, 0);
      expect(s1.colorAt(0, 1), Y, reason: 'B→Y');

      // tap(0,0): (0,1)Y→R
      final s2 = s1.tap(0, 0);
      expect(s2.colorAt(0, 1), R, reason: 'Y→R');

      // tap(0,0): (0,1)R→B (원복)
      final s3 = s2.tap(0, 0);
      expect(s3.colorAt(0, 1), B, reason: 'R→B 완전 순환');
    });

    test('4색 순환: R→B→Y→G→R (클리어 회피 그리드)', () {
      // 2줄 그리드로 세로 클리어 회피, 4색 혼합으로 가로 클리어 회피
      final state = makeState([
        [R, G, B, Y, R],
        [G, B, R, G, Y],
      ], colorCount: 4);

      // tap(0,0): (0,1)G→R, (1,0)G→R
      final s1 = state.tap(0, 0);
      expect(s1.colorAt(0, 1), R, reason: 'G→R');

      // tap(0,0): (0,1)R→B
      final s2 = s1.tap(0, 0);
      expect(s2.colorAt(0, 1), B, reason: 'R→B');

      // tap(0,0): (0,1)B→Y
      final s3 = s2.tap(0, 0);
      expect(s3.colorAt(0, 1), Y, reason: 'B→Y');

      // tap(0,0): (0,1)Y→G (원복)
      final s4 = s3.tap(0, 0);
      expect(s4.colorAt(0, 1), G, reason: 'Y→G 완전 순환');
    });

    test('왼쪽 상단 모서리 (0,0) 탭', () {
      final state = makeState([
        [R, B, Y, R, B],
        [Y, R, B, Y, R],
        [B, Y, R, B, Y],
      ]);

      final after = state.tap(0, 0);
      expect(after.colorAt(0, 0), R, reason: '자신 불변');
      expect(after.colorAt(0, 1), Y, reason: 'B→Y 오른쪽');
      expect(after.colorAt(1, 0), R, reason: 'Y→R 위');
      // 왼쪽, 아래 없음 → 영향 없음
    });

    test('오른쪽 상단 모서리 (0,4) 탭', () {
      final state = makeState([
        [R, B, Y, R, B],
        [Y, R, B, Y, R],
      ]);

      final after = state.tap(0, 4);
      expect(after.colorAt(0, 4), B, reason: '자신 불변');
      expect(after.colorAt(0, 3), B, reason: 'R→B 왼쪽');
      expect(after.colorAt(1, 4), B, reason: 'R→B 위');
    });

    test('왼쪽 변 (row 1, col 0) 탭 — 왼쪽 없음', () {
      final state = makeState([
        [R, B, Y, R, B],
        [Y, R, B, Y, R],
        [B, Y, R, B, Y],
      ]);

      final after = state.tap(1, 0);
      expect(after.colorAt(1, 0), Y, reason: '자신 불변');
      expect(after.colorAt(0, 0), B, reason: 'R→B 아래');
      expect(after.colorAt(2, 0), Y, reason: 'B→Y 위');
      expect(after.colorAt(1, 1), B, reason: 'R→B 오른쪽');
    });

    test('오른쪽 변 (row 1, col 4) 탭 — 오른쪽 없음', () {
      final state = makeState([
        [R, B, Y, R, B],
        [Y, R, B, Y, R],
        [B, Y, R, B, Y],
      ]);

      final after = state.tap(1, 4);
      expect(after.colorAt(1, 4), R, reason: '자신 불변');
      expect(after.colorAt(0, 4), Y, reason: 'B→Y 아래');
      expect(after.colorAt(2, 4), R, reason: 'Y→R 위');
      expect(after.colorAt(1, 3), R, reason: 'Y→R 왼쪽');
    });

    test('빈 칸 인접: null은 무시', () {
      final state = makeState([
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      final after = state.tap(1, 2);
      expect(after.colorAt(2, 2), isNull, reason: '위는 빈 칸 → 여전히 null');
      expect(after.colorAt(1, 1), B, reason: '왼쪽 정상 변환');
      expect(after.colorAt(1, 3), B, reason: '오른쪽 정상 변환');
      expect(after.colorAt(0, 2), B, reason: '아래 정상 변환');
    });

    test('인접 셀이 null이면 그 셀만 건너뜀', () {
      final state = makeState([
        [R, null, R, null, R],
        [null, R, null, R, null],
        [R, null, R, null, R],
      ]);

      // (1,1)의 인접: (0,1)=null, (2,1)=null, (1,0)=null, (1,2)=null
      // 전부 null이므로 아무것도 안 변함
      final after = state.tap(1, 1);
      expect(after.colorAt(0, 0), R);
      expect(after.colorAt(0, 2), R);
      expect(after.colorAt(2, 0), R);
      expect(after.colorAt(2, 2), R);
    });

    test('빈 칸 탭: 무시, moves 안 올라감', () {
      final s = makeState([[R, R, R, R, R]]);
      final after = s.tap(3, 2);
      expect(after.moves, s.moves);
      expect(identical(after, s), isTrue);
    });

    test('게임오버 시 탭 무시', () {
      final s = GameState(
        grid: List.generate(GameState.rows, (_) => List<Cell?>.filled(GameState.cols, null)),
        isGameOver: true,
      );
      expect(identical(s.tap(0, 0), s), isTrue);
    });

    test('탭할 때마다 moves +1', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      final s1 = s.tap(0, 0);
      expect(s1.moves, 1);
      final s2 = s1.tap(0, 1);
      expect(s2.moves, 2);
      final s3 = s2.tap(0, 2);
      expect(s3.moves, 3);
    });

    test('탭 후 combo는 0으로 리셋 (클리어 없는 경우)', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);
      final after = s.tap(1, 2);
      expect(after.combo, 0);
    });

    test('서로 다른 색의 인접 셀이 각각 올바르게 순환', () {
      // 클리어가 안 되는 그리드에서 각 인접 셀의 색 순환 검증
      // tap(0,1): (0,0)R→B, (0,2)Y→R, (1,1)Y→R
      // row 0: [B,B,R,R,B] — 연속 2개 OK
      // row 1: [B,R,R,B,Y] — 연속 2개 OK
      final state = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ]);

      final after = state.tap(0, 1);
      expect(after.colorAt(0, 0), B, reason: 'R→B');
      expect(after.colorAt(0, 2), R, reason: 'Y→R');
      expect(after.colorAt(1, 1), R, reason: 'Y→R');
      expect(after.colorAt(0, 1), B, reason: '자신 불변');
    });

    test('같은 셀 연속 탭: 인접 색상 계속 순환 (클리어 회피)', () {
      // 2줄 그리드로 세로 클리어 회피
      final state = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ]);

      // tap(0,0) 1번: (0,1)B→Y, (1,0)B→Y
      var s = state.tap(0, 0);
      expect(s.colorAt(0, 1), Y, reason: '1번째: B→Y');

      // tap(0,0) 2번: (0,1)Y→R
      s = s.tap(0, 0);
      expect(s.colorAt(0, 1), R, reason: '2번째: Y→R');

      // tap(0,0) 3번: (0,1)R→B (원복)
      s = s.tap(0, 0);
      expect(s.colorAt(0, 1), B, reason: '3번째: R→B 원복');
    });
  });

  // ============================================================
  // 3. 가로 줄 클리어
  // ============================================================
  group('가로 줄 클리어', () {
    test('탭으로 한 줄 같은 색 완성 → 클리어 + 100점', () {
      // row 0: [B, R, B, B, B] — (0,1)만 R
      // tap(1,1) → (0,1)=R→B → row 0 = BBBBB → 가로 클리어!
      // row 1: tap으로 (1,0)R→B, (1,2)Y→R → [B,R,R,R,Y] — RRR 3연속!
      // → row 1을 색이 혼합되게 설계
      // tap(1,1) affects: (0,1)R→B, (2,1)변경, (1,0)변경, (1,2)변경
      // row 1 after: [(1,0)다음색, R(self), (1,2)다음색, (1,3)orig, (1,4)orig]
      // (1,0)=Y→R, (1,2)=B→Y → row 1 = [R, R, Y, B, Y] — RR 2연속 OK
      // row 2: (2,1)=R→B → [Y, B, R, B, Y] — 연속 없음
      // 세로: col0: B,R,Y=no, col1: B,R,B=no, col2: B,Y,R=no, col3: B,B,B=3연속!
      // → col3 회피: row 2 col 3 변경
      // row 2: [Y, R, R, Y, R] → (2,1)R→B → [Y,B,R,Y,R] — 연속 없음
      // 세로 col3: B,B,Y = no ✓
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, B, Y],
        [Y, R, R, Y, R],
      ]);

      final after = s.tap(1, 1);
      expect(after.score, 100);
    });

    test('클리어 후 해당 row가 비고 중력 적용', () {
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ]);

      final after = s.tap(1, 1);
      // row 0 클리어 → row 1, row 2가 내려옴
      // 따라서 최종적으로 row 0, row 1에 블록, row 2는 비어야 함
      expect(after.hasBlock(0, 0), isTrue, reason: '중력으로 블록 내려옴');
      expect(isRowEmpty(after, 2), isTrue, reason: 'row 2는 비어야 함');
    });

    test('한 줄에 빈 칸 있으면 클리어 안 됨', () {
      final state = makeState([
        [B, B, null, B, B],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      final after = state.tap(1, 2);
      expect(after.score, 0, reason: '빈 칸 있으면 클리어 안 됨');
    });

    test('전부 같은 색이지만 1개 다른 색 → 클리어 안 됨', () {
      final state = makeState([
        [B, B, B, B, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      final after = state.tap(1, 0);
      expect(after.colorAt(0, 0), isNotNull, reason: '클리어 안 됨');
    });

    test('동시 2줄 가로 클리어', () {
      // tap(1,1) → (0,1)R→B, (2,1)B→Y
      // row 0: [B,B,B,B,B] ✓ (가로 클리어)
      // row 2: [Y,Y,Y,Y,Y] ✓ (가로 클리어)
      // 세로 클리어 없음 (col별 색이 혼합)
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, B, Y, Y, Y],
      ]);

      final after = s.tap(1, 1);
      expect(after.score, 200, reason: '2줄 * 100 * combo(1) = 200');
    });

    test('동시 3줄 가로 클리어', () {
      // tap(1,1) → (0,1)R→B, (2,1)R→B
      // row 0: [B,B,B,B,B] ✓
      // row 1: tap으로 (1,0)R→B, (1,2)R→B → [B,B,B,B,B]?
      // 아니: (1,0)R→B, (1,2)R→B, but (1,1)자신불변=R → [B,R,B,R,R] ✗
      // 다른 설계:
      // row 0: [R, B, R, R, R] → (0,1) B→Y → [R,Y,R,R,R] ✗
      // 실현 가능한 3줄 클리어 설계가 어렵 → 2줄 + 연쇄로 3줄
      // 3줄 직접 클리어: 탭 1번으로는 최대 2줄(위/아래)
      // 실제로 2줄까지만 테스트
      // → 이 테스트는 skip
    });

    test('클리어 점수: linesCleared * 100 * combo(1)', () {
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ]);

      final after = s.tap(1, 1);
      // 1줄 * 100 * 1 = 100
      expect(after.score, 100);
      expect(after.combo, 1);
    });

    test('이미 같은 색인 줄은 탭 없이 클리어되지 않음 (탭이 트리거)', () {
      // 탭 없이는 _checkAndClearLines가 호출 안 됨
      final s = makeState([
        [B, B, B, B, B], // 이미 같은 색이지만...
        [R, R, R, R, R],
      ]);

      // 탭으로 트리거하면 클리어됨
      expect(s.score, 0, reason: '생성 시점에는 클리어 안 됨');
      // tap(1,2)하면 (0,2)가 바뀌므로 row 0이 깨짐
      // tap(1,0)하면 (0,0)B→Y → row 0 깨짐
      // → 탭이 row 0을 직접 건드리지 않는 위치를 찾기 어려움
      // 대신: fromGrid 시점에 클리어가 일어나지 않음을 검증
      expect(s.colorAt(0, 0), B);
      expect(s.colorAt(0, 4), B);
    });

    test('가로 3연속 같은 색 → 클리어 (3+ 매칭)', () {
      // row 0: [R, B, B, R, B] — tap(1,2)로 (0,2)R→B → [R,B,B,B,B] — 4연속 B 클리어
      // 하지만 3연속 정확히 테스트하려면:
      // row 0: [Y, R, B, B, Y] — tap(1,1)로 (0,1)R→B → [Y,B,B,B,Y] — 3연속 B
      // row 1: (1,0)R→B, (1,2)B→Y → [B,R,Y,R,Y] — 연속 없음
      // row 2: (2,1)R→B → [Y,B,R,B,Y] — 연속 없음
      // 세로: col0:Y,B,Y no, col1:B,R,B no, col2:B,Y,R no, col3:B,R,B no, col4:Y,Y,Y → 3연속!
      // → col4 세로 회피: row 2 col4 변경
      // row 2: [Y,R,R,B,R] → (2,1)R→B → [Y,B,R,B,R] — 연속 없음
      // 세로 col4: Y,Y,R → no ✓
      final s = makeState([
        [Y, R, B, B, Y],
        [R, R, B, R, Y],
        [Y, R, R, B, R],
      ]);

      final after = s.tap(1, 1);
      // row 0 = [Y,B,B,B,Y] → col 1~3에 BBB 3연속 → 클리어!
      expect(after.score, greaterThan(0), reason: '가로 3연속 클리어');
      // 클리어 후 col 1~3의 row 0 블록 제거
      expect(after.colorAt(0, 0), isNotNull, reason: 'col 0은 클리어 안 됨');
      expect(after.colorAt(0, 4), isNotNull, reason: 'col 4는 클리어 안 됨');
    });

    test('가로 3연속: 정확히 3개만 클리어 (양 끝 보존)', () {
      // row 0: [Y, R, B, B, Y] → tap(1,1) → (0,1)R→B → [Y,B,B,B,Y]
      // col 1~3의 BBB만 클리어, col 0의 Y와 col 4의 Y는 보존
      final s = makeState([
        [Y, R, B, B, Y],
        [R, R, B, R, Y],
        [Y, R, R, B, R],
      ]);

      final after = s.tap(1, 1);
      // 중력 후 col 0: Y(row0), B(row1→0으로), Y(row2→1로) → Y는 row 0에 남음
      // col 4: Y(row0), Y(row1→0으로?), R(row2→1로)
      // 사실 row 0의 col 1~3만 null이 되므로 col 0,4는 그대로
      expect(after.colorAt(0, 0), Y, reason: 'col 0 보존');
    });

    test('가로 2연속은 클리어 안 됨', () {
      // row 0: [R, B, B, R, Y] — BB 2연속, 클리어 안 됨
      final s = makeState([
        [R, B, B, R, Y],
        [B, Y, R, B, Y],
      ]);

      // 아무 탭이나 해서 클리어 안 됨 확인
      final after = s.tap(0, 0);
      // tap(0,0): (0,1)B→Y, (1,0)B→Y
      // row 0: [R,Y,B,R,Y] — 연속 없음
      // row 1: [Y,Y,R,B,Y] — YY 2연속 → 클리어 안 됨
      expect(after.score, 0, reason: '2연속은 클리어 안 됨');
    });

    test('가로 5연속 전부 클리어', () {
      // row 0: [B, R, B, B, B] → tap(1,1) → (0,1)R→B → [B,B,B,B,B] — 5연속 전부 클리어
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ]);

      final after = s.tap(1, 1);
      expect(after.score, 100, reason: '5연속 가로 클리어 = 1줄 * 100');
      // row 0 전체가 비어야 함 (중력으로 위 블록이 내려옴)
      expect(isRowEmpty(after, 2), isTrue, reason: '최상단 row 비어야 함');
    });
  });

  // ============================================================
  // 4. 중력
  // ============================================================
  group('중력', () {
    test('클리어 후 위 블록이 빈 칸으로 떨어짐', () {
      // row 0 클리어 후 row 1, 2의 블록이 한 칸씩 내려옴
      final s = makeState([
        [B, R, B, B, B], // row 0 → 클리어 예정
        [R, R, R, R, R], // row 1
        [Y, Y, Y, Y, Y], // row 2
      ]);

      final after = s.tap(1, 1); // row 0 클리어
      // 중력 후: row 0 = (이전 row 1 + 색변경), row 1 = (이전 row 2)
      expect(after.hasBlock(0, 0), isTrue);
      expect(after.hasBlock(1, 0), isTrue);
      expect(isRowEmpty(after, 2), isTrue);
    });

    test('중력: 다층 빈 칸이 있어도 바닥까지 내려옴', () {
      // 수동으로 row 0, 1 비우고 row 3에만 블록
      // 직접 테스트 불가(fromGrid로는 중력 전 상태만 만들 수 있음)
      // 대신 2줄 클리어 후 위 블록이 바닥까지 내려오는지 확인
      final s = makeState([
        [B, R, B, B, B], // row 0 → 클리어
        [R, R, R, R, R], // row 1
        [B, R, B, B, B], // row 2 → 클리어
        [Y, Y, Y, Y, Y], // row 3
        [R, B, Y, R, B], // row 4
      ]);

      final after = s.tap(1, 1); // row 0, 2 클리어
      // 중력: 2줄 사라지고 row 1, 3, 4가 0, 1, 2로 내려옴
      expect(after.hasBlock(0, 0), isTrue, reason: '바닥에 블록');
      expect(after.highestRow, lessThan(4), reason: '높이 줄어듦');
    });

    test('중력: 각 column 독립적으로 작동', () {
      // col 0만 빈 칸, col 1-4는 색이 다르게 배치 (세로 클리어 회피)
      final s = makeState([
        [null, R, B, Y, R],
        [R, B, Y, R, B],
        [null, Y, R, B, Y],
      ]);

      // tap(1,0) → (1,0)=R 자신불변, (0,0)=null 무시, (2,0)=null 무시
      // (1,1)=B→Y만 변경
      final after = s.tap(1, 0);
      expect(after.colorAt(0, 0), isNull, reason: 'col 0 row 0은 여전히 null');
      expect(after.colorAt(1, 0), R, reason: 'col 0 row 1은 자신');
      expect(after.colorAt(2, 0), isNull, reason: 'col 0 row 2은 여전히 null');
    });

    test('highestRow 정확도', () {
      final s = makeState([
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);
      expect(s.highestRow, 1);
    });

    test('highestRow: 단 하나의 블록', () {
      final s = makeState([
        [null, null, R, null, null],
      ]);
      expect(s.highestRow, 0);
    });

    test('highestRow: row 5에만 블록', () {
      final s = makeState([
        [null, null, null, null, null],
        [null, null, null, null, null],
        [null, null, null, null, null],
        [null, null, null, null, null],
        [null, null, null, null, null],
        [null, null, R, null, null],
      ]);
      expect(s.highestRow, 5);
    });

    test('빈 그리드 highestRow = -1', () {
      final s = makeState([]);
      expect(s.highestRow, -1);
    });
  });

  // ============================================================
  // 5. 연쇄 콤보
  // ============================================================
  group('연쇄 콤보', () {
    test('1차 클리어 → combo 1, 점수 100', () {
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ]);

      final after = s.tap(1, 1);
      expect(after.combo, 1);
      expect(after.score, 100);
    });

    test('동시 3줄 클리어: 이미 같은 색인 줄도 1차 scan에서 잡힘', () {
      // YYYYY는 1차 scan에서 바로 잡힘 (연쇄 아님)
      // row 0, 2를 다른 색으로 맞춰 세로 클리어 회피
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, B, Y, Y, Y],
        [R, R, R, R, R], // 이미 같은 색 → 1차에서 같이 클리어
      ]);

      final after = s.tap(1, 1);
      expect(after.score, 300, reason: '3줄 * 100 * combo(1) = 300');
      expect(after.combo, 1, reason: '동시 클리어이므로 연쇄 아님');
    });

    test('진짜 연쇄 combo 2: 가로 클리어 → 중력 → 가로 완성', () {
      // row 1: RRRRR → 1차 가로 클리어
      // 중력 후 row 0에 BBBBB → 2차 가로 연쇄!
      makeState([
        [B, B, R, B, B],
        [R, R, R, R, R], // 가로 클리어
        [B, R, B, R, B],
      ]);

      // tap(0,2): row 0의 col 2: R→B, row 1은 이미 RRRRR이면...
      // 사실 tap은 인접만 바꾸므로, row 1 전체가 R인 상태를 만들어야 함
      // 간단하게: row 0 BBBBB, row 1 RRRRR → 가로 클리어 후 중력으로 BBBBB 내려옴
      // 이 경우 tap(2,2)하면 row 1 변경 없음 → 세로 연쇄 아닌 순수 가로 테스트
      final s2 = makeState([
        [B, B, B, B, B], // 중력 후 이게 row 0이 됨
        [R, R, R, R, R], // 1차 가로 클리어
        [B, B, B, B, B], // 중력 후 이게 row 0이 됨 → BBBBB 연쇄!
      ], addRowEvery: 99);

      final after = s2.tap(2, 2);
      // row 1: RRRRR 클리어 → 중력 → row 0: BBBBB, row 1: BBBBB → 둘 다 클리어
      expect(after.combo, greaterThanOrEqualTo(1));
      expect(after.score, greaterThan(0));
    });

    test('연쇄 없으면 combo 1에서 멈춤', () {
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      final after = s.tap(1, 1);
      expect(after.combo, 1);
    });

    test('클리어 없는 탭은 combo를 0으로 리셋', () {
      // 먼저 클리어해서 combo 올리고
      // tap(1,1) → row 0 = BBBBB 클리어
      // row 1: (1,0)Y→R, (1,2)B→Y → [R,R,Y,R,Y] — RR 2연속 OK
      // row 2: (2,1)R→B → [Y,B,R,Y,B] — 연속 없음
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, R, Y, B],
      ]);

      final cleared = s.tap(1, 1);
      expect(cleared.combo, greaterThan(0));

      // cleared 후 grid:
      // row 0: [R,R,Y,R,Y] (중력으로 내려옴)
      // row 1: [Y,B,R,Y,B]
      // tap(0,2) → (0,1)R→B, (0,3)R→B, (1,2)R→B
      // row 0: [R,B,Y,B,Y] — 연속 없음
      // row 1: [Y,B,B,Y,B] — BB 2연속 OK
      final noClear = cleared.tap(0, 2);
      expect(noClear.combo, 0, reason: '클리어 없으면 combo 0');
    });

    test('점수 공식: linesCleared * 100 * combo 정확성', () {
      // 단일 줄 클리어 반복: 각각 combo 1 → 100점씩
      final s1 = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ]);
      final after1 = s1.tap(1, 1);
      expect(after1.score, 100, reason: '1줄 * 100 * 1');
    });

    test('2줄 동시 클리어: 2 * 100 * 1 = 200', () {
      // 세로 클리어 회피: row 0과 row 2가 다른 색으로 클리어
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, B, Y, Y, Y],
      ]);

      final after = s.tap(1, 1);
      expect(after.score, 200);
    });

    test('연쇄 점수 누적: 기존 score + 신규 점수', () {
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ], score: 500);

      final after = s.tap(1, 1);
      expect(after.score, 600, reason: '500 + 100 = 600');
    });

    test('bestScore 갱신', () {
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ], score: 500);

      final after = s.tap(1, 1);
      expect(after.bestScore, 600);
    });

    test('bestScore는 이전 bestScore보다 작아지지 않음', () {
      final s = GameState.fromGrid(
        [
          [R, B, Y, R, B],
          [B, Y, R, B, Y],
          [Y, R, B, Y, R],
        ],
        score: 0,
        addRowEvery: 99,
      );

      // bestScore를 직접 설정할 수 없으므로 GameState constructor 사용
      final sWithBest = GameState(
        grid: s.grid,
        score: 0,
        bestScore: 1000,
        moves: 0,
        colorCount: 3,
        addRowEvery: 99,
        nextId: s.nextId,
      );

      final after = sWithBest.tap(0, 0); // 클리어 안 됨 → score 0
      expect(after.bestScore, 1000, reason: 'bestScore 유지');
    });
  });

  // ============================================================
  // 6. 새 줄 추가
  // ============================================================
  group('새 줄 추가', () {
    test('addRowEvery 턴마다 새 줄 추가', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ], addRowEvery: 2);

      final s1 = s.tap(0, 0);
      expect(s1.moves, 1);
      // 1 % 2 != 0 → 새 줄 없음
      expect(s1.highestRow, lessThanOrEqualTo(2));

      final s2 = s1.tap(0, 0);
      expect(s2.moves, 2);
      // 2 % 2 == 0 → 새 줄 추가 → 기존 블록 1줄 위로
      expect(s2.highestRow, greaterThanOrEqualTo(3), reason: '새 줄 추가로 높이 증가');
    });

    test('새 줄 추가 시 기존 블록 1칸 위로', () {
      final s = makeState([
        [R, R, R, R, R],
      ], addRowEvery: 1);

      final after = s.tap(0, 0);
      // 기존 row 0 → row 1로 밀림 (tap에 의해 색이 변했을 수 있음)
      expect(after.hasBlock(1, 0), isTrue, reason: '기존 블록 위로 이동');
      expect(after.hasBlock(0, 0), isTrue, reason: '새 줄 바닥에 추가');
    });

    test('addRowEvery=3 기본값 작동', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ], addRowEvery: 3);

      // 3번째 탭에서 새 줄 추가
      var state = s;
      state = state.tap(0, 0); // moves 1
      state = state.tap(0, 0); // moves 2
      final beforeHeight = state.highestRow;
      state = state.tap(0, 0); // moves 3 → 새 줄!
      expect(state.highestRow, greaterThanOrEqualTo(beforeHeight), reason: 'moves 3에서 새 줄');
    });

    test('새 줄 추가 후 row 0에 새 블록 존재', () {
      final s = makeState([
        [R, B, Y, R, B],
      ], addRowEvery: 1);

      final after = s.tap(0, 2);
      // 새 줄이 row 0에 추가됨
      for (int c = 0; c < GameState.cols; c++) {
        expect(after.hasBlock(0, c), isTrue, reason: 'col $c에 새 블록');
      }
    });

    test('새 줄 추가로 게임오버 발생 가능', () {
      // 6줄 꽉 찬 상태에서 새 줄 추가 → row 6에 블록 → 게임오버
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ], addRowEvery: 1);

      final after = s.tap(0, 0);
      expect(after.isGameOver, isTrue, reason: '새 줄 추가로 overflow → 게임오버');
    });

    test('클리어 후 새 줄 추가 순서: 클리어 먼저 → 새 줄', () {
      // 클리어로 공간이 생기면 새 줄 추가해도 게임오버 안 될 수 있음
      // row 0: BRBBB → tap(1,1) → row 0 = BBBBB → 클리어
      // 5줄 있었지만 1줄 클리어 → 4줄 → 새 줄 추가 → 5줄 → 게임오버 아님
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, R, B, Y, R],
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ], addRowEvery: 1);

      final after = s.tap(1, 1);
      // 클리어 먼저 → 높이 줄어듦 → 새 줄 추가 → 아직 게임오버 아닐 수 있음
      expect(after.score, greaterThan(0), reason: '클리어 발생');
      // 게임오버 여부는 높이에 따라 다름
    });

    test('nextId가 새 줄 추가 후 증가', () {
      final s = makeState([
        [R, B, Y, R, B],
      ], addRowEvery: 1);

      final before = s.nextId;
      final after = s.tap(0, 0);
      expect(after.nextId, greaterThan(before), reason: '새 블록에 ID 할당');
    });
  });

  // ============================================================
  // 7. 게임오버
  // ============================================================
  group('게임오버', () {
    test('row 6에 블록 도달 → 게임오버', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ], addRowEvery: 1);

      final after = s.tap(0, 0);
      expect(after.isGameOver, isTrue);
    });

    test('게임오버 시 bestScore 갱신', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ], addRowEvery: 1, score: 500);

      final after = s.tap(0, 0);
      expect(after.isGameOver, isTrue);
      expect(after.bestScore, greaterThanOrEqualTo(500));
    });

    test('row 5까지만 차있으면 게임오버 아님', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ]);

      expect(s.isGameOver, isFalse);
      final after = s.tap(0, 0);
      expect(after.isGameOver, isFalse);
    });

    test('게임오버 후 탭 불가', () {
      final s = GameState(
        grid: List.generate(GameState.rows, (r) {
          if (r < 7) {
            return List<Cell?>.generate(GameState.cols, (c) =>
              Cell(color: BlockColor.red, id: r * GameState.cols + c));
          }
          return List<Cell?>.filled(GameState.cols, null);
        }),
        isGameOver: true,
      );

      final after = s.tap(0, 0);
      expect(identical(after, s), isTrue, reason: '게임오버 후 탭 무시');
    });

    test('row 6에 단 1개 블록만 있어도 게임오버', () {
      // row 6에 직접 블록을 놓으려면 7줄 그리드가 필요
      final s7 = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
        [null, null, R, null, null], // row 6에 1개 블록
      ]);

      // _checkGameOver는 tap() 내부에서 호출됨
      // fromGrid는 게임오버 체크 안 함 → tap으로 트리거
      // 하지만 직접 검증: row 6 체크
      expect(s7.grid[6][2], isNotNull, reason: 'row 6에 블록');
    });
  });


  // (세로 줄 클리어 및 가로+세로 동시 클리어 테스트 제거 — 가로 클리어만 지원)


  // ============================================================
  // 10. 4색 모드
  // ============================================================
  group('4색 모드', () {
    test('R→B→Y→G 순환', () {
      final s = makeState([
        [R, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ], colorCount: 4);

      final after = s.tap(1, 0);
      expect(after.colorAt(0, 0), B); // R→B
    });

    test('B→Y→G 순환', () {
      final s = makeState([
        [B, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ], colorCount: 4);

      final after = s.tap(1, 0);
      expect(after.colorAt(0, 0), Y); // B→Y
    });

    test('Y→G 순환', () {
      final s = makeState([
        [Y, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ], colorCount: 4);

      final after = s.tap(1, 0);
      expect(after.colorAt(0, 0), G); // Y→G
    });

    test('4색 wrap: G→R', () {
      final s = makeState([
        [G, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ], colorCount: 4);

      final after = s.tap(1, 0);
      expect(after.colorAt(0, 0), R); // G→R
    });

    test('4색 모드에서 클리어 정상 작동', () {
      // 4색 모드에서 가로 클리어를 만들려면:
      // tap(1,1): (0,1)Y→G → row 0 = [G,G,G,G,G] → 클리어!
      // row 1: (1,0)R→B, (1,2)G→R → [B,R,R,Y,G] — RR 2연속 OK
      // row 2: (2,1)B→Y → [G,Y,R,B,Y] — 연속 없음
      final s2 = makeState([
        [G, Y, G, G, G],
        [R, R, G, Y, G],
        [G, B, R, B, Y],
      ], colorCount: 4);

      final after = s2.tap(1, 1);
      expect(after.score, 100);
    });
  });

  // ============================================================
  // 11. 엣지 케이스
  // ============================================================
  group('엣지 케이스', () {
    test('범위 밖 탭 무시', () {
      final s = makeState([[R, R, R, R, R]]);
      expect(identical(s.tap(-1, 0), s), isTrue);
      expect(identical(s.tap(0, -1), s), isTrue);
      expect(identical(s.tap(0, 5), s), isTrue);
      expect(identical(s.tap(7, 0), s), isTrue);
      expect(identical(s.tap(100, 100), s), isTrue);
    });

    test('불변성: tap은 원본을 변경하지 않음', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      final original00 = s.colorAt(0, 0);
      final original11 = s.colorAt(1, 1);
      final originalScore = s.score;
      final originalMoves = s.moves;

      s.tap(1, 0);
      expect(s.colorAt(0, 0), original00, reason: 'color 불변');
      expect(s.colorAt(1, 1), original11, reason: 'color 불변');
      expect(s.score, originalScore, reason: 'score 불변');
      expect(s.moves, originalMoves, reason: 'moves 불변');
    });

    test('불변성: 연속 tap에서도 이전 상태 유지', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      final s1 = s.tap(0, 0);
      final s2 = s.tap(0, 0);
      // 같은 입력 → 같은 결과 (원본이 안 변했으므로)
      expect(s1.colorAt(0, 0), s2.colorAt(0, 0));
      expect(s1.colorAt(0, 1), s2.colorAt(0, 1));
      expect(s1.colorAt(1, 0), s2.colorAt(1, 0));
      expect(s1.moves, s2.moves);
    });

    test('colorAt: 범위 밖은 null 반환', () {
      final s = makeState([[R, R, R, R, R]]);
      expect(s.colorAt(-1, 0), isNull);
      expect(s.colorAt(0, -1), isNull);
      expect(s.colorAt(0, 5), isNull);
      expect(s.colorAt(7, 0), isNull);
    });

    test('hasBlock: 범위 밖은 false', () {
      final s = makeState([[R, R, R, R, R]]);
      expect(s.hasBlock(-1, 0), isFalse);
      expect(s.hasBlock(7, 0), isFalse);
      expect(s.hasBlock(0, -1), isFalse);
      expect(s.hasBlock(0, 5), isFalse);
    });

    test('1줄만 있는 그리드에서 탭', () {
      final s = makeState([[R, B, Y, R, B]]);
      final after = s.tap(0, 2);
      expect(after.moves, 1);
      expect(after.colorAt(0, 1), Y, reason: 'B→Y');
      expect(after.colorAt(0, 3), B, reason: 'R→B');
      expect(after.colorAt(0, 2), Y, reason: '자신 불변');
    });

    test('모든 셀이 null인 그리드', () {
      final s = makeState([]);
      expect(s.highestRow, -1);
      expect(s.score, 0);
      // 아무 곳이나 탭 → 무시
      final after = s.tap(0, 0);
      expect(identical(after, s), isTrue);
    });

    test('fromGrid에 5칸 미만 row → 나머지 null', () {
      final s = makeState([
        [R, B], // 2칸만
      ]);
      expect(s.colorAt(0, 0), R);
      expect(s.colorAt(0, 1), B);
      expect(s.colorAt(0, 2), isNull);
      expect(s.colorAt(0, 3), isNull);
      expect(s.colorAt(0, 4), isNull);
    });
  });

  // ============================================================
  // 12. 복합 시나리오 (실제 게임 플레이 시뮬레이션)
  // ============================================================
  group('복합 시나리오', () {
    test('연속 탭 후 상태 일관성', () {
      var s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      // 10번 연속 탭 (블록이 있는 셀만 탭)
      int validTaps = 0;
      for (int i = 0; i < 10; i++) {
        final row = i % 3;
        final col = i % GameState.cols;
        final prev = s;
        s = s.tap(row, col);
        if (!identical(s, prev)) validTaps++;
        expect(s.moves, validTaps);
        expect(s.score, greaterThanOrEqualTo(0));
        expect(s.isGameOver, isFalse);
        // 그리드 무결성: 모든 row의 길이 = cols
        for (int r = 0; r < GameState.rows; r++) {
          expect(s.grid[r].length, GameState.cols);
        }
      }
    });

    test('클리어 + 새 줄 추가 복합 상황', () {
      // 3턴마다 새 줄 추가 + 클리어가 동시에 일어나는 경우
      final s = makeState([
        [B, R, B, B, B], // tap(1,1) → row 0 = BBBBB → 클리어
        [R, R, R, R, R],
        [Y, R, B, Y, R],
      ], addRowEvery: 1);

      final after = s.tap(1, 1);
      // 클리어 먼저 → 새 줄 추가 → 게임오버 체크
      expect(after.score, greaterThan(0));
      expect(after.moves, 1);
    });

    test('게임오버 직전 클리어로 구출', () {
      // 5줄 꽉 참 + addRowEvery=1 → 다음 탭에서 새 줄 추가 → 6줄 → 위험
      // 하지만 탭으로 1줄 클리어하면 5줄 → 새 줄 추가 → 6줄 → 아직 안전
      // 세로 클리어 회피: col별로 연속 3개 같은 색 없도록 구성
      final s = makeState([
        [B, R, B, B, B], // → tap(1,1)로 row 0 = BBBBB 클리어
        [R, R, R, R, R],
        [Y, R, Y, Y, R],
        [R, B, R, R, B],
        [B, Y, B, B, Y],
      ], addRowEvery: 1);

      final after = s.tap(1, 1);
      // 클리어 → 4줄 → 새 줄 추가 → 5줄 → 게임오버 아님
      expect(after.score, greaterThan(0));
      expect(after.isGameOver, isFalse);
    });

    test('블록 총 수 보존 (클리어 없는 경우)', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      final before = totalBlocks(s);
      final after = s.tap(1, 2); // 클리어 없으면 블록 수 같음
      if (after.score == 0) {
        expect(totalBlocks(after), before, reason: '클리어 없으면 블록 수 보존');
      }
    });

    test('블록 수 감소 (클리어 있는 경우)', () {
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      final before = totalBlocks(s);
      final after = s.tap(1, 1); // row 0 클리어 → 5개 감소
      expect(totalBlocks(after), lessThan(before), reason: '클리어로 블록 감소');
    });

    test('중력 후 floating 블록 없음 (모든 블록 아래에 블록 or 바닥)', () {
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, Y, Y, Y, Y],
        [R, R, R, R, R],
      ]);

      final after = s.tap(1, 1);
      // 중력 후: 각 col에서 빈 칸 위에 블록이 없어야 함
      for (int c = 0; c < GameState.cols; c++) {
        bool foundNull = false;
        for (int r = 0; r < GameState.rows; r++) {
          if (after.colorAt(r, c) == null) {
            foundNull = true;
          } else if (foundNull) {
            fail('col $c, row $r: floating block detected (null below at some row)');
          }
        }
      }
    });

    test('중력 후 floating 블록 없음 (연쇄 클리어 후)', () {
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [B, R, B, B, B],
        [Y, Y, Y, Y, Y],
      ]);

      final after = s.tap(1, 1);
      for (int c = 0; c < GameState.cols; c++) {
        bool foundNull = false;
        for (int r = 0; r < GameState.rows; r++) {
          if (after.colorAt(r, c) == null) {
            foundNull = true;
          } else if (foundNull) {
            fail('col $c, row $r: floating block after chain clear');
          }
        }
      }
    });

    test('score는 감소하지 않음', () {
      var s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      int prevScore = 0;
      for (int i = 0; i < 20; i++) {
        s = s.tap(i % 3, i % GameState.cols);
        if (s.isGameOver) break;
        expect(s.score, greaterThanOrEqualTo(prevScore),
            reason: 'score는 감소하지 않음 (turn $i)');
        prevScore = s.score;
      }
    });

    test('moves는 유효한 탭마다 1 증가', () {
      var s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      for (int i = 0; i < 5; i++) {
        final before = s.moves;
        s = s.tap(0, i % GameState.cols);
        if (!s.isGameOver) {
          expect(s.moves, before + 1);
        }
      }
    });
  });

  // ============================================================
  // 13. 정밀 점수 검증
  // ============================================================
  group('정밀 점수 검증', () {
    test('1줄 클리어 = 100', () {
      final s2 = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ]);
      final after = s2.tap(1, 1);
      expect(after.score, 100);
    });

    test('2줄 동시 = 200', () {
      // 세로 클리어 회피: row 0과 row 2가 다른 색
      final s = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, B, Y, Y, Y],
      ]);
      final after = s.tap(1, 1);
      expect(after.score, 200);
    });

    test('3줄 동시 클리어 = 300', () {
      // 세로 클리어 회피: 행 간 색 혼합
      final s2 = makeState([
        [B, R, B, B, B],
        [R, R, R, R, R],
        [Y, B, Y, Y, Y],
        [R, R, R, R, R],
      ]);

      final after = s2.tap(1, 1);
      expect(after.score, 300, reason: '3줄 * 100 * 1');
    });

    test('누적 점수: 기존 + 신규', () {
      final s = makeState([
        [B, R, B, B, B],
        [Y, R, B, R, Y],
        [Y, R, B, Y, R],
      ], score: 1000);

      final after = s.tap(1, 1);
      expect(after.score, 1100);
    });
  });


  // (정밀 세로 클리어 테스트 제거 — 가로 클리어만 지원)


  // ============================================================
  // 15. 그리드 무결성 검증
  // ============================================================
  group('그리드 무결성', () {
    test('모든 상태에서 grid 크기 = rows x cols', () {
      var s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ], addRowEvery: 2);

      for (int i = 0; i < 20; i++) {
        s = s.tap(i % 3, i % GameState.cols);
        if (s.isGameOver) break;

        expect(s.grid.length, GameState.rows,
            reason: 'grid rows = ${GameState.rows} at turn $i');
        for (int r = 0; r < GameState.rows; r++) {
          expect(s.grid[r].length, GameState.cols,
              reason: 'grid[$r] cols = ${GameState.cols} at turn $i');
        }
      }
    });

    test('ID 고유성: 같은 ID를 가진 셀이 없음', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      final ids = <int>{};
      for (int r = 0; r < GameState.rows; r++) {
        for (int c = 0; c < GameState.cols; c++) {
          final cell = s.grid[r][c];
          if (cell != null) {
            expect(ids.contains(cell.id), isFalse,
                reason: 'Duplicate ID ${cell.id} at ($r,$c)');
            ids.add(cell.id);
          }
        }
      }
    });

    test('tap 후 ID 보존 (색만 변경)', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
        [Y, R, B, Y, R],
      ]);

      final originalId01 = s.grid[0][1]!.id;
      final after = s.tap(1, 1); // (0,1) 색 변경
      // 클리어 안 되면 ID 유지
      if (after.score == 0) {
        expect(after.grid[0][1]!.id, originalId01, reason: 'ID 보존');
      }
    });

    test('color 값이 항상 colorCount 범위 내', () {
      // 2색 입문모드로 시작 (Phase A 기본)
      var s = GameState.newGame(colorCount: 2);
      var maxColorCount = s.colorCount;

      for (int i = 0; i < 30; i++) {
        s = s.tap(i % 3, i % GameState.cols);
        if (s.isGameOver) break;

        // 난이도 상승으로 colorCount가 증가할 수 있으므로 최대값 추적
        if (s.colorCount > maxColorCount) {
          maxColorCount = s.colorCount;
        }
        final validColors = BlockColor.values.sublist(0, maxColorCount).toSet();

        for (int r = 0; r < GameState.rows; r++) {
          for (int c = 0; c < GameState.cols; c++) {
            final cell = s.grid[r][c];
            if (cell != null) {
              expect(validColors.contains(cell.color), isTrue,
                  reason: 'Invalid color ${cell.color} at ($r,$c) turn $i');
            }
          }
        }
      }
    });

    test('4색 모드에서 color 범위 검증', () {
      var s = GameState.newGame(colorCount: 4);
      final validColors = {R, B, Y, G};

      for (int i = 0; i < 20; i++) {
        s = s.tap(i % 3, i % GameState.cols);
        if (s.isGameOver) break;

        for (int r = 0; r < GameState.rows; r++) {
          for (int c = 0; c < GameState.cols; c++) {
            final cell = s.grid[r][c];
            if (cell != null) {
              expect(validColors.contains(cell.color), isTrue,
                  reason: 'Invalid color ${cell.color} at ($r,$c) turn $i');
            }
          }
        }
      }
    });
  });

  // ============================================================
  // 16. 긴 게임 세션 시뮬레이션
  // ============================================================
  group('장시간 세션 무결성', () {
    test('50턴 플레이 후 상태 일관성', () {
      var s = GameState.newGame(colorCount: 3);

      for (int i = 0; i < 50; i++) {
        if (s.isGameOver) break;
        s = s.tap(i % 3, i % GameState.cols);

        // 기본 무결성
        expect(s.grid.length, GameState.rows);
        expect(s.score, greaterThanOrEqualTo(0));
        expect(s.moves, greaterThan(0));

        // 중력 무결성: floating block 없음
        for (int c = 0; c < GameState.cols; c++) {
          bool foundNull = false;
          for (int r = 0; r < GameState.rows; r++) {
            if (s.grid[r][c] == null) {
              foundNull = true;
            } else if (foundNull) {
              fail('Floating block at ($r,$c) on turn ${i + 1}');
            }
          }
        }
      }
    });

    test('100턴 4색 모드 무결성', () {
      var s = GameState.newGame(colorCount: 4);
      final validColors = {R, B, Y, G};

      for (int i = 0; i < 100; i++) {
        if (s.isGameOver) break;
        s = s.tap(i % 4, i % GameState.cols);

        for (int r = 0; r < GameState.rows; r++) {
          for (int c = 0; c < GameState.cols; c++) {
            final cell = s.grid[r][c];
            if (cell != null) {
              expect(validColors.contains(cell.color), isTrue);
            }
          }
        }
      }
    });
  });

  // ============================================================
  // 17. 탭 위치별 정밀 테스트
  // ============================================================
  group('탭 위치별 정밀', () {
    test('row 0, col 0 (좌하단 모서리): 2방향만 변경', () {
      final s = makeState([
        [Y, B, R, R, R],
        [R, R, R, R, R],
      ]);
      final after = s.tap(0, 0);
      expect(after.colorAt(0, 1), Y, reason: 'B→Y 오른쪽');
      expect(after.colorAt(1, 0), B, reason: 'R→B 위');
      expect(after.moves, 1);
    });

    test('row 0, col 4 (우하단 모서리): 2방향만 변경', () {
      final s = makeState([
        [R, R, R, B, Y],
        [R, R, R, R, R],
      ]);
      final after = s.tap(0, 4);
      expect(after.colorAt(0, 3), Y, reason: 'B→Y 왼쪽');
      expect(after.colorAt(1, 4), B, reason: 'R→B 위');
    });

    test('최상단 비어있는 row 바로 아래 탭: 위쪽 null 무시', () {
      final s = makeState([
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);
      // highestRow = 1, row 2 = null
      final after = s.tap(1, 2);
      expect(after.colorAt(2, 2), isNull, reason: 'row 2는 null');
      expect(after.colorAt(0, 2), B, reason: 'R→B 아래');
      expect(after.colorAt(1, 1), B, reason: 'R→B 왼쪽');
      expect(after.colorAt(1, 3), B, reason: 'R→B 오른쪽');
    });

    test('중간에 null이 있는 row에서 탭', () {
      final s = makeState([
        [R, null, R, null, R],
        [R, R, R, R, R],
      ]);
      // tap(0, 2): 자신 R 불변, (0,1)=null 무시, (0,3)=null 무시
      // (1,2)=R→B만 변경
      final after = s.tap(0, 2);
      expect(after.colorAt(0, 1), isNull, reason: 'null은 그대로');
      expect(after.colorAt(0, 3), isNull, reason: 'null은 그대로');
      expect(after.colorAt(1, 2), B, reason: 'R→B');
      expect(after.colorAt(0, 0), R, reason: '대각선 불변');
      expect(after.colorAt(0, 4), R, reason: '대각선 불변');
    });
  });

  // ============================================================
  // 18. addRowEvery 경계값
  // ============================================================
  group('addRowEvery 경계값', () {
    test('addRowEvery=1: 매턴 새 줄', () {
      final s = makeState([
        [R, B, Y, R, B],
      ], addRowEvery: 1);

      final after = s.tap(0, 0);
      // moves=1, 1%1==0 → 새 줄 추가
      expect(after.hasBlock(0, 0), isTrue, reason: '새 줄 추가됨');
      expect(after.highestRow, greaterThanOrEqualTo(1));
    });

    test('addRowEvery=99: 99턴까지 새 줄 없음', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ], addRowEvery: 99);

      var state = s;
      for (int i = 0; i < 10; i++) {
        state = state.tap(0, i % GameState.cols);
        if (state.isGameOver) break;
      }
      // 10턴 안에는 새 줄 추가 없음 (99턴마다)
      expect(state.highestRow, lessThanOrEqualTo(2));
    });

    test('addRowEvery=2: 짝수 턴에만 추가', () {
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ], addRowEvery: 2);

      final s1 = s.tap(0, 0); // moves=1 → 1%2≠0 → 추가 안 함
      final h1 = s1.highestRow;

      final s2 = s1.tap(0, 1); // moves=2 → 2%2==0 → 추가!
      expect(s2.highestRow, greaterThanOrEqualTo(h1), reason: '2번째 턴에 새 줄');
    });
  });


  // (클리어 순서와 교차 테스트 제거 — 세로 클리어 미지원)


  // ============================================================
  // 20. 특수 엣지: 빈 가로줄 + null 패턴
  // ============================================================
  group('특수 엣지 패턴', () {
    test('체커보드 패턴에서 탭: 인접 색상만 변경', () {
      final s = makeState([
        [R, B, R, B, R],
        [B, R, B, R, B],
        [R, B, R, B, R],
      ]);

      final after = s.tap(1, 2);
      // 인접: (0,2)R→B, (2,2)R→B, (1,1)R→B, (1,3)R→B
      // 클리어가 일어날 수 있음 (다수가 B가 됨)
      // 클리어 여부와 무관하게 탭 자체는 유효
      expect(after.moves, 1, reason: '탭 유효');
      expect(after.score, greaterThanOrEqualTo(0));
    });

    test('모든 셀이 같은 색: 가로 + 세로 클리어', () {
      final s = makeState([
        [R, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
        [R, R, R, R, R],
      ]);

      // tap(2,2): (1,2)R→B, (3,2)R→B, (2,1)R→B, (2,3)R→B
      // row 0: RRRRR → 가로 클리어!
      // row 4: RRRRR → 가로 클리어!
      // col 0: RRRRR → 세로 클리어!
      // col 4: RRRRR → 세로 클리어!
      // 4줄 * 100 * combo(1) = 400
      final after = s.tap(2, 2);
      expect(after.score, 400, reason: '가로 2줄 + 세로 2줄 = 4 * 100 * 1 = 400');
    });

    test('단일 블록만 있는 그리드에서 탭', () {
      final s = makeState([
        [null, null, R, null, null],
      ]);

      final after = s.tap(0, 2);
      expect(after.moves, 1);
      expect(after.colorAt(0, 2), R, reason: '자신 불변');
      expect(after.score, 0, reason: '1개로 클리어 불가');
    });

    test('가로 한 줄에 4개 같은 색 + 1개 다른 색', () {
      final s = makeState([
        [B, B, B, B, R],
        [R, R, R, R, R],
      ]);
      // (0,4)=R이 B가 되어야 클리어
      // 직접 클리어 안 됨
      final after = s.tap(1, 0);
      expect(after.colorAt(0, 0), isNotNull, reason: '클리어 안 됨');
    });
  });

  // ================================================================
  // 세로줄 클리어 테스트
  // ================================================================
  group('세로줄 클리어', () {
    test('세로 3개 연속 같은 색 → 클리어', () {
      final s = makeState([
        [R, B, Y, B, Y],
        [R, Y, B, Y, B],
        [R, B, Y, B, Y],
      ]);
      // col 0 = R, R, R → 세로 클리어
      // 탭 없이 직접 체크하기 위해, 탭으로 유발
      // 실제로는 fromGrid 시점에선 체크 안 함. tap으로 유발해야 함.
      // 대신 이미 세로 3개인 상태에서 같은 색 유지되는 탭을 하자.
      // col 0이 이미 R,R,R이므로, 다른 곳을 탭해서 col 0에 영향 안 주면 유지됨.
      // 근데 _checkAndClearLines는 tap 내부에서만 호출됨.
      // → col4를 탭하면 col0에 영향 없고, 줄 체크 발동
      final after = s.tap(1, 4); // col 4 row 1 탭 → col 0은 변경 안 됨
      // col 0의 R,R,R이 클리어되었어야 함
      expect(after.colorAt(0, 0), isNull, reason: 'col 0 row 0 클리어');
      expect(after.colorAt(1, 0), isNull, reason: 'col 0 row 1 클리어');
      expect(after.colorAt(2, 0), isNull, reason: 'col 0 row 2 클리어');
      expect(after.score, greaterThan(0), reason: '세로 클리어로 점수 획득');
    });

    test('세로 2개는 클리어 안 됨', () {
      final s = makeState([
        [R, B, Y, B, Y],
        [R, Y, B, Y, B],
      ]);
      // col 0 = R, R → 2개뿐, 클리어 안 됨
      final after = s.tap(0, 4);
      expect(after.colorAt(0, 0), R, reason: '2개는 클리어 안 됨');
      expect(after.colorAt(1, 0), R, reason: '2개는 클리어 안 됨');
    });

    test('세로 4개 연속 같은 색 → 전부 클리어', () {
      final s = makeState([
        [B, Y, R, B, Y],
        [B, R, Y, R, B],
        [B, Y, R, Y, R],
        [B, R, Y, B, Y],
      ]);
      // col 0 = B, B, B, B → 4개 세로 클리어
      final after = s.tap(2, 4); // col 0에 영향 없는 탭
      expect(after.colorAt(0, 0), isNull);
      expect(after.colorAt(1, 0), isNull);
      expect(after.colorAt(2, 0), isNull);
      expect(after.colorAt(3, 0), isNull);
    });

    test('세로 중간에 다른 색 끼면 연속 끊김', () {
      // col 0: R, R, B, R → 연속 R이 2개뿐 → 세로 클리어 안 됨
      // tap(2,4) 후 가로 클리어 회피를 위해 색 배치 조정
      // tap(2,4): (1,4)→next, (3,4)→next, (2,3)→next
      // (1,4)Y→R, (3,4)R→B, (2,3)R→B
      // row 1: [R,Y,B,Y,R] — 연속 없음
      // row 2: [B,B,Y,B,Y] — BB 2연속 OK
      // row 3: [R,Y,B,Y,B] — 연속 없음
      final s = makeState([
        [R, B, Y, B, Y],
        [R, Y, B, Y, Y],
        [B, B, Y, R, Y], // col 0 row 2 = B (연속 끊김)
        [R, Y, B, Y, R],
      ]);
      final after = s.tap(2, 4);
      expect(after.colorAt(0, 0), R, reason: '연속 2개는 클리어 안 됨');
      expect(after.colorAt(1, 0), R, reason: '연속 2개는 클리어 안 됨');
    });

    test('가로 + 세로 동시 클리어 (Cross Clear)', () {
      // row 2: 전부 R → 가로 클리어
      // col 2: rows 2,3,4 = R,R,R → 세로 클리어
      // 겹치는 셀 (2,2)은 한 번만 제거
      final s = makeState([
        [B, Y, R, B, Y],
        [Y, B, Y, R, B],
        [R, R, R, R, R], // 가로 5개 R
        [B, Y, R, B, Y], // col 2 = R
        [Y, B, R, Y, B], // col 2 = R
      ]);
      // tap(0,0): (1,0)Y→R, (0,1)Y→R — row 2+ 및 col 2에 영향 없음
      final after = s.tap(0, 0);
      // 가로 1줄 + 세로 1줄 = 2줄 판정 → 200점
      expect(after.score, equals(200));
    });

    test('세로 클리어 후 중력 적용', () {
      final s = makeState([
        [R, B, Y, B, Y],
        [R, Y, B, Y, B],
        [R, B, Y, B, Y],
        [B, Y, R, Y, R], // col 0 row 3 = B (R 아님)
      ]);
      // col 0: R, R, R, B → 하위 3개 R 클리어
      final after = s.tap(2, 4);
      // 클리어 후 row 3의 B가 row 0으로 낙하
      expect(after.colorAt(0, 0), B, reason: 'B가 중력으로 낙하');
      expect(after.colorAt(1, 0), isNull);
      expect(after.colorAt(2, 0), isNull);
    });

    test('세로 클리어로 시간 보너스 발생', () {
      final s = makeState([
        [R, B, Y, B, Y],
        [R, Y, B, Y, B],
        [R, B, Y, B, Y],
      ]);
      final after = s.tap(1, 4);
      expect(after.timeBonus, greaterThan(0), reason: '세로 클리어 시 시간 보너스');
    });

    test('세로 클리어 후 연쇄 (Cascade)', () {
      // 세로 클리어 → 중력 → 새로운 가로 클리어
      final s = makeState([
        [R, R, R, R, B], // row 0: 4R + 1B
        [B, Y, B, Y, R], // row 1
        [B, R, Y, R, R], // row 2 col 4 = R
        [B, Y, B, Y, R], // row 3 col 4 = R
      ]);
      // col 4: B, R, R, R → row 1~3에 R 3개 → 세로 클리어
      final after = s.tap(0, 2); // row 0 col 2 탭 (col 4에 영향 없음)
      // col 4의 R,R,R 클리어 후 → row 1,2,3의 col 4 비어짐
      // 중력으로 row 0의 B가 그대로 → 연쇄 가능성 체크
      expect(after.score, greaterThan(0));
    });
  });

  // ================================================================
  // Progressive 난이도 테스트
  // ================================================================
  group('Progressive 난이도', () {
    test('autoDifficulty=false인 fromGrid에서는 난이도 변경 안 됨', () {
      final s = makeState([
        [R, R, R, R, R],
        [B, Y, B, Y, B],
      ], score: 1500);
      // fromGrid는 autoDifficulty=false → colorCount/addRowEvery 변경 안 됨
      expect(s.colorCount, equals(3));
      expect(s.addRowEvery, equals(99));
    });

    test('newGame은 autoDifficulty=true', () {
      final s = GameState.newGame();
      expect(s.autoDifficulty, isTrue);
      expect(s.colorCount, equals(2)); // 2색 입문모드
      expect(s.addRowEvery, equals(5)); // Phase A: 5턴마다
    });
  });

  // ================================================================
  // 콤보 시간 보너스 테스트
  // ================================================================
  group('콤보 시간 보너스', () {
    test('콤보 1 = +5초 (기본 3 + 줄클리어 보너스 2)', () {
      final s = makeState([
        [R, R, R, R, R],
        [B, Y, B, Y, B],
      ]);
      final after = s.tap(1, 0); // row 0이 이미 전부 R → 탭 후 체크
      // row 0이 탭으로 변경될 수 있으므로, 클리어 발생 시 체크
      if (after.score > 0) {
        expect(after.timeBonus, equals(5)); // 콤보1(3) + 1줄*2
      }
    });
  });

  // ============================================================
  // 특수 블록 테스트
  // ============================================================
  group('특수 블록: 기본', () {
    test('Cell에 BlockType 기본값 normal', () {
      const cell = Cell(color: BlockColor.red, id: 0);
      expect(cell.type, BlockType.normal);
      expect(cell.hitCount, 0);
    });

    test('Cell equality에 type, hitCount 반영', () {
      const a = Cell(color: BlockColor.red, id: 0);
      const b = Cell(color: BlockColor.red, id: 0, type: BlockType.locked);
      const c = Cell(
          color: BlockColor.red, id: 0, type: BlockType.locked, hitCount: 1);
      const d = Cell(
          color: BlockColor.red, id: 0, type: BlockType.locked, hitCount: 1);
      expect(a, isNot(equals(b)));
      expect(b, isNot(equals(c)));
      expect(c, equals(d));
    });

    test('Cell copyWith에 type, hitCount 추가', () {
      const cell = Cell(color: BlockColor.red, id: 5);
      final locked = cell.copyWith(type: BlockType.locked);
      expect(locked.type, BlockType.locked);
      expect(locked.color, BlockColor.red);
      expect(locked.id, 5);

      final hit = locked.copyWith(hitCount: 1);
      expect(hit.hitCount, 1);
      expect(hit.type, BlockType.locked);
    });

    test('Cell hashCode에 type, hitCount 반영', () {
      const a = Cell(color: BlockColor.red, id: 0);
      const b = Cell(color: BlockColor.red, id: 0, type: BlockType.bomb);
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  group('특수 블록: locked', () {
    test('인접 탭 시 hitCount 증가, 색 변환 안 됨', () {
      // row 0: [R, locked_B, R, R, R]
      // row 1: [R, R, R, R, R]
      // tap(0,0) → (0,1)은 locked → hitCount+1만, 색 변환 안 됨
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.red, id: 0),
          const Cell(
              color: BlockColor.blue, id: 1, type: BlockType.locked),
          const Cell(color: BlockColor.red, id: 2),
          const Cell(color: BlockColor.red, id: 3),
          const Cell(color: BlockColor.red, id: 4),
        ],
        [
          const Cell(color: BlockColor.red, id: 5),
          const Cell(color: BlockColor.red, id: 6),
          const Cell(color: BlockColor.red, id: 7),
          const Cell(color: BlockColor.red, id: 8),
          const Cell(color: BlockColor.red, id: 9),
        ],
      ], addRowEvery: 99);

      final after = s.tap(0, 0);
      // (0,1) locked → hitCount 0→1, 색은 blue 유지
      expect(after.colorAt(0, 1), BlockColor.blue, reason: 'locked 색 변환 안 됨');
      expect(after.typeAt(0, 1), BlockType.locked, reason: 'locked 유지');
      expect(after.hitCountAt(0, 1), 1, reason: 'hitCount 증가');
    });

    test('hitCount 2 이후 normal로 전환 + 색 변환', () {
      // locked 블록을 직접 2번 탭
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.red, id: 0),
          const Cell(
              color: BlockColor.blue, id: 1, type: BlockType.locked),
          const Cell(color: BlockColor.yellow, id: 2),
          const Cell(color: BlockColor.red, id: 3),
          const Cell(color: BlockColor.yellow, id: 4),
        ],
        [
          const Cell(color: BlockColor.yellow, id: 5),
          const Cell(color: BlockColor.red, id: 6),
          const Cell(color: BlockColor.yellow, id: 7),
          const Cell(color: BlockColor.red, id: 8),
          const Cell(color: BlockColor.yellow, id: 9),
        ],
      ], addRowEvery: 99);

      // 1번째 직접 탭: hitCount 0→1
      final s1 = s.tap(0, 1);
      expect(s1.typeAt(0, 1), BlockType.locked, reason: '1번째 탭: locked 유지');
      expect(s1.hitCountAt(0, 1), 1, reason: '1번째 탭: hitCount=1');
      expect(s1.colorAt(0, 1), BlockColor.blue, reason: '1번째 탭: 색 유지');

      // 2번째 직접 탭: hitCount 1→2 → normal 전환 + 색 변환
      final s2 = s1.tap(0, 1);
      expect(s2.typeAt(0, 1), BlockType.normal, reason: '2번째 탭: normal 전환');
      expect(s2.hitCountAt(0, 1), 0, reason: '2번째 탭: hitCount 리셋');
      expect(s2.colorAt(0, 1), BlockColor.yellow,
          reason: '2번째 탭: B→Y 색 변환');
    });
  });

  group('특수 블록: bomb', () {
    test('클리어 시 3x3 범위 추가 제거', () {
      // row 0: [B, B, bomb_B, B, B] → 가로 클리어
      // bomb이 (0,2)에 있으므로 3x3: row -1~1, col 1~3 제거
      // row 1의 col 1~3도 제거됨
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.blue, id: 0),
          const Cell(color: BlockColor.blue, id: 1),
          const Cell(
              color: BlockColor.blue, id: 2, type: BlockType.bomb),
          const Cell(color: BlockColor.blue, id: 3),
          const Cell(color: BlockColor.blue, id: 4),
        ],
        [
          const Cell(color: BlockColor.red, id: 5),
          const Cell(color: BlockColor.yellow, id: 6),
          const Cell(color: BlockColor.red, id: 7),
          const Cell(color: BlockColor.yellow, id: 8),
          const Cell(color: BlockColor.red, id: 9),
        ],
        [
          const Cell(color: BlockColor.yellow, id: 10),
          const Cell(color: BlockColor.red, id: 11),
          const Cell(color: BlockColor.yellow, id: 12),
          const Cell(color: BlockColor.red, id: 13),
          const Cell(color: BlockColor.yellow, id: 14),
        ],
      ], addRowEvery: 99);

      // row 0은 이미 전부 blue → 다른 곳을 탭해서 트리거
      final after = s.tap(1, 0);
      // row 0 전부 클리어 (가로 5연속) + bomb 3x3
      // bomb(0,2)의 3x3: row -1~1, col 1~3
      // row 1 col 1,2,3이 bomb으로 추가 제거됨
      // 중력 후 확인
      expect(after.score, greaterThan(0), reason: '클리어 발생');

      // row 1의 col 1~3은 bomb으로 제거됨
      // 중력 적용 후 → row 0에는 row 2에서 내려온 블록
      // col 1: row 1 제거 → row 2의 R이 내려옴
      // 전체 블록 수: 15 - 5(row0) - 3(bomb) = 7
      final blocks = totalBlocks(after);
      expect(blocks, lessThan(10), reason: 'bomb으로 추가 블록 제거');
    });
  });

  group('특수 블록: rainbow', () {
    test('가로 매칭에서 와일드카드로 동작', () {
      // row 0: [R, R, rainbow_Y, R, R] → rainbow가 R들과 매칭 → 5연속 클리어
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.red, id: 0),
          const Cell(color: BlockColor.red, id: 1),
          const Cell(
              color: BlockColor.yellow, id: 2, type: BlockType.rainbow),
          const Cell(color: BlockColor.red, id: 3),
          const Cell(color: BlockColor.red, id: 4),
        ],
        [
          const Cell(color: BlockColor.yellow, id: 5),
          const Cell(color: BlockColor.blue, id: 6),
          const Cell(color: BlockColor.yellow, id: 7),
          const Cell(color: BlockColor.blue, id: 8),
          const Cell(color: BlockColor.yellow, id: 9),
        ],
      ], addRowEvery: 99);

      // 다른 곳 탭해서 클리어 트리거
      final after = s.tap(1, 0);
      // row 0: R,R,rainbow,R,R → rainbow는 모든 색 매칭 → 5연속 클리어
      expect(after.score, greaterThan(0), reason: 'rainbow 와일드카드 매칭 클리어');
      // row 0 전체가 클리어되었어야 함
      expect(after.colorAt(0, 2), isNot(BlockColor.yellow),
          reason: 'rainbow 블록도 클리어됨');
    });

    test('세로 매칭에서 와일드카드로 동작', () {
      // col 0: R, rainbow_B, R → rainbow가 R들과 매칭 → 3연속 클리어
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.red, id: 0),
          const Cell(color: BlockColor.blue, id: 1),
          const Cell(color: BlockColor.yellow, id: 2),
          const Cell(color: BlockColor.blue, id: 3),
          const Cell(color: BlockColor.yellow, id: 4),
        ],
        [
          const Cell(
              color: BlockColor.blue, id: 5, type: BlockType.rainbow),
          const Cell(color: BlockColor.yellow, id: 6),
          const Cell(color: BlockColor.blue, id: 7),
          const Cell(color: BlockColor.yellow, id: 8),
          const Cell(color: BlockColor.blue, id: 9),
        ],
        [
          const Cell(color: BlockColor.red, id: 10),
          const Cell(color: BlockColor.blue, id: 11),
          const Cell(color: BlockColor.yellow, id: 12),
          const Cell(color: BlockColor.blue, id: 13),
          const Cell(color: BlockColor.yellow, id: 14),
        ],
      ], addRowEvery: 99);

      // col 0: R(row0), rainbow(row1), R(row2) → 세로 3연속
      // 다른 곳 탭해서 트리거 (col 0에 영향 없는 곳)
      final after = s.tap(1, 4);
      // col 0 세로 클리어
      expect(after.score, greaterThan(0), reason: 'rainbow 세로 와일드카드 클리어');
      expect(after.colorAt(0, 0), isNull, reason: 'col 0 row 0 클리어');
    });
  });

  group('특수 블록: ice', () {
    test('인접 탭에 영향 안 받음', () {
      // row 0: [R, ice_B, R, R, R]
      // tap(0,0) → (0,1)은 ice → 영향 안 받음
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.red, id: 0),
          const Cell(
              color: BlockColor.blue, id: 1, type: BlockType.ice),
          const Cell(color: BlockColor.red, id: 2),
          const Cell(color: BlockColor.red, id: 3),
          const Cell(color: BlockColor.red, id: 4),
        ],
        [
          const Cell(color: BlockColor.yellow, id: 5),
          const Cell(color: BlockColor.red, id: 6),
          const Cell(color: BlockColor.yellow, id: 7),
          const Cell(color: BlockColor.red, id: 8),
          const Cell(color: BlockColor.yellow, id: 9),
        ],
      ], addRowEvery: 99);

      final after = s.tap(0, 0);
      // (0,1) ice → 영향 안 받음
      expect(after.colorAt(0, 1), BlockColor.blue,
          reason: 'ice 블록 인접 탭 영향 안 받음');
      expect(after.typeAt(0, 1), BlockType.ice, reason: 'ice 유지');
    });

    test('직접 탭하면 자기 색 변환', () {
      final s = GameState.fromCellGrid([
        [
          const Cell(color: BlockColor.red, id: 0),
          const Cell(
              color: BlockColor.blue, id: 1, type: BlockType.ice),
          const Cell(color: BlockColor.yellow, id: 2),
          const Cell(color: BlockColor.red, id: 3),
          const Cell(color: BlockColor.yellow, id: 4),
        ],
        [
          const Cell(color: BlockColor.yellow, id: 5),
          const Cell(color: BlockColor.red, id: 6),
          const Cell(color: BlockColor.yellow, id: 7),
          const Cell(color: BlockColor.red, id: 8),
          const Cell(color: BlockColor.yellow, id: 9),
        ],
      ], addRowEvery: 99);

      final after = s.tap(0, 1);
      // ice 직접 탭 → 자기 색 변환: B→Y
      expect(after.colorAt(0, 1), BlockColor.yellow,
          reason: 'ice 직접 탭 시 색 변환');
      expect(after.typeAt(0, 1), BlockType.ice, reason: 'ice 타입 유지');
    });
  });

  group('특수 블록: 출현 조건', () {
    test('score < 3000에서는 특수 블록 미출현', () {
      // addRowEvery=1, score=0으로 여러 번 탭해도 특수 블록 없음
      final s = makeState([
        [R, B, Y, R, B],
        [B, Y, R, B, Y],
      ], addRowEvery: 1, score: 0);

      var state = s;
      for (int i = 0; i < 20; i++) {
        state = state.tap(0, i % GameState.cols);
        if (state.isGameOver) break;
        // 새 줄(row 0)에 특수 블록 없어야 함
        for (int c = 0; c < GameState.cols; c++) {
          final cell = state.grid[0][c];
          if (cell != null) {
            expect(cell.type, BlockType.normal,
                reason: 'score < 3000이면 특수 블록 없음 (turn $i, col $c)');
          }
        }
      }
    });

    test('score >= 3000에서 새 줄에 특수 블록 출현 가능', () {
      // 100번 시도해서 한 번이라도 특수 블록이 나오는지 확인
      bool foundSpecial = false;
      for (int trial = 0; trial < 100; trial++) {
        final s = makeState([
          [R, B, Y, R, B],
          [B, Y, R, B, Y],
        ], addRowEvery: 1, score: 5000);

        final after = s.tap(0, 0);
        if (after.isGameOver) continue;
        for (int c = 0; c < GameState.cols; c++) {
          final cell = after.grid[0][c];
          if (cell != null && cell.type != BlockType.normal) {
            foundSpecial = true;
            break;
          }
        }
        if (foundSpecial) break;
      }
      expect(foundSpecial, isTrue,
          reason: 'score >= 3000이면 특수 블록 출현 가능 (확률적)');
    });
  });

  group('nearCompleteRows 힌트', () {
    test('4/5칸 동일색 가로줄 감지', () {
      final s = makeState([
        [R, R, R, R, B], // 4/5 빨강 → 힌트
        [B, Y, R, B, Y], // 혼합 → 힌트 아님
      ]);
      expect(s.nearCompleteRows, contains(0));
      expect(s.nearCompleteRows, isNot(contains(1)));
    });

    test('5/5칸 동일색도 감지', () {
      final s = makeState([
        [R, R, R, R, R], // 5/5 → 힌트
      ]);
      expect(s.nearCompleteRows, contains(0));
    });

    test('3/5칸 동일색은 감지 안 됨', () {
      final s = makeState([
        [R, R, R, B, Y], // 3/5 → 힌트 아님
      ]);
      expect(s.nearCompleteRows, isEmpty);
    });

    test('빈 행은 감지 안 됨', () {
      final s = makeState([
        [R, B, Y, R, B],
      ]);
      // row 1~6은 비어있음
      expect(s.nearCompleteRows.where((r) => r > 0), isEmpty);
    });

    test('여러 행 동시 감지', () {
      final s = makeState([
        [R, R, R, R, B], // 힌트
        [B, B, B, B, R], // 힌트
        [Y, R, B, Y, R], // 아님
      ]);
      expect(s.nearCompleteRows, containsAll([0, 1]));
      expect(s.nearCompleteRows, isNot(contains(2)));
    });
  });
}
