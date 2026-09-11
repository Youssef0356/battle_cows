import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/models/hex_cell.dart';
import '../../game/models/herd.dart';
import '../../core/constants/colors.dart';

class HexCellComponent extends PositionComponent {
  final HexCell cell;
  Herd? herd;
  bool isSelected;
  bool isValidMove;
  double pulseValue;
  final int flipMode;
  final ui.Image? texture;
  PlayerColor? territoryOwner;
  ui.Image? _specialImage;
  ui.Image? _cowImage;
  double _lifeTime = 0;

  HexCellComponent({
    required this.cell,
    this.herd,
    this.isSelected = false,
    this.isValidMove = false,
    this.pulseValue = 0.0,
    required super.position,
    required super.size,
    this.flipMode = 0,
    this.texture,
    this.territoryOwner,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _specialImage = await _loadImage(_specialAssetPath);
    _cowImage = await _loadImage(_cowAssetPath);
  }

  String? get _specialAssetPath {
    switch (cell.specialType) {
      case SpecialTileType.mud:
        return 'assets/images/Board Tiles/tile_mud.png';
      case SpecialTileType.waterPond:
        return 'assets/images/Board Tiles/tile_water_pond.png';
      case SpecialTileType.hayBale:
        return 'assets/images/Board Tiles/tile_hay_bale.png';
      case SpecialTileType.goldenPasture:
        return 'assets/images/Board Tiles/tile_golden_pasture.png';
      case SpecialTileType.hill:
        return 'assets/images/Board Tiles/tile_hill.png';
      case SpecialTileType.none:
        return null;
    }
  }

  String? get _cowAssetPath {
    if (herd == null) return null;
    switch (herd!.owner) {
      case PlayerColor.blue:
        return 'assets/images/Cows/cow_viking.png';
      case PlayerColor.red:
        return 'assets/images/Cows/cow_cowboy.png';
      case PlayerColor.yellow:
        return 'assets/images/Cows/cow_farmer.png';
      case PlayerColor.purple:
        return 'assets/images/Cows/cow_disco.png';
    }
  }

  Future<ui.Image?> _loadImage(String? path) async {
    if (path == null) return null;
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    } catch (_) {
      return null;
    }
  }

  void setHerd(Herd? value) {
    herd = value;
    _cowImage = null;
    _loadImage(_cowAssetPath).then((image) {
      _cowImage = image;
    });
  }

  @override
  void render(Canvas canvas) {
    _lifeTime += 0.016;
    final center = Vector2(size.x / 2, size.y / 2);
    final hexRadius = size.x / 2;

    final path = _createHexPath(center, hexRadius);

    _draw3DDepth(canvas, path, center, hexRadius);
    _drawHexFill(canvas, path, center, hexRadius);
    _drawHexBorder(canvas, path);

    if (cell.isObstacle) {
      _drawObstacleFenceOrRock(canvas, center, hexRadius);
    }

    if (isSelected) {
      _drawSelectionGlow(canvas, path);
    }

    if (isValidMove) {
      _drawValidMoveDashedOutline(canvas, center, hexRadius);
    }

    if (cell.specialType != SpecialTileType.none) {
      _drawSpecialTile(canvas, center, hexRadius);
    }

    if (herd != null && herd!.size > 0) {
      final bob = sin(_lifeTime * 2.2 + cell.position.q * 0.8 + cell.position.r * 0.45) * 2.2;
      if (_cowImage != null) {
        _drawAsset(canvas, _cowImage!, center, hexRadius * 0.78, bob);
      } else {
        _drawCowPieceWithShield(canvas, Vector2(center.x, center.y + bob), hexRadius);
      }
    }
  }

  Path _createHexPath(Vector2 center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _draw3DDepth(Canvas canvas, Path path, Vector2 center, double radius) {
    final depthOffset = radius * 0.14;
    final sidePath = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final topPoint = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle),
      );

