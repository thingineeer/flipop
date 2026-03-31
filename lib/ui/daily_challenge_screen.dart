import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/daily_challenge.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/secure_storage_service.dart';
import '../services/sound_service.dart';
import '../l10n/app_localizations.dart';
import 'block_widget.dart';
import 'pop_particle.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen>
    with TickerProviderStateMixin {
  late GameState _state;
  late ChallengeType _challengeType;

  // 타이머
  Timer? _gameTimer;
  int _remainingSeconds = 0;
  int _initialTime = 0;

  // limitedMoves
  int _remainingMoves = 20;

  // speedRun
  int _elapsedSeconds = 0;
  static const int _speedRunTarget = 500;

  // comboMaster
  int _comboScore = 0;

  // 게임 상태
  bool _waitingToStart = true;
  bool _isGameOver = false;
  int _finalScore = 0;

  // 시도 횟수
  int _attemptsUsed = 0;
  bool _canAttempt = true;

  // 파티클 이펙트
  final List<_ParticleData> _activeParticles = [];
  int _particleIdCounter = 0;

  // 콤보 쉐이크
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  // 그리드 레이아웃 정보
  double _cellSize = 0;
  double _gap = 0;

  @override
  void initState() {
    super.initState();
    _challengeType = DailyChallenge.todayType();
    _state = DailyChallenge.generateGrid(DailyChallenge.todaySeed());

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticIn),
    );

    _setupChallenge();
    _loadAttempts();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shakeController?.dispose();
    super.dispose();
  }

  void _setupChallenge() {
    switch (_challengeType) {
      case ChallengeType.timeAttack:
        _initialTime = 60;
        _remainingSeconds = 60;
      case ChallengeType.limitedMoves:
        _remainingMoves = 20;
        _initialTime = 0;
      case ChallengeType.comboMaster:
        _initialTime = 120;
        _remainingSeconds = 120;
        _comboScore = 0;
      case ChallengeType.speedRun:
        _elapsedSeconds = 0;
        _initialTime = 0;
      case ChallengeType.normal:
        _initialTime = 120;
        _remainingSeconds = 120;
    }
  }

  Future<void> _loadAttempts() async {
    final attempts = await SecureStorageService().getDailyChallengeAttempts();
    final canAttempt = await SecureStorageService().canAttemptDailyChallenge();
    if (mounted) {
      setState(() {
        _attemptsUsed = attempts;
        _canAttempt = canAttempt;
      });
    }
  }

  void _startGame() {
    if (!_canAttempt) return;

    AnalyticsService().logGameStart(
      mode: 'challenge_${_challengeType.name}',
      colors: _state.colorCount,
    );

    setState(() {
      _state = DailyChallenge.generateGrid(DailyChallenge.todaySeed());
      _waitingToStart = false;
      _isGameOver = false;
      _activeParticles.clear();
      _setupChallenge();
    });

    SecureStorageService().incrementDailyChallengeAttempts();
    _attemptsUsed++;
    _canAttempt = _attemptsUsed < 3;

    // 타이머 시작 (타이머 기반 모드)
    if (_challengeType == ChallengeType.timeAttack ||
        _challengeType == ChallengeType.comboMaster ||
        _challengeType == ChallengeType.normal) {
      _startCountdownTimer();
    }

    // speedRun: 경과 시간 측정
    if (_challengeType == ChallengeType.speedRun) {
      _startElapsedTimer();
    }
  }

  void _startCountdownTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isGameOver) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _endGame();
        }
      });
    });
  }

  void _startElapsedTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isGameOver) return;
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _endGame() {
    _gameTimer?.cancel();

    setState(() {
      _isGameOver = true;
      if (_challengeType == ChallengeType.comboMaster) {
        _finalScore = _comboScore;
      } else {
        _finalScore = _state.score;
      }
    });

    HapticFeedback.heavyImpact();
    SoundService().playSE('gameover');

    AnalyticsService().logChallengeComplete(
      type: _challengeType.name,
      score: _finalScore,
    );
  }

  void _onTap(int row, int col) {
    if (_isGameOver || _waitingToStart) return;

    // limitedMoves: 터치 제한 체크
    if (_challengeType == ChallengeType.limitedMoves && _remainingMoves <= 0) {
      return;
    }

    HapticFeedback.lightImpact();
    SoundService().playSE('tap');

    final oldGrid = _state.grid;
    final oldScore = _state.score;
    final newState = _state.tap(row, col);

    // 사라진 블록 찾기
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

    final disappeared =
        oldIds.keys.where((id) => !newIds.contains(id)).toList();
    if (disappeared.isNotEmpty) {
      _spawnParticles(disappeared, oldIds);
    }

    setState(() {
      _state = newState;

      // 타이머 기반 모드: 보너스 시간
      if (_state.timeBonus > 0 &&
          (_challengeType == ChallengeType.timeAttack ||
              _challengeType == ChallengeType.comboMaster ||
              _challengeType == ChallengeType.normal)) {
        _remainingSeconds += _state.timeBonus;
      }

      // comboMaster: 콤보 x3 이상만 점수
      if (_challengeType == ChallengeType.comboMaster) {
        if (_state.combo >= 3 && _state.score > oldScore) {
          _comboScore += _state.score - oldScore;
        }
      }

      // limitedMoves: 터치 카운트 감소
      if (_challengeType == ChallengeType.limitedMoves) {
        _remainingMoves--;
        if (_remainingMoves <= 0) {
          _remainingMoves = 0;
          _endGame();
          return;
        }
      }

      // 햅틱 + 사운드 피드백
      if (_state.score > oldScore) {
        final newCombo = _state.combo;
        if (newCombo >= 3) {
          HapticFeedback.heavyImpact();
          SoundService().playSE('combo3');
          _triggerShake();
        } else if (newCombo >= 2) {
          HapticFeedback.mediumImpact();
          SoundService().playSE('combo2');
        } else {
          HapticFeedback.mediumImpact();
          SoundService().playSE('pop');
        }
      }

      // speedRun: 목표 점수 도달 시 종료
      if (_challengeType == ChallengeType.speedRun &&
          _state.score >= _speedRunTarget) {
        _endGame();
        return;
      }

      // 게임오버 (그리드 오버플로)
      if (_state.isGameOver) {
        _endGame();
      }
    });
  }

  void _spawnParticles(
      List<int> disappearedIds, Map<int, _BlockInfo> blockInfoMap) {
    for (final id in disappearedIds) {
      final info = blockInfoMap[id]!;
      if (info.row >= GameState.maxVisibleRows) continue;

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

  void _dismissGameOver() {
    setState(() {
      _waitingToStart = true;
      _isGameOver = false;
    });
  }

  String _challengeTypeName(AppLocalizations l10n) {
    return switch (_challengeType) {
      ChallengeType.timeAttack => l10n.challengeTimeAttack,
      ChallengeType.limitedMoves => l10n.challengeLimitedMoves,
      ChallengeType.comboMaster => l10n.challengeComboMaster,
      ChallengeType.speedRun => l10n.challengeSpeedRun,
      ChallengeType.normal => l10n.challengeNormal,
    };
  }

  Color _challengeColor() {
    return switch (_challengeType) {
      ChallengeType.timeAttack => GameColors.blockColors[BlockColor.red]!,
      ChallengeType.limitedMoves => GameColors.blockColors[BlockColor.blue]!,
      ChallengeType.comboMaster => GameColors.blockColors[BlockColor.yellow]!,
      ChallengeType.speedRun => GameColors.blockColors[BlockColor.green]!,
      ChallengeType.normal => GameColors.blockColors[BlockColor.blue]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _shakeAnimation!,
                builder: (context, child) {
                  final shakeOffset = _shakeController!.isAnimating
                      ? (1 - _shakeAnimation!.value) *
                          3 *
                          (_shakeAnimation!.value > 0.5 ? 1 : -1)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(shakeOffset, 0),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    _buildHeader(l10n),
                    const SizedBox(height: 8),
                    _buildStatusBar(l10n),
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
                              final availableWidth = constraints.maxWidth -
                                  gridContainerPadding -
                                  gridBorder;
                              _cellSize = ((availableWidth -
                                          (GameState.cols - 1) * _gap) /
                                      GameState.cols)
                                  .floorToDouble();
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildGrid(
                                      _cellSize, GameState.maxVisibleRows, _gap),
                                  ..._activeParticles.map((p) {
                                    final x =
                                        p.col * (_cellSize + _gap) +
                                            _cellSize / 2 +
                                            10;
                                    final displayRow =
                                        GameState.maxVisibleRows - 1 - p.row;
                                    final y =
                                        displayRow * (_cellSize + _gap) +
                                            _cellSize / 2 +
                                            10 +
                                            6;
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // 게임 오버 오버레이
              if (_isGameOver) _buildGameOverOverlay(l10n),

              // 시작 대기 화면
              if (_waitingToStart) _buildStartOverlay(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final displayScore = _challengeType == ChallengeType.comboMaster
        ? _comboScore
        : _state.score;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scoreLabel,
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '$displayScore',
                  style: TextStyle(
                    color: GameColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // 챌린지 타입 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _challengeColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _challengeTypeName(l10n),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 콤보 표시
          if (_state.combo > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GameColors.blockColors[BlockColor.yellow],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x${_state.combo}',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(AppLocalizations l10n) {
    // 타이머 기반 모드
    if (_challengeType == ChallengeType.timeAttack ||
        _challengeType == ChallengeType.comboMaster ||
        _challengeType == ChallengeType.normal) {
      return _buildTimerBar();
    }

    // limitedMoves: 남은 터치 표시
    if (_challengeType == ChallengeType.limitedMoves) {
      return _buildMovesBar(l10n);
    }

    // speedRun: 경과 시간 + 목표 점수
    if (_challengeType == ChallengeType.speedRun) {
      return _buildSpeedRunBar(l10n);
    }

    return const SizedBox.shrink();
  }

  Widget _buildTimerBar() {
    final progress =
        _initialTime > 0 ? _remainingSeconds / _initialTime : 0.0;
    final isUrgent = _remainingSeconds <= 15;
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.timeLabel,
                style: TextStyle(
                  color: isUrgent
                      ? GameColors.blockColors[BlockColor.red]
                      : GameColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                timeText,
                style: TextStyle(
                  color: isUrgent
                      ? GameColors.blockColors[BlockColor.red]
                      : GameColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: GameColors.gridLine,
              valueColor: AlwaysStoppedAnimation(
                isUrgent
                    ? GameColors.blockColors[BlockColor.red]!
                    : GameColors.blockColors[BlockColor.yellow]!,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovesBar(AppLocalizations l10n) {
    final progress = _remainingMoves / 20.0;
    final isUrgent = _remainingMoves <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.labelMoves,
                style: TextStyle(
                  color: isUrgent
                      ? GameColors.blockColors[BlockColor.red]
                      : GameColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                l10n.movesLeft(_remainingMoves),
                style: TextStyle(
                  color: isUrgent
                      ? GameColors.blockColors[BlockColor.red]
                      : GameColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: GameColors.gridLine,
              valueColor: AlwaysStoppedAnimation(
                isUrgent
                    ? GameColors.blockColors[BlockColor.red]!
                    : GameColors.blockColors[BlockColor.blue]!,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRunBar(AppLocalizations l10n) {
    final progress =
        (_state.score / _speedRunTarget).clamp(0.0, 1.0);
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    final timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.targetScore(_speedRunTarget),
                style: TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                timeText,
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
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
                GameColors.blockColors[BlockColor.green]!,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(double cellSize, int visibleRows, double gap) {
    final bool showUrgentBorder;
    if (_challengeType == ChallengeType.timeAttack ||
        _challengeType == ChallengeType.comboMaster ||
        _challengeType == ChallengeType.normal) {
      showUrgentBorder = _remainingSeconds <= 30;
    } else if (_challengeType == ChallengeType.limitedMoves) {
      showUrgentBorder = _remainingMoves <= 3;
    } else {
      showUrgentBorder = false;
    }

    return Container(
      decoration: BoxDecoration(
        color: GameColors.gridBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: showUrgentBorder
              ? GameColors.blockColors[BlockColor.red]!
                  .withValues(alpha: 0.6 + 0.4 * ((_remainingSeconds % 2 == 0) ? 1.0 : 0.5))
              : GameColors.gridLine,
          width: showUrgentBorder ? 3 : 2,
        ),
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
              color:
                  GameColors.blockColors[BlockColor.red]!.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          for (int displayRow = visibleRows - 1; displayRow >= 0; displayRow--)
            Padding(
              padding: EdgeInsets.only(bottom: displayRow > 0 ? gap : 0),
              child: Container(
                decoration: _state.nearCompleteRows.contains(displayRow)
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.blockColors[BlockColor.yellow]!
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      )
                    : null,
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
        if (animation.status == AnimationStatus.reverse) {
          final popScale = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeIn),
          );
          return ScaleTransition(
            scale: popScale,
            child: FadeTransition(opacity: animation, child: child),
          );
        }
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: cell == null
          ? SizedBox(
              key: ValueKey('empty_${row}_$col'),
              width: cellSize,
              height: cellSize)
          : BlockWidget(
              key: ValueKey(cell.id),
              cell: cell,
              size: cellSize,
              onTap: () => _onTap(row, col),
            ),
    );
  }

  Widget _buildStartOverlay(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _canAttempt ? _startGame : null,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 챌린지 타입 뱃지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _challengeColor(),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _challengeTypeName(l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // START 버튼 또는 시도 불가 메시지
              if (_canAttempt)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  decoration: BoxDecoration(
                    color: GameColors.blockColors[BlockColor.blue],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.blockDarkColors[BlockColor.blue]!
                            .withValues(alpha: 0.4),
                        offset: const Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.labelStart,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: GameColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.noAttemptsLeft,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tryAgainTomorrow,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 광고 보고 +1회 버튼
                      if (AdService().isRewardedReady)
                        GestureDetector(
                          onTap: () {
                            AdService().showRewardedAd(
                              onRewarded: () {
                                setState(() {
                                  _canAttempt = true;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: GameColors.blockColors[BlockColor.yellow],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_circle_filled_rounded,
                                  color: GameColors.textPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.watchAd,
                                  style: const TextStyle(
                                    color: GameColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),
              // 남은 시도 횟수
              Text(
                l10n.attemptsLeft(3 - _attemptsUsed),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(AppLocalizations l10n) {
    final displayScore = _challengeType == ChallengeType.comboMaster
        ? _comboScore
        : _finalScore;

    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: GameColors.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.gameOver,
                style: const TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$displayScore',
                style: const TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.scoreLabel,
                style: const TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              // speedRun: 걸린 시간 표시
              if (_challengeType == ChallengeType.speedRun &&
                  _state.score >= _speedRunTarget) ...[
                const SizedBox(height: 8),
                Text(
                  '${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: GameColors.blockColors[BlockColor.green],
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Text(
                l10n.tryAgainTomorrow,
                style: const TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.attemptsLeft(3 - _attemptsUsed),
                style: const TextStyle(
                  color: GameColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // 닫기 버튼
              GestureDetector(
                onTap: _dismissGameOver,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: GameColors.gridBackground,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: GameColors.gridLine, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: GameColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
  _ParticleData(
      {required this.id,
      required this.row,
      required this.col,
      required this.color});
}
