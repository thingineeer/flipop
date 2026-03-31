import 'dart:math';
import 'package:flutter/material.dart';

/// 블록이 사라질 때 터지는 파티클 이펙트
class PopParticle extends StatefulWidget {
  final Offset position;
  final double size;
  final Color color;
  final VoidCallback onComplete;

  const PopParticle({
    super.key,
    required this.position,
    required this.size,
    required this.color,
    required this.onComplete,
  });

  @override
  State<PopParticle> createState() => _PopParticleState();
}

class _PopParticleState extends State<PopParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 6개 파티클 생성
    _particles = List.generate(6, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 30.0 + _random.nextDouble() * 40.0;
      final particleSize = widget.size * (0.12 + _random.nextDouble() * 0.1);
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: particleSize,
      );
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            color: widget.color,
            progress: _controller.value,
            center: widget.position,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;

  _Particle({required this.dx, required this.dy, required this.size});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double progress;
  final Offset center;

  _ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 1.0 + progress * 0.5; // 약간 퍼지는 효과

    for (final p in particles) {
      final x = center.dx + p.dx * progress * scale;
      final y = center.dy + p.dy * progress * scale;
      final particleSize = p.size * (1.0 - progress * 0.5);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);

      // 반짝임 (흰색 하이라이트)
      if (progress < 0.3) {
        final sparkPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), particleSize * 0.4, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
