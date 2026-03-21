import 'package:flutter/material.dart';
import '../game/game_state.dart';
import '../game/game_colors.dart';

class BlockWidget extends StatefulWidget {
  final Cell cell;
  final double size;
  final VoidCallback onTap;
  final bool highlighted;

  const BlockWidget({
    super.key,
    required this.cell,
    required this.size,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = GameColors.blockColors[widget.cell.color]!;
    final darkColor = GameColors.blockDarkColors[widget.cell.color]!;
    final imagePath = GameColors.blockImages[widget.cell.color]!;
    final blockType = widget.cell.type;

    final borderRadius = BorderRadius.circular(widget.size * 0.2);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: _buildBorder(blockType),
            boxShadow: [
              BoxShadow(
                color: darkColor.withValues(alpha: 0.4),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
              // bomb: 주황색 글로우
              if (blockType == BlockType.bomb)
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              children: [
                // 기본 블록 이미지
                Padding(
                  padding: EdgeInsets.all(widget.size * 0.08),
                  child: Image.asset(
                    imagePath,
                    width: widget.size * 0.84,
                    height: widget.size * 0.84,
                    fit: BoxFit.contain,
                  ),
                ),

                // rainbow: 무지개 그라디언트 테두리
                if (blockType == BlockType.rainbow)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RainbowBorderPainter(
                        borderRadius: widget.size * 0.2,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),

                // ice: 반투명 파란 오버레이 + 결정 아이콘
                if (blockType == BlockType.ice) ...[
                  Positioned.fill(
                    child: Container(
                      color: Colors.lightBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Icon(
                      Icons.ac_unit_rounded,
                      size: widget.size * 0.35,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],

                // locked: 자물쇠 아이콘 + hitCount 표시
                if (blockType == BlockType.locked) ...[
                  Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: widget.size * 0.4,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (widget.cell.hitCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: widget.size * 0.25,
                        height: widget.size * 0.25,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.cell.hitCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.size * 0.15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 블록 타입별 테두리
  Border? _buildBorder(BlockType type) {
    if (widget.highlighted) {
      return Border.all(color: Colors.white, width: 3);
    }
    switch (type) {
      case BlockType.bomb:
        return Border.all(color: Colors.orange, width: 2.5);
      default:
        return null;
    }
  }
}

/// rainbow 블록 테두리용 커스텀 페인터
class _RainbowBorderPainter extends CustomPainter {
  final double borderRadius;
  final double strokeWidth;

  _RainbowBorderPainter({
    required this.borderRadius,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RainbowBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.strokeWidth != strokeWidth;
}
