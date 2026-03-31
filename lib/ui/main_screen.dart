import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../game/game_colors.dart';
import 'banner_ad_widget.dart';
import 'daily_challenge_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'more_screen.dart';

/// 메인 탭 네비게이션 쉘
/// IndexedStack으로 탭 전환 시 위젯 상태 보존
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /// 게임 탭 활성 여부 — GameScreen에서 타이머 pause/resume 처리
  final ValueNotifier<bool> gameTabVisible = ValueNotifier<bool>(true);

  /// 랭킹 탭 활성 여부 — LeaderboardScreen에서 데이터 리로드
  final ValueNotifier<bool> rankingTabVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    gameTabVisible.dispose();
    rankingTabVisible.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // 탭 활성 상태 알림
    gameTabVisible.value = (index == 0);
    rankingTabVisible.value = (index == 2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: GameColors.getBackground(isDark),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: 게임
          GameScreen(gameTabVisible: gameTabVisible),
          // 1: 챌린지
          const DailyChallengeScreen(),
          // 2: 랭킹
          LeaderboardScreen(embedded: true, tabVisible: rankingTabVisible),
          // 3: 더보기
          MoreScreen(onSwitchToRanking: () => _onTabSelected(2)),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(
                  color: GameColors.getTextPrimary(isDark),
                  size: 24,
                );
              }
              return IconThemeData(
                color: GameColors.getTextSecondary(isDark),
                size: 24,
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  color: GameColors.getTextPrimary(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                );
              }
              return TextStyle(
                color: GameColors.getTextSecondary(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: GameColors.getBackground(isDark),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: GameColors.getGridBackground(isDark),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.videogame_asset_outlined),
              selectedIcon: const Icon(Icons.videogame_asset),
              label: l10n.tabGame,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_today),
              label: l10n.tabChallenge,
            ),
            NavigationDestination(
              icon: const Icon(Icons.leaderboard_outlined),
              selectedIcon: const Icon(Icons.leaderboard),
              label: l10n.tabRanking,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon: const Icon(Icons.more_horiz),
              label: l10n.tabMore,
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }
}