      if (i == 0) {
        sidePath.moveTo(topPoint.dx, topPoint.dy);
      } else {
        sidePath.lineTo(topPoint.dx, topPoint.dy);
      }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i - pi / 6;
      final bottomPoint = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle) + depthOffset,
      );
      sidePath.lineTo(bottomPoint.dx, bottomPoint.dy);
    }
    sidePath.close();

    final sidePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5A3D1E), Color(0xFF321E0B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, center.y, size.x, depthOffset));

    canvas.drawPath(sidePath, sidePaint);

    final shadowPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.x + radius * cos(angle),
        center.y + radius * sin(angle) + depthOffset + 3,
      );
      if (i == 0) {
        shadowPath.moveTo(point.dx, point.dy);
      } else {
        shadowPath.lineTo(point.dx, point.dy);
      }
    }
    shadowPath.close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawHexFill(Canvas canvas, Path path, Vector2 center, double radius) {
    canvas.save();
    canvas.clipPath(path);

    if (texture != null && !cell.isObstacle) {
      _drawTexture(canvas, center, radius);
    } else if (cell.isObstacle) {
      canvas.drawPath(path, Paint()..color = const Color(0xFF4E342E));
    } else {
      final grassShades = [
        const Color(0xFF689F38),
        const Color(0xFF7CB342),
        const Color(0xFF558B2F),
      ];
      canvas.drawPath(path, Paint()..color = grassShades[cell.position.q.abs() % 3]);
    }

    if (territoryOwner != null && (herd == null || herd!.size == 0)) {
      final tint = AppColors.getPlayerPrimary(territoryOwner!).withValues(alpha: 0.15);
      canvas.drawPath(path, Paint()..color = tint);
    }

    if (herd != null && herd!.size > 0) {
      final tint = AppColors.getPlayerPrimary(herd!.owner).withValues(alpha: 0.3);
      canvas.drawPath(path, Paint()..color = tint);
    }

    canvas.restore();
  }

  void _drawTexture(Canvas canvas, Vector2 center, double radius) {
    if (texture == null) return;

    final imgSize = radius * 2.0;
    final src = Rect.fromLTWH(0, 0, texture!.width.toDouble(), texture!.height.toDouble());
    final dst = Rect.fromLTWH(
      center.x - radius,
      center.y - radius,
      imgSize,
      imgSize,
    );

    canvas.save();
    if (flipMode == 1) {
      canvas.translate(center.x, center.y);
      canvas.scale(-1, 1);
      canvas.translate(-center.x, -center.y);
    } else if (flipMode == 2) {
      canvas.translate(center.x, center.y);
      canvas.scale(1, -1);
      canvas.translate(-center.x, -center.y);
    } else if (flipMode == 3) {
      canvas.translate(center.x, center.y);
      canvas.scale(-1, -1);
      canvas.translate(-center.x, -center.y);
    }

    canvas.drawImageRect(texture!, src, dst, Paint()..filterQuality = FilterQuality.medium);
    canvas.restore();
  }

  void _drawHexBorder(Canvas canvas, Path path) {
    final borderPaint = Paint()
      ..color = const Color(0xFF33691E).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  void _drawObstacleFenceOrRock(Canvas canvas, Vector2 center, double radius) {
    final isFence = (cell.position.q + cell.position.r) % 2 == 0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: isFence ? '🪵' : '🪨',
        style: TextStyle(fontSize: radius * 0.9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.x - textPainter.width / 2, center.y - textPainter.height / 2),
    );
  }

  void _drawSelectionGlow(Canvas canvas, Path path) {
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.6 + pulseValue * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 + pulseValue * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
  }

  void _drawValidMoveDashedOutline(Canvas canvas, Vector2 center, double radius) {
    final dashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw dashed hex perimeter
    final innerRadius = radius * 0.9;
    for (var i = 0; i < 6; i++) {
      final a1 = (pi / 3) * i - pi / 6;
      final a2 = (pi / 3) * (i + 1) - pi / 6;
      final p1 = Offset(center.x + innerRadius * cos(a1), center.y + innerRadius * sin(a1));
      final p2 = Offset(center.x + innerRadius * cos(a2), center.y + innerRadius * sin(a2));

      final mid1 = Offset(p1.dx * 0.65 + p2.dx * 0.35, p1.dy * 0.65 + p2.dy * 0.35);
      final mid2 = Offset(p1.dx * 0.35 + p2.dx * 0.65, p1.dy * 0.35 + p2.dy * 0.65);

      canvas.drawLine(p1, mid1, dashPaint);
      canvas.drawLine(mid2, p2, dashPaint);
    }
  }

  void _drawCowPieceWithShield(Canvas canvas, Vector2 center, double radius) {
    final herdSize = herd!.size;
    final primaryColor = AppColors.getPlayerPrimary(herd!.owner);
    final darkColor = AppColors.getPlayerDark(herd!.owner);
    final pieceRadius = radius * 0.55;

    // 1. 3D Hexagonal / Octagonal Pedestal Base
    final pedestalPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final point = Offset(
        center.x + pieceRadius * cos(angle),
        center.y + pieceRadius * sin(angle),
      );
      if (i == 0) {
        pedestalPath.moveTo(point.dx, point.dy);
      } else {
        pedestalPath.lineTo(point.dx, point.dy);
      }
    }
    pedestalPath.close();

    // Pedestal Depth / Shadow
    final pedDepth = pieceRadius * 0.25;
    final pedSidePath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final point = Offset(center.x + pieceRadius * cos(angle), center.y + pieceRadius * sin(angle));
      if (i == 0) {
        pedSidePath.moveTo(point.dx, point.dy);
      } else {
        pedSidePath.lineTo(point.dx, point.dy);
      }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i;
      final point = Offset(center.x + pieceRadius * cos(angle), center.y + pieceRadius * sin(angle) + pedDepth);
      pedSidePath.lineTo(point.dx, point.dy);
    }
    pedSidePath.close();

    canvas.drawPath(pedSidePath, Paint()..color = darkColor);

    // Pedestal Face Gradient
    final faceGradient = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      colors: [
        _lightenColor(primaryColor, 0.3),
        primaryColor,
        darkColor,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    canvas.drawPath(
      pedestalPath,
      Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: Offset(center.x, center.y), radius: pieceRadius)),
    );

    // White Pedestal Rim
    canvas.drawPath(
      pedestalPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 2. Cow Face Center Avatar
    final cowPainter = TextPainter(
      text: TextSpan(
        text: '🐮',
        style: TextStyle(fontSize: pieceRadius * 1.1),
      ),
      textDirection: TextDirection.ltr,
    );
    cowPainter.layout();
    cowPainter.paint(
      canvas,
      Offset(center.x - cowPainter.width / 2, center.y - cowPainter.height / 2 - 2),
    );

    // 3. Shield Badge with Stack Count (Bottom-Right / Center-Bottom)
    final shieldWidth = pieceRadius * 0.75;
    final shieldHeight = pieceRadius * 0.85;
    final shieldCenter = Offset(center.x + pieceRadius * 0.35, center.y + pieceRadius * 0.3);

    _drawShieldBadge(canvas, shieldCenter, shieldWidth, shieldHeight, herdSize, primaryColor);
  }

  void _drawSpecialTile(Canvas canvas, Vector2 center, double radius) {
    if (_specialImage != null) {
      _drawAsset(canvas, _specialImage!, center, radius * 0.78, 0);
      return;
    }
    final details = switch (cell.specialType) {
      SpecialTileType.mud => ('MUD', const Color(0xFF6D4C41)),
      SpecialTileType.hayBale => ('HAY', const Color(0xFFFFC107)),
      SpecialTileType.waterPond => ('💧', const Color(0xFF29B6F6)),
      SpecialTileType.goldenPasture => ('★', const Color(0xFFFFD54F)),
      SpecialTileType.hill => ('▲', const Color(0xFFBDBDBD)),
      SpecialTileType.none => ('', Colors.transparent),
    };
    canvas.drawCircle(
      Offset(center.x, center.y),
      radius * .34,
      Paint()..color = details.$2.withValues(alpha: .78),
    );
    final painter = TextPainter(
      text: TextSpan(
        text: details.$1,
        style: TextStyle(
          fontSize: radius * (details.$1.length > 2 ? .24 : .46),
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(center.x - painter.width / 2, center.y - painter.height / 2));
  }

  void _drawAsset(Canvas canvas, ui.Image image, Vector2 center, double radius, double yOffset) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromCircle(center: Offset(center.x, center.y + yOffset), radius: radius);
    canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.medium);
  }

  void _drawShieldBadge(Canvas canvas, Offset center, double width, double height, int count, Color teamColor) {
    final hw = width / 2;
    final hh = height / 2;

    final shieldPath = Path()
      ..moveTo(center.dx - hw, center.dy - hh)
      ..lineTo(center.dx + hw, center.dy - hh)
      ..lineTo(center.dx + hw, center.dy)
      ..quadraticBezierTo(center.dx + hw, center.dy + hh, center.dx, center.dy + hh)
      ..quadraticBezierTo(center.dx - hw, center.dy + hh, center.dx - hw, center.dy)
      ..close();

    // Shield shadow & fill
    canvas.drawPath(
      shieldPath,
      Paint()..color = const Color(0xFF1B0000).withValues(alpha: 0.85),
    );

    // Shield border
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          fontSize: height * 0.65,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFamily: 'Bangers',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - 1),
    );
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  // ignore: unused_element
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static int getFlipMode(int q, int r) {
    return (q * 7 + r * 13 + q * r * 3).abs() % 4;
  }
}
