import 'dart:math';
import 'package:flutter/material.dart';

class RusticPlank extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final int seed;

  const RusticPlank({
    super.key,
    required this.child,
    this.color = const Color(0xFF4E342E),
    this.padding = const EdgeInsets.all(10),
    this.radius = 14,
    this.seed = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RusticPlankPainter(color: color, seed: seed),
      child: Padding(padding: padding, child: child),
    );
  }
}

class RopeStrap extends StatelessWidget {
  final Alignment alignment;
  final double width;
  final double height;

  const RopeStrap({
    super.key,
    this.alignment = Alignment.topCenter,
    this.width = 180,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: CustomPaint(
          size: Size(width, height),
          painter: _RopePainter(),
        ),
      ),
    );
  }
}

class RusticPlankPainter extends CustomPainter {
  final Color color;
  final int seed;

  const RusticPlankPainter({required this.color, this.seed = 1});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = Random(seed);
    final path = Path()
      ..moveTo(2, 3 + rng.nextDouble() * 2)
      ..lineTo(size.width - 4, 1 + rng.nextDouble() * 3)
      ..lineTo(size.width - 1, size.height - 4)
      ..lineTo(size.width * 0.68, size.height - 2)
      ..lineTo(size.width * 0.64, size.height - 5)
      ..lineTo(size.width * 0.26, size.height - 1)
      ..lineTo(1, size.height - 5)
      ..close();

    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [_lighten(color, .12), color, _darken(color, .16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    final grain = Paint()
      ..color = _darken(color, .22).withValues(alpha: .22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var y = 7.0; y < size.height - 3; y += 7) {
      final line = Path()..moveTo(4, y);
      for (var x = 8.0; x < size.width; x += 16) {
        line.quadraticBezierTo(x + 5, y - 2, x + 11, y + sin(x + seed) * 1.4);
      }
      canvas.drawPath(line, grain);
    }

    final crack = Paint()
      ..color = Colors.black.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final crackPath = Path()
      ..moveTo(size.width * .16, 2)
      ..lineTo(size.width * .13, size.height * .35)
      ..lineTo(size.width * .19, size.height * .55)
      ..lineTo(size.width * .15, size.height - 3)
      ..moveTo(size.width * .84, size.height - 2)
      ..lineTo(size.width * .8, size.height * .62)
      ..lineTo(size.width * .87, size.height * .42);
    canvas.drawPath(crackPath, crack);

    final nail = Paint()..color = const Color(0xFFBCAAA4);
    for (final point in [Offset(9, 8), Offset(size.width - 10, size.height - 9)]) {
      canvas.drawCircle(point, 2.4, Paint()..color = Colors.black.withValues(alpha: .45));
      canvas.drawCircle(point.translate(-.6, -.6), 1.5, nail);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2D1B13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Color _lighten(Color value, double amount) {
    final hsl = HSLColor.fromColor(value);
    return hsl.withLightness((hsl.lightness + amount).clamp(0, 1)).toColor();
  }

  Color _darken(Color value, double amount) {
    final hsl = HSLColor.fromColor(value);
    return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
  }

  @override
  bool shouldRepaint(covariant RusticPlankPainter oldDelegate) =>
      color != oldDelegate.color || seed != oldDelegate.seed;
}

class _RopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rope = Paint()
      ..color = const Color(0xFFD7B27D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * .25)
      ..quadraticBezierTo(size.width * .25, size.height, size.width * .5, size.height * .35)
      ..quadraticBezierTo(size.width * .75, -size.height * .25, size.width, size.height * .55);
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, rope);
    for (var x = 8.0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, size.height * .2), Offset(x + 5, size.height * .65), Paint()..color = const Color(0xFF8D6742)..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
