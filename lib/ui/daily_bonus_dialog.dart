import 'package:flutter/material.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/daily_bonus_service.dart';

class DailyBonusDialog extends StatefulWidget {
  const DailyBonusDialog({super.key});

  /// 보너스 수령 가능 시에만 다이얼로그를 표시한다.
  /// 반환값: 수령한 코인 (취소 시 null)
  static Future<int?> showIfAvailable(BuildContext context) async {
    final canClaim = await DailyBonusService().canClaimToday();
    if (!canClaim) return null;
    if (!context.mounted) return null;
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DailyBonusDialog(),
    );
  }

  @override
  State<DailyBonusDialog> createState() => _DailyBonusDialogState();
}

class _DailyBonusDialogState extends State<DailyBonusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  final _bonusService = DailyBonusService();
  int _streak = 0;
  int _previewReward = 50;
  bool _claiming = false;

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
    _loadData();
  }

  Future<void> _loadData() async {
    final streak = await _bonusService.getStreak();
    final lastDate =
        await _bonusService.canClaimToday() ? null : 'already_claimed';

    // 다음 streak 예측 (수령 시 적용될 값)
    int nextStreak;
    if (lastDate == null) {
      // 첫 수령이거나 연속 출석인지 판별
      final storedStreak = streak;
      // 간단히: 현재 streak + 1 (claimBonus에서 실제 연속 여부를 판별)
      nextStreak = storedStreak + 1;
    } else {
      nextStreak = streak;
    }

    if (mounted) {
      setState(() {
        _streak = nextStreak;
        _previewReward = _calculatePreviewReward(nextStreak);
      });
    }
  }

  int _calculatePreviewReward(int streak) {
    switch (streak) {
      case 1:
        return 50;
      case 2:
        return 75;
      case 3:
        return 100;
      case 7:
        return 200;
      default:
        final bonus = streak * 10;
        return 50 + (bonus > 150 ? 150 : bonus);
    }
  }

  Future<void> _onClaimTap() async {
    if (_claiming) return;
    setState(() => _claiming = true);

    final adService = AdService();
    if (!adService.isRewardedReady) {
      // 광고 미준비 시 그냥 수령
      final reward = await _bonusService.claimBonus();
      final streak = await _bonusService.getStreak();
      AnalyticsService().logDailyBonusClaim(streak: streak, coins: reward);
      if (mounted) Navigator.of(context).pop(reward);
      return;
    }

    adService.showRewardedAd(
      onRewarded: () async {
        final reward = await _bonusService.claimBonus();
        final streak = await _bonusService.getStreak();
        AnalyticsService().logDailyBonusClaim(streak: streak, coins: reward);
        if (mounted) Navigator.of(context).pop(reward);
      },
      onAdDismissed: () {
        // 광고 닫혔지만 보상 못 받은 경우
        if (mounted) setState(() => _claiming = false);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: _buildContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
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
          // 타이틀
          Text(
            AppLocalizations.of(context)!.labelDailyBonus,
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),

          // 연속 출석 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: GameColors.blockColors[BlockColor.yellow]!
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppLocalizations.of(context)!.labelDay(_streak),
              style: TextStyle(
                color: GameColors.blockDarkColors[BlockColor.yellow],
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 코인 보상 표시
          Text(
            '+$_previewReward',
            style: const TextStyle(
              color: GameColors.textPrimary,
              fontSize: 44,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.labelCoins,
            style: const TextStyle(
              color: GameColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),

          // 광고 보고 받기 버튼
          GestureDetector(
            onTap: _claiming ? null : _onClaimTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _claiming
                    ? GameColors.gridLine
                    : GameColors.blockColors[BlockColor.green],
                borderRadius: BorderRadius.circular(16),
                boxShadow: _claiming
                    ? null
                    : [
                        BoxShadow(
                          color: GameColors
                              .blockDarkColors[BlockColor.green]!
                              .withValues(alpha: 0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_claiming)
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  if (!_claiming) const SizedBox(width: 8),
                  Text(
                    _claiming ? '...' : AppLocalizations.of(context)!.watchAdAndClaim,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 나중에 버튼
          GestureDetector(
            onTap: _claiming ? null : () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: GameColors.gridBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameColors.gridLine, width: 2),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.labelLater,
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
        ],
      ),
    );
  }
}
