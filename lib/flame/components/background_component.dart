import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundComponent extends PositionComponent {
  BackgroundComponent({
    required super.position,
    required super.size,
  });

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final gradient = LinearGradient(
      colors: [
        const Color(0xFF1B5E20),
        const Color(0xFF2E7D32),
        const Color(0xFF388E3C),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );

    _drawGrassPattern(canvas);
  }

  void _drawGrassPattern(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 50; i++) {
      final x = (i * 37) % size.x.toInt();
      final y = (i * 53) % size.y.toInt();
      canvas.drawLine(
        Offset(x.toDouble(), y.toDouble()),
        Offset(x.toDouble(), (y - 8).toDouble()),
        paint,
      );
    }
  }
}
