import 'package:flutter/material.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../services/ad_service.dart';
import 'leaderboard_screen.dart';

class GameOverOverlay extends StatefulWidget {
  final int score;
  final int bestScore;
  final VoidCallback onRestart;
  final VoidCallback? onLeaderboard;
  final VoidCallback? onRevive;
  final bool canRevive;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.onRestart,
    this.onLeaderboard,
    this.onRevive,
    this.canRevive = false,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

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
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onReviveTap() {
    final adService = AdService();
    if (!adService.isRewardedReady) return;

    adService.showRewardedAd(
      onRewarded: () {
        widget.onRevive?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNewBest = widget.score >= widget.bestScore && widget.score > 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
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
                        isNewBest ? '🎉 NEW BEST!' : 'GAME OVER',
                        style: const TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${widget.score}',
                        style: const TextStyle(
                          color: GameColors.textPrimary,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SCORE',
                        style: TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BEST: ${widget.bestScore}',
                        style: const TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 이어하기 (광고) 버튼
                      if (widget.canRevive && widget.onRevive != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: _onReviveTap,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color:
                                    GameColors.blockColors[BlockColor.yellow],
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_outline,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    '이어하기 (광고)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // PLAY AGAIN 버튼
                      GestureDetector(
                        onTap: widget.onRestart,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: GameColors.blockColors[BlockColor.blue],
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
                          child: const Center(
                            child: Text(
                              'PLAY AGAIN',
                              style: TextStyle(
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
                                builder: (_) => const LeaderboardScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: GameColors.gridBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: GameColors.gridLine, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              'RANKING',
                              style: TextStyle(
                                color: GameColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
