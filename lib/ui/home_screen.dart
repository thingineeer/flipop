import 'dart:io';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';

class HomeScreen extends StatefulWidget {
  /// 비로그인(익명) 시작 콜백
  final VoidCallback onGuestStart;

  /// 소셜 로그인 성공 콜백 (프로필 유무를 bool로 전달)
  final void Function(bool hasProfile) onSocialLogin;

  const HomeScreen({
    super.key,
    required this.onGuestStart,
    required this.onSocialLogin,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;

  Future<void> _startAsGuest() async {
    setState(() => _loading = true);
    try {
      await AuthService().signInAnonymously();
      widget.onGuestStart();
    } catch (e) {
      // 익명 로그인 실패해도 게임은 진행
      widget.onGuestStart();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final (user, failure) = await AuthService().signInWithGoogle();
      if (failure != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google 로그인 실패: ${failure.message}')),
          );
        }
        return;
      }
      if (user != null) {
        final hasProfile = await AuthService().hasProfile();
        widget.onSocialLogin(hasProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      final (user, failure) = await AuthService().signInWithApple();
      if (failure != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Apple 로그인 실패: ${failure.message}')),
          );
        }
        return;
      }
      if (user != null) {
        final hasProfile = await AuthService().hasProfile();
        widget.onSocialLogin(hasProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple 로그인 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고
              const Text(
                'FLIPOP',
                style: TextStyle(
                  color: GameColors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 32),

              // 캐릭터 4개
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacter(
                    'assets/images/cat_red.png',
                    BlockColor.red,
                  ),
                  const SizedBox(width: 12),
                  _buildCharacter(
                    'assets/images/puppy_blue.png',
                    BlockColor.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildCharacter(
                    'assets/images/bunny_yellow.png',
                    BlockColor.yellow,
                  ),
                  const SizedBox(width: 12),
                  _buildCharacter(
                    'assets/images/frog_green.png',
                    BlockColor.green,
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // 바로 시작하기 버튼 (메인 CTA)
              _buildMainButton(
                label: '바로 시작하기',
                color: GameColors.blockColors[BlockColor.blue]!,
                shadowColor: GameColors.blockDarkColors[BlockColor.blue]!,
                textColor: Colors.white,
                onTap: _loading ? null : _startAsGuest,
              ),
              const SizedBox(height: 24),

              // 구분선 + "또는"
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
                        color: GameColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
              const SizedBox(height: 24),

              // Google로 시작 버튼
              _buildSocialButton(
                label: 'Google로 시작',
                backgroundColor: Colors.white,
                textColor: GameColors.textPrimary,
                borderColor: GameColors.gridLine,
                icon: _buildGoogleIcon(),
                onTap: _loading ? null : _signInWithGoogle,
              ),
              const SizedBox(height: 12),

              // Apple로 시작 버튼 (iOS만)
              if (Platform.isIOS)
                _buildSocialButton(
                  label: 'Apple로 시작',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  icon: const Icon(Icons.apple, color: Colors.white, size: 20),
                  onTap: _loading ? null : _signInWithApple,
                ),

              const Spacer(),

              // 하단 유도 메시지
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '로그인하면 기록이 저장되고 랭킹에 참여할 수 있어요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GameColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacter(String imagePath, BlockColor color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: GameColors.blockColors[color]!.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildMainButton({
    required String label,
    required Color color,
    required Color shadowColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

/// Google 'G' 로고를 그리는 커스텀 페인터
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // 파란색 (오른쪽 상단)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    // 빨간색 (오른쪽 하단)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    // 노란색 (왼쪽 하단)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    // 녹색 (왼쪽 상단)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.2
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.7);

    // 파란색 호 (오른쪽: -45도 ~ 45도)
    canvas.drawArc(rect, -0.8, 1.2, false, bluePaint);
    // 빨간색 호 (상단: -135도 ~ -45도)
    canvas.drawArc(rect, -2.0, 1.2, false, redPaint);
    // 노란색 호 (왼쪽: 135도 ~ -135도)
    canvas.drawArc(rect, -3.2, 1.2, false, yellowPaint);
    // 녹색 호 (하단: 45도 ~ 135도)
    canvas.drawArc(rect, 0.4, 1.2, false, greenPaint);

    // 파란색 가로선
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, h * 0.4, w * 0.45, h * 0.2),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
