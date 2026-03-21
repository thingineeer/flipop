import 'package:flutter/material.dart';
import 'game_state.dart';

/// 블록 색상 매핑 (귀여운 파스텔 톤)
class GameColors {
  static const Map<BlockColor, Color> blockColors = {
    BlockColor.red: Color(0xFFFF6B8A),    // 코랄 핑크
    BlockColor.blue: Color(0xFF6BC5FF),   // 스카이 블루
    BlockColor.yellow: Color(0xFFFFD93D), // 써니 옐로우
    BlockColor.green: Color(0xFF6BCB77),  // 민트 그린
  };

  static const Map<BlockColor, Color> blockDarkColors = {
    BlockColor.red: Color(0xFFE8506E),
    BlockColor.blue: Color(0xFF4DA8E8),
    BlockColor.yellow: Color(0xFFE8C236),
    BlockColor.green: Color(0xFF55B065),
  };

  static const Map<BlockColor, String> blockEmojis = {
    BlockColor.red: '🐱',
    BlockColor.blue: '🐶',
    BlockColor.yellow: '🐰',
    BlockColor.green: '🐸',
  };

  static const Map<BlockColor, String> blockImages = {
    BlockColor.red: 'assets/images/cat_red.png',
    BlockColor.blue: 'assets/images/puppy_blue.png',
    BlockColor.yellow: 'assets/images/bunny_yellow.png',
    BlockColor.green: 'assets/images/frog_green.png',
  };

  // 라이트 모드 (기존)
  static const Color background = Color(0xFFF8F5F0);
  static const Color gridBackground = Color(0xFFEDE8E0);
  static const Color gridLine = Color(0xFFD8D0C4);
  static const Color textPrimary = Color(0xFF3D3228);
  static const Color textSecondary = Color(0xFF8A7E72);
  static const Color dangerZone = Color(0x30FF6B8A);

  // 다크 모드
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color gridBackgroundDark = Color(0xFF16213E);
  static const Color gridLineDark = Color(0xFF0F3460);
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFF8A8A9A);
  static const Color dangerZoneDark = Color(0x30FF6B8A);

  // 현재 테마 기반 색상 가져오기
  static Color getBackground(bool isDark) =>
      isDark ? backgroundDark : background;
  static Color getGridBackground(bool isDark) =>
      isDark ? gridBackgroundDark : gridBackground;
  static Color getGridLine(bool isDark) => isDark ? gridLineDark : gridLine;
  static Color getTextPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondary;
  static Color getDangerZone(bool isDark) =>
      isDark ? dangerZoneDark : dangerZone;
}
