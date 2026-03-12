import 'dart:math';

/// 블록 색상 (3색 기본, 난이도에 따라 확장)
enum BlockColor {
  red,
  blue,
  yellow,
  green, // 난이도 4+
}

/// 그리드 위의 한 칸
class Cell {
  final BlockColor color;
  final int id;

  const Cell({required this.color, required this.id});

  Cell copyWith({BlockColor? color}) {
    return Cell(color: color ?? this.color, id: id);
  }

  @override
  String toString() => '${color.name[0].toUpperCase()}$id';

  @override
  bool operator ==(Object other) =>
      other is Cell && other.color == color && other.id == id;

  @override
  int get hashCode => Object.hash(color, id);
}

/// 게임 전체 상태 (불변)
class GameState {
  static const int cols = 5;
  static const int rows = 7; // 플레이 영역 + 버퍼
  static const int maxVisibleRows = 6; // row index 6에 블록 있으면 게임오버

  final List<List<Cell?>> grid; // grid[row][col], row 0 = 바닥
  final int score;
  final int bestScore;
  final int moves;
  final int combo;
  final int colorCount;
  final bool isGameOver;
  final int addRowEvery;
  final int nextId;
  final int timeBonus; // 줄 클리어 시 보너스 시간 (초)

  const GameState({
    required this.grid,
    this.score = 0,
    this.bestScore = 0,
    this.moves = 0,
    this.combo = 0,
    this.colorCount = 3,
    this.isGameOver = false,
    this.addRowEvery = 3,
    this.nextId = 0,
    this.timeBonus = 0,
  });

  /// 새 게임 (랜덤)
  factory GameState.newGame({int colorCount = 3, int bestScore = 0}) {
    final random = Random();
    final colors = BlockColor.values.sublist(0, colorCount);
    var id = 0;

    final grid = List.generate(rows, (row) {
      if (row < 3) {
        return List<Cell?>.generate(cols, (col) {
          return Cell(color: colors[random.nextInt(colorCount)], id: id++);
        });
      }
      return List<Cell?>.filled(cols, null);
    });

    return GameState(
      grid: grid,
      colorCount: colorCount,
      bestScore: bestScore,
      nextId: id,
    );
  }

  /// 테스트용: 지정된 그리드로 생성
  factory GameState.fromGrid(
    List<List<BlockColor?>> colorGrid, {
    int colorCount = 3,
    int score = 0,
    int moves = 0,
    int addRowEvery = 3,
  }) {
    var id = 0;
    // colorGrid[0] = 바닥 줄
    final grid = List.generate(rows, (row) {
      if (row < colorGrid.length) {
        return List<Cell?>.generate(cols, (col) {
          if (col < colorGrid[row].length && colorGrid[row][col] != null) {
            return Cell(color: colorGrid[row][col]!, id: id++);
          }
          return null;
        });
      }
      return List<Cell?>.filled(cols, null);
    });

    return GameState(
      grid: grid,
      colorCount: colorCount,
      score: score,
      moves: moves,
      addRowEvery: addRowEvery,
      nextId: id,
    );
  }

  /// 블록 탭: 인접 4방향 블록의 색을 다음 색으로 순환
  GameState tap(int row, int col) {
    if (isGameOver) return this;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return this;
    if (grid[row][col] == null) return this;

    final colors = BlockColor.values.sublist(0, colorCount);
    final newGrid = _copyGrid();

    const directions = [
      [0, 1],  // 오른쪽
      [0, -1], // 왼쪽
      [1, 0],  // 위
      [-1, 0], // 아래
    ];

    for (final dir in directions) {
      final nr = row + dir[0];
      final nc = col + dir[1];
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && newGrid[nr][nc] != null) {
        final currentColor = newGrid[nr][nc]!.color;
        final currentIndex = colors.indexOf(currentColor);
        final nextIndex = (currentIndex + 1) % colorCount;
        newGrid[nr][nc] = newGrid[nr][nc]!.copyWith(color: colors[nextIndex]);
      }
    }

    final newMoves = moves + 1;

    var state = GameState(
      grid: newGrid,
      score: score,
      bestScore: bestScore,
      moves: newMoves,
      combo: 0,
      colorCount: colorCount,
      addRowEvery: addRowEvery,
      nextId: nextId,
      timeBonus: 0,
    );

    // 줄 클리어 + 연쇄
    state = state._checkAndClearLines();

    // N턴마다 새 줄 추가
    if (newMoves % addRowEvery == 0) {
      state = state._addNewRow();
    }

    // 게임오버 체크
    state = state._checkGameOver();

