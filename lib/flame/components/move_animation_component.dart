import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MoveAnimationComponent extends PositionComponent {
  final Vector2 from;
  final Vector2 to;
  final int count;
  final Color color;
  final VoidCallback onComplete;

  double _progress = 0;
  static const double duration = 0.4;

  MoveAnimationComponent({
    required this.from,
    required this.to,
    required this.count,
    required this.color,
    required this.onComplete,
  }) : super(position: from);

  @override
  void update(double dt) {
    super.update(dt);
    _progress += dt / duration;
    if (_progress >= 1.0) {
      _progress = 1.0;
      removeFromParent();
      onComplete();
      return;
    }

    final t = Curves.easeInOut.transform(_progress);
    position = Vector2(
      from.x + (to.x - from.x) * t,
      from.y + (to.y - from.y) * t - 20 * sin(pi * t),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = 10.0;
    final darkColor = _darkenColor(color, 0.3);

    for (int i = min(count, 5) - 1; i >= 0; i--) {
      final offset = Offset(0, -i * 6.0);
      _drawCoin(canvas, Offset(size.x / 2, size.y / 2) + offset, radius, color, darkColor);
    }

    if (count > 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.x / 2 - textPainter.width / 2,
          size.y / 2 - textPainter.height / 2 - (min(count, 5) - 1) * 3,
        ),
      );
    }
  }

  void _drawCoin(Canvas canvas, Offset center, double radius, Color faceColor, Color edgeColor) {
    final edgeHeight = radius * 0.25;

    final edgePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + edgeHeight), radius: radius))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(edgePath, Paint()..color = edgeColor);

    final faceGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [
        _lightenColor(faceColor, 0.3),
        faceColor,
        _darkenColor(faceColor, 0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius),
      Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      rimPaint,
    );

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawOval(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      highlightPaint,
    );
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
