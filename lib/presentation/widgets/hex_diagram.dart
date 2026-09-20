import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../game/models/hex_position.dart';

/// One hex inside a [HexDiagram], described the way the board describes it:
/// an optional owner with a herd size, selection / valid-move state and an
/// optional special tile image.
class HexDiagramCell {
  final HexPosition position;
  final PlayerColor? owner;
  final int herdSize;
  final bool isSelected;
  final bool isValidMove;
  final String? specialAsset;

  const HexDiagramCell(
    this.position, {
    this.owner,
    this.herdSize = 0,
    this.isSelected = false,
    this.isValidMove = false,
    this.specialAsset,
  });

  /// A hex holding a herd of [herdSize] cows.
  const HexDiagramCell.herd(
    this.position,
    PlayerColor this.owner,
    this.herdSize, {
    this.isSelected = false,
    this.isValidMove = false,
  }) : specialAsset = null;
}

/// A straight-line arrow drawn between two hexes (movement range / attacks).
class HexDiagramArrow {
  final HexPosition from;
  final HexPosition to;
  final Color color;
  final bool dashed;

  const HexDiagramArrow(
    this.from,
    this.to, {
    this.color = const Color(0xFFFFD54F),
    this.dashed = false,
  });
}

enum HexBadgeSlot { topRight, topLeft, bottom, centerTop }

/// A small label pinned to a hex ("1 STAYS", "TAP HERE", a step number).
class HexDiagramBadge {
  final HexPosition position;
  final String text;
  final Color color;
  final HexBadgeSlot slot;

  const HexDiagramBadge(
    this.position,
    this.text, {
    this.color = const Color(0xFFFFD54F),
    this.slot = HexBadgeSlot.topRight,
  });
}
/// Renders a mini pasture exactly like the real board: flipped tile texture,
/// grass shading by column, player-tinted cow pieces with cow-count badges,
/// selection glow, dashed valid-move outlines and special tile images.
class HexDiagram extends StatelessWidget {
  static const String tileTexture = 'assets/images/Tile Image/Tile Texture.jpg';

  final List<HexDiagramCell> cells;
  final List<HexDiagramArrow> arrows;
  final List<HexDiagramBadge> badges;
  final double radius;
  final String? caption;

  const HexDiagram({
    super.key,
    required this.cells,
    this.arrows = const [],
    this.badges = const [],
    this.radius = 30,
    this.caption,
  });

  /// Same pointy-top layout the game uses (`HexBoardComponent.hexToPixel`).
  static Offset hexToOffset(HexPosition hex, double radius) {
    final x = radius * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = radius * (3.0 / 2 * hex.r);
    return Offset(x, y);
  }

