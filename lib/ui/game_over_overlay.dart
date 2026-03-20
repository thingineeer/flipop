import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';
import '../services/ad_service.dart';
import 'leaderboard_screen.dart';

class GameOverOverlay extends StatefulWidget {
  final int score;
  final int bestScore;
  final VoidCallback onRestart;
  final VoidCallback? onRevive;
  final bool canRevive;
  final VoidCallback? onTimeBonus;
  final bool canTimeBonus;
  final VoidCallback? onScoreDouble;
  final bool canScoreDouble;
  final VoidCallback? onClose;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.onRestart,
    this.onRevive,
    this.canRevive = false,
    this.onTimeBonus,
    this.canTimeBonus = false,
    this.onScoreDouble,
    this.canScoreDouble = false,
    this.onClose,
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

  void _showRewardedAd({required VoidCallback onRewarded}) {
    final adService = AdService();
    if (!adService.isRewardedReady) return;

    adService.showRewardedAd(
      onRewarded: onRewarded,
    );
  }

  void _onReviveTap() {
    _showRewardedAd(onRewarded: () {
      widget.onRevive?.call();
    });
  }

  void _onTimeBonusTap() {
    _showRewardedAd(onRewarded: () {
      widget.onTimeBonus?.call();
    });
  }

  void _onScoreDoubleTap() {
    _showRewardedAd(onRewarded: () {
      widget.onScoreDouble?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        isNewBest ? l10n.newBest : l10n.gameOver,
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
                      Text(
                        l10n.scoreLabel,
                        style: const TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.bestLabel}: ${widget.bestScore}',
                        style: const TextStyle(
                          color: GameColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 리워드 광고 버튼들
                      _buildRewardButton(
                        icon: Icons.play_circle_outline,
                        label: l10n.continueWithAd,
                        enabled: widget.canRevive && widget.onRevive != null,
                        onTap: _onReviveTap,
                      ),
                      const SizedBox(height: 8),
                      _buildRewardButton(
                        icon: Icons.timer_outlined,
                        label: l10n.timeBonus,
                        enabled: widget.canTimeBonus && widget.onTimeBonus != null,
                        onTap: _onTimeBonusTap,
                      ),
                      const SizedBox(height: 8),
                      _buildRewardButton(
                        icon: Icons.star_outline,
                        label: l10n.scoreDouble,
                        enabled: widget.canScoreDouble && widget.onScoreDouble != null,
                        onTap: _onScoreDoubleTap,
                      ),
                      const SizedBox(height: 16),

                      // PLAY AGAIN 버튼
                      GestureDetector(
                        key: const Key('play_again_button'),
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
                          child: Center(
                            child: Text(
                              l10n.rankingLabel,
                              style: const TextStyle(
                                color: GameColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.onClose != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: widget.onClose,
                          child: const Icon(
                            Icons.close_rounded,
                            color: GameColors.textSecondary,
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
        );
      },
    );
  }

  Widget _buildRewardButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled
              ? GameColors.blockColors[BlockColor.yellow]
              : GameColors.gridLine,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: GameColors.blockDarkColors[BlockColor.yellow]!
                        .withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: enabled ? Colors.white : GameColors.textSecondary,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : GameColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
