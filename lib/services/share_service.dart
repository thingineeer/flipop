import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// 스코어 카드 이미지 캡처 + 공유 서비스 (싱글톤)
class ShareService {
  static final ShareService _instance = ShareService._();
  factory ShareService() => _instance;
  ShareService._();

  /// RepaintBoundary → 이미지 캡처 → 임시 파일 저장 → share_plus로 공유
  Future<void> shareScoreCard(
    GlobalKey repaintKey, {
    required int score,
    String? fallbackText,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        // fallback: 텍스트 공유
        if (fallbackText != null) {
          await Share.share(fallbackText);
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        if (fallbackText != null) {
          await Share.share(fallbackText);
        }
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/flipop_score_$score.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: fallbackText,
      );
    } catch (_) {
      // 이미지 캡처 실패 시 텍스트 fallback
      if (fallbackText != null) {
        await Share.share(fallbackText);
      }
    }
  }
}