  /// Cow artwork per player, matching `HexCellComponent._cowAssetPath`.
  static String cowAssetFor(PlayerColor color) {
    switch (color) {
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

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();

    const padding = 14.0;
    final centers =
        cells.map((cell) => hexToOffset(cell.position, radius)).toList();

    final minX = centers.map((o) => o.dx).reduce(min) - radius;
    final maxX = centers.map((o) => o.dx).reduce(max) + radius;
    final minY = centers.map((o) => o.dy).reduce(min) - radius;
    final maxY = centers.map((o) => o.dy).reduce(max) + radius;
    final depth = radius * 0.24;
    final width = (maxX - minX) + padding * 2;
    final height = (maxY - minY) + padding * 2 + depth;

    Offset local(HexPosition hex) {
      final o = hexToOffset(hex, radius);
      return Offset(o.dx - minX + padding, o.dy - minY + padding);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final arrow in arrows)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ArrowPainter(
                      from: local(arrow.from),
                      to: local(arrow.to),
                      color: arrow.color,
                      radius: radius,
                      dashed: arrow.dashed,
                    ),
                  ),
                ),
              for (final cell in cells)
                Positioned(
                  left: local(cell.position).dx - radius,
                  top: local(cell.position).dy - radius,
                  child: _GuideHex(
                    radius: radius,
                    position: cell.position,
                    owner: cell.owner,
                    herdSize: cell.herdSize,
                    specialAsset: cell.specialAsset,
                    isSelected: cell.isSelected,
                    isValidMove: cell.isValidMove,
                  ),
                ),
              for (final badge in badges)
                Positioned(
                  left: _badgeLeft(local(badge.position), radius, badge.slot),
                  top: _badgeTop(local(badge.position), radius, badge.slot),
                  child: _BadgeChip(text: badge.text, color: badge.color),
                ),
            ],
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width + 40),
            child: Text(
              caption!,
              textAlign: TextAlign.center,
              style: GoogleFonts.bangers(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static double _badgeLeft(Offset center, double radius, HexBadgeSlot slot) {
    switch (slot) {
      case HexBadgeSlot.topRight:
        return center.dx + radius * 0.18;
      case HexBadgeSlot.topLeft:
        return center.dx - radius * 1.12;
      case HexBadgeSlot.bottom:
      case HexBadgeSlot.centerTop:
        return center.dx - radius * 0.62;
    }
  }

  static double _badgeTop(Offset center, double radius, HexBadgeSlot slot) {
    switch (slot) {
      case HexBadgeSlot.topRight:
      case HexBadgeSlot.topLeft:
        return center.dy - radius * 0.92;
      case HexBadgeSlot.bottom:
        return center.dy + radius * 0.5;
      case HexBadgeSlot.centerTop:
        return center.dy - radius * 0.28;
    }
  }
}
/// A single board hex: clipped tile texture, grass shading, cow piece with a
/// count badge, optional special tile art, selection glow and move dashes.
class _GuideHex extends StatelessWidget {
  final double radius;
  final HexPosition position;
  final PlayerColor? owner;
  final int herdSize;
  final String? specialAsset;
  final bool isSelected;
  final bool isValidMove;

  const _GuideHex({
    required this.radius,
    required this.position,
    this.owner,
    this.herdSize = 0,
    this.specialAsset,
    this.isSelected = false,
    this.isValidMove = false,
  });

  /// Same mirroring trick the board uses so repeated textures do not tile
  /// identically (`HexCellComponent.getFlipMode`).
  static int getFlipMode(int q, int r) =>
      (q * 7 + r * 13 + q * r * 3).abs() % 4;

  @override
  Widget build(BuildContext context) {
    final side = radius * 2;
    final depth = radius * 0.24;
    final flip = getFlipMode(position.q, position.r);
    final shade = [
      AppColors.grassMid,
      AppColors.grassLight,
      AppColors.grassDark,
    ][position.q.abs() % 3];

    return SizedBox(
      width: side,
      height: side + depth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: depth,
            child: CustomPaint(
              size: Size(side, side),
              painter: const _HexDepthPainter(),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: ClipPath(
              clipper: _HexClipper(),
              child: SizedBox(
                width: side,
                height: side,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        flip == 1 || flip == 3 ? -1 : 1,
                        flip == 2 || flip == 3 ? -1 : 1,
                        1,
                      ),
                      child: Image.asset(
                        HexDiagram.tileTexture,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    ColoredBox(color: shade.withValues(alpha: 0.55)),
                    if (owner != null)
                      ColoredBox(
                        color: AppColors.getPlayerPrimary(owner!)
                            .withValues(alpha: 0.38),
                      ),
                    if (specialAsset != null)
                      Image.asset(
                        specialAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    if (owner != null) ...[
                      Center(
                        child: Image.asset(
                          HexDiagram.cowAssetFor(owner!),
                          width: radius * 1.45,
                          height: radius * 1.45,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Text(
                            '🐮',
                            style: TextStyle(fontSize: radius * 0.9),
                          ),
                        ),
                      ),
                      if (herdSize > 0)
                        Positioned(
                          right: radius * 0.1,
                          bottom: radius * 0.12,
                          child: _CowCountBadge(
                            count: herdSize,
                            color: AppColors.getPlayerPrimary(owner!),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: CustomPaint(
              size: Size(side, side),
              painter: _HexOutlinePainter(
                drawBorder: specialAsset == null,
                isSelected: isSelected,
                isValidMove: isValidMove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CowCountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CowCountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xE61B0000),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.bangers(
          fontSize: 12,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String text;
  final Color color;

  const _BadgeChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xE61B0000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        text,
        style: GoogleFonts.bangers(
          fontSize: 10,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}


/// Pointy-top hex outline centred in a `2 * radius` square.
class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Green side band that gives the tile its 3D thickness.
class _HexDepthPainter extends CustomPainter {
  const _HexDepthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final depth = radius * 0.24;
    final side = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final p = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final down = p.translate(0, depth);
      if (i == 0) {
        side.moveTo(p.dx, p.dy);
      } else {
        side.lineTo(p.dx, p.dy);
      }
      side.lineTo(down.dx, down.dy);
    }
    side.close();

    canvas.drawPath(
      side,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4E7A25), Color(0xFF2D5016)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(0, center.dy - radius, size.width, size.height),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tile border, selection glow and dashed "you can move here" outline.
class _HexOutlinePainter extends CustomPainter {
  final bool drawBorder;
  final bool isSelected;
  final bool isValidMove;

  const _HexOutlinePainter({
    this.drawBorder = true,
    this.isSelected = false,
    this.isValidMove = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _HexClipper().getClip(size);

    if (drawBorder) {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.tileBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (isSelected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.selectionGlow.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    if (isValidMove) {
      final paint = Paint()
        ..color = AppColors.validMoveOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      for (final metric in path.computeMetrics()) {
        var distance = 0.0;
        while (distance < metric.length) {
          final next = min(distance + 7, metric.length);
          canvas.drawPath(metric.extractPath(distance, next), paint);
          distance = next + 5;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HexOutlinePainter oldDelegate) =>
      drawBorder != oldDelegate.drawBorder ||
      isSelected != oldDelegate.isSelected ||
      isValidMove != oldDelegate.isValidMove;
}

/// Straight-line arrow between two hex centres, trimmed to the hex edges.
class _ArrowPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;
  final double radius;
  final bool dashed;

  const _ArrowPainter({
    required this.from,
    required this.to,
    required this.color,
    required this.radius,
    this.dashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final delta = to - from;
    final length = delta.distance;
    if (length < 1) return;
    final unit = Offset(delta.dx / length, delta.dy / length);
    final start = from + unit * radius * 0.72;
    final end = to - unit * radius * 0.86;
    if ((end - start).distance < 1) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (dashed) {
      var distance = 0.0;
      const dash = 6.0;
      const gap = 4.0;
      final total = (end - start).distance;
      while (distance < total) {
        final next = min(distance + dash, total);
        canvas.drawLine(start + unit * distance, start + unit * next, paint);
        distance = next + gap;
      }
    } else {
      canvas.drawLine(start, end, paint);
    }

    final head = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - unit.dx * 11 - unit.dy * 7,
        end.dy - unit.dy * 11 + unit.dx * 7,
      )
      ..lineTo(
        end.dx - unit.dx * 11 + unit.dy * 7,
        end.dy - unit.dy * 11 - unit.dx * 7,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      from != oldDelegate.from ||
      to != oldDelegate.to ||
      color != oldDelegate.color ||
      dashed != oldDelegate.dashed;
}