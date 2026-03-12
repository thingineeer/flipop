import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onSkip;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;

  const WelcomeScreen({
    super.key,
    required this.onSkip,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
            // 페이지 인디케이터
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentPage ? 28 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? GameColors.blockColors[BlockColor.blue]
                          : GameColors.gridLine,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1페이지: 귀여운 캐릭터와 함께!
  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 캐릭터 4개 배열
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final bc in BlockColor.values)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: GameColors.blockColors[bc]!.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      GameColors.blockImages[bc]!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // FLIPOP 로고
          Text(
            'FLIPOP',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: GameColors.textPrimary,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: GameColors.blockColors[BlockColor.blue]!
                      .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 페이지 제목
          const Text(
            '귀여운 캐릭터와 함께!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: GameColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 설명
          const Text(
            '블록을 탭해서 색을 바꾸고,\n한 줄을 완성하세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: GameColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 2페이지: 전 세계 플레이어와 경쟁!
  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 랭킹 아이콘
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: GameColors.blockColors[BlockColor.yellow]!
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.leaderboard,
              size: 56,
              color: GameColors.blockColors[BlockColor.yellow],
            ),
          ),
          const SizedBox(height: 32),

          // 페이지 제목
          const Text(
            '전 세계 플레이어와 경쟁!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: GameColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 설명 1
          const Text(
            '로그인하면 점수가 저장되고\n세계 랭킹에 참여!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: GameColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // 설명 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: GameColors.blockColors[BlockColor.blue]!
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '계정을 연동하면 앱을 삭제해도\n기록이 유지됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: GameColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3페이지: 지금 시작하세요!
  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '지금 시작하세요!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: GameColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),

          // Apple 로그인 버튼 (iOS만)
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onAppleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Apple로 시작',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Google 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onGoogleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: GameColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: GameColors.gridLine,
                    width: 1.5,
                  ),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.g_mobiledata, size: 24);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Google로 시작',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 구분선 "또는"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: GameColors.gridLine,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '또는',
                  style: TextStyle(
                    fontSize: 13,
                    color: GameColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: GameColors.gridLine,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 로그인 없이 시작하기
          GestureDetector(
            onTap: widget.onSkip,
            child: const Text(
              '로그인 없이 시작하기',
              style: TextStyle(
                fontSize: 14,
                color: GameColors.textSecondary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: GameColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 하단 안내 문구
          const Text(
            '나중에 설정에서 언제든 로그인할 수 있어요',
            style: TextStyle(
              fontSize: 12,
              color: GameColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
