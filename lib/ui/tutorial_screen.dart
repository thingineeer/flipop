import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/secure_storage_service.dart';

/// 3개 미니 퍼즐로 게임 메커닉을 학습하는 튜토리얼 화면
class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({super.key, required this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPuzzle = 0;
  bool _puzzleCleared = false;

  late GameState _state;
  late GameState _initialState;

  @override
  void initState() {
    super.initState();
    _loadPuzzle(0);
  }

  void _loadPuzzle(int index) {
    setState(() {
      _currentPuzzle = index;
      _puzzleCleared = false;
      _state = _buildPuzzle(index);
      _initialState = _state;
    });
  }

  /// 각 퍼즐의 고정 그리드 생성 (GameState.fromGrid 활용)
  GameState _buildPuzzle(int index) {
    switch (index) {
      case 0:
        // 퍼즐1 "탭의 효과": 3x3 그리드
        // 가운데 탭하면 상하좌우가 변하는 걸 확인
        return GameState.fromGrid(
          [
            // row 0 (바닥)
            [BlockColor.red, BlockColor.blue, BlockColor.red, null, null],
            // row 1
            [BlockColor.yellow, BlockColor.red, BlockColor.blue, null, null],
            // row 2
            [BlockColor.blue, BlockColor.yellow, BlockColor.yellow, null, null],
          ],
          colorCount: 3,
          addRowEvery: 999,
        );
      case 1:
        // 퍼즐2 "줄 맞추기": 5x2 그리드
        // row 0: 4칸 blue + 1칸 red → 탭으로 줄 완성 가능
        return GameState.fromGrid(
          [
            // row 0 (바닥): blue blue blue red blue → (1,3) 탭하면 red→blue
            [BlockColor.blue, BlockColor.blue, BlockColor.blue, BlockColor.red, BlockColor.blue],
            // row 1: 랜덤 색
            [BlockColor.red, BlockColor.yellow, BlockColor.blue, BlockColor.yellow, BlockColor.red],
          ],
          colorCount: 3,
          addRowEvery: 999,
        );
      case 2:
        // 퍼즐3 "콤보": 5x3 그리드
        // 한 줄 클리어 후 중력으로 또 다른 줄이 완성되는 구조
        return GameState.fromGrid(
          [
            // row 0 (바닥): red red red yellow red
            [BlockColor.red, BlockColor.red, BlockColor.red, BlockColor.yellow, BlockColor.red],
            // row 1: blue blue blue blue blue → 이미 완성! 탭으로 row0 먼저 클리어 → 중력 → row1 클리어
            [BlockColor.blue, BlockColor.blue, BlockColor.blue, BlockColor.blue, BlockColor.blue],
            // row 2: red yellow red blue yellow
            [BlockColor.red, BlockColor.yellow, BlockColor.red, BlockColor.blue, BlockColor.yellow],
          ],
          colorCount: 3,
          addRowEvery: 999,
        );
      default:
        return GameState.fromGrid(
          [
            [BlockColor.red, BlockColor.blue, BlockColor.red, null, null],
          ],
          colorCount: 3,
          addRowEvery: 999,
        );
    }
  }

  void _onTap(int row, int col) {
    if (_puzzleCleared) return;

    HapticFeedback.lightImpact();

    final newState = _state.tap(row, col);

    // 퍼즐 클리어 판정: 블록 수가 줄었으면 줄 클리어 발생
    final oldBlockCount = _countBlocks(_state);
    final newBlockCount = _countBlocks(newState);
    final cleared = newBlockCount < oldBlockCount;

    setState(() {
      _state = newState;
      if (cleared) {
        _puzzleCleared = true;
      }
    });

    if (_puzzleCleared) {
      HapticFeedback.mediumImpact();
      // 자동 전환 딜레이
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_currentPuzzle < 2) {
          _loadPuzzle(_currentPuzzle + 1);
        } else {
          _completeTutorial();
        }
      });
    }
  }

  int _countBlocks(GameState state) {
    int count = 0;
    for (int r = 0; r < GameState.rows; r++) {
      for (int c = 0; c < GameState.cols; c++) {
        if (state.grid[r][c] != null) count++;
      }
    }
    return count;
  }

  void _resetPuzzle() {
    setState(() {
      _state = _initialState;
      _puzzleCleared = false;
    });
  }

  Future<void> _completeTutorial() async {
    await SecureStorageService().setSeenOnboarding();
    if (mounted) {
      widget.onComplete();
    }
  }

  void _skip() {
    _completeTutorial();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.tutorialPuzzleTapTitle,
      l10n.tutorialPuzzleLineTitle,
      l10n.tutorialPuzzleComboTitle,
    ];
    final descriptions = [
      l10n.tutorialPuzzleTapDesc,
      l10n.tutorialPuzzleLineDesc,
      l10n.tutorialPuzzleComboDesc,
    ];
    final successMessages = [
      l10n.tutorialPuzzleTapSuccess,
      l10n.tutorialPuzzleLineSuccess,
      l10n.tutorialPuzzleComboSuccess,
    ];

    // 퍼즐별 그리드 크기
    final puzzleCols = [3, 5, 5];
    final puzzleRows = [3, 2, 3];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // 상단: 진행 표시 + 스킵
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // 단계 인디케이터
                    Expanded(
                      child: Row(
                        children: List.generate(3, (i) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: i <= _currentPuzzle
                                    ? GameColors.blockColors[BlockColor.blue]
                                    : GameColors.gridLine,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 스킵 버튼
                    GestureDetector(
                      onTap: _skip,
                      child: Text(
                        l10n.labelSkip,
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 퍼즐 번호 + 제목
              Text(
                '${_currentPuzzle + 1}/3',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titles[_currentPuzzle],
                style: const TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _puzzleCleared
                    ? successMessages[_currentPuzzle]
                    : descriptions[_currentPuzzle],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _puzzleCleared
                      ? GameColors.blockColors[BlockColor.blue]
                      : GameColors.textSecondary,
                  fontSize: 15,
                  fontWeight: _puzzleCleared ? FontWeight.w700 : FontWeight.w500,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // 미니 그리드
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = puzzleCols[_currentPuzzle];
                      final rows = puzzleRows[_currentPuzzle];
                      const gap = 4.0;
                      final cellSize =
                          ((constraints.maxWidth - (cols - 1) * gap) / cols)
                              .floorToDouble()
                              .clamp(0.0, 64.0);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GameColors.gridBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _puzzleCleared
                                ? GameColors.blockColors[BlockColor.blue]!
                                : GameColors.gridLine,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int displayRow = rows - 1;
                                displayRow >= 0;
                                displayRow--)
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: displayRow > 0 ? gap : 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int col = 0; col < cols; col++)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: col < cols - 1 ? gap : 0),
                                        child: _buildPuzzleCell(
                                          displayRow,
                                          col,
                                          cellSize,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 리셋 버튼
              if (!_puzzleCleared)
                GestureDetector(
                  onTap: _resetPuzzle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: GameColors.gridBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 16,
                          color: GameColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.labelReset,
                          style: TextStyle(
                            color: GameColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleCell(int row, int col, double cellSize) {
    final cell = _state.grid[row][col];
    if (cell == null) {
      return SizedBox(width: cellSize, height: cellSize);
    }

    final color = GameColors.blockColors[cell.color]!;
    final darkColor = GameColors.blockDarkColors[cell.color]!;
    final imagePath = GameColors.blockImages[cell.color]!;

    return GestureDetector(
      onTap: () => _onTap(row, col),
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(cellSize * 0.2),
          boxShadow: [
            BoxShadow(
              color: darkColor.withValues(alpha: 0.4),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cellSize * 0.2),
          child: Padding(
            padding: EdgeInsets.all(cellSize * 0.08),
            child: Image.asset(
              imagePath,
              width: cellSize * 0.84,
              height: cellSize * 0.84,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
