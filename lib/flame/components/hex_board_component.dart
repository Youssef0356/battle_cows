import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import '../../assets/asset_paths.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/game_board.dart';
import '../../game/models/hex_cell.dart';
import '../../game/models/player_color.dart';
import 'hex_cell_component.dart';

class HexBoardComponent extends PositionComponent {
  final GameBoard board;
  final Map<HexPosition, HexCellComponent> _cells = {};
  HexPosition? _selectedPosition;
  List<HexPosition> _validMoves = [];
  double _pulseTime = 0;
  PlayerColor? _turnOwner;
  ui.Image? _texture;

  /// Player color whose herds render with [skinOverride] (the local
  /// player's equipped shop skin). Null disables skin overrides.
  PlayerColor? skinOwnerColor;
  String? skinOverride;

  /// Tile texture asset for the equipped board skin. Null uses the default.
  final String? textureAsset;

  HexBoardComponent({
    required this.board,
    required super.position,
    required super.size,
    this.skinOwnerColor,
    this.skinOverride,
    this.textureAsset,
  });

  Map<HexPosition, HexCellComponent> get cells => _cells;

  static Future<ui.Image?> _loadTexture(String? path) async {
    final asset = path ?? AssetPaths.boardTextureWood;
    try {
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  /// Swaps the board tile texture for every cell (equipped board skin).
  Future<void> setTextureAsset(String? path) async {
    _texture = await _loadTexture(path);
    for (final cell in _cells.values) {
      cell.applyTexture(_texture);
    }
  }

  /// Swaps the equipped skin override for every cell.
  void setSkinOverride(PlayerColor? owner, String? skin) {
    skinOwnerColor = owner;
    skinOverride = skin;
    for (final cell in _cells.values) {
      cell.applySkin(owner, skin);
    }
  }

  @override
  Future<void> onLoad() async {
    await HexCellComponent.precacheAllAssets();
    _texture = await _loadTexture(textureAsset);

    final hexSize = size.x / 15;

    for (final entry in board.cells.entries) {
      final pos = entry.key;
      final cell = entry.value;
      final herd = board.getHerdAt(pos);

      final pixelPos = hexToPixel(pos, hexSize);
      final cellComponent = HexCellComponent(
        cell: cell,
        herd: herd,
        position: pixelPos,
        size: Vector2.all(hexSize * 2),
        flipMode: HexCellComponent.getFlipMode(pos.q, pos.r),
        texture: _texture,
        territoryOwner: herd?.owner,
        skinOverride: skinOverride,
        skinOwnerColor: skinOwnerColor,
      );

      _cells[pos] = cellComponent;
      add(cellComponent);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
    final pulseValue = (sin(_pulseTime * 3) + 1) / 2;

    for (final entry in _cells.entries) {
      final isSelected = _selectedPosition == entry.key;
      entry.value.isSelected = isSelected;
      entry.value.isValidMove = _validMoves.contains(entry.key);
      if (isSelected) {
        entry.value.pulseValue = pulseValue;
      } else {
        entry.value.pulseValue = 0;
      }

      final herd = entry.value.herd;
      if (herd != null && herd.size > 1) {
        final trapped = board.getReachablePositions(entry.key, max(herd.size, 5)).isEmpty;
        entry.value.isTrapped = trapped;
      } else {
        entry.value.isTrapped = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw glowing curved trajectory arrows for valid moves
    if (_selectedPosition != null && _validMoves.isNotEmpty) {
      final fromCell = _cells[_selectedPosition];
      if (fromCell != null) {
        final hexRadius = size.x / 30;
        for (final targetPos in _validMoves) {
          final toCell = _cells[targetPos];
          if (toCell != null) {
            _drawTrajectoryArrow(canvas, fromCell.position, toCell.position, hexRadius);
          }
        }
      }
    }
  }

  void _drawTrajectoryArrow(Canvas canvas, Vector2 from, Vector2 to, double radius) {
    final dist = from.distanceTo(to);
    if (dist < 1.0) return;

    final midX = (from.x + to.x) / 2;
    final midY = (from.y + to.y) / 2;
    final curveHeight = min(dist * 0.28, 48.0);
    final ctrl = Offset(midX, midY - curveHeight);

    final arrowPath = Path()
      ..moveTo(from.x, from.y)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, to.x, to.y);

    // Outer neon glow
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF69F0AE)],
      ).createShader(Rect.fromPoints(Offset(from.x, from.y), Offset(to.x, to.y)))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(arrowPath, glowPaint);

    // Inner bright beam
    final beamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(arrowPath, beamPaint);

    // Arrowhead at destination
    final dx = to.x - ctrl.dx;
    final dy = to.y - ctrl.dy;
    final angle = atan2(dy, dx);

    final arrowHead = Path();
    final arrowSize = radius * 0.55;
    arrowHead.moveTo(to.x, to.y);
    arrowHead.lineTo(
      to.x - arrowSize * cos(angle - pi / 6),
      to.y - arrowSize * sin(angle - pi / 6),
    );
    arrowHead.lineTo(
      to.x - arrowSize * 0.6 * cos(angle),
      to.y - arrowSize * 0.6 * sin(angle),
    );
    arrowHead.lineTo(
      to.x - arrowSize * cos(angle + pi / 6),
      to.y - arrowSize * sin(angle + pi / 6),
    );
    arrowHead.close();

    final headPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowHead, headPaint);

    final headStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(arrowHead, headStroke);
  }

  /// Sets the player whose turn it is; their herds get a colored
  /// border + stronger tint as the on-board turn indicator.
  set turnOwner(PlayerColor? owner) {
    _turnOwner = owner;
    for (final cell in _cells.values) {
      cell.turnOwner = owner;
    }
  }

  void updateSelection(HexPosition? selected, List<HexPosition> validMoves) {
    _selectedPosition = selected;
    _validMoves = validMoves;
  }

  void triggerCellBounce(HexPosition pos) {
    _cells[pos]?.triggerBounce();
  }

  void updateBoard(GameBoard newBoard) {
    for (final entry in _cells.entries) {
      final pos = entry.key;
      final newCell = newBoard.cells[pos];
      if (newCell != null && newCell.specialType != entry.value.cell.specialType) {
        entry.value.cell = newCell;
        entry.value.updateSpecialImage();
      }
      final herd = newBoard.getHerdAt(pos);
      entry.value.setHerd(herd);
      entry.value.territoryOwner = herd?.owner;
    }
  }

  void addCell(HexPosition pos, {bool isSelected = false, bool isPreview = false}) {
    if (_cells.containsKey(pos)) return;
    final hexSize = size.x / 15;
    final cell = board.cells[pos] ?? HexCell(position: pos);
    final pixelPos = hexToPixel(pos, hexSize);
    final cellComponent = HexCellComponent(
      cell: cell,
      position: pixelPos,
      size: Vector2.all(hexSize * 2),
      flipMode: HexCellComponent.getFlipMode(pos.q, pos.r),
      texture: _texture,
      isValidMove: isPreview,
      skinOverride: skinOverride,
      skinOwnerColor: skinOwnerColor,
    );
    cellComponent.turnOwner = _turnOwner;
    _cells[pos] = cellComponent;
    add(cellComponent);
  }

  void removeCell(HexPosition pos) {
    final cell = _cells.remove(pos);
    if (cell != null) {
      cell.removeFromParent();
    }
  }

  Vector2 hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Vector2(x, y);
  }
}
