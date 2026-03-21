import 'dart:math';

/// 블록 색상 (3색 기본, 난이도에 따라 확장)
enum BlockColor {
  red,
  blue,
  yellow,
  green, // 난이도 4+
}

/// 특수 블록 타입
enum BlockType {
  normal,   // 기본 블록
  locked,   // 잠금 블록 (2회 탭해야 변환)
  bomb,     // 폭탄 블록 (클리어 시 주변 3×3 제거)
  rainbow,  // 무지개 블록 (모든 색과 매칭)
  ice,      // 얼음 블록 (인접 탭에 영향 안 받음, 직접 탭해야)
}

/// 그리드 위의 한 칸
class Cell {
  final BlockColor color;
  final int id;
  final BlockType type;
  final int hitCount; // locked 블록용 (0→1→변환)

  const Cell({
    required this.color,
    required this.id,
    this.type = BlockType.normal,
    this.hitCount = 0,
  });

  Cell copyWith({BlockColor? color, BlockType? type, int? hitCount}) {
    return Cell(
      color: color ?? this.color,
      id: id,
      type: type ?? this.type,
      hitCount: hitCount ?? this.hitCount,
    );
  }

  @override
  String toString() => '${color.name[0].toUpperCase()}$id';

  @override
  bool operator ==(Object other) =>
      other is Cell &&
      other.color == color &&
      other.id == id &&
      other.type == type &&
      other.hitCount == hitCount;

