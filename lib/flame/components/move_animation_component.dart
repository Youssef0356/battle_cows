import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/models/player_color.dart';
import '../../game/utils/cow_skin_loader.dart';
import 'hex_cell_component.dart';

class MoveAnimationComponent extends PositionComponent {
  final Vector2 from;
  final Vector2 to;
  final int count;
  final Color color;
  final PlayerColor? playerColor;
  final String? skinOverride;
  final VoidCallback onComplete;

  double _progress = 0;
  ui.Image? _dustImage;
  ui.Image? _cowImage;
  static const double duration = 0.38;

  // Trail dust particles
  final List<_TrailDust> _dustParticles = [];
  double _dustSpawnTimer = 0.0;

  MoveAnimationComponent({
    required this.from,
    required this.to,
    required this.count,
    required this.color,
    this.playerColor,
    this.skinOverride,
    required this.onComplete,
  }) : super(
          position: from,
          size: Vector2(48, 48),
          anchor: Anchor.center,
          priority: 80,
        );

  @override
  Future<void> onLoad() async {
    // 1. Resolve cow sprite
    final colorOwner = playerColor ?? PlayerColor.blue;
    final cowPath = CowSkins.assetFor(colorOwner, skinId: skinOverride);

    if (HexCellComponent.imageCache.containsKey(cowPath)) {
      _cowImage = HexCellComponent.imageCache[cowPath];
    } else {
      try {
        final data = await rootBundle.load(cowPath);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        _cowImage = (await codec.getNextFrame()).image;
        HexCellComponent.imageCache[cowPath] = _cowImage!;
      } catch (_) {}
    }

    // 2. Load dust image if not cached
    if (HexCellComponent.imageCache.containsKey('assets/images/Effects/Stampede Dust.png')) {
      _dustImage = HexCellComponent.imageCache['assets/images/Effects/Stampede Dust.png'];
    } else {
      try {
        final data = await rootBundle.load('assets/images/Effects/Stampede Dust.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        _dustImage = (await codec.getNextFrame()).image;
        HexCellComponent.imageCache['assets/images/Effects/Stampede Dust.png'] = _dustImage!;
      } catch (_) {}
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _progress += dt / duration;

    // Spawn trailing dust puffs behind the running herd
    _dustSpawnTimer += dt;
    if (_dustSpawnTimer >= 0.04 && _progress < 0.92) {
      _dustSpawnTimer = 0.0;
      final rng = Random();
      final jitter = (rng.nextDouble() - 0.5) * 8.0;
      _dustParticles.add(_TrailDust(
        pos: Vector2(position.x + jitter, position.y + 10 + jitter * 0.5),
        radius: 6.0 + rng.nextDouble() * 5.0,
      ));
    }

    // Update trail dust
    for (int i = _dustParticles.length - 1; i >= 0; i--) {
      _dustParticles[i].life -= dt * 3.0;
      if (_dustParticles[i].life <= 0) {
        _dustParticles.removeAt(i);
      }
    }

    if (_progress >= 1.0) {
      _progress = 1.0;
      removeFromParent();
      onComplete();
      return;
    }

    final t = Curves.easeInOutQuad.transform(_progress);
    // Slight arc leap over hexes
    final arc = sin(pi * t) * 16.0;
    position = Vector2(
      from.x + (to.x - from.x) * t,
      from.y + (to.y - from.y) * t - arc,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Render trailing dust puffs in local space relative to current position
    for (final dust in _dustParticles) {
      final localX = dust.pos.x - position.x + size.x / 2;
      final localY = dust.pos.y - position.y + size.y / 2;
      final paint = Paint()
        ..color = const Color(0xFFF0E5D3).withValues(alpha: (dust.life * 0.55).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(localX, localY), dust.radius * (1.0 + (1.0 - dust.life) * 0.5), paint);
    }

    final t = _progress.clamp(0.0, 1.0);
    final movingLeft = to.x < from.x;

    // Gallop trot bounce
    final trot = sin(t * pi * 7).abs() * 5.0;

    // Running bank/tilt angle
    final tilt = (movingLeft ? -1 : 1) * 0.12 * sin(t * pi);

    final centerX = size.x / 2;
    final centerY = size.y / 2 - trot;

    // Ground shadow underneath cow
    final shadowWidth = size.x * 0.65;
    final shadowHeight = size.y * 0.22;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: (0.35 - trot * 0.03).clamp(0.1, 0.4))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, size.y / 2 + 16),
        width: shadowWidth * (1.0 - trot * 0.05),
        height: shadowHeight,
      ),
      shadowPaint,
    );

    // Stampede dust cloud sprite if available
    if (_dustImage != null && t > 0.1 && t < 0.88) {
      final dustSrc = Rect.fromLTWH(0, 0, _dustImage!.width.toDouble(), _dustImage!.height.toDouble());
      final dustDst = Rect.fromCenter(
        center: Offset(movingLeft ? centerX + 16 : centerX - 16, centerY + 10),
        width: size.x * 1.3,
        height: size.y * 0.7,
      );
      canvas.drawImageRect(
        _dustImage!,
        dustSrc,
        dustDst,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = Colors.white.withValues(alpha: 0.65),
      );
    }

    canvas.save();
    canvas.translate(centerX, centerY);
    if (tilt != 0.0) canvas.rotate(tilt);
    if (movingLeft) canvas.scale(-1, 1);

    final cowRadius = size.x * 0.44;

    // 2. Draw animated running cow
    if (_cowImage != null) {
      final src = Rect.fromLTWH(0, 0, _cowImage!.width.toDouble(), _cowImage!.height.toDouble());
      final dst = Rect.fromCircle(center: Offset.zero, radius: cowRadius);
      canvas.drawImageRect(
        _cowImage!,
        src,
        dst,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      // Styled fallback cow piece
      _drawCowPiece(canvas, Offset.zero, cowRadius);
    }

    canvas.restore();

    // 3. Cow Count Badge (always upright and un-flipped)
    final badgeCenter = Offset(
      centerX + (movingLeft ? -cowRadius * 0.5 : cowRadius * 0.5),
      centerY + cowRadius * 0.4,
    );
    _drawBadge(canvas, badgeCenter, cowRadius * 0.85, count, color);
  }

  void _drawBadge(Canvas canvas, Offset center, double diameter, int count, Color teamColor) {
    final radius = diameter / 2;
    // Outer white rim
    canvas.drawCircle(center, radius + 2, Paint()..color = Colors.white);
    // Dark base
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1B0000));
    // Team colored border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = teamColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          fontSize: diameter * 0.72,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFamily: 'Bangers',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - 1),
    );
  }

  void _drawCowPiece(Canvas canvas, Offset center, double radius) {
    final faceGradient = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      colors: [
        _lightenColor(color, 0.3),
        color,
        _darkenColor(color, 0.25),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final cowPainter = TextPainter(
      text: TextSpan(
        text: '🐮',
        style: TextStyle(fontSize: radius * 1.2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    cowPainter.paint(
      canvas,
      Offset(center.dx - cowPainter.width / 2, center.dy - cowPainter.height / 2 - 1),
    );
  }

  Color _lightenColor(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darkenColor(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

class _TrailDust {
  final Vector2 pos;
  final double radius;
  double life = 1.0;

  _TrailDust({required this.pos, required this.radius});
}
