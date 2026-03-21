import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../domain/entities/achievement.dart';
import '../services/achievement_service.dart';
import '../services/ad_service.dart';
import '../services/auth_service.dart';
import '../services/leaderboard_service.dart';
import '../services/secure_storage_service.dart';
import '../services/analytics_service.dart';
import '../services/review_service.dart';
import '../services/sound_service.dart';
import '../l10n/app_localizations.dart';
import 'achievement_popup.dart';
import 'block_widget.dart';
import 'daily_bonus_dialog.dart';
import 'game_over_overlay.dart';
import 'onboarding_overlay.dart';
import 'pop_particle.dart';

class GameScreen extends StatefulWidget {
  final ValueNotifier<bool>? gameTabVisible;

  const GameScreen({super.key, this.gameTabVisible});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const int _initialTime = 120; // 2분 (여유로운 시작)

  late GameState _state;
  int _bestScore = 0;
  bool _showOnboarding = false; // async 체크 후 true로 변경 (깜빡임 방지)
  bool _waitingToStart = true; // 게임 시작 전 대기 상태 (최초 진입 포함)

  // 가이디드 첫 게임
  bool _isGuidedMode = false;
  int _guidedTurns = 0;
  static const int _guidedTurnLimit = 3;

  // 타이머
  Timer? _gameTimer;
  int _remainingSeconds = _initialTime;

  // 파티클 이펙트
  final List<_ParticleData> _activeParticles = [];
  int _particleIdCounter = 0;

  // 콤보 쉐이크
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  // 점수 펄스 애니메이션
  AnimationController? _scorePulseController;
  Animation<double>? _scorePulseAnimation;

  // 시간 추가 플로팅 텍스트
  final List<_FloatingText> _floatingTexts = [];
  int _floatingTextId = 0;

  // 업적 팝업
  final List<Achievement> _achievementPopups = [];