  @override
  int get hashCode => Object.hash(color, id, type, hitCount);
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
  final bool autoDifficulty; // Progressive 난이도 자동 적용 여부

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
    this.autoDifficulty = false,
  });

  /// 새 게임 (랜덤) — 2색 입문 모드로 시작
  factory GameState.newGame({int colorCount = 2, int bestScore = 0}) {
    final random = Random();
    final colors = BlockColor.values.sublist(0, colorCount);
    var id = 0;

    final grid = List.generate(rows, (row) {
      if (row == 0) {
        // 하단 첫 줄: 4/5칸 같은 색 (1탭 클리어 가능)
        final mainColor = colors[random.nextInt(colorCount)];
        final oddCol = random.nextInt(cols);
        return List<Cell?>.generate(cols, (col) {
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
      autoDifficulty: true,
      addRowEvery: 5, // Phase A: 5턴마다
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

  /// 테스트용: Cell 객체를 직접 지정하여 생성
  factory GameState.fromCellGrid(
    List<List<Cell?>> cellGrid, {
    int colorCount = 3,
    int score = 0,
    int moves = 0,
    int addRowEvery = 3,
  }) {
    var maxId = 0;
    for (final row in cellGrid) {
      for (final cell in row) {
        if (cell != null && cell.id >= maxId) {
          maxId = cell.id + 1;
        }
      }
    }

    final grid = List.generate(rows, (row) {
      if (row < cellGrid.length) {
        return List<Cell?>.generate(cols, (col) {
          if (col < cellGrid[row].length) {
            return cellGrid[row][col];
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
      nextId: maxId,
    );
  }

  /// 블록 탭: 인접 4방향 블록의 색을 다음 색으로 순환
  GameState tap(int row, int col) {
    if (isGameOver) return this;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return this;
    if (grid[row][col] == null) return this;

    final colors = BlockColor.values.sublist(0, colorCount);
    final newGrid = _copyGrid();
    final tappedCell = newGrid[row][col]!;

    // locked 블록 직접 탭 처리
    if (tappedCell.type == BlockType.locked) {
      final newHit = tappedCell.hitCount + 1;
      if (newHit >= 2) {
        // normal로 전환 + 색 변환
        final currentIndex = colors.indexOf(tappedCell.color);
        final nextIndex = (currentIndex + 1) % colorCount;
        newGrid[row][col] = tappedCell.copyWith(
          color: colors[nextIndex],
          type: BlockType.normal,
          hitCount: 0,
        );
      } else {
        // hitCount만 증가
        newGrid[row][col] = tappedCell.copyWith(hitCount: newHit);
      }
    }

    // ice 블록 직접 탭 처리: 자기 자신의 색 순환
    if (tappedCell.type == BlockType.ice) {
      final currentIndex = colors.indexOf(tappedCell.color);
      final nextIndex = (currentIndex + 1) % colorCount;
      newGrid[row][col] = tappedCell.copyWith(color: colors[nextIndex]);
    }

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
        final neighbor = newGrid[nr][nc]!;

        // ice 블록은 인접 탭에 영향 안 받음
        if (neighbor.type == BlockType.ice) continue;

        // locked 블록은 인접 탭으로 hitCount+1만 (색 변환 안 됨)
        if (neighbor.type == BlockType.locked) {
          newGrid[nr][nc] = neighbor.copyWith(hitCount: neighbor.hitCount + 1);
          continue;
        }

        final currentColor = neighbor.color;
        final currentIndex = colors.indexOf(currentColor);
        final nextIndex = (currentIndex + 1) % colorCount;
        newGrid[nr][nc] = neighbor.copyWith(color: colors[nextIndex]);
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
      autoDifficulty: autoDifficulty,
    );

    // 줄 클리어 + 연쇄
    state = state._checkAndClearLines();

    // Progressive 난이도 적용
    if (autoDifficulty) {
      state = state._applyDifficulty();
    }

    // N턴마다 새 줄 추가
    if (newMoves % state.addRowEvery == 0) {
      state = state._addNewRow();
    }

    // 게임오버 체크
    state = state._checkGameOver();

    return state;
  }

  /// 두 셀이 매칭되는지 확인 (rainbow는 와일드카드)
  static bool _colorsMatch(Cell a, Cell b) {
    if (a.type == BlockType.rainbow || b.type == BlockType.rainbow) return true;
    return a.color == b.color;
  }

  /// 가로 + 세로 줄 클리어 체크
  GameState _checkAndClearLines() {
    final newGrid = _copyGrid();
    var linesCleared = 0;

    // 클리어 대상 셀을 수집 (겹치는 셀은 한 번만 제거)
    final toClear = <(int, int)>{};

    // 가로 줄 체크: 각 row에서 연속 3개 이상 같은 색 (rainbow는 와일드카드)
    for (int r = 0; r < rows; r++) {
      int runStart = -1;
      int runLength = 0;

      for (int c = 0; c < cols; c++) {
        final cell = newGrid[r][c];
        if (cell != null && runStart >= 0 && runLength > 0) {
          final prevCell = newGrid[r][c - 1]!;
          if (_colorsMatch(cell, prevCell)) {
            runLength++;
          } else {
            if (runLength >= 3) {
              for (int i = runStart; i < runStart + runLength; i++) {
                toClear.add((r, i));
              }
              linesCleared++;
            }
            runStart = c;
            runLength = 1;
          }
        } else if (cell != null) {
          runStart = c;
          runLength = 1;
        } else {
          if (runLength >= 3) {
            for (int i = runStart; i < runStart + runLength; i++) {
              toClear.add((r, i));
            }
            linesCleared++;
          }
          runStart = -1;
          runLength = 0;
        }
      }
      if (runLength >= 3) {
        for (int i = runStart; i < runStart + runLength; i++) {
          toClear.add((r, i));
        }
        linesCleared++;
      }
    }

    // 세로 줄 체크: 각 column에서 연속 3개 이상 같은 색 (rainbow는 와일드카드)
    for (int c = 0; c < cols; c++) {
      int runStart = -1;
      int runLength = 0;

      for (int r = 0; r < rows; r++) {
        final cell = newGrid[r][c];
        if (cell != null && runStart >= 0 && runLength > 0) {
          final prevCell = newGrid[r - 1][c]!;
          if (_colorsMatch(cell, prevCell)) {
            runLength++;
          } else {
            if (runLength >= 3) {
              for (int i = runStart; i < runStart + runLength; i++) {
                toClear.add((i, c));
              }
              linesCleared++;
            }
            runStart = r;
            runLength = 1;
          }
        } else if (cell != null) {
          runStart = r;
          runLength = 1;
        } else {
          if (runLength >= 3) {
            for (int i = runStart; i < runStart + runLength; i++) {
              toClear.add((i, c));
            }
            linesCleared++;
          }
          runStart = -1;
          runLength = 0;
        }
      }
      // 마지막 run 체크
      if (runLength >= 3) {
        for (int i = runStart; i < runStart + runLength; i++) {
          toClear.add((i, c));
        }
        linesCleared++;
      }
    }

    if (linesCleared == 0) return this;

    // bomb 블록: 클리어 대상에 bomb이 있으면 3×3 범위 추가 제거
    final bombExplosions = <(int, int)>{};
    for (final (r, c) in toClear) {
      if (newGrid[r][c] != null && newGrid[r][c]!.type == BlockType.bomb) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = r + dr;
            final nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && newGrid[nr][nc] != null) {
              bombExplosions.add((nr, nc));
            }
          }
        }
      }
    }
    toClear.addAll(bombExplosions);

    // 클리어 대상 셀 제거
    for (final (r, c) in toClear) {
      newGrid[r][c] = null;
    }

    final newCombo = combo + 1;
    final points = linesCleared * 100 * newCombo;

    // 콤보에 따른 시간 보너스 계산 (상향)
    int bonus;
    if (newCombo >= 5) {
      bonus = 12;
    } else if (newCombo >= 3) {
      bonus = 8;
    } else if (newCombo == 2) {
      bonus = 5;
    } else {
      bonus = 3;
    }
    // 줄 클리어 기본 보너스 (콤보와 별개)
    bonus += linesCleared * 2;

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
      autoDifficulty: autoDifficulty,
    );

    // 연쇄 체크 (중력 후 새 줄이 완성될 수 있음)
    return state._checkAndClearLines();
  }

  /// 점수에 따른 난이도 조정 (Phase A~D 곡선)
  GameState _applyDifficulty() {
    int newColorCount;
    int newAddRowEvery;

    if (score >= 1500) {
      // Phase D: 하드코어
      newColorCount = 4;
      newAddRowEvery = 2;
    } else if (score >= 700) {
      // Phase C: 도전
      newColorCount = 3;
      newAddRowEvery = 3;
    } else if (score >= 300) {
      // Phase B: 중급
      newColorCount = 3;
      newAddRowEvery = 4;
    } else {
      // Phase A: 입문 (2색만! 쉽게 시작)
      newColorCount = 2;
      newAddRowEvery = 5;
    }

    if (newColorCount == colorCount && newAddRowEvery == addRowEvery) {
      return this;
    }

    return GameState(
      grid: grid,
      score: score,
      bestScore: bestScore,
      moves: moves,
      combo: combo,
      colorCount: newColorCount,
      addRowEvery: newAddRowEvery,
      nextId: nextId,
      timeBonus: timeBonus,
      autoDifficulty: autoDifficulty,
    );
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
    // ~15% 확률로 거의 완성된 줄 생성
    if (rng.nextDouble() < 0.15) {
      final mainColor = colors[rng.nextInt(colorCount)];
      final oddCol = rng.nextInt(cols);
      for (int c = 0; c < cols; c++) {
        if (c == oddCol) {
          // 다른 색 선택
          BlockColor otherColor;
          do {
            otherColor = colors[rng.nextInt(colorCount)];
          } while (otherColor == mainColor);
          newGrid[0][c] = Cell(color: otherColor, id: id++);
        } else {
          newGrid[0][c] = Cell(color: mainColor, id: id++);
        }
      }
    } else {
      // 기존 로직: 완전 랜덤
      for (int c = 0; c < cols; c++) {
        newGrid[0][c] = Cell(
          color: colors[rng.nextInt(colorCount)],
          id: id++,
        );
      }
    }

    // score >= 3000일 때 10% 확률로 특수 블록 1개 배치
    if (score >= 3000 && rng.nextDouble() < 0.10) {
      final specialCol = rng.nextInt(cols);
      final roll = rng.nextDouble();
      BlockType specialType;
      if (roll < 0.40) {
        specialType = BlockType.locked;
      } else if (roll < 0.65) {
        specialType = BlockType.bomb;
      } else if (roll < 0.80) {
        specialType = BlockType.rainbow;
      } else {
        specialType = BlockType.ice;
      }
      newGrid[0][specialCol] = newGrid[0][specialCol]!.copyWith(type: specialType);
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
      autoDifficulty: autoDifficulty,
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
          autoDifficulty: autoDifficulty,
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

  /// 특정 셀의 블록 타입 (테스트 헬퍼)
  BlockType? typeAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return grid[row][col]?.type;
  }

  /// 특정 셀의 hitCount (테스트 헬퍼)
  int? hitCountAt(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return grid[row][col]?.hitCount;
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
      autoDifficulty: autoDifficulty,
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
        autoDifficulty: autoDifficulty,
      );

  /// 게임 오버 상태 변경 (타임 보너스 등에서 사용)
  GameState withGameOver(bool gameOver) => GameState(
        grid: grid,
        score: score,
        bestScore: bestScore,
        moves: moves,
        combo: 0,
        colorCount: colorCount,
        isGameOver: gameOver,
        addRowEvery: addRowEvery,
        nextId: nextId,
        autoDifficulty: autoDifficulty,
      );

  int get highestRow {
    for (int r = rows - 1; r >= 0; r--) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] != null) return r;
      }
    }
    return -1;
  }

  /// 거의 완성된 가로 줄 감지 (연속 4개 이상 같은 색 + 1칸만 다름)
  /// UI에서 힌트 하이라이트에 사용
  List<int> get nearCompleteRows {
    final result = <int>[];
    for (int r = 0; r < maxVisibleRows; r++) {
      // 해당 행의 non-null 셀 색상 카운트
      final colorCounts = <BlockColor, int>{};
      int nonNull = 0;
      for (int c = 0; c < cols; c++) {
        final cell = grid[r][c];
        if (cell != null) {
          nonNull++;
          colorCounts[cell.color] = (colorCounts[cell.color] ?? 0) + 1;
        }
      }
      // 행에 블록이 4개 이상이고, 최다 색상이 (전체-1)개 이상이면 힌트
      if (nonNull >= 4) {
        final maxCount = colorCounts.values.fold(0, max);
        if (maxCount >= nonNull - 1 && maxCount >= 4) {
          result.add(r);
        }
      }
    }
    return result;
  }
}
