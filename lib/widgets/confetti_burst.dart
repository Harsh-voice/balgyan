import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A dependency-free confetti explosion: ~40 candy-colored pieces fired
/// from the center with gravity, spin, and fade. Overlay it and give it a
/// fresh [burstKey] to replay.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.play});

  final bool play;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _Piece {
  _Piece(Random r)
      : angle = r.nextDouble() * 2 * pi,
        speed = 220 + r.nextDouble() * 320,
        spin = (r.nextDouble() - 0.5) * 14,
        size = 7 + r.nextDouble() * 9,
        color = _palette[r.nextInt(_palette.length)],
        isCircle = r.nextBool();

  static const _palette = AppColors.accents;

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final Color color;
  final bool isCircle;
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  final _random = Random();
  List<_Piece> _pieces = [];

  @override
  void didUpdateWidget(ConfettiBurst old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) {
      _pieces = List.generate(42, (_) => _Piece(_random));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _pieces.isEmpty || _controller.value == 0
              ? null
              : _ConfettiPainter(_pieces, _controller.value),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final paint = Paint();
    for (final p in pieces) {
      final drag = 1 - pow(1 - t, 2).toDouble(); // fast launch, slow finish
      final dx = cos(p.angle) * p.speed * drag;
      final dy = sin(p.angle) * p.speed * drag + 300 * t * t; // gravity
      final pos = center + Offset(dx, dy);
      paint.color = p.color.withValues(alpha: (1 - t).clamp(0, 1));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
