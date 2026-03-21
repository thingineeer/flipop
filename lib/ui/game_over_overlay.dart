import 'dart:ui';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/daily_bonus_service.dart';
import '../services/share_service.dart';
import 'leaderboard_screen.dart';
import 'share_card_widget.dart';

class GameOverOverlay extends StatefulWidget {
  final int score;
  final int bestScore;
  final int combo;
  final VoidCallback onRestart;
  final VoidCallback? onClose;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    this.combo = 0,
    required this.onRestart,
    this.onClose,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  // 점수 카운팅 애니메이션
  late AnimationController _countController;
  late Animation<int> _countAnimation;

  // 신기록 바운스 애니메이션
  AnimationController? _bounceController;
  Animation<double>? _bounceAnimation;

  // 공유 카드 캡처용 키
  final GlobalKey _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // 점수 카운팅: 0 → 최종점수 (1.5초)
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _countAnimation = IntTween(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
    );

    final isNewBest = widget.score >= widget.bestScore && widget.score > 0;
    if (isNewBest) {
      _bounceController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _bounceAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 20),
        TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 30),
      ]).animate(
        CurvedAnimation(parent: _bounceController!, curve: Curves.easeInOut),
      );
    }

    _controller.forward().then((_) {
      _countController.forward().then((_) {
        _bounceController?.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _countController.dispose();
    _bounceController?.dispose();
    super.dispose();
  }

  void _shareScoreCard() {
    final l10n = AppLocalizations.of(context)!;
    final fallbackText = l10n.shareScore(widget.score);

    ShareService().shareScoreCard(
      _shareCardKey,
      score: widget.score,
      fallbackText: fallbackText,
    );

    AnalyticsService().logShareScore(score: widget.score);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNewBest = widget.score >= widget.bestScore && widget.score > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auth = AuthService();
    final nickname = auth.nickname ?? '???';
    final avatarId = auth.avatarId ?? 'cat';

    return Stack(
      children: [
        // Offstage로 ShareCardWidget 렌더링 (화면에 안 보임)
        Offstage(
          offstage: true,
          child: ShareCardWidget(
            score: widget.score,
            combo: widget.combo,
            nickname: nickname,
            avatarId: avatarId,
            repaintKey: _shareCardKey,
          ),
        ),
        // 기존 오버레이
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _fadeIn.value * 5,
                sigmaY: _fadeIn.value * 5,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: _fadeIn.value * 0.5),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: GameColors.getBackground(isDark),
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
                            // 타이틀: 신기록 시 바운스 + 골드
                            if (isNewBest && _bounceAnimation != null)
                              AnimatedBuilder(
                                animation: _bounceAnimation!,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _bounceAnimation!.value,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  l10n.ui_newBest,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                              )
                            else
                              Text(
                                isNewBest ? l10n.ui_newBest : l10n.gameOver,
                                style: TextStyle(
                                  color: isNewBest
                                      ? const Color(0xFFFFD700)
                                      : GameColors.getTextPrimary(isDark),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            const SizedBox(height: 20),
                            // 점수 카운팅 애니메이션
                            AnimatedBuilder(
                              animation: _countAnimation,
                              builder: (context, child) {
                                return Text(
                                  '${_countAnimation.value}',
                                  style: TextStyle(
                                    color: GameColors.getTextPrimary(isDark),
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.scoreLabel,
                              style: TextStyle(
                                color: GameColors.getTextSecondary(isDark),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${l10n.bestLabel}: ${widget.bestScore}',
                              style: TextStyle(
                                color: GameColors.getTextSecondary(isDark),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // PLAY AGAIN 버튼
                            GestureDetector(
                              onTap: widget.onRestart,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color:
                                      GameColors.blockColors[BlockColor.blue],
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: GameColors
                                          .blockDarkColors[BlockColor.blue]!
                                          .withValues(alpha: 0.4),
                                      offset: const Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.playAgain,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const LeaderboardScreen()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color:
                                      GameColors.getGridBackground(isDark),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: GameColors.getGridLine(isDark),
                                      width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.rankingLabel,
                                    style: TextStyle(
                                      color:
                                          GameColors.getTextPrimary(isDark),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 공유 버튼 (이미지 카드 공유)
                            GestureDetector(
                              onTap: _shareScoreCard,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: GameColors
                                      .blockColors[BlockColor.yellow],
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: GameColors
                                          .blockDarkColors[BlockColor.yellow]!
                                          .withValues(alpha: 0.4),
                                      offset: const Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.share_rounded,
                                      color:
                                          GameColors.getTextPrimary(false),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.shareButton,
                                      style: TextStyle(
                                        color:
                                            GameColors.getTextPrimary(false),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 코인 리워드 광고 버튼
                            if (AdService().isRewardedReady) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  AdService().showRewardedAd(
                                    onRewarded: () async {
                                      await DailyBonusService().addCoins(30);
                                      AnalyticsService().logAdWatched(type: 'rewarded_coins');
                                    },
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: GameColors.getGridBackground(isDark),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: GameColors.blockColors[BlockColor.green]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_circle_filled_rounded,
                                        color: GameColors.blockColors[BlockColor.green],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+30 ${l10n.meta_coins}',
                                        style: TextStyle(
                                          color: GameColors.blockColors[BlockColor.green],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (widget.onClose != null) ...[
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: widget.onClose,
                                child: Icon(
                                  Icons.close_rounded,
                                  color:
                                      GameColors.getTextSecondary(isDark),
                                  size: 28,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
