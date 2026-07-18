import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Visual identity for each module — typographic marks for the live modules
/// (this IS a letters-and-numbers app, so type is the honest icon) and
/// simple drawn glyphs for the locked ones. No emoji anywhere.
class ModuleMark extends StatelessWidget {
  const ModuleMark({
    super.key,
    required this.moduleId,
    this.size = 72,
    this.color = Colors.white,
  });

  final String moduleId;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (moduleId) {
      case 'abcd':
        return Text('Aa', style: AppText.display(size * 0.58, color));
      case 'numbers':
        return Text('123', style: AppText.display(size * 0.48, color));
      case 'colors':
        return _ColorDots(size: size * 0.55);
      case 'fruits':
        return CustomPaint(
          size: Size.square(size * 0.55),
          painter: _ApplePainter(color),
        );
      default:
        return Icon(Icons.circle_outlined, size: size * 0.5, color: color);
    }
  }
}

/// 2×2 paint-dot swatch for the Colors module.
class _ColorDots extends StatelessWidget {
  const _ColorDots({required this.size});

  final double size;

  static const _dots = [
    AppColors.pink,
    AppColors.amber,
    AppColors.primary,
    AppColors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final dot = size / 2.4;
    return SizedBox(
      width: size,
      height: size,
      child: Wrap(
        spacing: size - dot * 2,
        runSpacing: size - dot * 2,
        children: [
          for (final c in _dots)
            Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

/// Minimal apple silhouette (body + stem + leaf) for the Fruits module.
class _ApplePainter extends CustomPainter {
  _ApplePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;

    // Body: two overlapping circles give the classic apple dimple.
    canvas.drawCircle(Offset(w * 0.38, h * 0.62), w * 0.30, paint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.62), w * 0.30, paint);

    // Stem.
    final stem = Paint()
      ..color = color
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.5, h * 0.34), Offset(w * 0.54, h * 0.12), stem);

    // Leaf.
    final leaf = Path()
      ..moveTo(w * 0.56, h * 0.22)
      ..quadraticBezierTo(w * 0.78, h * 0.02, w * 0.88, h * 0.22)
      ..quadraticBezierTo(w * 0.70, h * 0.34, w * 0.56, h * 0.22);
    canvas.drawPath(leaf, paint);
  }

  @override
  bool shouldRepaint(_ApplePainter old) => old.color != color;
}

/// Circular monogram badge used on language cards and stat rows.
class MonogramBadge extends StatelessWidget {
  const MonogramBadge({
    super.key,
    required this.text,
    required this.color,
    this.size = 56,
  });

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: AppShapes.clay(color, radius: size / 2),
      alignment: Alignment.center,
      child: Text(text, style: AppText.display(size * 0.42, Colors.white)),
    );
  }
}
