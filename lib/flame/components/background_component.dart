import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundComponent extends PositionComponent {
  ui.Image? _bgImage;
  bool _loaded = false;
  String assetPath;

  // Ambient farm pasture life
  final List<_AmbientButterfly> _butterflies = [];
  final List<_FloatingSeed> _seeds = [];
  bool _ambientInitialized = false;

  BackgroundComponent({
    required super.position,
    required super.size,
    this.assetPath = 'assets/images/Background/Table image.jpg',
  });

  @override
  Future<void> onLoad() async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _bgImage = frame.image;
      _loaded = true;
    } catch (_) {
      _loaded = false;
    }
  }

  void _initAmbientLife() {
    if (_ambientInitialized || size.x <= 0 || size.y <= 0) return;
    _ambientInitialized = true;

    final rng = Random();

    // 2 playful cartoon butterflies
    _butterflies.add(_AmbientButterfly(
      pos: Vector2(size.x * 0.25, size.y * 0.4),
      color: const Color(0xFFFFEE58), // bright dandelion yellow
      accentColor: const Color(0xFFFF9800),
      bounds: size,
    ));
    _butterflies.add(_AmbientButterfly(
      pos: Vector2(size.x * 0.75, size.y * 0.6),
      color: const Color(0xFF80D8FF), // pastel sky blue
      accentColor: const Color(0xFF00B0FF),
      bounds: size,
    ));

    // 12 gentle floating meadow seeds / sun motes
    for (int i = 0; i < 12; i++) {
      _seeds.add(_FloatingSeed(
        x: rng.nextDouble() * size.x,
        y: rng.nextDouble() * size.y,
        speedX: 10.0 + rng.nextDouble() * 16.0,
        wobbleFreq: 1.2 + rng.nextDouble() * 1.5,
        wobbleAmp: 8.0 + rng.nextDouble() * 12.0,
        radius: 1.5 + rng.nextDouble() * 1.8,
        phase: rng.nextDouble() * pi * 2,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_ambientInitialized) {
      _initAmbientLife();
    }

    for (final b in _butterflies) {
      b.update(dt, size);
    }
    for (final s in _seeds) {
      s.update(dt, size);
    }
  }

  Future<void> setAsset(String path) async {
    assetPath = path;
    _loaded = false;
    _bgImage = null;
    await onLoad();
  }

  @override
  void render(Canvas canvas) {
    if (_loaded && _bgImage != null) {
      final imgW = _bgImage!.width.toDouble();
      final imgH = _bgImage!.height.toDouble();
      final scaleX = size.x / imgW;
      final scaleY = size.y / imgH;
      final scale = scaleX > scaleY ? scaleX : scaleY;
      final scaledW = imgW * scale;
      final scaledH = imgH * scale;
      final offsetX = (size.x - scaledW) / 2;
      final offsetY = (size.y - scaledH) / 2;

      final src = Rect.fromLTWH(0, 0, imgW, imgH);
      final dst = Rect.fromLTWH(offsetX, offsetY, scaledW, scaledH);
      canvas.drawImageRect(_bgImage!, src, dst, Paint()..filterQuality = FilterQuality.low);

      final fadePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.20),
            Colors.black.withValues(alpha: 0.05),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.20),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fadePaint);

      final fadePaintV = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.16),
            Colors.black.withValues(alpha: 0.04),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.04),
            Colors.black.withValues(alpha: 0.16),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fadePaintV);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..shader = const LinearGradient(
          colors: [Color(0xFF1B3A1B), Color(0xFF0D2B0D), Color(0xFF1B3A1B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
      );
    }

    // Render Ambient Meadow Particles
    _renderAmbientLife(canvas);
  }

  void _renderAmbientLife(Canvas canvas) {
    // 1. Floating sun seeds
    for (final s in _seeds) {
      final alpha = (0.22 + 0.16 * sin(s.phase)).clamp(0.08, 0.45);
      final glowPaint = Paint()
        ..color = const Color(0xFFFFF9C4).withValues(alpha: alpha * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(s.x, s.y), s.radius * 1.5, glowPaint);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(s.x, s.y), s.radius, corePaint);
    }

    // 2. Fluttering butterflies
    for (final b in _butterflies) {
      b.render(canvas);
    }
  }
}

class _AmbientButterfly {
  Vector2 pos;
  Vector2 target;
  final Color color;
  final Color accentColor;
  double flapTimer = 0.0;
  double restTimer = 0.0;
  double angle = 0.0;
  static final Random _rng = Random();

  _AmbientButterfly({
    required this.pos,
    required this.color,
    required this.accentColor,
    required Vector2 bounds,
  }) : target = _pickTarget(bounds);

  static Vector2 _pickTarget(Vector2 bounds) {
    final w = bounds.x > 50 ? bounds.x : 400.0;
    final h = bounds.y > 50 ? bounds.y : 600.0;
    return Vector2(
      w * 0.1 + _rng.nextDouble() * (w * 0.8),
      h * 0.15 + _rng.nextDouble() * (h * 0.7),
    );
  }

  void update(double dt, Vector2 bounds) {
    flapTimer += dt * 14.0;

    if (restTimer > 0) {
      restTimer -= dt;
      return;
    }

    final toTarget = target - pos;
    final dist = toTarget.length;

    if (dist < 25.0) {
      // Pick next target, occasionally resting for a second
      target = _pickTarget(bounds);
      if (_rng.nextDouble() < 0.25) {
        restTimer = 0.8 + _rng.nextDouble() * 1.2;
      }
      return;
    }

    // Move smoothly towards target with small organic flutter oscillation
    final dir = toTarget.normalized();
    final flutterOsc = sin(flapTimer * 0.5) * 15.0;
    final speed = 35.0;

    pos.x += (dir.x * speed) * dt;
    pos.y += (dir.y * speed + flutterOsc) * dt;

    // Smooth heading rotation
    final desiredAngle = atan2(dir.y, dir.x);
    angle += (desiredAngle - angle) * (dt * 3.5);
  }

  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(pos.x, pos.y);
    canvas.rotate(angle);

    final wingFlap = cos(flapTimer).abs().clamp(0.12, 1.0);

    // Left wing
    final leftWingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-8 * wingFlap, -10, -12 * wingFlap, -5)
      ..quadraticBezierTo(-10 * wingFlap, 5, 0, 2)
      ..close();
    canvas.drawPath(leftWingPath, Paint()..color = color.withValues(alpha: 0.88));
    canvas.drawPath(
      leftWingPath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Right wing
    final rightWingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(8 * wingFlap, -10, 12 * wingFlap, -5)
      ..quadraticBezierTo(10 * wingFlap, 5, 0, 2)
      ..close();
    canvas.drawPath(rightWingPath, Paint()..color = color.withValues(alpha: 0.88));
    canvas.drawPath(
      rightWingPath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Tiny cute body
    final bodyPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 0), width: 2.2, height: 7.0), bodyPaint);

    canvas.restore();
  }
}

class _FloatingSeed {
  double x;
  double y;
  final double speedX;
  final double wobbleFreq;
  final double wobbleAmp;
  final double radius;
  double phase;

  _FloatingSeed({
    required this.x,
    required this.y,
    required this.speedX,
    required this.wobbleFreq,
    required this.wobbleAmp,
    required this.radius,
    required this.phase,
  });

  void update(double dt, Vector2 bounds) {
    phase += dt * wobbleFreq;
    x += speedX * dt;
    y += sin(phase) * (wobbleAmp * dt);

    if (x > bounds.x + 20) {
      x = -20;
      y = Random().nextDouble() * bounds.y;
    }
  }
}