    return state;
  }

  /// 가로 줄 클리어 체크
  GameState _checkAndClearLines() {
    final newGrid = _copyGrid();
    var linesCleared = 0;

    // 가로 줄 체크: 해당 row의 cols개가 전부 non-null이고 같은 색
    for (int r = 0; r < rows; r++) {
      if (_isFullRow(newGrid, r)) {
        final firstColor = newGrid[r][0]!.color;
        if (newGrid[r].every((c) => c != null && c.color == firstColor)) {
          for (int c = 0; c < cols; c++) {
            newGrid[r][c] = null;
          }
          linesCleared++;
        }
      }
    }

    if (linesCleared == 0) return this;

    final newCombo = combo + 1;
    final points = linesCleared * 100 * newCombo;

    // 콤보에 따른 시간 보너스 계산
    int bonus;
    if (newCombo >= 3) {
      bonus = 7;
    } else if (newCombo == 2) {
      bonus = 5;
    } else {
      bonus = 3;
    }

    // 중력
    _applyGravity(newGrid);

    var state = GameState(
      grid: newGrid,
      score: score + points,
      bestScore: max(bestScore, score + points),
      moves: moves,
      combo: newCombo,
      colorCount: colorCount,
      addRowEvery: addRowEvery,
      nextId: nextId,
      timeBonus: timeBonus + bonus,
    );

    // 연쇄 체크 (중력 후 새 줄이 완성될 수 있음)
    return state._checkAndClearLines();
  }

  /// row가 전부 non-null인지
  static bool _isFullRow(List<List<Cell?>> grid, int r) {
    for (int c = 0; c < cols; c++) {
      if (grid[r][c] == null) return false;
    }
    return true;
  }

  /// 중력: 빈 칸 위의 블록을 아래로
  static void _applyGravity(List<List<Cell?>> grid) {
    for (int c = 0; c < cols; c++) {
      int writePos = 0;
      for (int r = 0; r < rows; r++) {
        if (grid[r][c] != null) {
          if (writePos != r) {
            grid[writePos][c] = grid[r][c];
            grid[r][c] = null;
          }
          writePos++;
        }
      }
    }
  }

  /// 바닥에 새 줄 추가
  GameState _addNewRow({Random? random}) {
    final rng = random ?? Random();
    final colors = BlockColor.values.sublist(0, colorCount);
    final newGrid = _copyGrid();
    var id = nextId;

    // 모든 블록 1줄 위로
    for (int r = rows - 1; r > 0; r--) {
      for (int c = 0; c < cols; c++) {
        newGrid[r][c] = newGrid[r - 1][c];
      }
    }

    // 바닥(row 0)에 새 줄
    for (int c = 0; c < cols; c++) {
      newGrid[0][c] = Cell(
        color: colors[rng.nextInt(colorCount)],
        id: id++,
      );
    }

    return GameState(
      grid: newGrid,
      score: score,
      bestScore: bestScore,
      moves: moves,
      combo: combo,
      colorCount: colorCount,
      addRowEvery: addRowEvery,
      nextId: id,
      timeBonus: timeBonus,
    );
  }

  /// 게임오버 체크
  GameState _checkGameOver() {
    for (int c = 0; c < cols; c++) {
      if (grid[maxVisibleRows][c] != null) {
        return GameState(
          grid: grid,
          score: score,
          bestScore: max(bestScore, score),
          moves: moves,
          combo: combo,
          colorCount: colorCount,
          isGameOver: true,
          addRowEvery: addRowEvery,
          nextId: nextId,
          timeBonus: timeBonus,
        );
      }
    }
    return this;
  }

  List<List<Cell?>> _copyGrid() {
    return grid.map((row) => List<Cell?>.from(row)).toList();
  }

  bool hasBlock(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return false;
    return grid[row][col] != null;
  }

  /// 특정 셀의 색상 (테스트 헬퍼)
  BlockColor? colorAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return grid[row][col]?.color;
  }

  /// 이어하기: 게임오버 상태에서 맨 윗줄(maxVisibleRows) 블록 제거 + isGameOver 해제
  GameState revive() {
    if (!isGameOver) return this;

    final newGrid = _copyGrid();

    // maxVisibleRows(인덱스 6) 줄의 블록 제거
    for (int c = 0; c < cols; c++) {
      newGrid[maxVisibleRows][c] = null;
    }

    // 중력 적용
    _applyGravity(newGrid);

    return GameState(
      grid: newGrid,
      score: score,
      bestScore: bestScore,
      moves: moves,
      combo: 0,
      colorCount: colorCount,
      isGameOver: false,
      addRowEvery: addRowEvery,
      nextId: nextId,
      timeBonus: 0,
    );
  }

  /// 점수를 변경한 새 GameState 반환
  GameState withScore(int newScore) => GameState(
        grid: grid,
        score: newScore,
        bestScore: max(bestScore, newScore),
        moves: moves,
        combo: combo,
        colorCount: colorCount,
        isGameOver: isGameOver,
        addRowEvery: addRowEvery,
        nextId: nextId,
      );

  int get highestRow {
    for (int r = rows - 1; r >= 0; r--) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] != null) return r;
      }
    }
    return -1;
  }
}
