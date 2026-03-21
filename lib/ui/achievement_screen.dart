import 'package:flutter/material.dart';
import '../domain/entities/achievement.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../l10n/app_localizations.dart';
import '../services/achievement_service.dart';

/// 전체 업적 목록 화면
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  Set<String> _unlocked = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final unlocked = await AchievementService().getUnlockedAchievements();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _loading = false;
      });
    }
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
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievements = AchievementService.allAchievements;
    final unlockedCount = _unlocked.length;

    return Scaffold(
      backgroundColor: GameColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: GameColors.getBackground(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: GameColors.getTextPrimary(isDark),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.meta_achievements,
          style: TextStyle(
            color: GameColors.getTextPrimary(isDark),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$unlockedCount/${achievements.length}',
                style: TextStyle(
                  color: GameColors.getTextSecondary(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: GameColors.getTextSecondary(isDark),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: achievements.length,
              itemBuilder: (context, index) =>
                  _buildAchievementTile(context, achievements[index], isDark),
            ),
    );
  }

  Widget _buildAchievementTile(
    BuildContext context,
    Achievement achievement,
    bool isDark,
  ) {
    final isUnlocked = _unlocked.contains(achievement.id);
    final title = _resolveL10n(context, achievement.titleKey);
    final desc = _resolveL10n(context, achievement.descKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked
            ? GameColors.blockColors[BlockColor.yellow]!.withValues(alpha: 0.15)
            : GameColors.getGridBackground(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? GameColors.blockColors[BlockColor.yellow]!.withValues(alpha: 0.5)
              : GameColors.getGridLine(isDark),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? GameColors.blockColors[BlockColor.yellow]
                  : GameColors.getGridLine(isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUnlocked
                  ? Icons.emoji_events_rounded
                  : Icons.lock_rounded,
              color: isUnlocked
                  ? Colors.white
                  : GameColors.getTextSecondary(isDark),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isUnlocked
                        ? GameColors.getTextPrimary(isDark)
                        : GameColors.getTextSecondary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: GameColors.getTextSecondary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // 보상
          Column(
            children: [
              if (isUnlocked)
                Icon(
                  Icons.check_circle_rounded,
                  color: GameColors.blockColors[BlockColor.green],
                  size: 20,
                )
              else
                Text(
                  '+${achievement.coinReward}',
                  style: TextStyle(
                    color: GameColors.getTextSecondary(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
