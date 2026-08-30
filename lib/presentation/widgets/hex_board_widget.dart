import 'package:flutter/material.dart';
import 'dart:math';
import '../../game/models/hex_position.dart';
import '../../game/models/game_board.dart';
import 'hex_cell_widget.dart';

class HexBoardWidget extends StatelessWidget {
  final GameBoard board;
  final HexPosition? selectedPosition;
  final List<HexPosition> validMoves;
  final Function(HexPosition) onCellTap;
  final dynamic currentPlayerColor;

  const HexBoardWidget({
    super.key,
    required this.board,
    this.selectedPosition,
    this.validMoves = const [],
    required this.onCellTap,
    this.currentPlayerColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final hexSize = size / (board.size * 2 + 3);

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: _buildHexGrid(hexSize),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildHexGrid(double hexSize) {
    final widgets = <Widget>[];

    for (final entry in board.cells.entries) {
      final pos = entry.key;
      final cell = entry.value;
      final herd = board.getHerdAt(pos);

      final pixelPos = _hexToPixel(pos, hexSize);
      final isSelected = selectedPosition == pos;
      final isValidMove = validMoves.contains(pos);

      widgets.add(
        Positioned(
          left: pixelPos.dx - hexSize,
          top: pixelPos.dy - hexSize,
          child: HexCellWidget(
            size: hexSize * 2,
            cell: cell,
            herd: herd,
            isSelected: isSelected,
            isValidMove: isValidMove,
            onTap: () => onCellTap(pos),
          ),
        ),
      );
    }

    return widgets;
  }

  Offset _hexToPixel(HexPosition hex, double size) {
    final x = size * (sqrt(3) * hex.q + sqrt(3) / 2 * hex.r);
    final y = size * (3.0 / 2 * hex.r);
    return Offset(x + size * 10, y + size * 10);
  }
}
