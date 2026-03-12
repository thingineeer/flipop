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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.size * 0.2),
            border: widget.highlighted
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: darkColor.withValues(alpha: 0.4),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size * 0.2),
            child: Padding(
              padding: EdgeInsets.all(widget.size * 0.08),
              child: Image.asset(
                imagePath,
                width: widget.size * 0.84,
                height: widget.size * 0.84,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
