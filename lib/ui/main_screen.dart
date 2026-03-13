import 'package:flutter/material.dart';

import '../game/game_colors.dart';
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
    rankingTabVisible.value = (index == 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: 게임
          GameScreen(gameTabVisible: gameTabVisible),
          // 1: 랭킹
          LeaderboardScreen(embedded: true, tabVisible: rankingTabVisible),
          // 2: 더보기
          MoreScreen(onSwitchToRanking: () => _onTabSelected(1)),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: GameColors.textPrimary,
                  size: 24,
                );
              }
              return const IconThemeData(
                color: GameColors.textSecondary,
                size: 24,
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                );
              }
              return const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: GameColors.background,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: GameColors.gridBackground,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.videogame_asset_outlined),
              selectedIcon: Icon(Icons.videogame_asset),
              label: 'Game',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard),
              label: 'Ranking',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
