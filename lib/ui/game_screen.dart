import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';
import 'block_widget.dart';
import 'game_over_overlay.dart';
import 'leaderboard_screen.dart';
import 'onboarding_overlay.dart';
import 'pop_particle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameState _state;
  int _bestScore = 0;
  bool _showOnboarding = true;

  // 파티클 이펙트
  final List<_ParticleData> _activeParticles = [];
  int _particleIdCounter = 0;

  // 콤보 쉐이크
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  // 그리드 레이아웃 정보 (파티클 위치 계산용)
  double _cellSize = 0;
  double _gap = 0;
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _state = GameState.newGame(colorCount: 3, bestScore: _bestScore);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController?.dispose();
    super.dispose();
  }

  void _onTap(int row, int col) {
    if (_state.isGameOver) return;

    HapticFeedback.lightImpact();

    final oldGrid = _state.grid;
    final oldScore = _state.score;
    final newState = _state.tap(row, col);

    // 사라진 블록 찾기 (oldGrid에는 있었는데 newGrid에는 없는 id)
    final oldIds = <int, _BlockInfo>{};
    for (int r = 0; r < GameState.rows; r++) {
      for (int c = 0; c < GameState.cols; c++) {
        final cell = oldGrid[r][c];
        if (cell != null) {
          oldIds[cell.id] = _BlockInfo(row: r, col: c, color: cell.color);
        }
      }
    }
    final newIds = <int>{};
    for (int r = 0; r < GameState.rows; r++) {
      for (int c = 0; c < GameState.cols; c++) {
        final cell = newState.grid[r][c];
        if (cell != null) newIds.add(cell.id);
      }
    }

    // 사라진 블록들에 파티클 생성
    final disappeared = oldIds.keys.where((id) => !newIds.contains(id)).toList();
    if (disappeared.isNotEmpty) {
      _spawnParticles(disappeared, oldIds);
    }

    setState(() {
      _state = newState;

      if (_state.score > oldScore) {
        final newCombo = _state.combo;
        if (newCombo >= 3) {
          HapticFeedback.heavyImpact();
          _triggerShake();
        } else if (newCombo >= 2) {
          HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
        } else {
          HapticFeedback.mediumImpact();
        }
      }

      if (_state.score > _bestScore) {
        _bestScore = _state.score;
      }

      if (_state.isGameOver) {
        HapticFeedback.heavyImpact();
        _submitScore();
      }
    });
  }

  void _spawnParticles(List<int> disappearedIds, Map<int, _BlockInfo> blockInfoMap) {
    for (final id in disappearedIds) {
      final info = blockInfoMap[id]!;
      if (info.row >= GameState.maxVisibleRows) continue; // 보이지 않는 영역

      final color = GameColors.blockColors[info.color]!;
      final particleId = _particleIdCounter++;

      setState(() {
        _activeParticles.add(_ParticleData(
          id: particleId,
          row: info.row,
          col: info.col,
          color: color,
        ));
      });
    }
  }

  void _removeParticle(int id) {
    setState(() {
      _activeParticles.removeWhere((p) => p.id == id);
    });
  }

  void _triggerShake() {
    _shakeController?.reset();
    _shakeController?.forward();
  }

  void _restart() {
    setState(() {
      _state = GameState.newGame(colorCount: 3, bestScore: _bestScore);
      _activeParticles.clear();
    });
  }

  Future<void> _submitScore() async {
    final auth = AuthService();
    if (!auth.isSignedIn || auth.nickname == null) return;

    try {
      await LeaderboardService().submitScore(
        uid: auth.currentUser!.uid,
        nickname: auth.nickname!,
        avatarId: auth.avatarId ?? 'cat',
        score: _state.score,
      );
    } catch (_) {
      // 순위 제출 실패는 조용히 무시
    }
  }

  void _openLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
  }

  void _dismissOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _shakeAnimation!,
              builder: (context, child) {
                final shakeOffset = _shakeController!.isAnimating
                    ? (1 - _shakeAnimation!.value) * 3 * (_shakeAnimation!.value > 0.5 ? 1 : -1)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: child,
                );
              },
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildTurnIndicator(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final gridContainerPadding = 8.0 * 2;
                            final gridBorder = 2.0 * 2;
                            _gap = 4.0;
                            final availableWidth =
                                constraints.maxWidth - gridContainerPadding - gridBorder;
                            _cellSize =
                                ((availableWidth - (GameState.cols - 1) * _gap) / GameState.cols)
                                    .floorToDouble();
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildGrid(_cellSize, GameState.maxVisibleRows, _gap),
                                // 파티클 오버레이
                                ..._activeParticles.map((p) {
                                  final x = p.col * (_cellSize + _gap) + _cellSize / 2 + 10; // padding
                                  // 화면 row 변환: visibleRows-1 → 상단, 0 → 하단
                                  final displayRow = GameState.maxVisibleRows - 1 - p.row;
                                  final y = displayRow * (_cellSize + _gap) + _cellSize / 2 + 10 + 6; // padding + danger line
                                  return PopParticle(
                                    key: ValueKey('particle_${p.id}'),
                                    position: Offset(x, y),
                                    size: _cellSize,
                                    color: p.color,
                                    onComplete: () => _removeParticle(p.id),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '탭하면 주변 색이 바뀌어요! 한 줄을 같은 색으로 🎯',
                      style: TextStyle(
                        color: GameColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_state.isGameOver)
              GameOverOverlay(
                score: _state.score,
                bestScore: _bestScore,
                onRestart: _restart,
              ),

            if (_showOnboarding && !_state.isGameOver)
              OnboardingOverlay(onDismiss: _dismissOnboarding),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '${_state.score}',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                'FLIPOP',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: _openLeaderboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: GameColors.blockColors[BlockColor.yellow]!.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'RANKING',
                    style: TextStyle(
                      color: GameColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'BEST',
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$_bestScore',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator() {
    final remaining = _state.addRowEvery - (_state.moves % _state.addRowEvery);
    final progress = 1.0 - (remaining / _state.addRowEvery);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '새 줄까지 $remaining턴',
                style: TextStyle(
                  color: remaining <= 1
                      ? GameColors.blockColors[BlockColor.red]
                      : GameColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_state.combo > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: GameColors.blockColors[BlockColor.yellow],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'COMBO x${_state.combo}',
                    style: TextStyle(
                      color: GameColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: GameColors.gridLine,
              valueColor: AlwaysStoppedAnimation(
                remaining <= 1
                    ? GameColors.blockColors[BlockColor.red]!
                    : GameColors.blockColors[BlockColor.blue]!,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(double cellSize, int visibleRows, double gap) {
    return Container(
      key: _gridKey,
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.gridLine, width: 2),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 위험 라인
          Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: GameColors.blockColors[BlockColor.red]!.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // 그리드 (위에서 아래로: row 5→0)
          for (int displayRow = visibleRows - 1; displayRow >= 0; displayRow--)
            Padding(
              padding: EdgeInsets.only(bottom: displayRow > 0 ? gap : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int col = 0; col < GameState.cols; col++)
                    Padding(
                      padding: EdgeInsets.only(
                        right: col < GameState.cols - 1 ? gap : 0,
                      ),
                      child: _buildCell(displayRow, col, cellSize),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    final cell = _state.grid[row][col];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        // 사라질 때: 팽창 후 축소 (POP!)
        if (animation.status == AnimationStatus.reverse) {
          final popScale = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );
          return ScaleTransition(
            scale: popScale,
            child: FadeTransition(opacity: animation, child: child),
          );
        }
        // 나타날 때: 바운스
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: cell == null
          ? SizedBox(key: ValueKey('empty_${row}_$col'), width: cellSize, height: cellSize)
          : BlockWidget(
              key: ValueKey(cell.id),
              cell: cell,
              size: cellSize,
              onTap: () => _onTap(row, col),
            ),
    );
  }
}

class _BlockInfo {
  final int row;
  final int col;
  final BlockColor color;
  _BlockInfo({required this.row, required this.col, required this.color});
}

class _ParticleData {
  final int id;
  final int row;
  final int col;
  final Color color;
  _ParticleData({required this.id, required this.row, required this.col, required this.color});
}
