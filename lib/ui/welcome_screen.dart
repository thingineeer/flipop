import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';

class WelcomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 캐릭터 인사 이미지
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
                l10n.appTitle,
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

              Text(
                l10n.welcomeDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: GameColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // "시작하기!" 버튼 (게스트/익명)
              GestureDetector(
                onTap: onSkip,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: GameColors.blockColors[BlockColor.blue],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.blockDarkColors[BlockColor.blue]!
                            .withValues(alpha: 0.4),
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      l10n.welcomeStart,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 구분선 "또는"
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: GameColors.gridLine),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.orDivider,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GameColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: GameColors.gridLine),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Google 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onGoogleSignIn,
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
                      Text(
                        l10n.signInGoogle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Apple 로그인 버튼 (iOS만)
              if (Platform.isIOS)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onAppleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.apple, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          l10n.signInApple,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // 하단 안내 문구
              Text(
                l10n.signInLaterHint,
                style: const TextStyle(
                  fontSize: 12,
                  color: GameColors.textSecondary,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
