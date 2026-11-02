import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../assets/asset_paths.dart';
import '../../game/models/hex_cell.dart';
import '../../game/models/herd.dart';
import '../../core/constants/colors.dart';
import '../../game/utils/cow_skin_loader.dart';

class HexCellComponent extends PositionComponent {
  HexCell cell;
  Herd? herd;
  bool isSelected;
  bool isValidMove;
  double pulseValue;
  final int flipMode;
  ui.Image? texture;
  PlayerColor? territoryOwner;

  /// Player whose turn it is.
  PlayerColor? turnOwner;
  ui.Image? _specialImage;
  ui.Image? _cowImage;
  double _lifeTime = 0;
  double _bounceTimer = 0.0;

  bool _isTrapped = false;
  bool get isTrapped => _isTrapped;
  set isTrapped(bool val) {
    if (_isTrapped != val) {
      _isTrapped = val;
      refreshHerdImages();
    }
  }

  void triggerBounce() {
    _bounceTimer = 0.35;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime += dt;
    if (_bounceTimer > 0) {
      _bounceTimer = max(0.0, _bounceTimer - dt);
    }
  }

  static final Map<String, ui.Image> imageCache = {};

  static Future<void> precacheAllAssets() async {
    final paths = [
      AssetPaths.hexNeutralPasture,
      AssetPaths.hexPlayer1Claimed,
      AssetPaths.hexPlayer2Claimed,
      AssetPaths.hexValidMoveHighlight,
      AssetPaths.hexBlockedTrapped,
      AssetPaths.cowP1HolsteinIdle,
      AssetPaths.cowP1HolsteinLeap,
      AssetPaths.cowP1HolsteinDizzy,
      AssetPaths.cowP2HighlandIdle,
      AssetPaths.cowP2HighlandLeap,
      AssetPaths.cowP2HighlandDizzy,
      AssetPaths.stackCounterBadge,
      AssetPaths.landingDustBurst,
      'assets/images/Cows/cow_viking.png',
      'assets/images/Cows/cow_cowboy.png',
      'assets/images/Cows/cow_farmer.png',
      'assets/images/Cows/cow_disco.png',
      'assets/images/Board Tiles/tile_fence_gate.png',
      'assets/images/Board Tiles/tile_mud.png',
      'assets/images/Board Tiles/tile_water_pond.png',
      'assets/images/Board Tiles/tile_hay_bale.png',
      'assets/images/Board Tiles/tile_golden_pasture.png',
      'assets/images/Board Tiles/tile_hill.png',
    ];
    for (final path in paths) {
      if (!imageCache.containsKey(path)) {
        try {
          final data = await rootBundle.load(path);
          final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
          final frame = await codec.getNextFrame();
          imageCache[path] = frame.image;
        } catch (_) {}
      }
    }
  }

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
    this.skinOwnerColor,
    this.skinOverride,
  }) : super(anchor: Anchor.center);

  /// Shop skin id (e.g. `skin_cowboy`). When non-empty it replaces the
  /// color-based cow sprite for herds owned by [skinOwnerColor].
  String? skinOverride;
  PlayerColor? skinOwnerColor;

  /// Swaps the equipped skin and re-resolves the cow sprite immediately.
  void applySkin(PlayerColor? owner, String? skin) {
    skinOwnerColor = owner;
    skinOverride = skin;
    refreshHerdImages();
  }

  /// Swaps the board tile texture immediately.
  void applyTexture(ui.Image? image) {
    texture = image;
  }

  @override
  Future<void> onLoad() async {
    _specialImage = await _loadImage(_specialAssetPath);
    _cowImage = await _loadImage(_cowAssetPath);
  }

  void updateSpecialImage() {
    final path = _specialAssetPath;
    if (path == null) {
      _specialImage = null;
    } else if (imageCache.containsKey(path)) {
      _specialImage = imageCache[path];
    } else {
      _loadImage(path).then((img) => _specialImage = img);
    }
  }

  String? get _specialAssetPath {
    switch (cell.specialType) {
      case SpecialTileType.mud:
        return 'assets/images/Board Tiles/tile_mud.png';
      case SpecialTileType.waterPond:
        return 'assets/images/Board Tiles/tile_water_pond.png';
      case SpecialTileType.hayBale:
        return 'assets/images/Board Tiles/tile_hay_bale.png';
      case SpecialTileType.fenceGate:
        return 'assets/images/Board Tiles/tile_fence_gate.png';
      case SpecialTileType.goldenPasture:
        return 'assets/images/Board Tiles/tile_golden_pasture.png';
      case SpecialTileType.none:
        return null;
    }
  }

  String? get _cowAssetPath {
    if (herd == null || herd!.size == 0) return null;
    final pose = _isTrapped ? CowPose.dizzy : CowPose.idle;
    if (skinOverride != null &&
        skinOverride!.isNotEmpty &&
        skinOwnerColor == herd!.owner) {
      return CowSkins.assetFor(herd!.owner, skinId: skinOverride, pose: pose);
    }
    return CowSkins.assetFor(herd!.owner, pose: pose);
  }

  /// Re-resolves the cow sprite for the current herd.
  void refreshHerdImages() {
    final path = _cowAssetPath;
    if (path == null) {
      _cowImage = null;
      return;
    }
    if (imageCache.containsKey(path)) {
      _cowImage = imageCache[path];
    } else {
      _loadImage(path).then((image) {
        _cowImage = image;
      });
    }
  }

  Future<ui.Image?> _loadImage(String? path) async {
    if (path == null) return null;
    if (imageCache.containsKey(path)) return imageCache[path];
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final image = (await codec.getNextFrame()).image;
      imageCache[path] = image;
      return image;
    } catch (_) {
      return null;
    }
  }

  void setHerd(Herd? value) {
    herd = value;
    refreshHerdImages();
  }

  @override
  void render(Canvas canvas) {
    final center = Vector2(size.x / 2, size.y / 2);
    final hexRadius = size.x / 2;
    final path = _createHexPath(center, hexRadius);

    // 1. Draw 2.5D Hex Tile Sprite (Neutral, Claimed Blue, Claimed Red, Valid Move, or Blocked Fence)
    _drawHexSprite(canvas, path, center, hexRadius);

    // 2. Golden Pasture special aura
    if (cell.specialType == SpecialTileType.goldenPasture) {
      final goldenPulse = (sin(_lifeTime * 3.5) + 1.0) / 2.0;
      final goldGlow = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.35 + goldenPulse * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 + goldenPulse * 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, goldGlow);
    }

    // 3. Draw special collectible / terrain props
    if (cell.specialType != SpecialTileType.none && _specialImage != null) {
      _drawSpecialProp(canvas, _specialImage!, center, hexRadius);
    }

    // 4. Selection glow
    if (isSelected) {
      _drawSelectionGlow(canvas, path);
    }

    // 5. Valid move indicator (neon mint glow hex asset already renders, plus pulse)
    if (isValidMove) {
      _drawValidMovePulse(canvas, center, hexRadius);
    }

    // 6. Cow Herd & Stack Counter Badge
    if (herd != null && herd!.size > 0) {
      double squashX = 1.0;
      double squashY = 1.0;
      double yOffset = 0.0;
      double rotation = 0.0;

      // Landing bounce squash-and-stretch
      if (_bounceTimer > 0) {
        final t = 1.0 - (_bounceTimer / 0.35);
        final wave = sin(t * pi * 3.5) * exp(-3.0 * t);
        squashX += wave * 0.22;
        squashY -= wave * 0.22;
      }

      // Dizzy wobble when boxed in vs. playful idle breathing
      if (_isTrapped) {
        // Dizzy head wobble & disoriented bobbing
        rotation = sin(_lifeTime * 9.0) * 0.09;
        yOffset = sin(_lifeTime * 4.5) * 2.0;
        squashX += sin(_lifeTime * 3.0) * 0.02;
        squashY -= sin(_lifeTime * 3.0) * 0.02;
      } else if (isSelected) {
        final hop = sin(_lifeTime * 9.0).abs() * 5.0;
        yOffset -= hop;
        rotation = sin(_lifeTime * 12.0) * 0.07;
        squashX += 0.04;
        squashY -= 0.04;
      } else {
        // Idle gentle breathing
        final breath = sin(_lifeTime * 2.5 + cell.position.q * 1.2 + cell.position.r * 0.8);
        final bob = sin(_lifeTime * 2.2 + cell.position.q * 0.8 + cell.position.r * 0.45) * 2.0;
        yOffset += bob;
        squashX += breath * 0.03;
        squashY -= breath * 0.03;

        final earCycle = (_lifeTime * 0.75 + cell.position.q * 2.1 + cell.position.r * 1.5) % 4.5;
        if (earCycle < 0.4) {
          rotation = sin(earCycle / 0.4 * pi * 4) * 0.07;
        }
      }

      if (_cowImage != null) {
        final cowRadius = hexRadius * 0.88;
        _drawAsset(
          canvas,
          _cowImage!,
          center,
          cowRadius,
          yOffset - hexRadius * 0.08,
          scaleX: squashX,
          scaleY: squashY,
          rotation: rotation,
        );
        _drawBadge(
          canvas,
          Offset(center.x + hexRadius * 0.35 * squashX, center.y + yOffset + hexRadius * 0.32 * squashY),
          hexRadius * 0.76,
          herd!.size,
          AppColors.getPlayerPrimary(herd!.owner),
        );
      } else {
        _drawCowPieceWithShield(
          canvas,
          Vector2(center.x, center.y + yOffset),
          hexRadius,
          scaleX: squashX,
          scaleY: squashY,
          rotation: rotation,
        );
      }
    }
  }

  void _drawHexSprite(Canvas canvas, Path path, Vector2 center, double radius) {
    ui.Image? hexImg;
    if (cell.isObstacle) {
      hexImg = imageCache[AssetPaths.hexBlockedTrapped];
    } else if (isValidMove) {
      hexImg = imageCache[AssetPaths.hexValidMoveHighlight];
    } else if (territoryOwner == PlayerColor.blue) {
      hexImg = imageCache[AssetPaths.hexPlayer1Claimed];
    } else if (territoryOwner == PlayerColor.red) {
      hexImg = imageCache[AssetPaths.hexPlayer2Claimed];
    } else {
      hexImg = imageCache[AssetPaths.hexNeutralPasture];
    }

    if (hexImg != null) {
      final hexWidth = radius * sqrt(3);
      final scale = hexWidth / 512.0;
      final dstW = 560.0 * scale;
      final dstH = 600.0 * scale;
      final dstLeft = center.x - 280.0 * scale;
      final dstTop = center.y - 260.0 * scale;
      final dst = Rect.fromLTWH(dstLeft, dstTop, dstW, dstH);
      final src = Rect.fromLTWH(0, 0, hexImg.width.toDouble(), hexImg.height.toDouble());

      canvas.drawImageRect(hexImg, src, dst, Paint()..filterQuality = FilterQuality.medium);

      // Tint for multiplayer 3rd/4th players (yellow, purple)
      if (territoryOwner != null &&
          territoryOwner != PlayerColor.blue &&
          territoryOwner != PlayerColor.red &&
          !cell.isObstacle &&
          !isValidMove) {
        final tint = AppColors.getPlayerPrimary(territoryOwner!).withValues(alpha: 0.22);
        canvas.drawPath(path, Paint()..color = tint);
      }
    } else {
      _draw3DDepth(canvas, path, center, radius);
      _drawHexFill(canvas, path, center, radius);
      _drawHexBorder(canvas, path);
    }
  }

  void _drawValidMovePulse(Canvas canvas, Vector2 center, double radius) {
    final movePulse = (sin(_lifeTime * 5.0) + 1.0) / 2.0;
    final innerPath = _createHexPath(center, radius * 0.88);
    final pulsePaint = Paint()
      ..color = const Color(0xFF69F0AE).withValues(alpha: 0.10 + movePulse * 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, pulsePaint);
  }

  void _drawBadge(Canvas canvas, Offset center, double diameter, int count, Color teamColor) {
    final badgeImg = imageCache[AssetPaths.stackCounterBadge];
    final radius = diameter / 2;
    if (badgeImg != null) {
      final src = Rect.fromLTWH(0, 0, badgeImg.width.toDouble(), badgeImg.height.toDouble());
      final dst = Rect.fromCircle(center: center, radius: radius);
      canvas.drawImageRect(badgeImg, src, dst, Paint()..filterQuality = FilterQuality.medium);
    } else {
      _drawCowCountBadge(canvas, center, diameter, count, teamColor);
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          fontSize: diameter * 0.55,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFD54F),
          fontFamily: 'Bangers',
          shadows: const [
            Shadow(color: Colors.black87, offset: Offset(1.2, 1.2), blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - 1),
    );
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

    // 1. ALWAYS draw authentic pasture base so every tile matches the board design
    if (cell.isObstacle) {
      canvas.drawPath(path, Paint()..color = const Color(0xFF4E342E));
    } else if (texture != null) {
      _drawTexture(canvas, center, radius);
    } else {
      final grassShades = [
        const Color(0xFF689F38),
        const Color(0xFF7CB342),
        const Color(0xFF558B2F),
      ];
      canvas.drawPath(path, Paint()..color = grassShades[cell.position.q.abs() % 3]);
    }

    // 2. Thematic pasture glow / aura for special tile types
    if (cell.specialType == SpecialTileType.goldenPasture) {
      final goldenPulse = (sin(_lifeTime * 3.5) + 1.0) / 2.0;
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: 0.22 + goldenPulse * 0.14)
          ..blendMode = BlendMode.srcOver,
      );
    } else if (cell.specialType == SpecialTileType.hayBale) {
      canvas.drawCircle(
        Offset(center.x, center.y),
        radius * 0.72,
        Paint()
          ..color = const Color(0xFFFFE082).withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // 3. Draw clean cartoon special prop on the pasture
    if (cell.specialType != SpecialTileType.none && _specialImage != null) {
      _drawSpecialProp(canvas, _specialImage!, center, radius);
    }

    // 4. Territory ownership & herd tints
    if (territoryOwner != null && (herd == null || herd!.size == 0)) {
      final tint = AppColors.getPlayerPrimary(territoryOwner!).withValues(alpha: 0.15);
      canvas.drawPath(path, Paint()..color = tint);
    }

    if (herd != null && herd!.size > 0) {
      final isTurnHerd = turnOwner != null && herd!.owner == turnOwner;
      final tint = AppColors.getPlayerPrimary(herd!.owner)
          .withValues(alpha: isTurnHerd ? 0.42 : 0.3);
      canvas.drawPath(path, Paint()..color = tint);
    }

    canvas.restore();
  }

  void _drawSpecialProp(Canvas canvas, ui.Image image, Vector2 center, double radius) {
    final floatOffset = cell.specialType == SpecialTileType.goldenPasture
        ? sin(_lifeTime * 2.8) * 2.0
        : (cell.specialType == SpecialTileType.hayBale ? sin(_lifeTime * 2.2) * 1.2 : 0.0);

    final double propScale;
    if (cell.specialType == SpecialTileType.mud) {
      propScale = 1.45;
    } else if (cell.specialType == SpecialTileType.goldenPasture) {
      propScale = 1.25;
    } else {
      propScale = 1.20;
    }

    final propSize = radius * propScale;
    final dst = Rect.fromCenter(
      center: Offset(center.x, center.y + floatOffset),
      width: propSize,
      height: propSize,
    );
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
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

  void _drawHexBorder(Canvas canvas, Path path, {Color? color}) {
    final borderPaint = Paint()
      ..color = (color ?? const Color(0xFF3F642D)).withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, borderPaint);
  }

  void _drawSelectionGlow(Canvas canvas, Path path) {
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.5 + pulseValue * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 + pulseValue * 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, glowPaint);

    final innerGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 + pulseValue * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(path, innerGlow);
  }

  void _drawCowPieceWithShield(
    Canvas canvas,
    Vector2 center,
    double radius, {
    double scaleX = 1.0,
    double scaleY = 1.0,
    double rotation = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.x, center.y);
    if (rotation != 0.0) canvas.rotate(rotation);
    if (scaleX != 1.0 || scaleY != 1.0) canvas.scale(scaleX, scaleY);

    final herdSize = herd!.size;
    final primaryColor = AppColors.getPlayerPrimary(herd!.owner);
    final darkColor = AppColors.getPlayerDark(herd!.owner);
    final pieceRadius = radius * 0.55;

    // 1. 3D Hexagonal / Octagonal Pedestal Base
    final pedestalPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i;
      final point = Offset(
        pieceRadius * cos(angle),
        pieceRadius * sin(angle),
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
      final point = Offset(pieceRadius * cos(angle), pieceRadius * sin(angle));
      if (i == 0) {
        pedSidePath.moveTo(point.dx, point.dy);
      } else {
        pedSidePath.lineTo(point.dx, point.dy);
      }
    }
    for (var i = 5; i >= 0; i--) {
      final angle = (pi / 3) * i;
      final point = Offset(pieceRadius * cos(angle), pieceRadius * sin(angle) + pedDepth);
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
      Paint()..shader = faceGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: pieceRadius)),
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
      Offset(-cowPainter.width / 2, -cowPainter.height / 2 - 2),
    );

    // 3. Shield Badge with Stack Count (Bottom-Right / Center-Bottom)
    final shieldWidth = pieceRadius * 0.75;
    final shieldHeight = pieceRadius * 0.85;
    final shieldCenter = Offset(pieceRadius * 0.35, pieceRadius * 0.3);

    _drawShieldBadge(canvas, shieldCenter, shieldWidth, shieldHeight, herdSize, primaryColor);

    canvas.restore();
  }

  void _drawAsset(
    Canvas canvas,
    ui.Image image,
    Vector2 center,
    double radius,
    double yOffset, {
    double scaleX = 1.0,
    double scaleY = 1.0,
    double rotation = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.x, center.y + yOffset);
    if (rotation != 0.0) canvas.rotate(rotation);
    if (scaleX != 1.0 || scaleY != 1.0) canvas.scale(scaleX, scaleY);
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.medium);
    canvas.restore();
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

  void _drawCowCountBadge(Canvas canvas, Offset center, double diameter, int count, Color teamColor) {
    final radius = diameter / 2;
    canvas.drawCircle(center, radius + 2, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1B0000));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = teamColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          fontSize: diameter * 0.68,
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
