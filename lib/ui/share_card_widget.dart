import 'package:flutter/material.dart';
import '../game/avatar_data.dart';
import '../game/game_colors.dart';
import '../game/game_state.dart';
import '../l10n/app_localizations.dart';

/// 공유용 카드 위젯 (RepaintBoundary로 이미지 캡처 가능)
class ShareCardWidget extends StatelessWidget {
  final int score;
  final int combo;
  final String nickname;
  final String avatarId;
  final GlobalKey repaintKey;

  const ShareCardWidget({
    super.key,
    required this.score,
    required this.combo,
    required this.nickname,
    required this.avatarId,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final avatarImage =
        AvatarData.images[avatarId] ?? 'assets/images/cat_red.png';
    final avatarColor = AvatarData.avatarColors[avatarId] ?? BlockColor.red;
    final now = DateTime.now();
    final dateStr =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 320,
        height: 480,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8D4F0), // 파스텔 블루
              Color(0xFFF0B8D4), // 파스텔 핑크
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // 상단: FLIPOP 로고
            const Text(
              'FLIPOP',
              style: TextStyle(
                color: Color(0xFF3D3228),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 28),
            // 아바타 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GameColors.blockColors[avatarColor],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.blockDarkColors[avatarColor]!
                        .withValues(alpha: 0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(avatarImage, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            // 닉네임
            Text(
              nickname,
              style: const TextStyle(
                color: Color(0xFF3D3228),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            // 점수 크게 표시
            Text(
              '$score',
              style: const TextStyle(
                color: Color(0xFF3D3228),
                fontSize: 56,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              AppLocalizations.of(context)?.scoreLabel ?? 'SCORE',
              style: const TextStyle(
                color: Color(0xFF8A7E72),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                decoration: TextDecoration.none,
              ),
            ),
            // 콤보 (있으면)
            if (combo > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: GameColors.blockColors[BlockColor.yellow],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'COMBO x$combo',
                  style: const TextStyle(
                    color: Color(0xFF3D3228),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
            const Spacer(),
            // 하단: 도전 메시지 + 날짜
            Text(
              _challengeText(context),
              style: const TextStyle(
                color: Color(0xFF5A5048),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: const TextStyle(
                color: Color(0xFF8A7E72),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  String _challengeText(BuildContext context) {
    return AppLocalizations.of(context)?.social_challengeMe ?? 'Can you beat this?';
  }
}
