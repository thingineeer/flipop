import 'package:flutter/material.dart';
import '../domain/entities/achievement.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../l10n/app_localizations.dart';

/// 업적 달성 시 상단에서 슬라이드 다운하는 팝업
class AchievementPopup extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementPopup({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // 2초 후 자동 사라짐
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _resolveL10n(BuildContext context, String key) {
    final l = AppLocalizations.of(context)!;
    return _l10nMap(l)[key] ?? key;
  }

  Map<String, String> _l10nMap(AppLocalizations l) {
    return {
      'meta_achFirstStep': l.meta_achFirstStep,
      'meta_achFirstStepDesc': l.meta_achFirstStepDesc,
      'meta_achTrainee': l.meta_achTrainee,
      'meta_achTraineeDesc': l.meta_achTraineeDesc,
      'meta_achFirstClear': l.meta_achFirstClear,
      'meta_achFirstClearDesc': l.meta_achFirstClearDesc,
      'meta_achComboIntro': l.meta_achComboIntro,
      'meta_achComboIntroDesc': l.meta_achComboIntroDesc,
      'meta_achTutorial': l.meta_achTutorial,
      'meta_achTutorialDesc': l.meta_achTutorialDesc,
      'meta_ach100': l.meta_ach100,
      'meta_ach100Desc': l.meta_ach100Desc,
      'meta_ach500': l.meta_ach500,
      'meta_ach500Desc': l.meta_ach500Desc,
      'meta_ach1000': l.meta_ach1000,
      'meta_ach1000Desc': l.meta_ach1000Desc,
      'meta_achComboMaster': l.meta_achComboMaster,
      'meta_achComboMasterDesc': l.meta_achComboMasterDesc,
      'meta_achChainReaction': l.meta_achChainReaction,
      'meta_achChainReactionDesc': l.meta_achChainReactionDesc,
      'meta_ach3000': l.meta_ach3000,
      'meta_ach3000Desc': l.meta_ach3000Desc,
      'meta_achComboKing': l.meta_achComboKing,
      'meta_achComboKingDesc': l.meta_achComboKingDesc,
      'meta_achSurvivor': l.meta_achSurvivor,
      'meta_achSurvivorDesc': l.meta_achSurvivorDesc,
      'meta_achPerfect': l.meta_achPerfect,
      'meta_achPerfectDesc': l.meta_achPerfectDesc,
      'meta_achBombMaster': l.meta_achBombMaster,
      'meta_achBombMasterDesc': l.meta_achBombMasterDesc,
      'meta_achShareKing': l.meta_achShareKing,
      'meta_achShareKingDesc': l.meta_achShareKingDesc,
      'meta_achTop100': l.meta_achTop100,
      'meta_achTop100Desc': l.meta_achTop100Desc,
      'meta_achChallenger': l.meta_achChallenger,
      'meta_achChallengerDesc': l.meta_achChallengerDesc,
      'meta_achZoo': l.meta_achZoo,
      'meta_achZooDesc': l.meta_achZooDesc,
      'meta_achFullCollection': l.meta_achFullCollection,
      'meta_achFullCollectionDesc': l.meta_achFullCollectionDesc,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = _resolveL10n(context, widget.achievement.titleKey);
    final reward = widget.achievement.coinReward;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: GameColors.blockColors[BlockColor.yellow],
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: GameColors.blockDarkColors[BlockColor.yellow]!
                      .withValues(alpha: 0.4),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: GameColors.getTextPrimary(false),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+$reward ${AppLocalizations.of(context)!.meta_coins}',
                        style: TextStyle(
                          color: GameColors.getTextPrimary(false)
                              .withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