  // 그리드 레이아웃 정보 (파티클 위치 계산용)
  double _cellSize = 0;
  double _gap = 0;
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _state = GameState.newGame(bestScore: _bestScore);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticIn),
    );

    _scorePulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scorePulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _scorePulseController!, curve: Curves.easeInOut),
    );

    widget.gameTabVisible?.addListener(_onTabVisibilityChanged);

    _checkOnboarding();
    _checkGuidedMode();
    _showDailyBonusIfAvailable();
    // 최초 진입 시 타이머 시작하지 않음 — START 버튼 탭 후 시작
  }

  Future<void> _showDailyBonusIfAvailable() async {
    // 약간 딜레이 후 표시 (화면 빌드 완료 대기)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await DailyBonusDialog.showIfAvailable(context);
  }

  @override
  void dispose() {
    widget.gameTabVisible?.removeListener(_onTabVisibilityChanged);
    _gameTimer?.cancel();
    _shakeController?.dispose();
    _scorePulseController?.dispose();
    for (final ft in _floatingTexts) {
      ft.controller.dispose();
    }
    super.dispose();
  }

  void _onTabVisibilityChanged() {
    final isVisible = widget.gameTabVisible?.value ?? true;
    if (!isVisible) {
      _gameTimer?.cancel();
    } else if (!_state.isGameOver && !_waitingToStart && _remainingSeconds > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.isGameOver) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          _gameTimer?.cancel();
          _state = GameState(
            grid: _state.grid,
            score: _state.score,
            bestScore: _state.bestScore,
            moves: _state.moves,
            combo: _state.combo,
            colorCount: _state.colorCount,
            isGameOver: true,
            addRowEvery: _state.addRowEvery,
            nextId: _state.nextId,
          );
          if (_state.score > _bestScore) {
            _bestScore = _state.score;
          }
          HapticFeedback.heavyImpact();
          SoundService().playSE('gameover');
          _submitScore();
          _trackGameCompletion();
          _logGameOver('timeout');
          AdService().showInterstitialAd();
        }
      });
    });
  }

  void _logGameOver(String reason) {
    AnalyticsService().logGameOver(
      score: _state.score,
      comboMax: _state.combo,
      reason: reason,
    );
  }

  void _showFloatingTimeBonus(int bonus) {
    final id = _floatingTextId++;
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    final ft = _FloatingText(
      id: id,
      text: '+${bonus}s',
      controller: controller,
      fadeOut: Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
        ),
      ),
      moveUp: Tween<double>(begin: 0, end: -40).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      ),
    );
    setState(() => _floatingTexts.add(ft));
    controller.forward().then((_) {
      controller.dispose();
      if (mounted) {
        setState(() => _floatingTexts.removeWhere((f) => f.id == id));
      }
    });
  }

  void _onTap(int row, int col) {
    if (_state.isGameOver) return;

    HapticFeedback.lightImpact();
    SoundService().playSE('tap');

    final oldGrid = _state.grid;
    final oldScore = _state.score;
    final newState = _state.tap(row, col);

    // 가이디드 첫 게임: 턴 카운트
    if (_isGuidedMode && _guidedTurns < _guidedTurnLimit) {
      _guidedTurns++;
      if (_guidedTurns >= _guidedTurnLimit) {
        // 3턴 완료 → 타이머 시작
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_state.isGameOver) {
            setState(() => _isGuidedMode = false);
            _startTimer();
          }
        });
      }
    }

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

      // 줄 클리어 시 보너스 시간 적용
      if (_state.timeBonus > 0) {
        _remainingSeconds += _state.timeBonus;
        _showFloatingTimeBonus(_state.timeBonus);
      }

      if (_state.score > oldScore) {
        // 점수 펄스 애니메이션 트리거
        _scorePulseController?.reset();
        _scorePulseController?.forward();

        final newCombo = _state.combo;
        if (newCombo >= 3) {
          HapticFeedback.heavyImpact();
          _triggerShake();
          SoundService().playSE('combo3');
        } else if (newCombo >= 2) {
          HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.mediumImpact();
          });
          SoundService().playSE('combo${newCombo.clamp(1, 3)}');
        } else {
          HapticFeedback.mediumImpact();
          SoundService().playSE('pop');
        }
      }

      if (_state.score > _bestScore) {
        _bestScore = _state.score;
      }

      if (_state.isGameOver) {
        HapticFeedback.heavyImpact();
        SoundService().playSE('gameover');
        _submitScore();
        _trackGameCompletion();
        _logGameOver('overflow');
        AdService().showInterstitialAd();
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

  void _dismissGameOver() {
    setState(() {
      _waitingToStart = true;
    });
  }

  void _restart() {
    setState(() {
      _state = GameState.newGame(bestScore: _bestScore);
      _activeParticles.clear();
      _remainingSeconds = _initialTime;
      _waitingToStart = false;
      _guidedTurns = 0;
    });
    // 가이디드 모드: 처음 3턴 동안 타이머 일시정지
    if (!_isGuidedMode) {
      _startTimer();
    }
    AnalyticsService().logGameStart(mode: 'normal', colors: _state.colorCount);
  }

  void _trackGameCompletion() {
    SecureStorageService().incrementGamesPlayed();
    SecureStorageService().updateDailyBest(_state.score);
    _maybeRequestReview();
    _checkAchievements();
  }

  Future<void> _checkAchievements() async {
    final storage = SecureStorageService();
    final totalGames = await storage.getTotalGamesPlayed();
    final tutorialDone = await storage.hasSeenOnboarding();
    final streak = await storage.getDailyBonusStreak();
    final unlockedAvatars = await storage.getUnlockedAvatars();

    final context = AchievementContext(
      totalGames: totalGames,
      bestScore: _bestScore,
      currentScore: _state.score,
      maxCombo: _state.combo,
      linesCleared: _state.score ~/ 100, // 근사치: 점수/100
      streak: streak,
      avatarsUnlocked: unlockedAvatars.length,
      tutorialDone: tutorialDone,
    );

    final service = AchievementService();
    final newAchievements = await service.checkAchievements(context);

    for (final achievement in newAchievements) {
      await service.unlockAchievement(achievement.id);
    }

    if (newAchievements.isNotEmpty && mounted) {
      setState(() {
        _achievementPopups.addAll(newAchievements);
      });
    }
  }

  void _dismissAchievementPopup() {
    if (mounted && _achievementPopups.isNotEmpty) {
      setState(() {
        _achievementPopups.removeAt(0);
      });
    }
  }

  Future<void> _maybeRequestReview() async {
    final storage = SecureStorageService();
    final gamesPlayed = await storage.getTotalGamesPlayed();
    final isNewBest = _state.score >= _bestScore && _state.score > 0;
    final streak = await storage.getDailyBonusStreak();
    await ReviewService().maybeRequestReview(
      gamesPlayed: gamesPlayed,
      isNewBest: isNewBest,
      streak: streak,
    );
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
        countryCode: auth.countryCode,
      );
    } catch (_) {
      // 순위 제출 실패는 조용히 무시
    }
  }

  Future<void> _checkOnboarding() async {
    final seen = await SecureStorageService().hasSeenOnboarding();
    if (!seen && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  Future<void> _checkGuidedMode() async {
    final gamesPlayed = await SecureStorageService().getTotalGamesPlayed();
    if (gamesPlayed == 0 && mounted) {
      setState(() => _isGuidedMode = true);
    }
  }

  void _dismissOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
    SecureStorageService().setSeenOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: GameColors.getBackground(isDark),
        body: SafeArea(
          bottom: false,
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
                  _buildHeader(isDark),
                  const SizedBox(height: 8),
                  _buildTimerBar(isDark),
                  const SizedBox(height: 8),
                  _buildTurnIndicator(isDark),
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
                                _buildGrid(_cellSize, GameState.maxVisibleRows, _gap, isDark),
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
                  const SizedBox(height: 8),
                ],
              ),
            ),

            if (_state.isGameOver && !_waitingToStart)
              GameOverOverlay(
                score: _state.score,
                bestScore: _bestScore,
                combo: _state.combo,
                onRestart: _restart,
                onClose: _dismissGameOver,
              ),

            // 게임 오버 닫기 후 대기 화면
            if (_waitingToStart)
              _buildStartOverlay(),

            if (_showOnboarding && !_state.isGameOver && !_waitingToStart)
              OnboardingOverlay(onDismiss: _dismissOnboarding),

            // 가이디드 첫 게임 힌트
            if (_isGuidedMode && !_waitingToStart && !_state.isGameOver && !_showOnboarding)
              _buildGuidedHint(),

            // 업적 달성 팝업
            if (_achievementPopups.isNotEmpty)
              AchievementPopup(
                key: ValueKey('ach_${_achievementPopups.first.id}'),
                achievement: _achievementPopups.first,
                onDismiss: _dismissAchievementPopup,
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
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
                  'SCORE',
                  style: TextStyle(
                    color: GameColors.getTextSecondary(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                AnimatedBuilder(
                  animation: _scorePulseAnimation!,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scorePulseAnimation!.value,
                      alignment: Alignment.centerLeft,
                      child: child,
                    );
                  },
                  child: Text(
                    '${_state.score}',
                    style: TextStyle(
                      color: GameColors.getTextPrimary(isDark),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'FLIPOP',
            style: TextStyle(
              color: GameColors.getTextPrimary(isDark),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'BEST',
                  style: TextStyle(
                    color: GameColors.getTextSecondary(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '$_bestScore',
                  style: TextStyle(
                    color: GameColors.getTextPrimary(isDark),
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(bool isDark) {
    final progress = _remainingSeconds / _initialTime;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isUrgent = _remainingSeconds <= 15;
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    // 그라데이션 색상: 초록→노랑→빨강 (progress 기반)
    final Color barColor;
    if (clampedProgress > 0.5) {
      // 초록 → 노랑
      final t = (clampedProgress - 0.5) / 0.5;
      barColor = Color.lerp(
        GameColors.blockColors[BlockColor.yellow]!,
        GameColors.blockColors[BlockColor.green]!,
        t,
      )!;
    } else {
      // 노랑 → 빨강
      final t = clampedProgress / 0.5;
      barColor = Color.lerp(
        GameColors.blockColors[BlockColor.red]!,
        GameColors.blockColors[BlockColor.yellow]!,
        t,
      )!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIME',
                    style: TextStyle(
                      color: isUrgent
                          ? GameColors.blockColors[BlockColor.red]
                          : GameColors.getTextSecondary(isDark),
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
                          : GameColors.getTextPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // 플로팅 "+3s" 텍스트들
              ..._floatingTexts.map((ft) {
                return Positioned(
                  right: 0,
                  top: 0,
                  child: AnimatedBuilder(
                    animation: ft.controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, ft.moveUp.value),
                        child: Opacity(
                          opacity: ft.fadeOut.value,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      ft.text,
                      style: TextStyle(
                        color: GameColors.blockColors[BlockColor.green],
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: clampedProgress,
                backgroundColor: GameColors.getGridLine(isDark),
                valueColor: AlwaysStoppedAnimation(barColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(bool isDark) {
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
                AppLocalizations.of(context)?.turnsUntilNewRow(remaining) ??
                    '$remaining',
                style: TextStyle(
                  color: remaining <= 1
                      ? GameColors.blockColors[BlockColor.red]
                      : GameColors.getTextSecondary(isDark),
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
                      color: GameColors.getTextPrimary(false),
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
              backgroundColor: GameColors.getGridLine(isDark),
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

  Widget _buildStartOverlay() {
    return GestureDetector(
      onTap: _restart,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 60),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
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
            child: const Text(
              'START',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidedHint() {
    final l10n = AppLocalizations.of(context)!;
    final isAboutToStart = _guidedTurns >= _guidedTurnLimit;
    final text = isAboutToStart ? l10n.guidedStart : l10n.guidedHint;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      left: 40,
      right: 40,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: GameColors.blockColors[BlockColor.blue]!.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: GameColors.blockDarkColors[BlockColor.blue]!.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(double cellSize, int visibleRows, double gap, bool isDark) {
    return Container(
      key: _gridKey,
      decoration: BoxDecoration(
        color: GameColors.getGridBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _remainingSeconds <= 30
              ? GameColors.blockColors[BlockColor.red]!
                  .withValues(alpha: 0.6 + 0.4 * ((_remainingSeconds % 2 == 0) ? 1.0 : 0.5))
              : GameColors.getGridLine(isDark),
          width: _remainingSeconds <= 30 ? 3 : 2,
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
              color: GameColors.blockColors[BlockColor.red]!.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // 그리드 (위에서 아래로: row 5→0)
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

class _FloatingText {
  final int id;
  final String text;
  final AnimationController controller;
  final Animation<double> fadeOut;
  final Animation<double> moveUp;
  _FloatingText({
    required this.id,
    required this.text,
    required this.controller,
    required this.fadeOut,
    required this.moveUp,
  });
}
