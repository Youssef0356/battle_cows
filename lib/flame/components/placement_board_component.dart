import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/models/hex_position.dart';
import '../battle_cows_game.dart';

/// Renders the pasture board in Flame during the tile placement phase.
/// Draws all placed hexes with 3D bevels, textures, juicy stamp/scale animations,
/// shockwave ripples, and the live preview tile.
class PlacementBoardComponent extends PositionComponent {
  final BattleCowsGame game;
  final double hexSize;
  ui.Image? _texture;
  double _pulseTime = 0;

  List<HexPosition>? _animatingHexes;
  double _animTimer = 0.0;

  PlacementBoardComponent({
    required this.game,
    this.hexSize = 30.0,
  }) : super(
          position: Vector2.zero(),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final data = await rootBundle.load('assets/images/Tile Image/Tile Texture.jpg');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _texture = frame.image;
    } catch (_) {}
  }

  void triggerStampAnimation(List<HexPosition> hexes) {
    _animatingHexes = List.from(hexes);
    _animTimer = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;

    if (_animatingHexes != null) {
      _animTimer += dt;
      if (_animTimer > 0.45) {
        _animatingHexes = null;
      }
    }
  }

  Vector2 hexToPixel(HexPosition hex) {
    final x = hexSize * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = hexSize * (3.0 / 2 * hex.r);
    return Vector2(x, y);
  }

  Path _createHexPath(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final pt = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  void render(Canvas canvas) {
    final placedHexes = game.boardBuilder.placedHexes;
    final currentTile = game.currentTile;
    final tileOffset = game.tileOffset;
    final canPlace = game.canPlaceCurrentTile;

    // 1. Center guide if board is empty
    if (placedHexes.isEmpty) {
      _drawCenterGuide(canvas);
    }

    // 2. Render all placed hexes (with scale animation if newly placed)
    for (final hex in placedHexes) {
      final pt = hexToPixel(hex);
      final center = Offset(pt.x, pt.y);
      _drawPlacedHex(canvas, center, hex);
    }

    // 3. Render ripple shockwave rings for newly placed hexes
    if (_animatingHexes != null && _animatingHexes!.isNotEmpty) {
      final t = (_animTimer / 0.42).clamp(0.0, 1.0);
      final rippleAlpha = ((1.0 - t) * 0.7).clamp(0.0, 1.0);

      for (final hex in _animatingHexes!) {
        final pt = hexToPixel(hex);
        final center = Offset(pt.x, pt.y);
        final rippleRadius = hexSize * (1.1 + t * 1.5);

        canvas.drawCircle(
          center,
          rippleRadius,
          Paint()
            ..color = const Color(0xFFFFD54F).withValues(alpha: rippleAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 * (1.0 - t) + 0.5,
        );
      }
    }

    // 4. Render current preview tile
    if (currentTile != null) {
      final preview = currentTile.translate(tileOffset);
      final pulse = (sin(_pulseTime * 4.5) + 1.0) / 2.0; // 0.0 to 1.0

      for (final hex in preview.hexes) {
        final pt = hexToPixel(hex);
        final center = Offset(pt.x, pt.y);
        _drawPreviewHex(canvas, center, canPlace, pulse);
      }
    }
  }

  void _drawCenterGuide(Canvas canvas) {
    final pulse = (sin(_pulseTime * 3.0) + 1.0) / 2.0;
    final guideRadius = hexSize * 2.8;

    final ringPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25 + pulse * 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, guideRadius, ringPaint);

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.12 + pulse * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset.zero, guideRadius, glowPaint);
  }

  void _drawPlacedHex(Canvas canvas, Offset center, HexPosition hex) {
    final isAnimating = _animatingHexes != null && _animatingHexes!.contains(hex);
    final t = (_animTimer / 0.42).clamp(0.0, 1.0);
    // Punchy drop scale: drops from 1.35 down to 1.0 with elastic bounce
    final scale = isAnimating ? (1.0 + (1.0 - t) * 0.38 * (1.0 + sin(t * pi * 2) * 0.2)) : 1.0;

    if (isAnimating) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
    }

    final path = _createHexPath(center, hexSize * 0.98);
    final depthOffset = hexSize * 0.14;

    // 3D Depth bevel
    final sidePath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final topPt = Offset(
        center.dx + hexSize * 0.98 * cos(angle),
        center.dy + hexSize * 0.98 * sin(angle),
      );
      if (i == 0) {
        sidePath.moveTo(topPt.dx, topPt.dy);
      } else {
        sidePath.lineTo(topPt.dx, topPt.dy);
      }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i - pi / 6;
      final botPt = Offset(
        center.dx + hexSize * 0.98 * cos(angle),
        center.dy + hexSize * 0.98 * sin(angle) + depthOffset,
      );
      sidePath.lineTo(botPt.dx, botPt.dy);
    }
    sidePath.close();

    // Side bevel gradient
    final sidePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5A3D1E), Color(0xFF2E1C0C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(center.dx - hexSize, center.dy, hexSize * 2, depthOffset));
    canvas.drawPath(sidePath, sidePaint);

    // Drop shadow
    final shadowPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final pt = Offset(
        center.dx + hexSize * 0.98 * cos(angle),
        center.dy + hexSize * 0.98 * sin(angle) + depthOffset + 2,
      );
      if (i == 0) {
        shadowPath.moveTo(pt.dx, pt.dy);
      } else {
        shadowPath.lineTo(pt.dx, pt.dy);
      }
    }
    shadowPath.close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Grass fill (texture or gradient)
    canvas.save();
    canvas.clipPath(path);

    if (_texture != null) {
      final imgSize = hexSize * 1.96;
      final src = Rect.fromLTWH(0, 0, _texture!.width.toDouble(), _texture!.height.toDouble());
      final dst = Rect.fromLTWH(center.dx - hexSize * 0.98, center.dy - hexSize * 0.98, imgSize, imgSize);
      canvas.drawImageRect(_texture!, src, dst, Paint()..filterQuality = FilterQuality.medium);
    } else {
      final shades = [
        const Color(0xFF689F38),
        const Color(0xFF558B2F),
        const Color(0xFF7CB342),
      ];
      final shade = shades[(hex.q.abs() + hex.r.abs()) % shades.length];
      canvas.drawPath(path, Paint()..color = shade);
    }

    canvas.restore();

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    if (isAnimating) {
      canvas.restore();
    }
  }

  void _drawPreviewHex(Canvas canvas, Offset center, bool canPlace, double pulse) {
    final radius = hexSize * (1.0 + pulse * 0.05);
    final path = _createHexPath(center, radius);

    final fillColor = canPlace
        ? const Color(0xFF4CAF50).withValues(alpha: 0.45 + pulse * 0.2)
        : const Color(0xFFF44336).withValues(alpha: 0.45 + pulse * 0.2);

    final borderColor = canPlace
        ? Color.lerp(const Color(0xFF76FF03), const Color(0xFFB2FF59), pulse)!
        : Color.lerp(const Color(0xFFFF5252), const Color(0xFFFF1744), pulse)!;

    // Glowing shadow
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor.withValues(alpha: 0.5 + pulse * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Fill
    canvas.drawPath(path, Paint()..color = fillColor);

    // Pulsing Border
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8 + pulse * 1.0,
    );

    // Small center accent (cow clover/target)
    final dotPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, dotPaint);
  }
}
