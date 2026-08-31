import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import '../../game/models/hex_position.dart';
import '../../game/models/game_board.dart';
import 'hex_cell_component.dart';

class HexBoardComponent extends PositionComponent {
  final GameBoard board;
  final Map<HexPosition, HexCellComponent> _cells = {};
  HexPosition? _selectedPosition;
  List<HexPosition> _validMoves = [];
  double _pulseTime = 0;
  ui.Image? _texture;
  final void Function(HexPosition)? onCellTap;

  HexBoardComponent({
    required this.board,
    required super.position,
    required super.size,
    this.onCellTap,
  });

  Map<HexPosition, HexCellComponent> get cells => _cells;

  @override
  Future<void> onLoad() async {
    try {
      final data = await rootBundle.load('assets/images/Tile Image/Tile Texture.png');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _texture = frame.image;
    } catch (_) {}

    final hexSize = size.x / 14;

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
        onTapCallback: () => onCellTap?.call(pos),
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
    }
  }

  void updateSelection(HexPosition? selected, List<HexPosition> validMoves) {
    _selectedPosition = selected;
    _validMoves = validMoves;
  }

  void updateBoard(GameBoard newBoard) {
    for (final entry in _cells.entries) {
      final pos = entry.key;
      final herd = newBoard.getHerdAt(pos);
      entry.value.herd = herd;
    }
  }

  Vector2 hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Vector2(x, y);
  }
}
