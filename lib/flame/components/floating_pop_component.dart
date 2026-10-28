import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Floating cartoon text popup for gameplay actions (captures, splits, bonuses).
class FloatingPopComponent extends PositionComponent {
  final String text;
  final Color color;
  final double fontSize;
  final double duration;

  double _elapsed = 0.0;
  final Vector2 _initialPosition;

  FloatingPopComponent({
    required this.text,
    required this.color,
    required Vector2 position,
    this.fontSize = 14.0,
    this.duration = 0.75,
  })  : _initialPosition = position.clone(),
        super(
          position: position,
          size: Vector2(160, 40),
          anchor: Anchor.center,
          priority: 100,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    final progress = (_elapsed / duration).clamp(0.0, 1.0);

    // Float upward with smooth deceleration
    final floatOffset = Curves.easeOutCubic.transform(progress) * 38.0;
    position.y = _initialPosition.y - floatOffset;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / duration).clamp(0.0, 1.0);

    // Scale pop: overshoot bounce at start, settle, then fade out
    double scale = 1.0;
    if (progress < 0.25) {
      final t = progress / 0.25;
      scale = Curves.easeOutBack.transform(t);
    }

    double opacity = 1.0;
    if (progress > 0.6) {
      opacity = (1.0 - (progress - 0.6) / 0.4).clamp(0.0, 1.0);
    }

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scale, scale);

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      fontFamily: 'Bangers',
      letterSpacing: 0.8,
    );

    // 1. Drop shadow / thick outline
    final strokePainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..color = const Color(0xFF1B0000).withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 2. Main colorful text fill
    final fillPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          color: color.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final centerOffset = Offset(-fillPainter.width / 2, -fillPainter.height / 2);
    strokePainter.paint(canvas, centerOffset);
    fillPainter.paint(canvas, centerOffset);

    canvas.restore();
  }
}

/// Cartoon dust burst effect on herd landing or territory claim.
class LandingImpactComponent extends PositionComponent {
  final double duration;
  double _elapsed = 0.0;
  final List<_PuffParticle> _puffs = [];

  LandingImpactComponent({
    required Vector2 position,
    this.duration = 0.4,
  }) : super(
          position: position,
          size: Vector2(60, 60),
          anchor: Anchor.center,
          priority: 90,
        ) {
    final rng = Random();
    const puffCount = 7;
    for (int i = 0; i < puffCount; i++) {
      final angle = (pi * 2 / puffCount) * i + rng.nextDouble() * 0.4;
      final speed = 25.0 + rng.nextDouble() * 30.0;
      final baseSize = 8.0 + rng.nextDouble() * 8.0;
      _puffs.add(_PuffParticle(
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed * 0.65), // flatter perspective
        currentOffset: Vector2.zero(),
        baseRadius: baseSize,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }

    for (final p in _puffs) {
      p.currentOffset.add(p.velocity * dt);
      p.velocity.scale(0.88); // friction deceleration
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final center = Offset(size.x / 2, size.y / 2);

    // Shockwave ring
    final ringRadius = (progress * 28.0) + 6.0;
    final ringPaint = Paint()
      ..color = const Color(0xFFFFF9C4).withValues(alpha: alpha * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, (1.0 - progress) * 3.5);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: ringRadius * 2, height: ringRadius * 1.3),
      ringPaint,
    );

    // Dust puffs
    for (final p in _puffs) {
      final puffPos = center + Offset(p.currentOffset.x, p.currentOffset.y);
      final puffRadius = p.baseRadius * (1.0 + progress * 0.6);

      final puffPaint = Paint()
        ..color = const Color(0xFFF5E6CA).withValues(alpha: alpha * 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(puffPos, puffRadius, puffPaint);

      // Cute little inner dust highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(puffPos + const Offset(-1.5, -1.5), puffRadius * 0.5, highlightPaint);
    }
  }
}

class _PuffParticle {
  final Vector2 velocity;
  final Vector2 currentOffset;
  final double baseRadius;

  _PuffParticle({
    required this.velocity,
    required this.currentOffset,
    required this.baseRadius,
  });
}

